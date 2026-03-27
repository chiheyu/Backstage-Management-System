<script setup>
import { computed, onMounted, reactive, ref, watch } from 'vue'
import { RouterLink, useRouter } from 'vue-router'
import EmptyState from '@/components/EmptyState.vue'
import StatusBadge from '@/components/StatusBadge.vue'
import { apiBaseUrl, commonApi, userApi } from '@/lib/api'
import { formatMoney, getRoleState, resolveImage, safeRows, shortText } from '@/lib/domain'
import { addCartItem, formatAddress, getDefaultAddress, loadAddressList } from '@/lib/localData'
import { pushNotice } from '@/lib/notice'
import { session } from '@/lib/session'

const props = defineProps({
  id: {
    type: String,
    required: true
  }
})

const router = useRouter()

const loading = ref(true)
const submitting = ref(false)
const accessory = ref(null)
const relatedList = ref([])
const addressList = ref(loadAddressList())
const selectedAddressId = ref('')

const orderForm = reactive({
  quantity: 1,
  receiverName: '',
  receiverPhone: '',
  receiverAddress: '',
  orderRemark: ''
})

const roleState = computed(() => getRoleState(session.roleType))
const isMerchantMode = computed(() => roleState.value.isMerchant)
const canOrder = computed(() => session.token && roleState.value.isUser && !roleState.value.isMerchant)
const resolvedImage = computed(() => resolveImage(accessory.value?.coverImage, apiBaseUrl))

function syncAddressOptions() {
  addressList.value = loadAddressList()
}

function applyAddress(address) {
  if (!address) {
    return
  }
  selectedAddressId.value = address.id
  orderForm.receiverName = address.name || ''
  orderForm.receiverPhone = address.phone || ''
  orderForm.receiverAddress = formatAddress(address)
}

function applyDefaultAddress() {
  const defaultAddress = getDefaultAddress()
  if (defaultAddress) {
    applyAddress(defaultAddress)
  }
}

async function loadDetail() {
  loading.value = true
  try {
    const detail = await commonApi.getAccessory(props.id)
    accessory.value = detail

    orderForm.receiverName = session.appUser?.nickName || ''
    orderForm.receiverPhone = session.appUser?.phone || ''
    applyDefaultAddress()

    const relatedPayload = await commonApi.listAccessories({
      categoryName: detail.categoryName,
      status: '0',
      pageNum: 1,
      pageSize: 4,
      params: session.appUser?.appUserId
        ? { appUserId: session.appUser.appUserId }
        : undefined
    })
    relatedList.value = safeRows(relatedPayload).filter(item => String(item.accessoryId) !== String(props.id))
  } catch (error) {
    accessory.value = null
    pushNotice(error.message || '商品详情加载失败', 'danger')
  } finally {
    loading.value = false
  }
}

async function toggleCollection() {
  if (!session.token) {
    router.push({ name: 'auth' })
    return
  }
  if (!roleState.value.isUser || isMerchantMode.value) {
    pushNotice('当前账号不能使用收藏功能', 'danger')
    return
  }
  if (!accessory.value) {
    return
  }

  submitting.value = true
  try {
    if (accessory.value.collected) {
      await userApi.cancelAccessoryCollection(accessory.value.accessoryId)
      accessory.value = { ...accessory.value, collected: false }
      pushNotice('已取消收藏', 'success')
    } else {
      await userApi.collectAccessory(accessory.value.accessoryId)
      accessory.value = { ...accessory.value, collected: true }
      pushNotice('收藏成功', 'success')
    }
  } catch (error) {
    pushNotice(error.message || '收藏操作失败', 'danger')
  } finally {
    submitting.value = false
  }
}

function addToCart() {
  if (!accessory.value) {
    return
  }
  if (isMerchantMode.value) {
    pushNotice('当前账号不能加入购物车', 'danger')
    return
  }
  if (Number(accessory.value.stock || 0) <= 0) {
    pushNotice('当前商品库存不足', 'danger')
    return
  }

  addCartItem({
    id: accessory.value.accessoryId,
    accessoryId: accessory.value.accessoryId,
    name: accessory.value.accessoryName,
    spec: accessory.value.categoryName,
    desc: accessory.value.accessoryDesc,
    image: resolveImage(accessory.value.coverImage, apiBaseUrl),
    price: accessory.value.price,
    stock: accessory.value.stock,
    count: 1
  })
  pushNotice('已加入购物车', 'success')
}

