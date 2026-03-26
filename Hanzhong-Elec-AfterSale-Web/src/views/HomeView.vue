<script setup>
import { computed, onMounted, ref } from 'vue'
import { RouterLink } from 'vue-router'
import StatusBadge from '@/components/StatusBadge.vue'
import EmptyState from '@/components/EmptyState.vue'
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
import { pushNotice } from '@/lib/notice'
import { session } from '@/lib/session'

const loading = ref(true)
const accessoryList = ref([])
const merchantList = ref([])
const merchantPendingOrders = ref([])

const roleState = computed(() => getRoleState(session.roleType))

const summaryCards = computed(() => {
  const cards = [
    {
      title: '售后流程',
      value: '4 个阶段',
      desc: '申请、接单、维修、完成一体化跟踪。'
    },
    {
      title: '在售配件',
      value: `${accessoryList.value.length} 件`,
      desc: '常用维修更换配件可在线浏览与下单。'
    },
    {
      title: roleState.value.isMerchant ? '当前角色' : '服务范围',
      value: roleState.value.isMerchant ? '商家账号' : '汉中市',
      desc: roleState.value.isMerchant ? '可处理售后工单并维护门店资料。' : '本地维修服务与配件供应集中展示。'
    }
  ]

  if (roleState.value.isMerchant) {
    cards.push({
      title: '待接工单',
      value: `${merchantPendingOrders.value.length} 条`,
      desc: '及时接单并推进维修处理进度。'
    })
  } else {
    cards.push({
      title: '服务门店',
      value: `${merchantList.value.length} 家`,
      desc: '查看门店信息后再选择报修与送修方式。'
    })
  }

  return cards
})

const serviceSteps = computed(() => {
  if (roleState.value.isMerchant) {
    return [
      {
        index: '01',
        title: '接收工单',
        desc: '查看待接单售后需求并快速响应。',
        actionLabel: '进入工单列表',
        to: { name: 'after-sales-orders' }
      },
      {
        index: '02',
        title: '维修跟进',
        desc: '记录检测结果、维修进度和处理备注。',
        actionLabel: '查看处理中工单',
        to: { name: 'after-sales-orders', query: { mode: 'mine' } }
      },
      {
        index: '03',
        title: '维护门店',
        desc: '持续更新电话、地址和服务范围。',
        actionLabel: '编辑门店资料',
        to: { name: 'merchant-settings' }
      }
    ]
  }

  return [
    {
      index: '01',
      title: '选购配件',
      desc: '浏览常用维修配件，按分类和价格筛选。',
      actionLabel: '进入配件商城',
      to: { name: 'mall' }
    },
    {
      index: '02',
      title: '提交售后',
      desc: '填写设备类型、故障情况和联系信息。',
      actionLabel: '立即申请售后',
      to: { name: 'after-sales-apply' }
    },
    {
      index: '03',
      title: '查看进度',
      desc: '在订单中心跟踪维修状态和处理结果。',
      actionLabel: '查看售后进度',
      to: { name: 'after-sales-orders' }
    }
  ]
})

