<script setup>
import { computed, onMounted, ref, watch } from 'vue'
import { RouterLink } from 'vue-router'
import AccessoryShowcaseCarousel from '@/components/AccessoryShowcaseCarousel.vue'
import EmptyState from '@/components/EmptyState.vue'
import StatusBadge from '@/components/StatusBadge.vue'
import { apiBaseUrl, commonApi, merchantApi } from '@/lib/api'
import {
  AFTER_SALES_STATUS,
  MERCHANT_AUDIT_STATUS,
  formatDateTime,
  getRoleLabel,
  getRoleState,
  getStatusMeta,
  safeRows,
  shortText
} from '@/lib/domain'
import { fetchMerchantDashboardSummary } from '@/lib/merchantDashboard'
import { pushNotice } from '@/lib/notice'
import { session } from '@/lib/session'

const FEATURED_ACCESSORY_LIMIT = 5
const ACCESSORY_PAGE_SIZE = 60
const MERCHANT_PENDING_ORDERS_PAGE_SIZE = 6

const loading = ref(true)
const featuredAccessories = ref([])
const totalAccessoryCount = ref(0)
const merchantList = ref([])
const merchantDashboard = ref(null)
const merchantPendingOrders = ref([])
const merchantPendingOrderItems = computed(() => merchantPendingOrders.value.slice(0, MERCHANT_PENDING_ORDERS_PAGE_SIZE))

const roleState = computed(() => getRoleState(session.roleType))
const featuredAccessoryMeta = computed(() => {
  if (roleState.value.isMerchant) {
    return {
      eyebrow: '我的配件',
      title: '我的配件',
      emptyTitle: '暂无已上架配件',
      emptyDescription: '当前商家还没有已上架配件，先去商品管理里补充商品。',
      ctaLabel: '管理商品',
      ctaTo: { name: 'merchant-accessories' }
    }
  }

  return {
    eyebrow: '热门配件',
    title: '热门配件',
    emptyTitle: '暂无热门配件',
    emptyDescription: '当前没有查询到可展示的上架配件。',
    ctaLabel: '查看全部',
    ctaTo: { name: 'mall' }
  }
})

const userSummaryCards = computed(() => [
  {
    title: '售后流程',
    value: '4 个阶段',
    desc: '申请、商家处理、完成一体化跟踪。'
  },
  {
    title: '在售配件',
    value: `${totalAccessoryCount.value} 件`,
    desc: '常用维修更换配件可直接浏览和下单。'
  },
  {
    title: '服务范围',
    value: '汉中市',
    desc: '本地售后服务与配件供应集中展示。'
  },
  {
    title: '服务商家',
    value: `${merchantList.value.length} 家`,
    desc: '先查看门店资料，再决定下单或提交售后。'
  }
])

const merchantCoreQuickLinks = computed(() => [
  { label: '未完成售后', desc: '优先处理待处理售后', to: { name: 'after-sales-orders', query: { type: 'pending' } } },
  { label: '售后处理', desc: '进入同意 / 拒绝面板', to: { name: 'after-sales-apply' } },
  { label: '配件订单', desc: '查看商城订单', to: { name: 'merchant-accessory-orders' } },
  { label: '商品管理', desc: '维护我的配件', to: { name: 'merchant-accessories' } }
])

function shuffleList(list = []) {
  const clonedList = [...list]
  for (let index = clonedList.length - 1; index > 0; index -= 1) {
    const randomIndex = Math.floor(Math.random() * (index + 1))
    const currentItem = clonedList[index]
    clonedList[index] = clonedList[randomIndex]
    clonedList[randomIndex] = currentItem
  }
  return clonedList
}

function dedupeAccessories(list = []) {
  return list.filter((item, index, array) => {
    return index === array.findIndex((current) => String(current.accessoryId) === String(item.accessoryId))
  })
}

