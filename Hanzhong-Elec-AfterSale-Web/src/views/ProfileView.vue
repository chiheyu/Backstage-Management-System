<script setup>
import { computed, onMounted, ref } from 'vue'
import { RouterLink, useRouter } from 'vue-router'
import EmptyState from '@/components/EmptyState.vue'
import StatusBadge from '@/components/StatusBadge.vue'
import { merchantApi, userApi } from '@/lib/api'
import {
  MERCHANT_AUDIT_STATUS,
  getRoleLabel,
  getRoleState,
  getStatusMeta
} from '@/lib/domain'
import { fetchMerchantDashboardSummary } from '@/lib/merchantDashboard'
import { pushNotice } from '@/lib/notice'
import { session } from '@/lib/session'

const router = useRouter()

const loading = ref(false)
const metrics = ref([])
const merchantSummary = ref(null)
const merchantStats = ref(null)

const roleState = computed(() => getRoleState(session.roleType))
const merchantInfo = computed(() => merchantSummary.value?.merchant || session.merchant || null)
const merchantStoreLink = computed(() => {
  const merchantId = merchantInfo.value?.merchantId
  if (merchantId) {
    return { name: 'merchant-detail', params: { id: merchantId } }
  }
  return { name: 'merchant-settings' }
})

const metricCards = computed(() => {
  if (roleState.value.isMerchant) {
    const counts = merchantSummary.value?.counts || {}
    return [
      { title: '未完成工单', value: counts.pendingAfterSales || 0, desc: '等待商家给出处理意见的售后工单' },
      { title: '已处理工单', value: counts.activeAfterSales || 0, desc: '商家已经提交同意或拒绝意见的工单' },
      { title: '已完成工单', value: counts.completedAfterSales || 0, desc: '已经处理完成的售后工单' },
      {
        title: '审核状态',
        value: getStatusMeta(MERCHANT_AUDIT_STATUS, merchantInfo.value?.auditStatus).label,
        desc: '网页端已按当前后端能力自动收敛商家功能'
      }
    ]
  }

  return metrics.value
})

const quickLinks = computed(() => {
  return [
    { label: '购物车', to: { name: 'cart' } },
    { label: '地址簿', to: { name: 'addresses' } },
    { label: '配件订单', to: { name: 'orders' } },
    { label: '售后订单', to: { name: 'after-sales-orders' } },
    { label: '配件商城', to: { name: 'mall' } }
  ]
})

const merchantAfterSalesLinks = [
  { label: '未完成售后', desc: '查看仍待商家处理意见的工单', to: { name: 'after-sales-orders', query: { type: 'pending' } } },
  { label: '全部售后工单', desc: '查看全部售后工单与处理结果', to: { name: 'after-sales-orders', query: { type: 'all' } } },
  { label: '售后处理', desc: '进入同意 / 拒绝处理面板', to: { name: 'after-sales-apply' } }
]

const merchantServiceLinks = computed(() => [
  { label: '商品管理', desc: '维护商品、库存、上下架状态和图片', to: { name: 'merchant-accessories' } },
  { label: '配件订单', desc: '处理商城订单的发货、完成和取消', to: { name: 'merchant-accessory-orders' } },
  { label: '店铺设置', desc: '维护店铺资料和服务范围', to: { name: 'merchant-settings' } },
  { label: '商家工作台', desc: '返回商家工作台入口', to: { name: 'cart' } },
  { label: '我的店铺', desc: '查看当前门店展示详情', to: merchantStoreLink.value }
])

async function loadMetrics() {
  if (!session.token) {
    return
  }

  loading.value = true
  try {
    if (roleState.value.isMerchant) {
      const [summary, stats] = await Promise.all([
        fetchMerchantDashboardSummary(),
        merchantApi.stats()
      ])
      merchantSummary.value = summary
      merchantStats.value = stats
      session.merchant = merchantSummary.value?.merchant || session.merchant
      return
    }

    const [afterSalesPayload, ordersPayload, favoritesPayload] = await Promise.all([
      userApi.listAfterSalesOrders({ pageNum: 1, pageSize: 1 }),
      userApi.listAccessoryOrders({ pageNum: 1, pageSize: 1 }),
      userApi.listAccessoryCollections({ pageNum: 1, pageSize: 1 })
    ])
    metrics.value = [
      { title: '售后订单', value: Number(afterSalesPayload?.total || 0), desc: '提交过的售后申请数量' },
      { title: '配件订单', value: Number(ordersPayload?.total || 0), desc: '商城下单后的订单总数' },
      { title: '商品收藏', value: Number(favoritesPayload?.total || 0), desc: '收藏夹里的配件数量' }
    ]
    merchantStats.value = null
  } catch (error) {
    pushNotice(error.message || '个人中心数据加载失败', 'danger')
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  loadMetrics()
})
</script>