async function loadHomeData() {
  loading.value = true
  try {
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

    if (roleState.value.isMerchant) {
      const pendingPayload = await merchantApi.listPendingOrders({
        pageNum: 1,
        pageSize: 3
      })
      merchantPendingOrders.value = safeRows(pendingPayload)
    }
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
    <section class="glass-card hero-card">
      <div class="hero-copy">
        <span class="eyebrow">售后服务平台</span>
        <h1>汉中电子产品售后与配件服务中心</h1>
        <p>
          集中处理电子产品报修、配件购买、门店查询和工单跟踪。
          无论是用户下单、提交售后，还是商家接单与维护资料，都可以在这里完成。
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
            <span>{{ roleState.isMerchant ? '我的门店' : '服务区域' }}</span>
            <strong>{{ roleState.isMerchant ? (session.merchant?.merchantName || '待完善门店信息') : '汉中市' }}</strong>
            <p>{{ roleState.isMerchant ? '门店资料完整后更方便接单。' : '支持本地售后报修与门店查询。' }}</p>
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
          <RouterLink
            v-for="step in serviceSteps"
            :key="step.title"
            class="hero-process__item"
            :to="step.to"
          >
            <span>{{ step.index }}</span>
            <div class="hero-process__content">
              <strong>{{ step.title }}</strong>
              <p>{{ step.desc }}</p>
              <em>{{ step.actionLabel }}</em>
            </div>
          </RouterLink>
        </div>
      </div>
    </section>

    <section class="summary-grid">
      <article v-for="card in summaryCards" :key="card.title" class="surface-card summary-card">
        <p>{{ card.title }}</p>
        <strong>{{ card.value }}</strong>
        <span>{{ card.desc }}</span>
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

        <div v-if="loading" class="card-grid">
          <article v-for="item in 3" :key="item" class="accessory-card accessory-card--ghost"></article>
        </div>
        <div v-else-if="accessoryList.length" class="card-grid">
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
            <span class="eyebrow">{{ roleState.isMerchant ? '待接工单' : '服务门店' }}</span>
            <h2>{{ roleState.isMerchant ? '待处理售后需求' : '可选维修门店' }}</h2>
            <p v-if="roleState.isMerchant">优先查看待接单需求，及时进入维修处理。</p>
            <p v-else>查看门店资料、服务范围和联系方式，选择合适的维修服务。</p>
          </div>
          <RouterLink
            class="btn btn--ghost btn--small"
            :to="roleState.isMerchant ? { name: 'after-sales-orders' } : { name: 'merchants' }"
          >
            {{ roleState.isMerchant ? '查看全部工单' : '查看全部门店' }}
          </RouterLink>
        </div>

        <div v-if="loading" class="merchant-stack">
          <article v-for="item in 3" :key="item" class="merchant-card merchant-card--ghost"></article>
        </div>
        <div v-else-if="roleState.isMerchant && merchantPendingOrders.length" class="merchant-stack">
          <article v-for="order in merchantPendingOrders" :key="order.orderId" class="merchant-card">
            <div class="merchant-card__head">
              <div>
                <h3>{{ order.productType }}</h3>
                <p>{{ order.orderNo }}</p>
              </div>
              <StatusBadge v-bind="getStatusMeta(AFTER_SALES_STATUS, order.status)" />
            </div>
            <p>{{ shortText(order.faultDesc, 58) }}</p>
            <div class="merchant-card__meta">
              <span>{{ order.contactName }} / {{ order.contactPhone }}</span>
              <span>{{ formatDateTime(order.createTime) }}</span>
            </div>
          </article>
        </div>
        <div v-else-if="!roleState.isMerchant && merchantList.length" class="merchant-stack">
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
            <p>{{ shortText(item.serviceScope || item.merchantDesc || '电子产品检修、保养、配件更换。', 60) }}</p>
            <div class="merchant-card__meta">
              <span>{{ item.contactName || '商家客服' }}</span>
              <span>{{ item.contactPhone || '--' }}</span>
            </div>
          </RouterLink>
        </div>
        <EmptyState
          v-else
          :title="roleState.isMerchant ? '暂时没有待接工单' : '暂无商家'"
          :description="roleState.isMerchant ? '待用户提交新的售后申请后即可在这里接单。' : '当前没有查到符合条件的服务门店。'"
        />
      </section>
    </section>
  </section>
</template>

<style scoped>
.home-page {
  display: grid;
  gap: 24px;
}

.hero-card {
  display: grid;
  grid-template-columns: minmax(0, 1.3fr) minmax(320px, 0.85fr);
  gap: 24px;
  padding: 30px;
}

.hero-copy h1 {
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

.hero-stat span {
  display: block;
  margin-bottom: 8px;
  color: var(--muted);
  font-size: 13px;
}

.hero-stat strong,
.summary-card strong {
  display: block;
  font-size: 20px;
  color: var(--primary-deep);
}

.hero-stat p,
.summary-card span {
  margin: 8px 0 0;
  color: var(--muted);
  line-height: 1.7;
}

.hero-panel {
  padding: 26px;
}

.hero-panel__head h2 {
  margin-bottom: 6px;
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

.hero-process__item:hover {
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

.hero-process__item strong {
  display: block;
}

.hero-process__item p {
  margin: 0;
}

.hero-process__item em {
  font-style: normal;
  color: var(--primary);
  font-weight: 700;
}

.summary-grid {
  display: grid;
  grid-template-columns: repeat(4, minmax(0, 1fr));
  gap: 18px;
}

.summary-card {
  padding: 22px;
}

.summary-card p {
  margin: 0 0 14px;
  font-size: 13px;
  color: var(--muted);
  letter-spacing: 0.08em;
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

.accessory-card:hover,
.merchant-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 26px 48px rgba(17, 61, 77, 0.12);
}

.accessory-card--ghost,
.merchant-card--ghost {
  min-height: 220px;
  background: linear-gradient(90deg, rgba(255, 255, 255, 0.65), rgba(237, 245, 247, 0.8), rgba(255, 255, 255, 0.65));
  background-size: 200% 100%;
  animation: pulse 1.8s linear infinite;
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
  color: var(--muted);
  font-size: 14px;
}

@keyframes pulse {
  to {
    background-position: -200% 0;
  }
}

@media (max-width: 980px) {
  .hero-card,
  .content-grid,
  .summary-grid {
    grid-template-columns: 1fr;
  }
}

@media (max-width: 720px) {
  .hero-stats,
  .card-grid {
    grid-template-columns: 1fr;
  }

  .hero-card {
    padding: 18px;
  }
}
</style>
