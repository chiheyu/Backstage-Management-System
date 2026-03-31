<script setup>
import { computed, onMounted, reactive, ref, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import EmptyState from '@/components/EmptyState.vue'
import StatusBadge from '@/components/StatusBadge.vue'
import { apiBaseUrl, merchantApi, userApi } from '@/lib/api'
import {
  AFTER_SALES_STATUS,
  formatDateTime,
  getRoleState,
  getStatusMeta,
  resolveImage,
  shortText
} from '@/lib/domain'
import { pushNotice } from '@/lib/notice'
import { fetchAllPagedRows } from '@/lib/pagination'
import { session } from '@/lib/session'

const PAGE_SIZE = 50
const MERCHANT_TAB_PENDING = 'pending'
const MERCHANT_TAB_FINISHED = 'finished'
const MERCHANT_TAB_ALL = 'all'

const route = useRoute()
const router = useRouter()

const loading = ref(false)
const merchantTab = ref(resolveMerchantTab(route.query))
const userOrders = ref([])
const merchantOrders = ref([])

const filters = reactive({
  orderNo: '',
  productType: '',
  status: ''
})

const statusOptions = computed(() => [
  { label: '全部状态', value: '' },
  ...Object.entries(AFTER_SALES_STATUS).map(([value, meta]) => ({ value, label: meta.label }))
])

const roleState = computed(() => getRoleState(session.roleType))

const pageTitle = computed(() => {
  if (roleState.value.isMerchant) {
    const titleMap = {
      [MERCHANT_TAB_PENDING]: '未完成售后工单',
      [MERCHANT_TAB_FINISHED]: '已完成售后工单',
      [MERCHANT_TAB_ALL]: '售后订单'
    }
    return titleMap[merchantTab.value] || titleMap[MERCHANT_TAB_PENDING]
  }
  return '我的售后订单'
})

const activeList = computed(() => {
  if (roleState.value.isMerchant) {
    if (merchantTab.value === MERCHANT_TAB_PENDING) {
      return merchantOrders.value.filter(item => isUnfinishedStatus(item.status))
    }
    if (merchantTab.value === MERCHANT_TAB_FINISHED) {
      return merchantOrders.value.filter(item => isFinishedStatus(item.status))
    }
    return merchantOrders.value
  }
  return userOrders.value
})

const summaryCards = computed(() => {
  if (roleState.value.isMerchant) {
    const unfinishedCount = merchantOrders.value.filter(item => isUnfinishedStatus(item.status)).length
    const finishedCount = merchantOrders.value.filter(item => isFinishedStatus(item.status)).length
    const rejectedCount = merchantOrders.value.filter(item => isRejectedOrder(item)).length
    return [
      { label: '未完成', value: unfinishedCount, desc: '仍待商家给出处理意见的工单' },
      { label: '已完成', value: finishedCount, desc: '商家已经给出处理结果的工单' },
      { label: '已拒绝', value: rejectedCount, desc: '处理备注中明确写明已拒绝的工单' }
    ]
  }

  return [
    { label: '全部订单', value: userOrders.value.length, desc: '当前账号提交过的售后申请' },
    { label: '处理中', value: userOrders.value.filter(item => ['0', '1', '2'].includes(String(item.status))).length, desc: '待接单、已接单或维修中的订单' },
    { label: '已结束', value: userOrders.value.filter(item => ['3', '4'].includes(String(item.status))).length, desc: '已完成或已取消的售后订单' }
  ]
})

function resolveMerchantTab(query = {}) {
  const rawType = String(query.type || '')
  if ([MERCHANT_TAB_PENDING, MERCHANT_TAB_FINISHED, MERCHANT_TAB_ALL].includes(rawType)) {
    return rawType
  }

  const rawMode = String(query.mode || '')
  if (rawMode === 'mine') {
    return MERCHANT_TAB_ALL
  }

  return MERCHANT_TAB_PENDING
}

function parseImages(value) {
  return String(value || '')
    .split(',')
    .map(item => item.trim())
    .filter(Boolean)
    .map(item => resolveImage(item, apiBaseUrl))
}

function buildBaseFilters() {
  return {
    orderNo: filters.orderNo,
    productType: filters.productType
  }
}

function isUnfinishedStatus(status) {
  return ['0', '1', '2'].includes(String(status))
}

function isFinishedStatus(status) {
  return ['3', '4'].includes(String(status))
}

function isRejectedOrder(order) {
  return String(order?.serviceRemark || '').trim().startsWith('已拒绝')
}

async function loadOrders() {
  if (!session.token) {
    return
  }

  loading.value = true
  try {
    if (roleState.value.isMerchant) {
      merchantOrders.value = await fetchAllPagedRows(params => merchantApi.listOrders(params), {
        params: {
          ...buildBaseFilters(),
          status: filters.status
        },
        pageSize: PAGE_SIZE,
        dedupeKey: 'orderId'
      })
      return
    }

    if (roleState.value.isUser) {
      userOrders.value = await fetchAllPagedRows(params => userApi.listAfterSalesOrders(params), {
        params: {
          ...buildBaseFilters(),
          status: filters.status
        },
        pageSize: PAGE_SIZE,
        dedupeKey: 'orderId'
      })
    }
  } catch (error) {
    pushNotice(error.message || '售后订单加载失败', 'danger')
  } finally {
    loading.value = false
  }
}

function canUserCancel(order) {
  return isUnfinishedStatus(order.status)
}

function canOpenReceipt(order) {
  return roleState.value.isMerchant && isUnfinishedStatus(order.status)
}

function openReceipt(order) {
  router.push({
    name: 'after-sales-apply',
    query: { orderId: order.orderId }
  })
}

async function handleUserCancel(orderId) {
  try {
    await userApi.cancelAfterSalesOrder(orderId)
    pushNotice('售后订单已取消', 'success')
    await loadOrders()
  } catch (error) {
    pushNotice(error.message || '取消失败', 'danger')
  }
}

function resetFilters() {
  filters.orderNo = ''
  filters.productType = ''
  filters.status = ''
  loadOrders()
}

function setMerchantTab(tab) {
  merchantTab.value = tab
  router.replace({
    name: 'after-sales-orders',
    query: tab === MERCHANT_TAB_PENDING ? {} : { type: tab }
  })
}

watch(
  () => [route.query.mode, route.query.type],
  () => {
    if (roleState.value.isMerchant) {
      merchantTab.value = resolveMerchantTab(route.query)
    }
  }
)

onMounted(() => {
  loadOrders()
})
</script>

<template>
  <section class="page-shell after-sale-orders-page">
    <EmptyState
      v-if="!session.token"
      title="请先登录后查看售后订单"
      description="登录后才能读取当前用户或商家的售后工单。"
      action-label="前往登录"
      @action="router.push({ name: 'auth' })"
    />

    <template v-else>
      <section class="glass-card order-hero">
        <div>
          <span class="eyebrow">售后工单</span>
          <h1>{{ pageTitle }}</h1>
        </div>

        <div v-if="roleState.isMerchant" class="status-filter">
          <button
            class="status-filter__item"
            :class="{ active: merchantTab === MERCHANT_TAB_PENDING }"
            @click="setMerchantTab(MERCHANT_TAB_PENDING)"
          >
            未完成
          </button>
          <button
            class="status-filter__item"
            :class="{ active: merchantTab === MERCHANT_TAB_FINISHED }"
            @click="setMerchantTab(MERCHANT_TAB_FINISHED)"
          >
            已完成
          </button>
          <button
            class="status-filter__item"
            :class="{ active: merchantTab === MERCHANT_TAB_ALL }"
            @click="setMerchantTab(MERCHANT_TAB_ALL)"
          >
            全部工单
          </button>
        </div>
      </section>

      <section class="summary-grid">
        <article v-for="item in summaryCards" :key="item.label" class="surface-card summary-card">
          <span>{{ item.label }}</span>
          <strong>{{ item.value }}</strong>
          <p>{{ item.desc }}</p>
        </article>
      </section>

      <section class="surface-card section-card">
        <div class="field-row">
          <input
            v-model.trim="filters.orderNo"
            class="field"
            placeholder="搜索订单号"
            @keyup.enter="loadOrders"
          />
          <input
            v-model.trim="filters.productType"
            class="field"
            placeholder="搜索产品类型"
            @keyup.enter="loadOrders"
          />
          <select v-model="filters.status" class="field">
            <option v-for="item in statusOptions" :key="item.value" :value="item.value">
              {{ item.label }}
            </option>
          </select>
          <button class="btn btn--primary btn--small" @click="loadOrders">刷新列表</button>
          <button class="btn btn--ghost btn--small" @click="resetFilters">清空筛选</button>
        </div>
      </section>

      <section v-if="loading" class="order-list">
        <article v-for="item in 3" :key="item" class="order-card order-card--ghost"></article>
      </section>

      <section v-else-if="activeList.length" class="order-list">
        <article v-for="order in activeList" :key="order.orderId" class="surface-card order-card">
          <div class="order-card__head">
            <div>
              <span class="eyebrow">{{ order.orderNo }}</span>
              <h2>{{ order.productType }}</h2>
            </div>
            <StatusBadge v-bind="getStatusMeta(AFTER_SALES_STATUS, order.status)" />
          </div>

          <p>{{ shortText(order.faultDesc, 120) }}</p>

          <div v-if="parseImages(order.faultImages).length" class="order-image-list">
            <img
              v-for="image in parseImages(order.faultImages)"
              :key="image"
              :src="image"
              alt="故障图片"
            />
          </div>

          <div class="order-meta-grid">
            <article>
              <strong>联系人</strong>
              <span>{{ order.contactName }} / {{ order.contactPhone }}</span>
            </article>
            <article>
              <strong>服务地址</strong>
              <span>{{ order.address || '未填写地址' }}</span>
            </article>
            <article>
              <strong>创建时间</strong>
              <span>{{ formatDateTime(order.createTime) }}</span>
            </article>
            <article>
              <strong>{{ roleState.isMerchant ? '用户昵称' : '接单商家' }}</strong>
              <span>{{ roleState.isMerchant ? order.userName || '--' : order.merchantName || '待接单' }}</span>
            </article>
            <article>
              <strong>{{ roleState.isMerchant ? '用户诉求' : '售后类型' }}</strong>
              <span>{{ String(order.productType || '').split('/')[0]?.trim() || '未填写' }}</span>
            </article>
          </div>

          <p v-if="order.serviceRemark" class="order-service-remark">
            <strong>处理备注：</strong>{{ order.serviceRemark }}
          </p>

          <div class="action-row">
            <template v-if="roleState.isMerchant">
              <button
                v-if="canOpenReceipt(order)"
                class="btn btn--primary btn--small"
                @click="openReceipt(order)"
              >
                售后处理
              </button>
            </template>

            <button
              v-if="roleState.isUser && canUserCancel(order)"
              class="btn btn--ghost btn--small"
              @click="handleUserCancel(order.orderId)"
            >
              取消订单
            </button>
          </div>
        </article>
      </section>

      <EmptyState
        v-else
        :title="roleState.isMerchant ? '暂无工单' : '暂无售后记录'"
        :description="roleState.isMerchant ? '当前筛选条件下没有待接或已接工单。' : '你还没有提交过售后申请，或者当前筛选结果为空。'"
        :action-label="roleState.isMerchant ? '' : '去提交售后'"
        @action="router.push({ name: 'after-sales-apply' })"
      />
    </template>
  </section>
</template>

<style scoped>
.after-sale-orders-page {
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

.summary-grid {
  display: grid;
  grid-template-columns: repeat(3, minmax(0, 1fr));
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

.summary-card p {
  margin-top: 10px;
}

.order-list {
  display: grid;
  gap: 18px;
}

.order-card {
  padding: 22px;
}

.order-card--ghost {
  min-height: 280px;
  background: linear-gradient(90deg, rgba(255, 255, 255, 0.7), rgba(237, 245, 247, 0.88), rgba(255, 255, 255, 0.7));
  background-size: 200% 100%;
  animation: order-pulse 1.8s linear infinite;
}

.order-card__head {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: 14px;
  margin-bottom: 10px;
}

.order-card__head h2 {
  margin: 10px 0 0;
}

.order-meta-grid {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 14px;
  margin: 18px 0;
}

.order-meta-grid article {
  padding: 16px;
  border-radius: 20px;
  background: linear-gradient(180deg, rgba(255, 255, 255, 0.92), rgba(247, 243, 235, 0.92));
  border: 1px solid rgba(17, 61, 77, 0.08);
}

.order-meta-grid strong {
  display: block;
  margin-bottom: 6px;
}

.order-service-remark {
  margin: 0 0 14px;
}

.order-image-list {
  display: flex;
  flex-wrap: wrap;
  gap: 12px;
  margin: 0 0 16px;
}

.order-image-list img {
  width: 108px;
  height: 108px;
  object-fit: cover;
  border-radius: 18px;
}

@keyframes order-pulse {
  to {
    background-position: -200% 0;
  }
}

@media (max-width: 980px) {
  .summary-grid {
    grid-template-columns: 1fr;
  }
}

@media (max-width: 820px) {
  .order-hero,
  .field-row,
  .order-card__head,
  .order-meta-grid {
    display: grid;
  }

  .order-meta-grid {
    grid-template-columns: 1fr;
  }
}
</style>