<template>
  <section class="page-shell profile-page">
    <EmptyState
      v-if="!session.token"
      title="还没有登录"
      description="登录后即可查看当前身份、订单统计和快捷入口。"
      action-label="前往登录"
      @action="router.push({ name: 'auth' })"
    />

    <template v-else>
      <section class="glass-card profile-hero">
        <div class="profile-avatar">
          {{ (session.appUser?.nickName || '访客').slice(0, 1).toUpperCase() }}
        </div>

        <div class="surface-card profile-main">
          <div class="between-row profile-main__top">
            <span class="eyebrow">个人中心</span>
            <StatusBadge
              :label="getRoleLabel(session.roleType)"
              :tone="roleState.isMerchant ? 'success' : 'brand'"
            />
          </div>

          <h1>{{ session.appUser?.nickName || session.appUser?.phone || '当前用户' }}</h1>
      
          <div v-if="merchantInfo" class="profile-merchant-inline">
            <strong>{{ merchantInfo.merchantName || '未命名门店' }}</strong>
            <span>{{ merchantInfo.contactPhone || '--' }}</span>
            <StatusBadge v-bind="getStatusMeta(MERCHANT_AUDIT_STATUS, merchantInfo.auditStatus)" />
          </div>
        </div>
      </section>

      <section class="surface-card section-card">
        <div class="section-head">
          <div>
            <span class="eyebrow">账号概览</span>
            <h2>{{ roleState.isMerchant ? '商家数据概览' : '账号概览' }}</h2>
          </div>
        </div>

        <div class="profile-metrics">
          <article v-for="item in metricCards" :key="item.title" class="profile-metric-card">
            <span>{{ item.title }}</span>
            <strong>{{ item.value }}</strong>
            <p>{{ item.desc }}</p>
          </article>
        </div>
      </section>

      <section v-if="roleState.isMerchant && merchantStats" class="surface-card section-card">
        <div class="section-head">
          <div>
            <span class="eyebrow">数据统计</span>
            <h2>数据统计</h2>
            <p>直接展示和小程序商家端一致的今日统计、类型占比与近 7 天趋势。</p>
          </div>
        </div>

        <div class="profile-metrics profile-metrics--stats">
          <article class="profile-metric-card">
            <span>今日待发货</span>
            <strong>{{ merchantStats.todayPendingShipment || 0 }}</strong>
            <p>今天新增且尚未发货的配件订单</p>
          </article>
          <article class="profile-metric-card">
            <span>今日已发货</span>
            <strong>{{ merchantStats.todayShipped || 0 }}</strong>
            <p>今天已推进到发货或完成状态的配件订单</p>
          </article>
          <article class="profile-metric-card">
            <span>今日待处理售后</span>
            <strong>{{ merchantStats.todayPendingAfterSale || 0 }}</strong>
            <p>今天仍待给出处理意见的售后工单</p>
          </article>
          <article class="profile-metric-card">
            <span>今日已处理售后</span>
            <strong>{{ merchantStats.todayCompletedAfterSale || 0 }}</strong>
            <p>今天已处理完成的售后工单</p>
          </article>
        </div>

        <section class="profile-stats-grid">
          <article class="profile-stats-card">
            <strong>本月总量</strong>
            <span>{{ merchantStats.monthTotal || 0 }}</span>
            <p>配件订单与售后处理合并统计</p>
          </article>

          <article class="profile-stats-card">
            <strong>售后类型占比</strong>
            <div class="stats-ratio-list">
              <div v-for="item in merchantStats.typeRatio || []" :key="item.name" class="stats-ratio-item">
                <div class="stats-ratio-left">
                  <span class="stats-ratio-dot" :style="{ backgroundColor: item.color || '#117565' }"></span>
                  <span>{{ item.name }}</span>
                </div>
                <strong>{{ item.ratio }}</strong>
              </div>
            </div>
          </article>
        </section>

        <section class="profile-trend-card">
          <div class="section-head section-head--compact">
            <div>
              <span class="eyebrow">近 7 天</span>
              <h2>处理趋势</h2>
            </div>
          </div>
          <div class="profile-trend-list">
            <div
              v-for="item in merchantStats.weekTrend || []"
              :key="item.date"
              class="profile-trend-item"
            >
              <span class="profile-trend-date">{{ item.date }}</span>
              <div class="profile-trend-bar-wrap">
                <div
                  class="profile-trend-bar"
                  :style="{ height: `${Math.max(Number(item.value || 0) * 10, 10)}px` }"
                ></div>
              </div>
              <strong>{{ item.value }}</strong>
            </div>
          </div>
        </section>
      </section>
    </template>
  </section>
</template>

<style scoped>
.profile-page {
  display: grid;
  gap: 22px;
}

.profile-hero {
  display: grid;
  grid-template-columns: 160px minmax(0, 1fr);
  gap: 24px;
  padding: 28px;
}

