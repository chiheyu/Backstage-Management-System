<script setup>
import { computed, onMounted, ref } from 'vue'
import { RouterLink } from 'vue-router'
import EmptyState from '@/components/EmptyState.vue'
import StatusBadge from '@/components/StatusBadge.vue'
import { apiBaseUrl, commonApi, merchantApi } from '@/lib/api'
import {
  AFTER_SALES_STATUS,
  MERCHANT_AUDIT_STATUS,
  formatDateTime,
  formatMoney,
  getRoleLabel,
  getRoleState,
  getStatusMeta,
  resolveImage,
  safeRows,
  shortText
} from '@/lib/domain'
import { fetchMerchantDashboardSummary } from '@/lib/merchantDashboard'
import { pushNotice } from '@/lib/notice'
import { session } from '@/lib/session'

const loading = ref(true)
const accessoryList = ref([])
const merchantList = ref([])
const merchantDashboard = ref(null)
const merchantPendingOrders = ref([])

const roleState = computed(() => getRoleState(session.roleType))

const userSummaryCards = computed(() => [
  {
    title: '售后流程',
    value: '4 个阶段',
    desc: '申请、接单、维修、完成一体化跟踪。'
  },
  {
    title: '在售配件',
    value: `${accessoryList.value.length} 件`,
    desc: '常用维修更换配件可直接浏览和下单。'
  },
  {
    title: roleState.value.isPendingMerchant ? '入驻状态' : '服务范围',
    value: roleState.value.isPendingMerchant ? '审核中' : '汉中市',
    desc: roleState.value.isPendingMerchant
      ? '审核通过前继续按普通用户模式使用网页端。'
      : '本地售后服务与配件供应集中展示。'
  },
  {
    title: '服务商家',
    value: `${merchantList.value.length} 家`,
    desc: '先查看门店资料，再决定下单或提交售后。'
  }
])

const merchantSummaryCards = computed(() => {
  const counts = merchantDashboard.value?.counts || {}
  return [
    { title: '待接售后', value: counts.pendingAfterSales || 0, desc: '等待当前商家接单的新售后工单' },
    { title: '处理中售后', value: counts.activeAfterSales || 0, desc: '已接单或维修中的售后工单' },
    { title: '已完成工单', value: counts.completedAfterSales || 0, desc: '已经提交回执并完成的售后工单' },
    {
      title: '店铺状态',
      value: getStatusMeta(MERCHANT_AUDIT_STATUS, merchantDashboard.value?.merchant?.auditStatus).label,
      desc: '网页端当前只接入后端已开放的商家售后能力'
    }
  ]
})

const merchantQuickLinks = computed(() => {
  const merchantId = merchantDashboard.value?.merchant?.merchantId || session.merchant?.merchantId
  return [
    { label: '待接售后工单', desc: '优先处理新提交的售后需求', to: { name: 'after-sales-orders', query: { mode: 'pending' } } },
    { label: '我的售后工单', desc: '查看已接单和处理中工单', to: { name: 'after-sales-orders', query: { mode: 'mine' } } },
    { label: '售后回执', desc: '填写检测结果、维修进度和完工说明', to: { name: 'after-sales-apply' } },
    { label: '配件订单', desc: '处理商城订单的发货、完成和取消', to: { name: 'merchant-accessory-orders' } },
    { label: '商品管理', desc: '维护商品、库存、状态和图片', to: { name: 'merchant-accessories' } },
    { label: '店铺设置', desc: '维护联系人、地址和服务范围', to: { name: 'merchant-settings' } },
    {
      label: '我的店铺',
      desc: '查看当前门店对外展示信息',
      to: merchantId ? { name: 'merchant-detail', params: { id: merchantId } } : { name: 'merchant-settings' }
    }
  ]
})

