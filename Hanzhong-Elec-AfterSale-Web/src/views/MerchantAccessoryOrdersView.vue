<script setup>
import { computed, onMounted, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import EmptyState from '@/components/EmptyState.vue'
import StatusBadge from '@/components/StatusBadge.vue'
import { apiBaseUrl, merchantApi } from '@/lib/api'
import { ACCESSORY_ORDER_STATUS, formatDateTime, formatMoney, getRoleState, getStatusMeta, resolveImage } from '@/lib/domain'
import { pushNotice } from '@/lib/notice'
import { session } from '@/lib/session'

const PAGE_SIZE = 50
const TAB_PENDING = 'pending'
const TAB_FINISHED = 'finished'
const TAB_ALL = 'all'

const route = useRoute()
const router = useRouter()

const loading = ref(false)
const actioningId = ref('')
const orderList = ref([])

const roleState = computed(() => getRoleState(session.roleType))
const currentTab = ref([TAB_PENDING, TAB_FINISHED, TAB_ALL].includes(String(route.query.type)) ? String(route.query.type) : TAB_PENDING)

const tabs = [
  { value: TAB_PENDING, label: '待处理' },
  { value: TAB_FINISHED, label: '已处理' },
  { value: TAB_ALL, label: '全部订单' }
]

const filteredOrders = computed(() => {
  if (currentTab.value === TAB_PENDING) {
    return orderList.value.filter(item => ['0', '1'].includes(item.status))
  }
  if (currentTab.value === TAB_FINISHED) {
    return orderList.value.filter(item => ['2', '3'].includes(item.status))
  }
  return orderList.value
})

const summaryCards = computed(() => [
  {
    title: '全部订单',
    value: orderList.value.length,
  },
  {
    title: '待处理',
    value: orderList.value.filter(item => ['0', '1'].includes(item.status)).length,
  },
  {
    title: '已处理',
    value: orderList.value.filter(item => ['2', '3'].includes(item.status)).length,
  },
  {
    title: '当前视图',
    value: tabs.find(item => item.value === currentTab.value)?.label || '待处理',
  }
])

function normalizeOrder(item = {}) {
  return {
    ...item,
    accessoryOrderId: item.accessoryOrderId,
    orderNo: item.orderNo || `AO${item.accessoryOrderId || ''}`,
    accessoryName: item.accessoryName || '未命名商品',
    userName: item.userName || '未返回',
    status: String(item.status ?? ''),
    quantity: Number(item.quantity || 0),
    price: Number(item.price || 0),
    totalAmount: Number(item.totalAmount || 0),
    coverImage: item.coverImage ? resolveImage(item.coverImage, apiBaseUrl) : ''
  }
}

async function fetchAllOrders() {
  let pageNum = 1
  let total = 0
  const rows = []

  while (true) {
    const payload = await merchantApi.listAccessoryOrders({
      pageNum,
      pageSize: PAGE_SIZE
    })
    const nextRows = Array.isArray(payload?.rows) ? payload.rows : []
    rows.push(...nextRows)
    total = Number(payload?.total || 0)

    if (!nextRows.length || nextRows.length < PAGE_SIZE || (total > 0 && rows.length >= total)) {
      break
    }

    pageNum += 1
  }

  return Array.from(
    new Map(rows.map(item => [String(item.accessoryOrderId), normalizeOrder(item)])).values()
  )
}

async function loadOrders() {
  if (!session.token || !roleState.value.isMerchant || loading.value) {
    return
  }

  loading.value = true
  try {
    orderList.value = await fetchAllOrders()
  } catch (error) {
    orderList.value = []
    pushNotice(error.message || '商家配件订单加载失败', 'danger')
  } finally {
    loading.value = false
  }
}

function setTab(value) {
  currentTab.value = value
  router.replace({
    name: 'merchant-accessory-orders',
    query: value === TAB_PENDING ? {} : { type: value }
  })
}

function canShip(item) {
  return item.status === '0'
}

function canComplete(item) {
  return item.status === '1'
}

function canCancel(item) {
  return ['0', '1'].includes(item.status)
}

async function runAction(item, executor, successMessage) {
  if (!item?.accessoryOrderId || actioningId.value) {
    return
  }

  actioningId.value = String(item.accessoryOrderId)
  try {
    await executor()
    pushNotice(successMessage, 'success')
    await loadOrders()
  } catch (error) {
    pushNotice(error.message || '订单处理失败', 'danger')
  } finally {
    actioningId.value = ''
  }
}

function shipOrder(item) {
  if (!window.confirm(`确认将订单 ${item.orderNo} 标记为已发货吗？`)) {
    return
  }
  runAction(item, () => merchantApi.shipAccessoryOrder(item.accessoryOrderId), '订单已更新为已发货')
}

function completeOrder(item) {
  if (!window.confirm(`确认将订单 ${item.orderNo} 标记为已完成吗？`)) {
    return
  }
  runAction(item, () => merchantApi.completeAccessoryOrder(item.accessoryOrderId), '订单已完成')
}

function cancelOrder(item) {
  if (!window.confirm(`确认取消订单 ${item.orderNo} 吗？`)) {
    return
  }
  runAction(item, () => merchantApi.cancelAccessoryOrder(item.accessoryOrderId), '订单已取消')
}

onMounted(() => {
  loadOrders()
})
</script>

<template>
  <section class="page-shell merchant-accessory-orders-page">
    <EmptyState
      v-if="!session.token"
      title="请先登录商家账号"
      description="商家配件订单页只对已登录商家开放。"
      action-label="前往登录"
      @action="router.push({ name: 'auth' })"
    />

    <EmptyState
      v-else-if="!roleState.isMerchant"
      title="当前账号不是商家"
      description="普通用户无法进入商家配件订单页。"
      action-label="返回个人中心"
      @action="router.push({ name: 'profile' })"
    />

    <template v-else>
      <section class="glass-card order-hero">
        <div>
          <span class="eyebrow">配件订单</span>
          <h1>商家配件订单管理</h1>
        </div>

        <div class="order-hero__actions">
          <button class="btn btn--primary" @click="loadOrders">刷新订单</button>
          <button class="btn btn--ghost" @click="router.push({ name: 'merchant-accessories' })">前往商品管理</button>
        </div>
      </section>

      <section class="summary-grid">
        <article v-for="item in summaryCards" :key="item.title" class="surface-card summary-card">
          <span>{{ item.title }}</span>
          <strong>{{ item.value }}</strong>
          <p>{{ item.desc }}</p>
        </article>
      </section>

      <section class="surface-card section-card">
        <div class="status-filter">
          <button
            v-for="item in tabs"
            :key="item.value"
            class="status-filter__item"
            :class="{ active: currentTab === item.value }"
            @click="setTab(item.value)"
          >
            {{ item.label }}
          </button>
        </div>
      </section>

      <section v-if="loading" class="order-list">
        <article v-for="item in 4" :key="item" class="order-card order-card--ghost"></article>
      </section>

      <section v-else-if="filteredOrders.length" class="order-list">
        <article v-for="item in filteredOrders" :key="item.accessoryOrderId" class="surface-card order-card">
          <div class="order-card__head">
            <div>
              <span class="eyebrow">{{ item.orderNo }}</span>
              <h2>{{ item.accessoryName }}</h2>
            </div>
            <StatusBadge v-bind="getStatusMeta(ACCESSORY_ORDER_STATUS, item.status)" />
          </div>

          <div class="order-card__body">
            <img
              v-if="item.coverImage"
              :src="item.coverImage"
              :alt="item.accessoryName"
            />
            <div v-else class="order-card__placeholder">暂无图片</div>

            <div class="order-card__info">
              <div class="order-card__meta">
                <span>下单用户：{{ item.userName }}</span>
                <span>数量：{{ item.quantity }}</span>
                <span>单价：¥{{ formatMoney(item.price) }}</span>
                <strong>合计：¥{{ formatMoney(item.totalAmount) }}</strong>
              </div>

              <div class="order-card__receiver">
                <span>收货人：{{ item.receiverName || '未填写' }}</span>
                <span>联系电话：{{ item.receiverPhone || '未填写' }}</span>
                <span>收货地址：{{ item.receiverAddress || '未填写' }}</span>
                <span>创建时间：{{ formatDateTime(item.createTime) }}</span>
              </div>

              <p v-if="item.orderRemark" class="order-card__remark">
                <strong>订单备注：</strong>{{ item.orderRemark }}
              </p>

              <div class="action-row">
                <button
                  v-if="canShip(item)"
                  class="btn btn--primary btn--small"
                  :disabled="actioningId === String(item.accessoryOrderId)"
                  @click="shipOrder(item)"
                >
                  {{ actioningId === String(item.accessoryOrderId) ? '处理中...' : '标记已发货' }}
                </button>
                <button
                  v-if="canComplete(item)"
                  class="btn btn--secondary btn--small"
                  :disabled="actioningId === String(item.accessoryOrderId)"
                  @click="completeOrder(item)"
                >
                  {{ actioningId === String(item.accessoryOrderId) ? '处理中...' : '标记已完成' }}
                </button>
                <button
                  v-if="canCancel(item)"
                  class="btn btn--ghost btn--small"
                  :disabled="actioningId === String(item.accessoryOrderId)"
                  @click="cancelOrder(item)"
                >
                  {{ actioningId === String(item.accessoryOrderId) ? '处理中...' : '取消订单' }}
                </button>
              </div>
            </div>
          </div>
        </article>
      </section>

      <EmptyState
        v-else
        title="当前没有匹配的配件订单"
        action-label="刷新订单"
        @action="loadOrders"
      />
    </template>
  </section>
</template>

<style scoped>
.merchant-accessory-orders-page {
  display: grid;
  gap: 22px;
}

.order-hero {
  display: flex;
  align-items: end;
  justify-content: space-between;
  gap: 18px;
  padding: 28px;
}

.order-hero h1 {
  margin: 14px 0 8px;
  font-size: clamp(32px, 4vw, 48px);
  line-height: 1.08;
}

.order-hero__actions {
  display: flex;
  gap: 12px;
  flex-wrap: wrap;
}

.summary-grid {
  display: grid;
  grid-template-columns: repeat(4, minmax(0, 1fr));
  gap: 16px;
}

.summary-card {
  padding: 20px;
}

.summary-card span {
  color: var(--muted);
}

.summary-card strong {
  display: block;
  margin-top: 10px;
  font-size: 28px;
  color: var(--primary-deep);
}

.order-list {
  display: grid;
  gap: 18px;
}

.order-card {
  padding: 24px;
}

.order-card--ghost {
  min-height: 220px;
  background: linear-gradient(90deg, rgba(255, 255, 255, 0.7), rgba(237, 245, 247, 0.9), rgba(255, 255, 255, 0.7));
  background-size: 200% 100%;
  animation: order-pulse 1.8s linear infinite;
}

.order-card__head {
  display: flex;
  align-items: start;
  justify-content: space-between;
  gap: 16px;
  margin-bottom: 18px;
}

.order-card__head h2 {
  margin: 12px 0 0;
}

.order-card__body {
  display: grid;
  grid-template-columns: 180px minmax(0, 1fr);
  gap: 18px;
}

.order-card__body img,
.order-card__placeholder {
  width: 180px;
  height: 180px;
  border-radius: 24px;
}

.order-card__body img {
  object-fit: cover;
}

.order-card__placeholder {
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, rgba(18, 105, 93, 0.14), rgba(215, 141, 43, 0.16));
  color: var(--primary-deep);
  font-weight: 700;
}

.order-card__info {
  display: grid;
  gap: 14px;
}

.order-card__meta,
.order-card__receiver {
  display: grid;
  gap: 8px;
  color: var(--muted);
}

.order-card__meta strong {
  color: var(--primary-deep);
}

.order-card__remark {
  margin: 0;
}

@keyframes order-pulse {
  to {
    background-position: -200% 0;
  }
}

@media (max-width: 1080px) {
  .summary-grid {
    grid-template-columns: repeat(2, minmax(0, 1fr));
  }
}

@media (max-width: 820px) {
  .order-hero,
  .summary-grid,
  .order-card__body,
  .order-card__head {
    display: grid;
    grid-template-columns: 1fr;
  }

  .order-card__body img,
  .order-card__placeholder {
    width: 100%;
    height: auto;
    aspect-ratio: 5 / 4;
  }
}
</style>