async function fetchAllAccessoryRows(loader, baseParams = {}) {
  let pageNum = 1
  let total = 0
  const mergedRows = []

  while (pageNum <= 20) {
    const payload = await loader({
      ...baseParams,
      pageNum,
      pageSize: ACCESSORY_PAGE_SIZE
    })
    const rows = safeRows(payload)
    if (!rows.length) {
      break
    }

    mergedRows.push(...rows)
    total = Number(payload?.total || total || 0)

    if ((total > 0 && mergedRows.length >= total) || rows.length < ACCESSORY_PAGE_SIZE) {
      break
    }

    pageNum += 1
  }

  const dedupedRows = dedupeAccessories(mergedRows)
  return {
    rows: dedupedRows,
    total: total || dedupedRows.length
  }
}

async function loadMerchantFeaturedAccessories() {
  const payload = await fetchAllAccessoryRows(merchantApi.listAccessories, {
    status: '0'
  })
  totalAccessoryCount.value = payload.total
  featuredAccessories.value = [...payload.rows]
    .sort((left, right) => Number(right.salesCount || 0) - Number(left.salesCount || 0))
    .slice(0, FEATURED_ACCESSORY_LIMIT)
}

async function loadUserFeaturedAccessories() {
  const payload = await fetchAllAccessoryRows(commonApi.listAccessories, {
    status: '0',
    params: session.appUser?.appUserId
      ? { appUserId: session.appUser.appUserId }
      : undefined
  })
  totalAccessoryCount.value = payload.total
  featuredAccessories.value = shuffleList(payload.rows).slice(0, FEATURED_ACCESSORY_LIMIT)
}

async function loadHomeData() {
  loading.value = true
  try {
    if (roleState.value.isMerchant) {
      const [dashboard, pendingPayload] = await Promise.all([
        fetchMerchantDashboardSummary(),
        merchantApi.listPendingOrders({
          pageNum: 1,
          pageSize: MERCHANT_PENDING_ORDERS_PAGE_SIZE
        })
      ])

      merchantDashboard.value = dashboard
      session.merchant = dashboard.merchant || session.merchant
      merchantPendingOrders.value = safeRows(pendingPayload)
      merchantList.value = []
      await loadMerchantFeaturedAccessories()
      return
    }

    const [accessoryPayload, merchantPayload] = await Promise.all([
      loadUserFeaturedAccessories(),
      commonApi.listMerchants({
        auditStatus: '1',
        pageNum: 1,
        pageSize: 4
      })
    ])

    merchantList.value = safeRows(merchantPayload)
  } catch (error) {
    pushNotice(error.message || '首页数据加载失败', 'danger')
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  loadHomeData()
})

watch(
  () => `${session.token || ''}:${session.roleType || ''}:${session.appUser?.appUserId || ''}`,
  () => {
    loadHomeData()
  }
)
</script>

