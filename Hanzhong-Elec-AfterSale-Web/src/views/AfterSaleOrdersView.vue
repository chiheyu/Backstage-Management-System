<script setup>
import { computed, onMounted, reactive, ref, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import EmptyState from '@/components/EmptyState.vue'
import StatusBadge from '@/components/StatusBadge.vue'
import { merchantApi, userApi } from '@/lib/api'
import {
  AFTER_SALES_STATUS,
  formatDateTime,
  getRoleState,
  getStatusMeta,
  safeRows,
  shortText
} from '@/lib/domain'
import { pushNotice } from '@/lib/notice'
import { session } from '@/lib/session'

const route = useRoute()
const router = useRouter()

const loading = ref(false)
const merchantTab = ref(route.query.mode === 'mine' ? 'mine' : 'pending')
const userOrders = ref([])
const pendingOrders = ref([])
const merchantOrders = ref([])
const remarkDraft = reactive({})

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
    return merchantTab.value === 'pending' ? '待接单工单' : '我的处理工单'
  }
  return '我的售后订单'
})

const activeList = computed(() => {
  if (roleState.value.isMerchant) {
    return merchantTab.value === 'pending' ? pendingOrders.value : merchantOrders.value
  }
  return userOrders.value
})

async function loadOrders() {
  if (!session.token) {
    return
  }

  loading.value = true
  try {
    if (roleState.value.isMerchant) {
      const [pendingPayload, minePayload] = await Promise.all([
        merchantApi.listPendingOrders({
          orderNo: filters.orderNo,
          productType: filters.productType,
          pageNum: 1,
          pageSize: 30
        }),
        merchantApi.listOrders({
          orderNo: filters.orderNo,
          productType: filters.productType,
          status: filters.status,
          pageNum: 1,
          pageSize: 30
        })
      ])
      pendingOrders.value = safeRows(pendingPayload)
      merchantOrders.value = safeRows(minePayload)
    } else if (roleState.value.isUser) {
      const payload = await userApi.listAfterSalesOrders({
        orderNo: filters.orderNo,
        productType: filters.productType,
        status: filters.status,
        pageNum: 1,
        pageSize: 30
      })
      userOrders.value = safeRows(payload)
    }
  } catch (error) {
    pushNotice(error.message || '售后订单加载失败', 'danger')
  } finally {
    loading.value = false
  }
}

function canUserCancel(order) {
  return !['3', '4'].includes(String(order.status))
}

function nextMerchantActions(order) {
  const status = String(order.status)
  if (status === '1') {
    return [{ label: '标记维修中', value: '2', tone: 'primary' }, { label: '取消工单', value: '4', tone: 'ghost' }]
  }
  if (status === '2') {
    return [{ label: '标记已完成', value: '3', tone: 'primary' }, { label: '取消工单', value: '4', tone: 'ghost' }]
  }
  return []
}

async function handleTakeOrder(orderId) {
  try {
    await merchantApi.takeOrder(orderId)
    pushNotice('接单成功，已进入我的处理工单', 'success')
    merchantTab.value = 'mine'
    await loadOrders()
  } catch (error) {
    pushNotice(error.message || '接单失败', 'danger')
  }
}

async function handleMerchantStatus(order, status) {
  try {
    await merchantApi.updateOrderStatus({
      orderId: order.orderId,
      status,
      serviceRemark: remarkDraft[order.orderId] || order.serviceRemark || ''
    })
    pushNotice('工单状态已更新', 'success')
    await loadOrders()
  } catch (error) {
    pushNotice(error.message || '状态更新失败', 'danger')
  }
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

watch(
  () => route.query.mode,
  value => {
    if (roleState.value.isMerchant) {
      merchantTab.value = value === 'mine' ? 'mine' : 'pending'
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

    <EmptyState
      v-else-if="roleState.isPendingMerchant"
      title="商家账号正在审核中"
      description="审核通过后，网页端会自动开放接单与工单流转能力。"
      action-label="查看店铺信息"
      @action="router.push({ name: 'merchant-settings' })"
    />

    <template v-else>
      <section class="glass-card order-hero">
        <div>
          <span class="eyebrow">售后工单</span>
          <h1>{{ pageTitle }}</h1>
          <p v-if="roleState.isMerchant">查看待接单与处理中工单，及时更新维修进度和处理备注。</p>
          <p v-else>跟踪售后申请状态，必要时可在未完成前取消订单。</p>
        </div>

        <div v-if="roleState.isMerchant" class="status-filter">
          <button
            class="status-filter__item"
            :class="{ active: merchantTab === 'pending' }"
            @click="merchantTab = 'pending'"
          >
            待接单
          </button>
          <button
            class="status-filter__item"
            :class="{ active: merchantTab === 'mine' }"
            @click="merchantTab = 'mine'"
          >
            我的工单
          </button>
        </div>
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
          </div>

          <label v-if="roleState.isMerchant && merchantTab === 'mine'" class="order-remark">
            <span>处理备注</span>
            <textarea
              v-model.trim="remarkDraft[order.orderId]"
              class="textarea"
              :placeholder="order.serviceRemark || '可填写维修说明、检测结果、交付备注等'"
            ></textarea>
          </label>
          <p v-else-if="order.serviceRemark" class="order-service-remark">
            <strong>处理备注：</strong>{{ order.serviceRemark }}
          </p>

          <div class="action-row">
            <button
              v-if="roleState.isMerchant && merchantTab === 'pending'"
              class="btn btn--primary btn--small"
              @click="handleTakeOrder(order.orderId)"
            >
              立即接单
            </button>

            <template v-if="roleState.isMerchant && merchantTab === 'mine'">
              <button
                v-for="action in nextMerchantActions(order)"
                :key="action.value"
                class="btn btn--small"
                :class="action.tone === 'primary' ? 'btn--primary' : 'btn--ghost'"
                @click="handleMerchantStatus(order, action.value)"
              >
                {{ action.label }}
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

.order-meta-grid strong,
.order-remark span {
  display: block;
  margin-bottom: 6px;
}

.order-remark {
  display: grid;
  gap: 8px;
}

.order-remark span {
  font-size: 14px;
  font-weight: 700;
  color: var(--primary-deep);
}

.order-service-remark {
  margin: 0 0 14px;
}

@keyframes order-pulse {
  to {
    background-position: -200% 0;
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
