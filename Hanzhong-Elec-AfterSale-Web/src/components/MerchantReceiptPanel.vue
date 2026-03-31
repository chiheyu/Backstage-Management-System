<script setup>
import { computed, onMounted, ref, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import EmptyState from '@/components/EmptyState.vue'
import StatusBadge from '@/components/StatusBadge.vue'
import { apiBaseUrl, merchantApi } from '@/lib/api'
import { AFTER_SALES_STATUS, formatDateTime, getStatusMeta, resolveImage, shortText } from '@/lib/domain'
import { pushNotice } from '@/lib/notice'
import { fetchAllPagedRows } from '@/lib/pagination'

const PAGE_SIZE = 50

const emit = defineEmits(['updated'])

const route = useRoute()
const router = useRouter()

const loading = ref(false)
const submitting = ref(false)
const merchantOrders = ref([])
const selectedOrderId = ref('')
const receiptRemark = ref('')
const isRejectMode = ref(false)

const summaryCards = computed(() => {
  const unfinishedCount = merchantOrders.value.filter(item => !['3', '4'].includes(String(item.status))).length
  const completedCount = merchantOrders.value.filter(item => ['3', '4'].includes(String(item.status))).length
  const rejectedCount = merchantOrders.value.filter(item => String(item.serviceRemark || '').trim().startsWith('已拒绝')).length

  return [
    { label: '未完成', value: unfinishedCount },
    { label: '已完成', value: completedCount },
    { label: '已拒绝', value: rejectedCount }
  ]
})

const selectedOrder = computed(() => {
  return merchantOrders.value.find(item => String(item.orderId) === String(selectedOrderId.value)) || null
})

const imageList = computed(() => {
  return String(selectedOrder.value?.faultImages || '')
    .split(',')
    .map(item => item.trim())
    .filter(Boolean)
    .map(item => resolveImage(item, apiBaseUrl))
})

function getDefaultRemark(order) {
  if (!order) {
    return ''
  }
  return String(order.serviceRemark || '').trim()
}

function syncRouteOrderId(orderId) {
  const nextOrderId = String(orderId || '')
  if (String(route.query.orderId || '') === nextOrderId) {
    return
  }

  const nextQuery = { ...route.query }
  if (nextOrderId) {
    nextQuery.orderId = nextOrderId
  } else {
    delete nextQuery.orderId
  }

  router.replace({ query: nextQuery })
}

function applySelection(order) {
  if (!order) {
    selectedOrderId.value = ''
    receiptRemark.value = ''
    syncRouteOrderId('')
    return
  }

  selectedOrderId.value = String(order.orderId)
  receiptRemark.value = getDefaultRemark(order)
  isRejectMode.value = false
  syncRouteOrderId(order.orderId)
}

function syncSelection() {
  if (!merchantOrders.value.length) {
    applySelection(null)
    return
  }

  const preferredOrderId = String(route.query.orderId || '')
  const preferredOrder = merchantOrders.value.find(item => String(item.orderId) === preferredOrderId)
  const currentOrder = merchantOrders.value.find(item => String(item.orderId) === String(selectedOrderId.value))
  applySelection(preferredOrder || currentOrder || merchantOrders.value[0])
}

async function loadMerchantOrders() {
  loading.value = true
  try {
    merchantOrders.value = (
      await fetchAllPagedRows(params => merchantApi.listOrders(params), {
        pageSize: PAGE_SIZE,
        dedupeKey: 'orderId'
      })
    ).filter(item => ['0', '1', '2', '3', '4'].includes(String(item.status)))
    syncSelection()
  } catch (error) {
    merchantOrders.value = []
    applySelection(null)
    pushNotice(error.message || '售后回执列表加载失败', 'danger')
  } finally {
    loading.value = false
  }
}

function selectMerchantOrder(order) {
  applySelection(order)
}

function parseOrderMeta(productType) {
  const parts = String(productType || '')
    .split('/')
    .map(item => item.trim())
    .filter(Boolean)

  return {
    serviceType: parts[0] || '',
    productName: parts[1] || '',
    orderNo: parts[2] || ''
  }
}

const selectedOrderMeta = computed(() => parseOrderMeta(selectedOrder.value?.productType))
const isReadonlyReceipt = computed(() => ['3', '4'].includes(String(selectedOrder.value?.status || '')))
const readonlyReceiptContent = computed(() => String(selectedOrder.value?.serviceRemark || '').trim() || '暂无处理意见')
const trimmedReceiptRemark = computed(() => receiptRemark.value.trim())

async function submitReceipt() {
  if (!selectedOrder.value || submitting.value || isReadonlyReceipt.value) {
    return
  }

  const remark = receiptRemark.value.trim()
  const finalRemark = isRejectMode.value ? `已拒绝 拒绝原因：${remark}` : '已同意售后申请'
  if (isRejectMode.value && !remark) {
    pushNotice('请先填写拒绝原因', 'danger')
    return
  }

  submitting.value = true
  try {
    await merchantApi.updateOrderStatus({
      orderId: selectedOrder.value.orderId,
      status: '3',
      serviceRemark: finalRemark
    })
    pushNotice('处理成功', 'success')
    emit('updated')
    await loadMerchantOrders()
  } catch (error) {
    pushNotice(error.message || '售后回执提交失败', 'danger')
  } finally {
    submitting.value = false
  }
}

function agreeOrder() {
  isRejectMode.value = false
  receiptRemark.value = ''
  submitReceipt()
}

function toggleRejectMode() {
  isRejectMode.value = !isRejectMode.value
  if (!isRejectMode.value) {
    receiptRemark.value = ''
  }
}

watch(
  () => route.query.orderId,
  () => {
    syncSelection()
  }
)

onMounted(() => {
  loadMerchantOrders()
})
</script>

<template>
  <section class="merchant-receipt-page">
    <section class="glass-card receipt-hero">
      <div>
        <span class="eyebrow">售后回执</span>
        <h1>商家售后回执中心</h1>
      </div>

      <div class="receipt-summary-grid">
        <article v-for="item in summaryCards" :key="item.label" class="surface-card receipt-summary-card">
          <span>{{ item.label }}</span>
          <strong>{{ item.value }}</strong>
          <p>{{ item.desc }}</p>
        </article>
      </div>
    </section>

    <section v-if="loading" class="receipt-grid">
      <section class="surface-card section-card receipt-card receipt-card--ghost"></section>
      <section class="surface-card section-card receipt-card receipt-card--ghost"></section>
    </section>

    <section v-else-if="merchantOrders.length" class="receipt-grid">
      <section class="surface-card section-card receipt-list-panel">
        <div class="section-head">
          <div>
            <span class="eyebrow">工单列表</span>
            <h2>待回执工单</h2>
          </div>
          <button class="btn btn--ghost btn--small" @click="router.push({ name: 'after-sales-orders', query: { mode: 'mine' } })">
            返回工单页
          </button>
        </div>

        <div class="receipt-list">
          <button
            v-for="item in merchantOrders"
            :key="item.orderId"
            class="receipt-order-item"
            :class="{ active: selectedOrderId === String(item.orderId) }"
            @click="selectMerchantOrder(item)"
          >
            <div class="between-row receipt-order-item__head">
              <span class="eyebrow">{{ item.orderNo || `AS${item.orderId}` }}</span>
              <StatusBadge
                :label="['3', '4'].includes(String(item.status)) ? '已完成' : '未完成'"
                :tone="['3', '4'].includes(String(item.status)) ? 'success' : 'warm'"
              />
            </div>
            <strong>{{ item.productType || '未填写产品类型' }}</strong>
            <p>{{ shortText(item.faultDesc, 66) }}</p>
            <div class="receipt-order-item__meta">
              <span>{{ item.userName || '未知用户' }}</span>
              <span>{{ formatDateTime(item.createTime) }}</span>
            </div>
          </button>
        </div>
      </section>

      <section class="surface-card section-card receipt-detail-panel">
        <div class="section-head">
          <div>
            <span class="eyebrow">工单处理</span>
            <h2>{{ selectedOrder?.productType || '选择工单' }}</h2>
          </div>
        </div>

        <template v-if="selectedOrder">
          <div class="receipt-detail-grid">
            <article class="receipt-detail-card">
              <strong>客户诉求</strong>
              <span>{{ selectedOrderMeta.serviceType || '未填写' }}</span>
              <span>{{ selectedOrderMeta.productName || '未填写' }} / {{ selectedOrderMeta.orderNo || '未填写' }}</span>
            </article>
            <article class="receipt-detail-card">
              <strong>用户信息</strong>
              <span>{{ selectedOrder.userName || '未知用户' }}</span>
              <span>{{ selectedOrder.contactName || '--' }} / {{ selectedOrder.contactPhone || '--' }}</span>
            </article>
            <article class="receipt-detail-card">
              <strong>服务地址</strong>
              <span>{{ selectedOrder.address || '未填写地址' }}</span>
            </article>
            <article class="receipt-detail-card">
              <strong>当前状态</strong>
              <StatusBadge
                :label="['3', '4'].includes(String(selectedOrder.status)) ? '已完成' : '未完成'"
                :tone="['3', '4'].includes(String(selectedOrder.status)) ? 'success' : 'warm'"
              />
            </article>
            <article class="receipt-detail-card">
              <strong>创建时间</strong>
              <span>{{ formatDateTime(selectedOrder.createTime) }}</span>
            </article>
          </div>

          <div v-if="imageList.length" class="receipt-image-list">
            <img v-for="image in imageList" :key="image" :src="image" alt="故障图片" />
          </div>

          <article class="receipt-fault-card">
            <strong>故障描述</strong>
            <p>{{ selectedOrder.faultDesc || '暂无故障描述' }}</p>
          </article>

          <article v-if="selectedOrder.serviceRemark" class="receipt-fault-card">
            <strong>处理意见</strong>
            <p>{{ selectedOrder.serviceRemark }}</p>
          </article>

          <div v-if="isReadonlyReceipt" class="receipt-readonly-box">
            <p>{{ readonlyReceiptContent }}</p>
          </div>

          <div v-else class="receipt-actions-shell">
            <div class="action-row receipt-actions dual-action">
              <button
                class="btn btn--primary"
                :disabled="submitting"
                @click="agreeOrder"
              >
                {{ submitting && !isRejectMode ? '提交中...' : '同意' }}
              </button>
              <button
                class="btn btn--ghost receipt-reject-btn"
                :disabled="submitting"
                @click="toggleRejectMode"
              >
                {{ isRejectMode ? '取消拒绝' : '拒绝' }}
              </button>
            </div>

            <label v-if="isRejectMode" class="receipt-form">
              <span>拒绝原因</span>
              <textarea
                v-model.trim="receiptRemark"
                class="textarea"
                placeholder="请输入拒绝原因"
              ></textarea>
            </label>

            <div v-if="isRejectMode" class="action-row receipt-actions">
              <button
                class="btn btn--primary"
                :disabled="submitting || !trimmedReceiptRemark"
                @click="submitReceipt"
              >
                {{ submitting ? '提交中...' : '提交' }}
              </button>
            </div>
          </div>

          <div class="action-row receipt-actions">
            <button
              class="btn btn--ghost"
              @click="router.push({ name: 'after-sales-orders', query: { mode: 'mine' } })"
            >
              查看我的工单
            </button>
          </div>
        </template>

        <EmptyState
          v-else
          title="请选择工单"
          description="先从左侧选择一个售后工单，再填写本次回执内容。"
        />
      </section>
    </section>

    <EmptyState
      v-else
      title="暂无可回执工单"
      description="当前还没有已接单或维修中的售后工单，先到售后工单页处理接单。"
      action-label="查看售后工单"
      @action="router.push({ name: 'after-sales-orders', query: { mode: 'mine' } })"
    />
  </section>
</template>

<style scoped>
.merchant-receipt-page {
  display: grid;
  gap: 22px;
}

.receipt-hero {
  display: grid;
  grid-template-columns: minmax(0, 1fr) 420px;
  gap: 22px;
  padding: 28px;
}

.receipt-hero h1 {
  margin: 14px 0 8px;
  font-size: clamp(32px, 4vw, 50px);
  line-height: 1.08;
}

.receipt-summary-grid {
  display: grid;
  grid-template-columns: repeat(3, minmax(0, 1fr));
  gap: 14px;
}

.receipt-summary-card {
  padding: 18px;
}

.receipt-summary-card span {
  color: var(--muted);
}

.receipt-summary-card strong {
  display: block;
  margin-top: 10px;
  font-size: 28px;
  color: var(--primary-deep);
}

.receipt-summary-card p {
  margin-top: 10px;
}

.receipt-grid {
  display: grid;
  --receipt-order-card-height: 152px;
  --receipt-order-gap: 14px;
  --receipt-list-visible-height: calc((var(--receipt-order-card-height) * 4) + (var(--receipt-order-gap) * 3));
  grid-template-columns: minmax(340px, 0.95fr) minmax(0, 1.15fr);
  gap: 24px;
  align-items: stretch;
  min-height: 780px;
}

.receipt-card--ghost {
  min-height: 420px;
  background: linear-gradient(90deg, rgba(255, 255, 255, 0.7), rgba(237, 245, 247, 0.88), rgba(255, 255, 255, 0.7));
  background-size: 200% 100%;
  animation: receipt-pulse 1.8s linear infinite;
}

.receipt-list-panel {
  display: flex;
  flex-direction: column;
  min-height: 0;
  height: 100%;
  min-height: 780px;
  overflow: hidden;
}

.receipt-detail-panel {
  display: flex;
  flex-direction: column;
  min-height: 0;
  height: 100%;
  min-height: 780px;
}

.receipt-list {
  display: grid;
  gap: 14px;
  flex: none;
  min-height: var(--receipt-list-visible-height);
  max-height: var(--receipt-list-visible-height);
  overflow-y: auto;
  padding-right: 6px;
}

.receipt-list::-webkit-scrollbar {
  width: 8px;
}

.receipt-list::-webkit-scrollbar-thumb {
  border-radius: 999px;
  background: rgba(17, 117, 101, 0.18);
}

.receipt-list::-webkit-scrollbar-track {
  background: transparent;
}

.receipt-order-item {
  min-height: 152px;
  padding: 18px;
  border-radius: 24px;
  text-align: left;
  background: linear-gradient(180deg, rgba(255, 255, 255, 0.96), rgba(248, 244, 236, 0.96));
  border: 1px solid rgba(17, 61, 77, 0.08);
  transition: transform 0.2s ease, box-shadow 0.2s ease, border-color 0.2s ease;
}

.receipt-order-item:hover,
.receipt-order-item.active {
  transform: translateY(-2px);
  border-color: rgba(18, 105, 93, 0.22);
  box-shadow: 0 20px 42px rgba(17, 61, 77, 0.1);
}

.receipt-order-item strong {
  display: block;
  margin: 10px 0 8px;
  color: var(--primary-deep);
}

.receipt-order-item p {
  margin: 0;
}

.receipt-order-item__meta {
  display: flex;
  flex-wrap: wrap;
  justify-content: space-between;
  gap: 10px;
  margin-top: 12px;
  color: var(--muted);
  font-size: 14px;
}

.receipt-detail-grid {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 14px;
}

.receipt-detail-card,
.receipt-fault-card {
  padding: 16px 18px;
  border-radius: 22px;
  background: linear-gradient(180deg, rgba(255, 255, 255, 0.96), rgba(248, 244, 236, 0.96));
  border: 1px solid rgba(17, 61, 77, 0.08);
}

.receipt-detail-card strong,
.receipt-fault-card strong,
.receipt-form span {
  display: block;
  margin-bottom: 8px;
  color: var(--primary-deep);
}

.receipt-detail-card span {
  display: block;
  color: var(--muted);
}

.receipt-image-list {
  display: flex;
  flex-wrap: wrap;
  gap: 12px;
  margin-top: 18px;
}

.receipt-image-list img {
  width: 112px;
  height: 112px;
  object-fit: cover;
  border-radius: 18px;
}

.receipt-readonly-box {
  margin-top: 18px;
  padding: 18px;
  border-radius: 22px;
  background: linear-gradient(180deg, rgba(255, 255, 255, 0.94), rgba(247, 243, 235, 0.94));
  border: 1px solid rgba(17, 61, 77, 0.08);
}

.receipt-readonly-box p {
  margin: 0;
}

.receipt-fault-card {
  margin-top: 18px;
}

.receipt-fault-card p {
  margin: 0;
}

.receipt-form {
  display: grid;
  gap: 8px;
  margin-top: 18px;
}

.receipt-form span {
  font-size: 14px;
  font-weight: 700;
}

.receipt-actions {
  margin-top: 18px;
}

.receipt-actions-shell {
  margin-top: 18px;
}

.dual-action {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
}

.receipt-reject-btn {
  border-color: rgba(193, 75, 45, 0.16);
  color: var(--danger);
}

@keyframes receipt-pulse {
  to {
    background-position: -200% 0;
  }
}

@media (max-width: 980px) {
  .receipt-hero,
  .receipt-grid,
  .receipt-summary-grid {
    grid-template-columns: 1fr;
  }

  .receipt-grid {
    min-height: auto;
  }
}

@media (max-width: 720px) {
  .receipt-hero,
  .receipt-detail-grid {
    grid-template-columns: 1fr;
  }

  .receipt-hero {
    padding: 18px;
  }
}
</style>