<template>
  <section class="page-shell home-page">
    <section v-if="loading" class="surface-card section-card home-loading">
      <span class="eyebrow">首页加载中</span>
      <h1>正在同步首页数据</h1>
      <p>系统正在根据当前账号身份装配首页内容。</p>
    </section>

    <template v-else-if="roleState.isMerchant">
      <section class="glass-card merchant-hero">
        <div>
          <span class="eyebrow">商家首页</span>
          <h1>{{ merchantDashboard?.merchant?.merchantName || '商家工作台' }}</h1>

          <div class="hero-actions">
            <RouterLink class="btn btn--primary" :to="{ name: 'after-sales-orders', query: { type: 'pending' } }">查看未完成工单</RouterLink>
            <RouterLink class="btn btn--secondary" :to="{ name: 'after-sales-apply' }">进入售后处理</RouterLink>
          </div>
        </div>

        <div class="surface-card merchant-hero__side">
          <div class="between-row merchant-hero__badge">
            <strong>{{ getRoleLabel(session.roleType) }}</strong>
            <StatusBadge v-bind="getStatusMeta(MERCHANT_AUDIT_STATUS, merchantDashboard?.merchant?.auditStatus)" />
          </div>
          <span>{{ merchantDashboard?.merchant?.contactName || '门店联系人' }} / {{ merchantDashboard?.merchant?.contactPhone || '--' }}</span>
          <span>{{ merchantDashboard?.merchant?.address || '请先完善门店地址' }}</span>
          <p>{{ shortText(merchantDashboard?.merchant?.serviceScope || merchantDashboard?.merchant?.merchantDesc || '可在店铺设置中补充服务范围和门店简介。', 84) }}</p>
        </div>
      </section>

      <AccessoryShowcaseCarousel
        :api-base-url="apiBaseUrl"
        :eyebrow="featuredAccessoryMeta.eyebrow"
        :title="featuredAccessoryMeta.title"
        :description="'只展示当前商家账户已上架的配件，并按销量从高到低选出 5 个轮播。'"
        :items="featuredAccessories"
        :empty-title="featuredAccessoryMeta.emptyTitle"
        :empty-description="featuredAccessoryMeta.emptyDescription"
        :cta-label="featuredAccessoryMeta.ctaLabel"
        :cta-to="featuredAccessoryMeta.ctaTo"
      />

      <section class="merchant-grid">
        <section class="surface-card section-card">
          <div class="section-head">
            <div>
              <span class="eyebrow">待接售后</span>
              <h2>最新未完成工单</h2>
              <p>优先查看需要商家给出处理意见的最新售后需求。</p>
            </div>
            <RouterLink class="btn btn--ghost btn--small" :to="{ name: 'after-sales-orders', query: { type: 'pending' } }">查看全部</RouterLink>
          </div>

          <div v-if="merchantPendingOrderItems.length" class="merchant-stack merchant-stack--scroll">
            <article v-for="order in merchantPendingOrderItems" :key="order.orderId" class="merchant-card merchant-card--compact">
              <div class="merchant-card__head">
                <div>
                  <h3>{{ order.productType }}</h3>
                  <p>{{ order.orderNo }}</p>
                </div>
                <StatusBadge v-bind="getStatusMeta(AFTER_SALES_STATUS, order.status)" />
              </div>
              <p>{{ shortText(order.faultDesc, 88) }}</p>
              <div class="merchant-card__meta">
                <span>{{ order.contactName }} / {{ order.contactPhone }}</span>
                <span>{{ formatDateTime(order.createTime) }}</span>
              </div>
            </article>
          </div>
          <EmptyState
            v-else
            title="暂无未完成工单"
            description="当前没有新的售后工单需要商家处理。"
          />
        </section>

        <section class="surface-card section-card merchant-workbench-card">
          <div class="section-head">
            <div>
              <span class="eyebrow">快捷入口</span>
              <h2>核心工作台</h2>
              <p>保留商家首页最常用的 4 个入口，方便快速切换处理。</p>
            </div>
          </div>

          <div class="merchant-core-grid">
            <RouterLink
              v-for="item in merchantCoreQuickLinks"
              :key="item.label"
              class="merchant-core-link"
              :to="item.to"
            >
              <strong>{{ item.label }}</strong>
              <span>{{ item.desc }}</span>
            </RouterLink>
          </div>
        </section>
      </section>
    </template>

    <template v-else>
      <section class="glass-card hero-card">
        <div class="hero-copy">
          <span class="eyebrow">售后服务平台</span>
          <h1>汉中电子产品售后与配件服务中心</h1>

          <div class="hero-actions">
            <RouterLink class="btn btn--primary" :to="{ name: 'mall' }">进入配件商城</RouterLink>
            <RouterLink class="btn btn--secondary" :to="{ name: 'after-sales-apply' }">提交售后申请</RouterLink>
          </div>

          <div class="hero-stats">
            <article class="hero-stat">
              <span>当前身份</span>
              <strong>{{ getRoleLabel(session.roleType) }}</strong>
              <p>{{ session.appUser?.nickName || '未登录用户' }}</p>
            </article>
            <article class="hero-stat">
              <span>服务区域</span>
              <strong>汉中市</strong>
              <p>支持本地售后报修与门店服务查询。</p>
            </article>
          </div>
        </div>

        
      </section>

      <section class="summary-grid">
        <article v-for="card in userSummaryCards" :key="card.title" class="surface-card summary-card">
          <span>{{ card.title }}</span>
          <strong>{{ card.value }}</strong>
          <p>{{ card.desc }}</p>
        </article>
      </section>

      <AccessoryShowcaseCarousel
        :api-base-url="apiBaseUrl"
        :eyebrow="featuredAccessoryMeta.eyebrow"
        :title="featuredAccessoryMeta.title"
        :description="featuredAccessoryMeta.description"
        :items="featuredAccessories"
        :empty-title="featuredAccessoryMeta.emptyTitle"
        :empty-description="featuredAccessoryMeta.emptyDescription"
        :cta-label="featuredAccessoryMeta.ctaLabel"
        :cta-to="featuredAccessoryMeta.ctaTo"
      />

      <section class="surface-card section-card">
        <div class="section-head">
          <div>
            <span class="eyebrow">服务门店</span>
            <h2>可选维修门店</h2>
            <p>查看门店资料、服务范围和联系方式，再选择合适的维修服务。</p>
          </div>
          <RouterLink class="btn btn--ghost btn--small" :to="{ name: 'merchants' }">查看全部门店</RouterLink>
        </div>

        <div v-if="merchantList.length" class="merchant-stack">
          <RouterLink
            v-for="item in merchantList"
            :key="item.merchantId"
            class="merchant-card"
            :to="{ name: 'merchant-detail', params: { id: item.merchantId } }"
          >
            <div class="merchant-card__head">
              <div>
                <h3>{{ item.merchantName }}</h3>
                <p>{{ item.cityName || '汉中市' }}</p>
              </div>
              <StatusBadge v-bind="getStatusMeta(MERCHANT_AUDIT_STATUS, item.auditStatus)" />
            </div>
            <p>{{ shortText(item.serviceScope || item.merchantDesc || '电子产品检修、保养和配件更换服务。', 60) }}</p>
            <div class="merchant-card__meta">
              <span>{{ item.contactName || '商家客服' }}</span>
              <span>{{ item.contactPhone || '--' }}</span>
            </div>
          </RouterLink>
        </div>
        <EmptyState
          v-else
          title="暂无商家"
          description="当前没有查询到符合条件的服务门店。"
        />
      </section>
    </template>
  </section>
