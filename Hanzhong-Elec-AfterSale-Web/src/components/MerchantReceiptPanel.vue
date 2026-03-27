<script setup>
import { computed, onMounted, ref, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import EmptyState from '@/components/EmptyState.vue'
import StatusBadge from '@/components/StatusBadge.vue'
import { apiBaseUrl, merchantApi } from '@/lib/api'
import { AFTER_SALES_STATUS, formatDateTime, getStatusMeta, resolveImage, safeRows, shortText } from '@/lib/domain'
import { pushNotice } from '@/lib/notice'

const emit = defineEmits(['updated'])

const route = useRoute()
const router = useRouter()

const loading = ref(false)
const submitting = ref(false)
const merchantOrders = ref([])
const selectedOrderId = ref('')
const receiptRemark = ref('')

const summaryCards = computed(() => {
  const acceptedCount = merchantOrders.value.filter(item => String(item.status) === '1').length
  const repairingCount = merchantOrders.value.filter(item => String(item.status) === '2').length
  const completedCount = merchantOrders.value.filter(item => String(item.status) === '3').length

  return [
    { label: '已接单', value: acceptedCount, desc: '等待填写检测或开修回执' },
    { label: '维修中', value: repairingCount, desc: '处理中的工单可补充完工回执' },
    { label: '已完成', value: completedCount, desc: '已提交完工回执的工单' }
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

const actionConfig = computed(() => {
  const status = String(selectedOrder.value?.status || '')
  if (status === '1') {
    return {
      label: '提交回执并开始维修',
      nextStatus: '2',
      successMessage: '回执已提交，工单已进入维修中'
    }
  }

  if (status === '2') {
    return {
      label: '提交回执并完成订单',
      nextStatus: '3',
      successMessage: '完工回执已提交，工单已完成'
    }
  }

  return {
    label: '当前状态无需提交回执',
    nextStatus: '',
    successMessage: ''
  }
})

function getDefaultRemark(order) {
  if (!order) {
    return ''
  }
  if (String(order.status) === '2') {
    return ''
  }
  return order.serviceRemark || ''
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
    const payload = await merchantApi.listOrders({
      pageNum: 1,
      pageSize: 50
    })
    merchantOrders.value = safeRows(payload).filter(item => ['1', '2', '3'].includes(String(item.status)))
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

async function submitReceipt() {
  if (!selectedOrder.value || !actionConfig.value.nextStatus || submitting.value) {
    return
  }

  const remark = receiptRemark.value.trim()
  if (!remark) {
    pushNotice('请先填写回执内容', 'danger')
    return
  }

  if (actionConfig.value.nextStatus === '3' && remark === String(selectedOrder.value.serviceRemark || '').trim()) {
    pushNotice('请填写本次完工回执后再完成工单', 'danger')
    return
  }

  submitting.value = true
  try {
    await merchantApi.updateOrderStatus({
      orderId: selectedOrder.value.orderId,
      status: actionConfig.value.nextStatus,
      serviceRemark: remark
    })
    pushNotice(actionConfig.value.successMessage, 'success')
    emit('updated')
    await loadMerchantOrders()
  } catch (error) {
    pushNotice(error.message || '售后回执提交失败', 'danger')
  } finally {
    submitting.value = false
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
        <p>按小程序商家模式提供检测、维修进展和完工回执入口，直接推动工单状态流转。</p>
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
      <section class="surface-card section-card">
        <div class="section-head">
          <div>
            <span class="eyebrow">工单列表</span>
            <h2>待回执工单</h2>
            <p>只显示已接单、维修中和已完成的工单，便于商家补充回执记录。</p>
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
              <StatusBadge v-bind="getStatusMeta(AFTER_SALES_STATUS, item.status)" />
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

      <section class="surface-card section-card">
        <div class="section-head">
          <div>
            <span class="eyebrow">回执内容</span>
            <h2>{{ selectedOrder?.productType || '选择工单后填写回执' }}</h2>
            <p>回执会同步写入当前售后工单，网页端和小程序端都能看到同一条处理记录。</p>
          </div>
        </div>

        <template v-if="selectedOrder">
          <div class="receipt-detail-grid">
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
              <StatusBadge v-bind="getStatusMeta(AFTER_SALES_STATUS, selectedOrder.status)" />
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
            <strong>最近回执</strong>
            <p>{{ selectedOrder.serviceRemark }}</p>
          </article>

          <label class="receipt-form">
            <span>本次回执</span>
            <textarea
              v-model.trim="receiptRemark"
              class="textarea"
              placeholder="请输入检测结果、维修进展、备件更换情况或完工说明"
            ></textarea>
          </label>

          <div class="action-row receipt-actions">
            <button
              class="btn btn--primary"
              :disabled="!actionConfig.nextStatus || submitting"
              @click="submitReceipt"
            >
              {{ submitting ? '提交中...' : actionConfig.label }}
            </button>
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
  grid-template-columns: minmax(340px, 0.95fr) minmax(0, 1.15fr);
  gap: 24px;
}

.receipt-card--ghost {
  min-height: 420px;
  background: linear-gradient(90deg, rgba(255, 255, 255, 0.7), rgba(237, 245, 247, 0.88), rgba(255, 255, 255, 0.7));
  background-size: 200% 100%;
  animation: receipt-pulse 1.8s linear infinite;
}

.receipt-list {
  display: grid;
  gap: 14px;
}

.receipt-order-item {
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
