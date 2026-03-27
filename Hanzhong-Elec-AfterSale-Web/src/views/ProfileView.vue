<script setup>
import { computed, onMounted, ref } from 'vue'
import { RouterLink, useRouter } from 'vue-router'
import EmptyState from '@/components/EmptyState.vue'
import StatusBadge from '@/components/StatusBadge.vue'
import { userApi } from '@/lib/api'
import {
  MERCHANT_AUDIT_STATUS,
  getRoleLabel,
  getRoleState,
  getStatusMeta
} from '@/lib/domain'
import { fetchMerchantDashboardSummary, merchantFeatureSupport } from '@/lib/merchantDashboard'
import { pushNotice } from '@/lib/notice'
import { session } from '@/lib/session'

const router = useRouter()

const loading = ref(false)
const metrics = ref([])
const merchantSummary = ref(null)

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
      { title: '待接售后', value: counts.pendingAfterSales || 0, desc: '等待商家接单的新售后工单' },
      { title: '处理中售后', value: counts.activeAfterSales || 0, desc: '已接单或维修中的工单' },
      { title: '已完成工单', value: counts.completedAfterSales || 0, desc: '已经提交回执并完工的工单' },
      {
        title: '审核状态',
        value: getStatusMeta(MERCHANT_AUDIT_STATUS, merchantInfo.value?.auditStatus).label,
        desc: '网页端已按当前后端能力自动收敛商家功能'
      }
    ]
  }

  if (roleState.value.isPendingMerchant) {
    return [
      {
        title: '审核状态',
        value: getStatusMeta(MERCHANT_AUDIT_STATUS, merchantInfo.value?.auditStatus).label,
        desc: '审核通过前仍按普通用户模式使用网页端'
      },
      { title: '店铺名称', value: merchantInfo.value?.merchantName || '--', desc: '注册时提交的商家名称' },
      { title: '联系电话', value: merchantInfo.value?.contactPhone || '--', desc: '用于平台联系和门店展示' }
    ]
  }

  return metrics.value
})

const quickLinks = computed(() => {
  if (roleState.value.isPendingMerchant) {
    return [
      { label: '店铺信息', to: { name: 'merchant-settings' } },
      { label: '购物车', to: { name: 'cart' } },
      { label: '地址簿', to: { name: 'addresses' } },
      { label: '浏览商家', to: { name: 'merchants' } },
      { label: '返回首页', to: { name: 'home' } }
    ]
  }

  return [
    { label: '购物车', to: { name: 'cart' } },
    { label: '地址簿', to: { name: 'addresses' } },
    { label: '配件订单', to: { name: 'orders' } },
    { label: '售后订单', to: { name: 'after-sales-orders' } },
    { label: '配件商城', to: { name: 'mall' } }
  ]
})

const merchantAfterSalesLinks = [
  { label: '待接售后', desc: '查看等待当前商家接单的工单', to: { name: 'after-sales-orders', query: { mode: 'pending' } } },
  { label: '我的工单', desc: '查看已接单和处理中工单', to: { name: 'after-sales-orders', query: { mode: 'mine' } } },
  { label: '售后回执', desc: '填写检测结果、维修进度和完工说明', to: { name: 'after-sales-apply' } }
]

const merchantServiceLinks = computed(() => [
  { label: '店铺设置', desc: '维护店铺资料和服务范围', to: { name: 'merchant-settings' } },
  { label: '商家工作台', desc: '返回商家工作台入口', to: { name: 'cart' } },
  { label: '我的店铺', desc: '查看当前门店展示详情', to: merchantStoreLink.value },
  { label: '配件商城', desc: '浏览公开配件数据，不进入商家管理模式', to: { name: 'mall' } }
])

const pendingMerchantMessage = computed(() => {
  const merchantName = merchantInfo.value?.merchantName
  if (merchantName) {
    return `已提交 ${merchantName} 的入驻资料，审核通过前可继续按普通用户模式使用网页端。`
  }
  return '已提交商家入驻资料，审核通过前可继续按普通用户模式使用网页端。'
})