</template>

<style scoped>
.home-page {
  display: grid;
  gap: 24px;
}

.home-loading {
  text-align: center;
}

.hero-card {
  display: grid;
  grid-template-columns: minmax(0, 1.3fr) minmax(320px, 0.85fr);
  gap: 24px;
  padding: 30px;
}

.hero-copy h1,
.merchant-hero h1 {
  margin: 18px 0 14px;
  font-size: clamp(34px, 5vw, 58px);
  line-height: 1.03;
  letter-spacing: -0.04em;
}

.hero-copy p {
  max-width: 720px;
  font-size: 16px;
}

.hero-actions {
  display: flex;
  flex-wrap: wrap;
  gap: 14px;
  margin: 28px 0;
}

.hero-stats {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 16px;
}

.hero-stat {
  padding: 18px 20px;
  border-radius: 24px;
  background: rgba(255, 255, 255, 0.68);
  border: 1px solid rgba(24, 48, 43, 0.08);
}

.hero-stat span,
.summary-card span,
.merchant-link-card span,
.merchant-card__meta span,
.merchant-hero__side span {
  color: var(--muted);
}

.hero-stat strong,
.summary-card strong,
.merchant-hero__side strong {
  display: block;
  font-size: 20px;
  color: var(--primary-deep);
}

.hero-stat p,
.summary-card p {
  margin-top: 8px;
}

.hero-panel {
  padding: 26px;
}

.merchant-link-card:hover,
.accessory-card:hover,
.merchant-card:hover {
  transform: translateY(-3px);
  border-color: rgba(18, 105, 93, 0.24);
  box-shadow: 0 20px 38px rgba(10, 66, 58, 0.1);
}

.merchant-hero {
  display: grid;
  grid-template-columns: minmax(0, 1fr) 360px;
  gap: 24px;
  padding: 30px;
}

.merchant-hero__side {
  display: grid;
  gap: 12px;
  align-content: start;
  padding: 22px;
}

.merchant-hero__badge {
  align-items: flex-start;
}

.merchant-hero__side p {
  margin: 0;
}