function validateOrder() {
  if (!accessory.value) {
    return false
  }
  if (!canOrder.value) {
    pushNotice('请使用普通用户或待审核商家账号下单', 'danger')
    return false
  }
  if (!orderForm.receiverName.trim()) {
    pushNotice('请填写收货人', 'danger')
    return false
  }
  if (!/^1\d{10}$/.test(orderForm.receiverPhone)) {
    pushNotice('请输入正确的联系电话', 'danger')
    return false
  }
  if (!orderForm.receiverAddress.trim()) {
    pushNotice('请填写收货地址', 'danger')
    return false
  }
  if (Number(orderForm.quantity) <= 0) {
    pushNotice('购买数量必须大于 0', 'danger')
    return false
  }
  if (Number(orderForm.quantity) > Number(accessory.value.stock || 0)) {
    pushNotice('购买数量不能超过当前库存', 'danger')
    return false
  }
  return true
}

async function submitOrder() {
  if (!validateOrder()) {
    return
  }

  submitting.value = true
  try {
    const order = await userApi.createAccessoryOrder({
      accessoryId: accessory.value.accessoryId,
      quantity: Number(orderForm.quantity),
      receiverName: orderForm.receiverName,
      receiverPhone: orderForm.receiverPhone,
      receiverAddress: orderForm.receiverAddress,
      orderRemark: orderForm.orderRemark
    })
    pushNotice(`下单成功，订单号 ${order.orderNo}`, 'success', 4200)
    router.push({ name: 'orders' })
  } catch (error) {
    pushNotice(error.message || '配件下单失败', 'danger')
  } finally {
    submitting.value = false
  }
}

watch(
  () => props.id,
  () => {
    syncAddressOptions()
    loadDetail()
  }
)

onMounted(() => {
  syncAddressOptions()
  loadDetail()
})
</script>