.profile-avatar {
  display: flex;
  align-items: center;
  justify-content: center;
  min-height: 160px;
  border-radius: 36px;
  background: linear-gradient(135deg, var(--accent), #d97706);
  color: #fff;
  font-size: 58px;
  font-weight: 800;
}

.profile-main {
  padding: 24px;
}

.profile-main h1 {
  margin: 0 0 10px;
  font-size: clamp(30px, 4vw, 46px);
  line-height: 1.08;
}

.profile-main__top {
  margin-bottom: 16px;
}

.profile-merchant-inline {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: 12px;
  margin-top: 22px;
  padding: 16px 18px;
  border-radius: 22px;
  background: rgba(255, 255, 255, 0.72);
  border: 1px solid rgba(17, 61, 77, 0.08);
}

.pending-banner {
  padding: 22px 24px;
}

.pending-banner__head strong {
  color: var(--primary-deep);
}

.pending-banner p {
  margin: 10px 0 0;
}

.profile-grid {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 24px;
}

.profile-metrics {
  display: grid;
  grid-template-columns: repeat(4, minmax(0, 1fr));
  gap: 16px;
}

.profile-metrics--stats {
  margin-bottom: 18px;
}

.profile-metric-card {
  padding: 18px;
  border-radius: 22px;
  background: linear-gradient(180deg, rgba(255, 255, 255, 0.94), rgba(248, 244, 236, 0.94));
  border: 1px solid rgba(17, 61, 77, 0.08);
}

.profile-metric-card span {
  display: block;
  color: var(--muted);
  margin-bottom: 8px;
}

.profile-metric-card strong {
  display: block;
  font-size: 26px;
  color: var(--primary-deep);
}

.profile-loading {
  margin-top: 16px;
  color: var(--muted);
}

.profile-stats-grid {
  display: grid;
  grid-template-columns: minmax(220px, 0.7fr) minmax(0, 1.3fr);
  gap: 16px;
  margin-bottom: 18px;
}

.profile-stats-card {
  padding: 18px;
  border-radius: 22px;
  background: linear-gradient(180deg, rgba(255, 255, 255, 0.94), rgba(248, 244, 236, 0.94));
  border: 1px solid rgba(17, 61, 77, 0.08);
}

.profile-stats-card strong {
  display: block;
  margin-bottom: 10px;
  color: var(--primary-deep);
}

.profile-stats-card > span {
  display: block;
  font-size: 30px;
  color: var(--accent-deep);
  font-weight: 700;
}

.profile-stats-card > p {
  margin-top: 10px;
  color: var(--muted);
}

.stats-ratio-list {
  display: grid;
  gap: 12px;
}

.stats-ratio-item {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
}

.stats-ratio-left {
  display: inline-flex;
  align-items: center;
  gap: 10px;
  color: var(--muted);
}

.stats-ratio-dot {
  width: 10px;
  height: 10px;
  border-radius: 999px;
}

.profile-trend-card {
  padding: 18px;
  border-radius: 22px;
  background: linear-gradient(180deg, rgba(255, 255, 255, 0.94), rgba(248, 244, 236, 0.94));
  border: 1px solid rgba(17, 61, 77, 0.08);
}

.section-head--compact {
  margin-bottom: 14px;
}

.profile-trend-list {
  display: grid;
  grid-template-columns: repeat(7, minmax(0, 1fr));
  gap: 12px;
  align-items: end;
}

.profile-trend-item {
  display: grid;
  justify-items: center;
  gap: 8px;
}

.profile-trend-date {
  font-size: 12px;
  color: var(--muted);
}

.profile-trend-bar-wrap {
  width: 100%;
  min-height: 120px;
  display: flex;
  align-items: end;
  justify-content: center;
}

.profile-trend-bar {
  width: 32px;
  min-height: 10px;
  border-radius: 999px 999px 10px 10px;
  background: linear-gradient(180deg, var(--accent), var(--primary));
}

.profile-links,
.admin-grid {
  display: grid;
  gap: 14px;
}

.admin-grid {
  grid-template-columns: repeat(4, minmax(0, 1fr));
}

.profile-link-card,
.admin-card {
  display: block;
  padding: 18px;
  border-radius: 22px;
  background: linear-gradient(180deg, rgba(255, 255, 255, 0.94), rgba(248, 244, 236, 0.94));
  border: 1px solid rgba(17, 61, 77, 0.08);
}

.profile-link-card strong,
.admin-card strong {
  display: block;
  margin-bottom: 8px;
  color: var(--primary-deep);
}

.profile-link-card span,
.admin-card span {
  color: var(--muted);
}

@media (max-width: 1080px) {
  .profile-metrics,
  .admin-grid,
  .profile-stats-grid {
    grid-template-columns: repeat(2, minmax(0, 1fr));
  }
}

@media (max-width: 980px) {
  .profile-hero,
  .profile-grid,
  .profile-metrics,
  .admin-grid,
  .profile-stats-grid,
  .profile-trend-list {
    grid-template-columns: 1fr;
  }
}

@media (max-width: 720px) {
  .profile-hero {
    padding: 18px;
  }

  .profile-main__top {
    display: grid;
  }
}
</style>
