<script setup>
import { computed, onMounted, reactive, ref, watch } from 'vue'
import { RouterLink, useRouter } from 'vue-router'
import EmptyState from '@/components/EmptyState.vue'
import StatusBadge from '@/components/StatusBadge.vue'
import { apiBaseUrl, commonApi, userApi } from '@/lib/api'
import { formatMoney, getRoleState, resolveImage, safeRows, shortText } from '@/lib/domain'
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

const orderForm = reactive({
  quantity: 1,
  receiverName: '',
  receiverPhone: '',
  receiverAddress: '',
  orderRemark: ''
})

const roleState = computed(() => getRoleState(session.roleType))
const canOrder = computed(() => session.token && roleState.value.isUser)

async function loadDetail() {
  loading.value = true
  try {
    const detail = await commonApi.getAccessory(props.id)
    accessory.value = detail

    orderForm.receiverName = session.appUser?.nickName || ''
    orderForm.receiverPhone = session.appUser?.phone || ''

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
  if (!roleState.value.isUser) {
    pushNotice('只有普通用户可以使用收藏功能', 'danger')
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

function validateOrder() {
  if (!accessory.value) {
    return false
  }
  if (!canOrder.value) {
    pushNotice('请使用普通用户账号下单', 'danger')
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
    loadDetail()
  }
)

onMounted(() => {
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
          <img :src="resolveImage(accessory.coverImage, apiBaseUrl)" :alt="accessory.accessoryName" />
        </div>

        <div class="surface-card accessory-main">
          <div class="between-row accessory-main__top">
            <span class="eyebrow">{{ accessory.categoryName || '通用配件' }}</span>
            <StatusBadge :label="accessory.collected ? '已收藏' : '可购买'" :tone="accessory.collected ? 'warm' : 'brand'" />
          </div>

          <h1>{{ accessory.accessoryName }}</h1>
          <p>{{ accessory.accessoryDesc || '适用于常见电子产品维修、更换和保养场景。' }}</p>

          <div class="accessory-price">
            <strong>￥{{ formatMoney(accessory.price) }}</strong>
            <span>库存 {{ accessory.stock || 0 }} / 销量 {{ accessory.salesCount || 0 }}</span>
          </div>

          <div class="accessory-points">
            <article>
              <strong>库存透明</strong>
              <span>下单前即可查看当前库存和销量。</span>
            </article>
            <article>
              <strong>收藏便捷</strong>
              <span>常用配件可随时加入或取消收藏。</span>
            </article>
            <article>
              <strong>售后衔接</strong>
              <span>购买后如需维修，可继续提交相关售后申请。</span>
            </article>
          </div>

          <div class="action-row">
            <button class="btn btn--ghost" :disabled="submitting" @click="toggleCollection">
              {{ accessory.collected ? '取消收藏' : '加入收藏' }}
            </button>
            <RouterLink class="btn btn--secondary" :to="{ name: 'after-sales-apply', query: { productType: accessory.accessoryName } }">
              配件相关售后
            </RouterLink>
          </div>
        </div>
      </section>

      <section class="accessory-grid">
        <section class="surface-card section-card">
          <div class="section-head">
            <div>
              <span class="eyebrow">在线下单</span>
              <h2>立即下单</h2>
              <p v-if="canOrder">填写收货信息后即可提交订单。</p>
              <p v-else-if="!session.token">登录后可下单，也可先收藏商品。</p>
              <p v-else>当前账号为商家/待审核商家，只可浏览，不可直接下单。</p>
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
                <span>收货地址</span>
                <input v-model.trim="orderForm.receiverAddress" class="field" placeholder="详细到门牌号" />
              </label>
            </div>

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
        </section>

        <section class="surface-card section-card">
          <div class="section-head">
            <div>
              <span class="eyebrow">同类推荐</span>
              <h2>同类推荐</h2>
              <p>继续浏览同类配件，方便一次完成选购。</p>
            </div>
          </div>

          <div v-if="relatedList.length" class="related-list">
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
          <EmptyState
            v-else
            title="暂无推荐"
            description="同分类下暂时没有更多可展示的配件。"
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
  .field-row {
    display: grid;
  }

  .accessory-hero {
    padding: 18px;
  }
}
</style>
