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
import { pushNotice } from '@/lib/notice'
import { session } from '@/lib/session'

const router = useRouter()

const loading = ref(false)
const metrics = ref([])

const roleState = computed(() => getRoleState(session.roleType))

const quickLinks = computed(() => {
  if (roleState.value.isMerchant) {
    return [
      { label: '待接工单', to: { name: 'after-sales-orders' } },
      { label: '我的工单', to: { name: 'after-sales-orders', query: { mode: 'mine' } } },
      { label: '店铺设置', to: { name: 'merchant-settings' } }
    ]
  }

  if (roleState.value.isPendingMerchant) {
    return [
      { label: '店铺信息', to: { name: 'merchant-settings' } },
      { label: '浏览商家', to: { name: 'merchants' } },
      { label: '返回首页', to: { name: 'home' } }
    ]
  }

  return [
    { label: '配件订单', to: { name: 'orders' } },
    { label: '售后订单', to: { name: 'after-sales-orders' } },
    { label: '配件商城', to: { name: 'mall' } }
  ]
})

async function loadMetrics() {
  if (!session.token) {
    return
  }

  loading.value = true
  try {
    if (roleState.value.isMerchant) {
      const [pendingPayload, minePayload] = await Promise.all([
        merchantApi.listPendingOrders({ pageNum: 1, pageSize: 1 }),
        merchantApi.listOrders({ pageNum: 1, pageSize: 1 })
      ])
      metrics.value = [
        { title: '待接工单', value: Number(pendingPayload?.total || 0), desc: '可立即接单的售后请求' },
        { title: '处理中的工单', value: Number(minePayload?.total || 0), desc: '当前商家名下的全部工单' },
        { title: '店铺名称', value: session.merchant?.merchantName || '--', desc: '当前登录商家资料' }
      ]
      return
    }

    if (roleState.value.isPendingMerchant) {
      metrics.value = [
        { title: '审核状态', value: getStatusMeta(MERCHANT_AUDIT_STATUS, session.merchant?.auditStatus).label, desc: '等待后台审核通过后开放接单' },
        { title: '店铺名称', value: session.merchant?.merchantName || '--', desc: '注册时提交的商家信息' },
        { title: '联系电话', value: session.merchant?.contactPhone || '--', desc: '用于平台联系和门店展示' }
      ]
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
          <p>手机号 {{ session.appUser?.phone || '--' }}，这里集中查看你的账号状态、订单统计和常用入口。</p>

          <div v-if="session.merchant" class="profile-merchant-inline">
            <strong>{{ session.merchant.merchantName }}</strong>
            <span>{{ session.merchant.contactPhone || '--' }}</span>
            <StatusBadge
              v-bind="getStatusMeta(MERCHANT_AUDIT_STATUS, session.merchant.auditStatus)"
            />
          </div>
        </div>
      </section>

      <section class="profile-grid">
        <section class="surface-card section-card">
          <div class="section-head">
            <div>
              <span class="eyebrow">账号概览</span>
              <h2>账号概览</h2>
              <p>按当前账号身份展示对应的业务统计数据。</p>
            </div>
          </div>

          <div class="profile-metrics">
            <article v-for="item in metrics" :key="item.title" class="profile-metric-card">
              <span>{{ item.title }}</span>
              <strong>{{ item.value }}</strong>
              <p>{{ item.desc }}</p>
            </article>
          </div>

          <div v-if="loading" class="profile-loading">正在同步统计数据...</div>
        </section>

        <section class="surface-card section-card">
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

.profile-grid {
  display: grid;
  grid-template-columns: minmax(0, 1.05fr) minmax(300px, 0.95fr);
  gap: 24px;
}

.profile-metrics {
  display: grid;
  grid-template-columns: repeat(3, minmax(0, 1fr));
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

.profile-links {
  display: grid;
  gap: 14px;
}

.profile-link-card {
  display: block;
  padding: 18px;
  border-radius: 22px;
  background: linear-gradient(180deg, rgba(255, 255, 255, 0.94), rgba(248, 244, 236, 0.94));
  border: 1px solid rgba(17, 61, 77, 0.08);
}

.profile-link-card strong {
  display: block;
  margin-bottom: 8px;
}

@media (max-width: 980px) {
  .profile-hero,
  .profile-grid,
  .profile-metrics {
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