.merchant-link-grid,
.summary-grid {
  display: grid;
  grid-template-columns: repeat(4, minmax(0, 1fr));
  gap: 18px;
}

.merchant-link-card,
.summary-card {
  padding: 22px;
  border-radius: 24px;
  border: 1px solid rgba(24, 48, 43, 0.08);
  transition: transform 0.2s ease, box-shadow 0.2s ease, border-color 0.2s ease;
}

.merchant-link-card strong {
  display: block;
  margin-bottom: 10px;
  color: var(--primary-deep);
}

.merchant-grid {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 24px;
}

.merchant-workbench-card {
  align-content: start;
}

.merchant-core-grid {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 14px;
}

.merchant-core-link {
  display: grid;
  gap: 10px;
  min-height: 148px;
  padding: 18px;
  border-radius: 24px;
  background: linear-gradient(180deg, rgba(255, 255, 255, 0.96), rgba(247, 243, 235, 0.96));
  border: 1px solid rgba(24, 48, 43, 0.08);
  transition: transform 0.2s ease, box-shadow 0.2s ease, border-color 0.2s ease;
}

.merchant-core-link:hover {
  transform: translateY(-3px);
  border-color: rgba(18, 105, 93, 0.24);
  box-shadow: 0 20px 38px rgba(10, 66, 58, 0.1);
}

.merchant-core-link strong {
  color: var(--primary-deep);
  font-size: 18px;
}

.merchant-core-link span {
  color: var(--muted);
  line-height: 1.7;
}

.merchant-note-card {
  align-content: start;
}

.accessory-card,
.merchant-card {
  display: block;
  border-radius: 24px;
  background: linear-gradient(180deg, rgba(255, 255, 255, 0.96), rgba(247, 243, 235, 0.96));
  border: 1px solid rgba(24, 48, 43, 0.08);
  overflow: hidden;
  transition: transform 0.2s ease, box-shadow 0.2s ease;
}

.accessory-card__cover {
  aspect-ratio: 16 / 10;
  background: linear-gradient(135deg, rgba(14, 116, 144, 0.12), rgba(245, 158, 11, 0.16));
}

.accessory-card__cover img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.accessory-card__content {
  padding: 18px;
}

.accessory-card__content span {
  color: var(--primary);
  font-size: 13px;
  font-weight: 700;
}

.accessory-card__content h3,
.merchant-card__head h3 {
  margin: 10px 0 8px;
}

.accessory-card__meta {
  margin-top: 14px;
}

.merchant-stack {
  display: grid;
  gap: 16px;
}

.merchant-stack--scroll {
  max-height: 348px;
  overflow-y: auto;
  padding-right: 6px;
  scroll-snap-type: y proximity;
}

.merchant-stack--scroll::-webkit-scrollbar {
  width: 6px;
}

.merchant-stack--scroll::-webkit-scrollbar-thumb {
  background: rgba(18, 105, 93, 0.22);
  border-radius: 999px;
}

.merchant-card {
  padding: 20px;
}

.merchant-card--compact {
  min-height: 166px;
  scroll-snap-align: start;
}

.merchant-card__head {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: 12px;
}

.merchant-card__head p,
.merchant-card p {
  margin: 0;
}

.merchant-card__meta {
  display: flex;
  flex-wrap: wrap;
  justify-content: space-between;
  gap: 10px;
  padding-top: 12px;
  font-size: 14px;
}

@media (max-width: 1080px) {
  .merchant-link-grid,
  .summary-grid {
    grid-template-columns: repeat(2, minmax(0, 1fr));
  }
}

@media (max-width: 980px) {
  .hero-card,
  .merchant-hero,
  .merchant-grid,
  .summary-grid {
    grid-template-columns: 1fr;
  }

  .merchant-core-grid {
    grid-template-columns: 1fr 1fr;
  }
}

@media (max-width: 720px) {
  .hero-stats,
  .merchant-link-grid {
    grid-template-columns: 1fr;
  }

  .merchant-core-grid {
    grid-template-columns: 1fr;
  }

  .hero-card,
  .merchant-hero {
    padding: 18px;
  }
}
</style>