<template>
  <section class="page-shell accessory-page">
    <section v-if="loading" class="surface-card section-card accessory-loading">
      <h1>正在加载商品详情...</h1>
      <p>正在同步商品信息、库存状态和推荐内容。</p>
    </section>

    <EmptyState
      v-else-if="!accessory"
      title="商品不存在"
      description="当前配件可能已下架，或传入的商品编号无效。"
      action-label="返回商城"
      @action="router.push({ name: 'mall' })"
    />

    <template v-else>
      <section class="glass-card accessory-hero">
        <div class="accessory-media">
          <img :src="resolvedImage" :alt="accessory.accessoryName" />
        </div>

        <div class="surface-card accessory-main">
          <div class="between-row accessory-main__top">
            <span class="eyebrow">{{ accessory.categoryName || '通用配件' }}</span>
            <StatusBadge
              :label="isMerchantMode ? '只读浏览' : accessory.collected ? '已收藏' : '可购买'"
              :tone="isMerchantMode ? 'muted' : accessory.collected ? 'warm' : 'brand'"
            />
          </div>

          <h1>{{ accessory.accessoryName }}</h1>
          <p>{{ accessory.accessoryDesc || '适用于常见电子产品维修、更换和保养场景。' }}</p>

          <div class="accessory-price">
            <strong>￥{{ formatMoney(accessory.price) }}</strong>
            <span>库存 {{ accessory.stock || 0 }} / 销量 {{ accessory.salesCount || 0 }}</span>
          </div>

          <div class="accessory-points">
            <article>
              <strong>{{ isMerchantMode ? '当前模式' : '库存透明' }}</strong>
              <span>{{ isMerchantMode ? '商家网页端当前只接入商品只读浏览能力。' : '下单前即可查看当前库存和销量。' }}</span>
            </article>
            <article>
              <strong>{{ isMerchantMode ? '接口适配' : '收藏便捷' }}</strong>
              <span>{{ isMerchantMode ? '后端未开放商品管理接口，已自动关闭编辑和上传操作。' : '常用配件可随时加入或取消收藏。' }}</span>
            </article>
            <article>
              <strong>{{ isMerchantMode ? '售后衔接' : '售后衔接' }}</strong>
              <span>{{ isMerchantMode ? '商家如需处理售后，请前往售后工单和回执页面。' : '购买后如需维修，可继续提交相关售后申请。' }}</span>
            </article>
          </div>

          <div class="action-row">
            <template v-if="!isMerchantMode">
              <button class="btn btn--ghost" :disabled="submitting" @click="toggleCollection">
                {{ accessory.collected ? '取消收藏' : '加入收藏' }}
              </button>
              <button class="btn btn--primary" @click="addToCart">加入购物车</button>
              <RouterLink class="btn btn--secondary" :to="{ name: 'after-sales-apply' }">
                配件相关售后
              </RouterLink>
            </template>
            <template v-else>
              <RouterLink class="btn btn--ghost" :to="{ name: 'after-sales-orders', query: { mode: 'pending' } }">售后工单</RouterLink>
              <RouterLink class="btn btn--primary" :to="{ name: 'merchant-settings' }">店铺设置</RouterLink>
            </template>
          </div>
        </div>
      </section>

      <section class="accessory-grid">
        <section class="surface-card section-card">
          <template v-if="isMerchantMode">
            <div class="section-head">
              <div>
                <span class="eyebrow">能力说明</span>
                <h2>商家网页端当前为只读商品页</h2>
                <p>当前后端没有开放商家商品查询/编辑接口，因此网页端只保留详情浏览，不再请求商品管理相关地址。</p>
              </div>
            </div>

            <div class="related-list">
              <article class="related-card">
                <div>
                  <strong>已保留</strong>
                  <p>公共配件详情浏览、库存查看、商品说明查看。</p>
                </div>
              </article>
              <article class="related-card">
                <div>
                  <strong>已关闭</strong>
                  <p>商品编辑、图片上传、上架下架、商家商品管理列表。</p>
                </div>
              </article>
              <article class="related-card">
                <div>
                  <strong>建议入口</strong>
                  <p>如需处理商家业务，请使用售后工单、售后回执和店铺设置页面。</p>
                </div>
              </article>
            </div>
          </template>

          <template v-else>
            <div class="section-head">
              <div>
                <span class="eyebrow">在线下单</span>
                <h2>立即下单</h2>
                <p v-if="canOrder">填写收货信息后即可直接提交订单，也可先加入购物车。</p>
                <p v-else-if="!session.token">登录后可下单，也可先加入购物车。</p>
                <p v-else>当前账号为商家，只可浏览商品，不可直接下单。</p>
              </div>
            </div>

            <form class="order-form" @submit.prevent="submitOrder">
              <div class="field-row">
                <label>
                  <span>购买数量</span>
                  <input v-model.number="orderForm.quantity" class="field" type="number" min="1" />
                </label>
                <label>
                  <span>收货人</span>
                  <input v-model.trim="orderForm.receiverName" class="field" placeholder="填写收货姓名" />
                </label>
              </div>

              <div class="field-row">
                <label>
                  <span>联系电话</span>
                  <input v-model.trim="orderForm.receiverPhone" class="field" placeholder="收货手机号" />
                </label>
                <label>
                  <span>已保存地址</span>
                  <select class="field" :value="selectedAddressId" @change="applyAddress(addressList.find(item => item.id === $event.target.value))">
                    <option value="">请选择地址</option>
                    <option v-for="item in addressList" :key="item.id" :value="item.id">
                      {{ item.name }} / {{ item.phone }} / {{ item.region }} {{ item.detail }}
                    </option>
                  </select>
                </label>
              </div>

              <label>
                <span>收货地址</span>
                <div class="field-row">
                  <input v-model.trim="orderForm.receiverAddress" class="field" placeholder="详细到门牌号" />
                  <RouterLink class="btn btn--ghost btn--small" :to="{ name: 'addresses' }">管理地址</RouterLink>
                </div>
              </label>

              <label>
                <span>订单备注</span>
                <textarea
                  v-model.trim="orderForm.orderRemark"
                  class="textarea"
                  placeholder="可填写颜色、型号、到货提醒等备注"
                ></textarea>
              </label>

              <div class="surface-card order-summary">
                <div>
                  <strong>预计总额</strong>
                  <span>￥{{ formatMoney(Number(accessory.price || 0) * Number(orderForm.quantity || 0)) }}</span>
                </div>
                <button
                  v-if="canOrder"
                  class="btn btn--primary"
                  :disabled="submitting || Number(accessory.stock || 0) <= 0"
                >
                  {{ submitting ? '提交中...' : Number(accessory.stock || 0) <= 0 ? '库存不足' : '提交订单' }}
                </button>
                <RouterLink v-else class="btn btn--primary" :to="{ name: session.token ? 'profile' : 'auth' }">
                  {{ session.token ? '查看账号权限' : '先去登录' }}
                </RouterLink>
              </div>
            </form>
          </template>
        </section>

        <section class="surface-card section-card">
          <div class="section-head">
            <div>
              <span class="eyebrow">{{ isMerchantMode ? '只读提示' : '同类推荐' }}</span>
              <h2>{{ isMerchantMode ? '商家端说明' : '同类推荐' }}</h2>
              <p v-if="isMerchantMode">当前商品详情页不会再发起商家商品管理请求，因此不会触发右上角失败弹窗。</p>
              <p v-else>继续浏览同类配件，方便一次完成选购。</p>
            </div>
          </div>

          <div v-if="!isMerchantMode && relatedList.length" class="related-list">
            <RouterLink
              v-for="item in relatedList"
              :key="item.accessoryId"
              class="related-card"
              :to="{ name: 'accessory-detail', params: { id: item.accessoryId } }"
            >
              <img :src="resolveImage(item.coverImage, apiBaseUrl)" :alt="item.accessoryName" />
              <div>
                <strong>{{ item.accessoryName }}</strong>
                <p>{{ shortText(item.accessoryDesc, 38) }}</p>
                <span>￥{{ formatMoney(item.price) }}</span>
              </div>
            </RouterLink>
          </div>
          <div v-else-if="isMerchantMode" class="related-list">
            <article class="related-card">
              <div>
                <strong>售后工单</strong>
                <p>进入售后工单页处理接单、维修中和已完成的工单。</p>
              </div>
            </article>
            <article class="related-card">
              <div>
                <strong>售后回执</strong>
                <p>进入回执页填写检测结果和完工说明，推动工单流转。</p>
              </div>
            </article>
          </div>
          <EmptyState
            v-else
            :title="isMerchantMode ? '暂无更多提示' : '暂无推荐'"
            :description="isMerchantMode ? '当前商品页已调整为只读浏览，无需额外处理。' : '同分类下暂时没有更多可展示的配件。'"
          />
        </section>
      </section>
    </template>
  </section>
