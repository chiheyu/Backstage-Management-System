<script setup>
import { computed, onMounted, reactive, ref, watch } from 'vue'
import { RouterLink, useRouter } from 'vue-router'
import EmptyState from '@/components/EmptyState.vue'
import StatusBadge from '@/components/StatusBadge.vue'
import { apiBaseUrl, commonApi, merchantApi, userApi } from '@/lib/api'
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
const merchantSaving = ref(false)
const merchantUploading = ref(false)
const merchantDeleting = ref(false)
const fileInput = ref(null)
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

const merchantForm = reactive({
  accessoryId: '',
  accessoryName: '',
  categoryName: '',
  accessoryDesc: '',
  coverImage: '',
  price: '',
  stock: '',
  status: '0'
})

const roleState = computed(() => getRoleState(session.roleType))
const isMerchantMode = computed(() => roleState.value.isMerchant)
const canOrder = computed(() => session.token && roleState.value.isUser && !roleState.value.isMerchant)
const resolvedImage = computed(() => {
  const imageUrl = isMerchantMode.value
    ? merchantForm.coverImage || accessory.value?.coverImage
    : accessory.value?.coverImage

  return resolveImage(imageUrl, apiBaseUrl)
})
const merchantStatusBadge = computed(() => (
  merchantForm.status === '0'
    ? { label: '上架中', tone: 'success' }
    : { label: '已下架', tone: 'muted' }
))

function normalizeAccessoryDetail(detail = {}) {
  return {
    ...detail,
    accessoryId: detail.accessoryId,
    accessoryName: detail.accessoryName || '未命名商品',
    categoryName: detail.categoryName || '通用配件',
    accessoryDesc: detail.accessoryDesc || '',
    coverImage: detail.coverImage || '',
    price: Number(detail.price || 0),
    stock: Number(detail.stock || 0),
    salesCount: Number(detail.salesCount || 0),
    status: String(detail.status ?? '0'),
    collected: Boolean(detail.collected)
  }
}

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

function syncMerchantForm(detail = {}) {
  merchantForm.accessoryId = detail.accessoryId ? String(detail.accessoryId) : ''
  merchantForm.accessoryName = detail.accessoryName || ''
  merchantForm.categoryName = detail.categoryName || ''
  merchantForm.accessoryDesc = detail.accessoryDesc || ''
  merchantForm.coverImage = detail.coverImage || ''
  merchantForm.price = detail.price === 0 ? '0' : String(detail.price ?? '')
  merchantForm.stock = detail.stock === 0 ? '0' : String(detail.stock ?? '')
  merchantForm.status = String(detail.status ?? '0')
}