async function loadMetrics() {
  if (!session.token) {
    return
  }

  loading.value = true
  try {
    if (roleState.value.isMerchant) {
      merchantSummary.value = await fetchMerchantDashboardSummary()
      session.merchant = merchantSummary.value?.merchant || session.merchant
      return
    }

    if (roleState.value.isPendingMerchant) {
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
              :tone="roleState.isMerchant ? 'success' : roleState.isPendingMerchant ? 'warm' : 'brand'"
            />
          </div>

          <h1>{{ session.appUser?.nickName || session.appUser?.phone || '当前用户' }}</h1>
          <p>手机号 {{ session.appUser?.phone || '--' }}，这里会根据当前账号身份切换普通用户或商家快捷入口。</p>

          <div v-if="merchantInfo" class="profile-merchant-inline">
            <strong>{{ merchantInfo.merchantName || '未命名门店' }}</strong>
            <span>{{ merchantInfo.contactPhone || '--' }}</span>
            <StatusBadge v-bind="getStatusMeta(MERCHANT_AUDIT_STATUS, merchantInfo.auditStatus)" />
          </div>
        </div>
      </section>

      <section v-if="roleState.isPendingMerchant" class="surface-card pending-banner">
        <div class="between-row pending-banner__head">
          <strong>商家入驻审核中</strong>
          <StatusBadge v-bind="getStatusMeta(MERCHANT_AUDIT_STATUS, merchantInfo?.auditStatus)" />
        </div>
        <p>{{ pendingMerchantMessage }}</p>
      </section>

      <section class="surface-card section-card">
        <div class="section-head">
          <div>
            <span class="eyebrow">账号概览</span>
            <h2>{{ roleState.isMerchant ? '商家数据概览' : roleState.isPendingMerchant ? '入驻概览' : '账号概览' }}</h2>
            <p v-if="roleState.isMerchant">这里只展示后端当前真实支持的商家售后和店铺资料能力。</p>
            <p v-else-if="roleState.isPendingMerchant">待审核商家仍可继续以普通用户模式浏览和下单。</p>
            <p v-else>按当前普通用户账号展示售后、订单和收藏统计。</p>
          </div>
        </div>

        <div class="profile-metrics">
          <article v-for="item in metricCards" :key="item.title" class="profile-metric-card">
            <span>{{ item.title }}</span>
            <strong>{{ item.value }}</strong>
            <p>{{ item.desc }}</p>
          </article>
        </div>

        <div v-if="loading" class="profile-loading">正在同步统计数据...</div>
      </section>

      <template v-if="roleState.isMerchant">
        <section class="profile-grid">
          <section class="surface-card section-card">
            <div class="section-head">
              <div>
                <span class="eyebrow">售后订单</span>
                <h2>售后订单入口</h2>
                <p>和小程序商家模式一致，保留待接单、我的工单和售后回执三个主入口。</p>
              </div>
            </div>

            <div class="profile-links">
              <RouterLink v-for="item in merchantAfterSalesLinks" :key="item.label" class="profile-link-card" :to="item.to">
                <strong>{{ item.label }}</strong>
                <span>{{ item.desc }}</span>
              </RouterLink>
            </div>
          </section>

          <section class="surface-card section-card">
            <div class="section-head">
              <div>
                <span class="eyebrow">商家后台</span>
                <h2>商家后台入口</h2>
                <p>店铺设置、工作台和店铺展示在这里统一汇总。</p>
              </div>
            </div>

            <div class="profile-links">
              <RouterLink v-for="item in merchantServiceLinks" :key="item.label" class="profile-link-card" :to="item.to">
                <strong>{{ item.label }}</strong>
                <span>{{ item.desc }}</span>
              </RouterLink>
            </div>
          </section>
        </section>

        <section class="surface-card section-card">
          <div class="section-head">
            <div>
              <span class="eyebrow">接口适配</span>
              <h2>网页端当前已静默降级</h2>
              <p>后端未开放的商家页面已从主要入口移除，避免继续触发不存在的接口。</p>
            </div>
          </div>

          <div class="admin-grid">
            <article class="admin-card">
              <strong>已保留</strong>
              <span>商家信息、待接售后、我的工单、回执提交、店铺资料维护。</span>
            </article>
            <article class="admin-card" v-if="!merchantFeatureSupport.accessoryOrders">
              <strong>配件订单</strong>
              <span>后端当前没有商家配件订单接口，网页端已隐藏相关入口。</span>
            </article>
            <article class="admin-card" v-if="!merchantFeatureSupport.accessoryCatalog">
              <strong>商品管理</strong>
              <span>后端当前没有商家商品管理接口，网页端保留公共配件浏览，不再进入管理模式。</span>
            </article>
          </div>
        </section>
      </template>

      <section v-else class="surface-card section-card">
        <div class="section-head">
          <div>
            <span class="eyebrow">快捷入口</span>
            <h2>快捷入口</h2>
            <p>常用业务入口集中在这里，方便快速切换。</p>
          </div>
        </div>

        <div class="profile-links">
          <RouterLink v-for="item in quickLinks" :key="item.label" class="profile-link-card" :to="item.to">
            <strong>{{ item.label }}</strong>
            <span>进入对应业务页面</span>
          </RouterLink>
        </div>
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
  .admin-grid {
    grid-template-columns: repeat(2, minmax(0, 1fr));
  }
}

@media (max-width: 980px) {
  .profile-hero,
  .profile-grid,
  .profile-metrics,
  .admin-grid {
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