async function loadHomeData() {
  loading.value = true
  try {
    if (roleState.value.isMerchant) {
      const [dashboard, pendingPayload] = await Promise.all([
        fetchMerchantDashboardSummary(),
        merchantApi.listPendingOrders({
          pageNum: 1,
          pageSize: 4
        })
      ])

      merchantDashboard.value = dashboard
      session.merchant = dashboard.merchant || session.merchant
      merchantPendingOrders.value = safeRows(pendingPayload)
      return
    }

    const [accessoryPayload, merchantPayload] = await Promise.all([
      commonApi.listAccessories({
        status: '0',
        pageNum: 1,
        pageSize: 6,
        params: session.appUser?.appUserId
          ? { appUserId: session.appUser.appUserId }
          : undefined
      }),
      commonApi.listMerchants({
        auditStatus: '1',
        pageNum: 1,
        pageSize: 4
      })
    ])

    accessoryList.value = safeRows(accessoryPayload)
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
          <p>网页端商家首页现在已经接入售后工单、配件订单、商品管理和店铺资料维护，和小程序保持同一套业务链路。</p>

          <div class="hero-actions">
            <RouterLink class="btn btn--primary" :to="{ name: 'after-sales-orders', query: { mode: 'pending' } }">查看待接工单</RouterLink>
            <RouterLink class="btn btn--secondary" :to="{ name: 'after-sales-apply' }">填写售后回执</RouterLink>
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

      <section class="merchant-link-grid">
        <RouterLink v-for="item in merchantQuickLinks" :key="item.label" class="surface-card merchant-link-card" :to="item.to">
          <strong>{{ item.label }}</strong>
          <span>{{ item.desc }}</span>
        </RouterLink>
      </section>

      <section class="summary-grid">
        <article v-for="card in merchantSummaryCards" :key="card.title" class="surface-card summary-card">
          <span>{{ card.title }}</span>
          <strong>{{ card.value }}</strong>
          <p>{{ card.desc }}</p>
        </article>
      </section>

      <section class="merchant-grid">
        <section class="surface-card section-card">
          <div class="section-head">
            <div>
              <span class="eyebrow">待接售后</span>
              <h2>最新待接工单</h2>
              <p>优先展示等待当前商家接单的售后需求。</p>
            </div>
            <RouterLink class="btn btn--ghost btn--small" :to="{ name: 'after-sales-orders', query: { mode: 'pending' } }">查看全部</RouterLink>
          </div>

          <div v-if="merchantPendingOrders.length" class="merchant-stack">
            <article v-for="order in merchantPendingOrders" :key="order.orderId" class="merchant-card">
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
            title="暂无待接工单"
            description="当前没有新的售后工单需要当前商家接单。"
          />
        </section>

        <section class="surface-card section-card merchant-note-card">
          <div class="section-head">
            <div>
              <span class="eyebrow">接口适配</span>
              <h2>当前网页端已接入商家完整主流程</h2>
              <p>现有后端已经提供商家商品和配件订单接口，网页端现在直接接入，不改动小程序和后端。</p>
            </div>
          </div>

          <div class="merchant-stack">
            <article class="merchant-card">
              <div class="merchant-card__head">
                <div>
                  <h3>已接入</h3>
                  <p>网页端已可直接使用</p>
                </div>
              </div>
              <p>商家信息、待接售后、我的工单、售后状态更新、售后回执、配件订单、商品管理、店铺资料维护。</p>
            </article>

            <article class="merchant-card">
              <div class="merchant-card__head">
                <div>
                  <h3>共享数据</h3>
                  <p>继续复用现有接口与数据表</p>
                </div>
              </div>
              <p>网页端与小程序继续共用同一套商家订单、商品、售后和店铺资料数据，不改变后端实现。</p>
            </article>
          </div>
        </section>
      </section>
    </template>

    <template v-else>
      <section class="glass-card hero-card">
        <div class="hero-copy">
          <span class="eyebrow">售后服务平台</span>
          <h1>汉中电子产品售后与配件服务中心</h1>
          <p>
            集中处理电子产品报修、配件购买、门店查询和工单跟踪。
            无论是普通用户下单与提交售后，还是待审核商家继续以用户身份使用，都可以在这里完成。
          </p>

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
              <span>{{ roleState.isPendingMerchant ? '入驻审核' : '服务区域' }}</span>
              <strong>{{ roleState.isPendingMerchant ? '审核中' : '汉中市' }}</strong>
              <p>{{ roleState.isPendingMerchant ? '审核通过前仍可按普通用户模式下单与申请售后。' : '支持本地售后报修与门店服务查询。' }}</p>
            </article>
          </div>
        </div>

        <div class="hero-panel surface-card">
          <div class="hero-panel__head">
            <span class="eyebrow">核心流程</span>
            <h2>把常用业务放到一个清晰入口里</h2>
            <p>根据当前账号身份展示最常用的业务路径。</p>
          </div>

          <div class="hero-process">
            <RouterLink class="hero-process__item" :to="{ name: 'mall' }">
              <span>01</span>
              <div class="hero-process__content">
                <strong>选购配件</strong>
                <p>浏览常用维修配件，按分类和价格筛选。</p>
                <em>进入配件商城</em>
              </div>
            </RouterLink>
            <RouterLink class="hero-process__item" :to="{ name: 'after-sales-apply' }">
              <span>02</span>
              <div class="hero-process__content">
                <strong>提交售后</strong>
                <p>填写产品、故障和联系信息，等待商家接单。</p>
                <em>立即提交售后</em>
              </div>
            </RouterLink>
            <RouterLink class="hero-process__item" :to="{ name: 'after-sales-orders' }">
              <span>03</span>
              <div class="hero-process__content">
                <strong>跟踪进度</strong>
                <p>在工单页查看接单、维修和回执状态。</p>
                <em>查看售后订单</em>
              </div>
            </RouterLink>
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

      <section class="content-grid">
        <section class="surface-card section-card">
          <div class="section-head">
            <div>
              <span class="eyebrow">热门配件</span>
              <h2>热门配件</h2>
              <p>优先展示常见维修更换配件，方便快速选购。</p>
            </div>
            <RouterLink class="btn btn--ghost btn--small" :to="{ name: 'mall' }">查看全部</RouterLink>
          </div>

          <div v-if="accessoryList.length" class="card-grid">
            <RouterLink
              v-for="item in accessoryList"
              :key="item.accessoryId"
              class="accessory-card"
              :to="{ name: 'accessory-detail', params: { id: item.accessoryId } }"
            >
              <div class="accessory-card__cover">
                <img :src="resolveImage(item.coverImage, apiBaseUrl)" :alt="item.accessoryName" />
              </div>
              <div class="accessory-card__content">
                <span>{{ item.categoryName || '通用配件' }}</span>
                <h3>{{ item.accessoryName }}</h3>
                <p>{{ shortText(item.accessoryDesc || '适用于常见电子产品维修、更换和保养场景。', 52) }}</p>
                <div class="between-row accessory-card__meta">
                  <strong>￥{{ formatMoney(item.price) }}</strong>
                  <small>销量 {{ item.salesCount || 0 }}</small>
                </div>
              </div>
            </RouterLink>
          </div>
          <EmptyState
            v-else
            title="暂无配件"
            description="当前没有查询到已上架配件。"
            action-label="刷新首页"
            @action="loadHomeData"
          />
        </section>

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

.hero-process {
  display: grid;
  gap: 14px;
  margin-top: 18px;
}

.hero-process__item {
  display: grid;
  grid-template-columns: 52px minmax(0, 1fr);
  gap: 14px;
  align-items: start;
  padding: 18px;
  border-radius: 22px;
  background: linear-gradient(180deg, rgba(255, 255, 255, 0.92), rgba(244, 239, 229, 0.9));
  border: 1px solid rgba(24, 48, 43, 0.08);
  transition: transform 0.2s ease, box-shadow 0.2s ease, border-color 0.2s ease;
}

.hero-process__item:hover,
.merchant-link-card:hover,
.accessory-card:hover,
.merchant-card:hover {
  transform: translateY(-3px);
  border-color: rgba(18, 105, 93, 0.24);
  box-shadow: 0 20px 38px rgba(10, 66, 58, 0.1);
}

.hero-process__item span {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 52px;
  height: 52px;
  border-radius: 18px;
  background: linear-gradient(135deg, rgba(18, 105, 93, 0.12), rgba(215, 141, 43, 0.22));
  color: var(--primary-deep);
  font-weight: 800;
}

.hero-process__content {
  display: grid;
  gap: 8px;
}

.hero-process__content p {
  margin: 0;
}

.hero-process__content em {
  font-style: normal;
  color: var(--primary);
  font-weight: 700;
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

.merchant-note-card {
  align-content: start;
}

.content-grid {
  display: grid;
  grid-template-columns: minmax(0, 1.1fr) minmax(340px, 0.8fr);
  gap: 24px;
}

.card-grid {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 18px;
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

.merchant-card {
  padding: 20px;
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
  .content-grid,
  .summary-grid {
    grid-template-columns: 1fr;
  }
}

@media (max-width: 720px) {
  .hero-stats,
  .merchant-link-grid,
  .card-grid {
    grid-template-columns: 1fr;
  }

  .hero-card,
  .merchant-hero {
    padding: 18px;
  }
}
</style>