async function loadDetail() {
  loading.value = true
  try {
    const detailPayload = isMerchantMode.value
      ? await merchantApi.getAccessory(props.id)
      : await commonApi.getAccessory(props.id)
    const detail = normalizeAccessoryDetail(detailPayload)

    accessory.value = detail

    if (isMerchantMode.value) {
      relatedList.value = []
      syncMerchantForm(detail)
      return
    }

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
    relatedList.value = []
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

function openImagePicker() {
  fileInput.value?.click()
}

async function handleMerchantImageChange(event) {
  const file = event.target.files?.[0]
  event.target.value = ''
  if (!file) {
    return
  }

  merchantUploading.value = true
  try {
    const payload = await merchantApi.uploadAccessoryImage(file)
    merchantForm.coverImage = payload?.url || merchantForm.coverImage
    pushNotice('图片上传成功', 'success')
  } catch (error) {
    pushNotice(error.message || '图片上传失败', 'danger')
  } finally {
    merchantUploading.value = false
  }
}

function toggleShelfStatus() {
  merchantForm.status = merchantForm.status === '0' ? '1' : '0'
}

function validateMerchantForm() {
  if (!merchantForm.accessoryName.trim()) {
    return '请输入商品名称'
  }
  if (!merchantForm.categoryName.trim()) {
    return '请输入商品分类'
  }
  if (!merchantForm.price || Number(merchantForm.price) <= 0) {
    return '请输入有效售价'
  }
  if (merchantForm.stock === '' || Number(merchantForm.stock) < 0) {
    return '请输入有效库存'
  }
  return ''
}

async function saveMerchantGoods() {
  if (!merchantForm.accessoryId) {
    pushNotice('缺少商品编号，无法保存', 'danger')
    return
  }

  const validationMessage = validateMerchantForm()
  if (validationMessage) {
    pushNotice(validationMessage, 'danger')
    return
  }
  if (merchantSaving.value) {
    return
  }

  merchantSaving.value = true
  try {
    await merchantApi.updateAccessory({
      accessoryId: Number(merchantForm.accessoryId),
      accessoryName: merchantForm.accessoryName.trim(),
      categoryName: merchantForm.categoryName.trim(),
      accessoryDesc: merchantForm.accessoryDesc.trim(),
      coverImage: merchantForm.coverImage.trim(),
      price: Number(merchantForm.price),
      stock: Number(merchantForm.stock),
      status: merchantForm.status
    })
    pushNotice('商品已更新', 'success')
    await loadDetail()
  } catch (error) {
    pushNotice(error.message || '商品保存失败', 'danger')
  } finally {
    merchantSaving.value = false
  }
}

async function deleteMerchantGoods() {
  if (!accessory.value?.accessoryId || merchantDeleting.value) {
    return
  }

  const confirmed = window.confirm(`确认删除商品“${merchantForm.accessoryName || accessory.value.accessoryName}”吗？`)
  if (!confirmed) {
    return
  }

  merchantDeleting.value = true
  try {
    await merchantApi.deleteAccessory(accessory.value.accessoryId)
    pushNotice('商品已删除', 'success')
    router.push({ name: 'merchant-accessories' })
  } catch (error) {
    pushNotice(error.message || '商品删除失败', 'danger')
  } finally {
    merchantDeleting.value = false
  }
}

watch(
  () => props.id,
  () => {
    syncAddressOptions()
    loadDetail()
  }
)

watch(
  () => session.roleType,
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
              v-if="isMerchantMode"
              v-bind="merchantStatusBadge"
            />
            <StatusBadge
              v-else
              :label="accessory.collected ? '已收藏' : '可购买'"
              :tone="accessory.collected ? 'warm' : 'brand'"
            />
          </div>

          <h1>{{ isMerchantMode ? (merchantForm.accessoryName || accessory.accessoryName) : accessory.accessoryName }}</h1>
          <p>{{ isMerchantMode ? (merchantForm.accessoryDesc || accessory.accessoryDesc || '请补充商品说明、适配型号和售后说明。') : (accessory.accessoryDesc || '适用于常见电子产品维修、更换和保养场景。') }}</p>

          <div class="accessory-price">
            <strong>￥{{ formatMoney(isMerchantMode ? merchantForm.price : accessory.price) }}</strong>
            <span>
              库存 {{ isMerchantMode ? merchantForm.stock || 0 : accessory.stock || 0 }}
              / 销量 {{ accessory.salesCount || 0 }}
            </span>
          </div>

          <div class="accessory-points">
            <article>
              <strong>{{ isMerchantMode ? '商品维护' : '库存透明' }}</strong>
              <span>{{ isMerchantMode ? '网页端商品详情页现在和小程序一致，可直接修改商品名称、分类、价格、库存、图片和上下架状态。' : '下单前即可查看当前库存和销量。' }}</span>
            </article>
            <article>
              <strong>{{ isMerchantMode ? '接口复用' : '收藏便捷' }}</strong>
              <span>{{ isMerchantMode ? '详情页直接复用现有商家商品接口，不改后端结构，也不影响小程序端。' : '常用配件可随时加入或取消收藏。' }}</span>
            </article>
            <article>
              <strong>售后衔接</strong>
              <span>{{ isMerchantMode ? '如需继续处理商家业务，可前往商品管理、配件订单和售后工单页面。' : '购买后如需维修，可继续提交相关售后申请。' }}</span>
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
              <RouterLink class="btn btn--ghost" :to="{ name: 'merchant-accessories' }">返回商品管理</RouterLink>
              <RouterLink class="btn btn--primary" :to="{ name: 'merchant-accessory-orders' }">查看配件订单</RouterLink>
            </template>
          </div>
        </div>
      </section>

      <section class="accessory-grid">
        <section class="surface-card section-card">
          <template v-if="isMerchantMode">
            <div class="section-head">
              <div>
                <span class="eyebrow">商品编辑</span>
                <h2>直接维护当前商品</h2>
                <p>这里按小程序商家详情页的交互补齐了商品编辑能力，支持修改、上下架、图片上传和删除。</p>
              </div>
            </div>

            <form class="order-form merchant-form" @submit.prevent="saveMerchantGoods">
              <div class="field-row">
                <label>
                  <span>商品名称</span>
                  <input v-model.trim="merchantForm.accessoryName" class="field" placeholder="请输入商品名称" />
                </label>
                <label>
                  <span>商品分类</span>
                  <input v-model.trim="merchantForm.categoryName" class="field" placeholder="请输入商品分类" />
                </label>
              </div>

              <div class="field-row">
                <label>
                  <span>售价</span>
                  <input v-model.trim="merchantForm.price" class="field" type="number" min="0" step="0.01" placeholder="请输入售价" />
                </label>
                <label>
                  <span>库存</span>
                  <input v-model.trim="merchantForm.stock" class="field" type="number" min="0" step="1" placeholder="请输入库存" />
                </label>
              </div>

              <label>
                <span>图片地址</span>
                <div class="field-row">
                  <input v-model.trim="merchantForm.coverImage" class="field" placeholder="支持直接填写图片地址或上传图片" />
                  <button type="button" class="btn btn--ghost btn--small" :disabled="merchantUploading" @click="openImagePicker">
                    {{ merchantUploading ? '上传中...' : '上传图片' }}
                  </button>
                </div>
              </label>

              <label>
                <span>商品详情</span>
                <textarea
                  v-model.trim="merchantForm.accessoryDesc"
                  class="textarea"
                  placeholder="请输入商品详情、适配型号和售后说明"
                ></textarea>
              </label>

              <div class="surface-card merchant-summary-card">
                <div class="merchant-summary-grid">
                  <article>
                    <strong>商品编号</strong>
                    <span>{{ accessory.accessoryId }}</span>
                  </article>
                  <article>
                    <strong>累计销量</strong>
                    <span>{{ accessory.salesCount || 0 }}</span>
                  </article>
                  <article>
                    <strong>当前状态</strong>
                    <span>{{ merchantStatusBadge.label }}</span>
                  </article>
                </div>
              </div>

              <div class="action-row merchant-form__footer">
                <button type="button" class="btn btn--ghost" @click="toggleShelfStatus">
                  {{ merchantForm.status === '0' ? '切换为下架' : '切换为上架' }}
                </button>
                <button type="button" class="btn btn--ghost" :disabled="merchantDeleting" @click="deleteMerchantGoods">
                  {{ merchantDeleting ? '删除中...' : '删除商品' }}
                </button>
                <button class="btn btn--primary" :disabled="merchantSaving">
                  {{ merchantSaving ? '保存中...' : '保存商品' }}
                </button>
              </div>
            </form>
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
              <span class="eyebrow">{{ isMerchantMode ? '公开预览' : '同类推荐' }}</span>
              <h2>{{ isMerchantMode ? '商品展示信息' : '同类推荐' }}</h2>
              <p v-if="isMerchantMode">当前页面右侧保留对外展示视角和业务提示，方便边改边确认商品信息是否完整。</p>
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
            <article class="related-card related-card--single">
              <div>
                <strong>当前对外展示</strong>
                <p>{{ merchantForm.accessoryName || accessory.accessoryName }}</p>
                <span>{{ merchantForm.categoryName || accessory.categoryName || '通用配件' }}</span>
              </div>
            </article>
            <article class="related-card related-card--single">
              <div>
                <strong>价格与库存</strong>
                <p>售价 ￥{{ formatMoney(merchantForm.price) }}</p>
                <span>库存 {{ merchantForm.stock || 0 }} / 销量 {{ accessory.salesCount || 0 }}</span>
              </div>
            </article>
            <article class="related-card related-card--single">
              <div>
                <strong>状态提醒</strong>
                <p>{{ merchantStatusBadge.label }}</p>
                <span>下架商品不会在用户公开商城中展示。</span>
              </div>
            </article>
            <article class="related-card related-card--single">
              <div>
                <strong>后续操作</strong>
                <p>如需处理商城订单或售后工单，可直接前往对应商家页面继续操作。</p>
                <span>不修改小程序前端，也不修改后端接口。</span>
              </div>
            </article>
          </div>

          <EmptyState
            v-else
            title="暂无推荐"
            description="同分类下暂时没有更多可展示的配件。"
          />
        </section>
      </section>

      <input
        ref="fileInput"
        class="file-input"
        type="file"
        accept="image/*"
        @change="handleMerchantImageChange"
      />
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
.order-summary strong,
.merchant-summary-card strong {
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

.merchant-summary-card {
  padding: 18px 20px;
  border-radius: 24px;
}

.merchant-summary-grid {
  display: grid;
  grid-template-columns: repeat(3, minmax(0, 1fr));
  gap: 14px;
}

.merchant-summary-grid article {
  padding: 14px 16px;
  border-radius: 18px;
  background: rgba(255, 255, 255, 0.72);
  border: 1px solid rgba(17, 61, 77, 0.08);
}

.merchant-summary-grid span {
  color: var(--muted);
  font-weight: 600;
}

.merchant-form__footer {
  justify-content: flex-end;
  flex-wrap: wrap;
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

.related-card--single {
  grid-template-columns: 1fr;
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

.file-input {
  display: none;
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
  .related-card,
  .merchant-summary-grid {
    display: grid;
  }

  .accessory-hero {
    padding: 18px;
  }
}
</style>