</template>

<style scoped>
.accessory-page {
  display: grid;
  gap: 24px;
}

.accessory-loading {
  text-align: center;
}

.accessory-hero {
  display: grid;
  grid-template-columns: minmax(0, 1fr) minmax(360px, 480px);
  gap: 24px;
  padding: 28px;
}

.accessory-media {
  min-height: 420px;
  border-radius: 28px;
  overflow: hidden;
  background: linear-gradient(135deg, rgba(14, 116, 144, 0.16), rgba(245, 158, 11, 0.2));
}

.accessory-media img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.accessory-main {
  padding: 24px;
}

.accessory-main__top {
  margin-bottom: 16px;
}

.accessory-main h1 {
  margin: 0 0 12px;
  font-size: clamp(30px, 4vw, 48px);
  line-height: 1.06;
}

.accessory-price {
  display: grid;
  gap: 8px;
  margin: 22px 0;
}

.accessory-price strong {
  font-size: 42px;
  color: var(--primary-deep);
}

.accessory-price span {
  color: var(--muted);
}

.accessory-points {
  display: grid;
  gap: 12px;
  margin-bottom: 22px;
}

.accessory-points article {
  padding: 14px 16px;
  border-radius: 20px;
  background: rgba(255, 255, 255, 0.68);
  border: 1px solid rgba(17, 61, 77, 0.08);
}

.accessory-points strong,
.related-card strong,
.order-summary strong {
  display: block;
  margin-bottom: 6px;
}

.accessory-grid {
  display: grid;
  grid-template-columns: minmax(0, 1.1fr) minmax(320px, 0.8fr);
  gap: 24px;
}

.order-form {
  display: grid;
  gap: 16px;
}

.order-form label {
  display: grid;
  gap: 8px;
  min-width: 0;
}

.order-form span {
  font-size: 14px;
  font-weight: 700;
  color: var(--primary-deep);
}

.order-summary {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 18px;
  padding: 18px 20px;
  border-radius: 24px;
}

.order-summary span {
  color: var(--accent);
  font-size: 26px;
  font-weight: 800;
}

.related-list {
  display: grid;
  gap: 14px;
}

.related-card {
  display: grid;
  grid-template-columns: 108px minmax(0, 1fr);
  gap: 14px;
  padding: 14px;
  border-radius: 22px;
  background: linear-gradient(180deg, rgba(255, 255, 255, 0.94), rgba(248, 244, 236, 0.94));
  border: 1px solid rgba(17, 61, 77, 0.08);
}

.related-card img {
  width: 108px;
  height: 108px;
  object-fit: cover;
  border-radius: 18px;
}

.related-card p {
  margin: 0 0 8px;
}

.related-card span {
  color: var(--primary-deep);
  font-weight: 700;
}

@media (max-width: 980px) {
  .accessory-hero,
  .accessory-grid {
    grid-template-columns: 1fr;
  }
}

@media (max-width: 720px) {
  .order-summary,
  .field-row,
  .related-card {
    display: grid;
  }

  .accessory-hero {
    padding: 18px;
  }
}
</style>
