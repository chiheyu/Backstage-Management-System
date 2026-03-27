<script setup>
import { computed, onMounted, reactive, ref } from 'vue'
import { RouterLink, useRouter } from 'vue-router'
import EmptyState from '@/components/EmptyState.vue'
import StatusBadge from '@/components/StatusBadge.vue'
import { apiBaseUrl, userApi } from '@/lib/api'
import {
  ACCESSORY_ORDER_STATUS,
  formatDateTime,
  formatMoney,
  getRoleState,
  getStatusMeta,
  resolveImage,
  safeRows,
  shortText
} from '@/lib/domain'
import { saveAfterSalePrefill } from '@/lib/localData'
import { pushNotice } from '@/lib/notice'
import { session } from '@/lib/session'

const router = useRouter()

const loading = ref(false)
const orderList = ref([])
const favoriteList = ref([])

const filters = reactive({
  orderNo: '',
  status: ''
})

const roleState = computed(() => getRoleState(session.roleType))

const statusOptions = computed(() => [
  { label: '全部订单状态', value: '' },
  ...Object.entries(ACCESSORY_ORDER_STATUS).map(([value, meta]) => ({ value, label: meta.label }))
])

async function loadData() {
  if (!session.token || !roleState.value.isUser) {
    return
  }

  loading.value = true
  try {
    const [orderPayload, favoritePayload] = await Promise.all([
      userApi.listAccessoryOrders({
        orderNo: filters.orderNo,
        status: filters.status,
        pageNum: 1,
        pageSize: 24
      }),
      userApi.listAccessoryCollections({
        pageNum: 1,
        pageSize: 12
      })
    ])

    orderList.value = safeRows(orderPayload)
    favoriteList.value = safeRows(favoritePayload)
  } catch (error) {
    pushNotice(error.message || '订单数据加载失败', 'danger')
  } finally {
    loading.value = false
  }
}

async function toggleCollection(accessoryId, collected) {
  try {
    if (collected) {
      await userApi.cancelAccessoryCollection(accessoryId)
      pushNotice('已从收藏中移除', 'success')
    } else {
      await userApi.collectAccessory(accessoryId)
      pushNotice('已加入收藏', 'success')
    }
    loadData()
  } catch (error) {
    pushNotice(error.message || '收藏操作失败', 'danger')
  }
}

function canApplyAfterSale(order) {
  return String(order.status) === '2'
}

function goAfterSale(order) {
  saveAfterSalePrefill({
    sourceType: 'accessoryOrder',
    sourceOrderId: order.accessoryOrderId,
    productName: order.accessoryName || '',
    productModel: order.orderNo || '',
    name: order.receiverName || '',
    phone: order.receiverPhone || '',
    receiverAddress: order.receiverAddress || ''
  })
  router.push({ name: 'after-sales-apply' })
}

function resetFilters() {
  filters.orderNo = ''
  filters.status = ''
  loadData()
}

onMounted(() => {
  loadData()
})
</script>

<template>
  <section class="page-shell orders-page">
    <EmptyState
      v-if="!session.token"
      title="登录后才能查看配件订单"
      description="配件订单和收藏都与当前登录账号绑定。"
      action-label="前往登录"
      @action="router.push({ name: 'auth' })"
    />

    <EmptyState
      v-else-if="!roleState.isUser"
      title="当前账号没有配件下单能力"
      description="商家账号主要处理售后工单，请切换普通用户账号查看配件订单。"
      action-label="查看售后工单"
      @action="router.push({ name: 'after-sales-orders' })"
    />

    <template v-else>
      <section class="glass-card orders-hero">
        <div>
          <span class="eyebrow">订单中心</span>
          <h1>我的配件订单与收藏</h1>
          <p>统一查看配件订单、收货信息和常用收藏商品。</p>
        </div>
        <StatusBadge :label="`订单 ${orderList.length} 条 / 收藏 ${favoriteList.length} 件`" tone="brand" />
      </section>

      <section class="orders-grid">
        <section class="surface-card section-card">
          <div class="section-head">
            <div>
              <span class="eyebrow">配件订单</span>
              <h2>配件订单</h2>
              <p>这里展示已提交的配件订单、收货信息和处理状态。</p>
            </div>
          </div>

          <div class="field-row order-filter">
            <input
              v-model.trim="filters.orderNo"
              class="field"
              placeholder="输入订单号搜索"
              @keyup.enter="loadData"
            />
            <select v-model="filters.status" class="field">
              <option v-for="item in statusOptions" :key="item.value" :value="item.value">
                {{ item.label }}
              </option>
            </select>
            <button class="btn btn--primary btn--small" @click="loadData">刷新订单</button>
            <button class="btn btn--ghost btn--small" @click="resetFilters">重置</button>
          </div>

          <div v-if="loading" class="order-list">
            <article v-for="item in 3" :key="item" class="order-card order-card--ghost"></article>
          </div>
          <div v-else-if="orderList.length" class="order-list">
            <article v-for="order in orderList" :key="order.accessoryOrderId" class="order-card">
              <div class="order-card__head">
                <div>
                  <span class="eyebrow">{{ order.orderNo }}</span>
                  <h3>{{ order.accessoryName }}</h3>
                </div>
                <StatusBadge v-bind="getStatusMeta(ACCESSORY_ORDER_STATUS, order.status)" />
              </div>

              <div class="order-card__main">
                <img :src="resolveImage(order.coverImage, apiBaseUrl)" :alt="order.accessoryName" />
                <div>
                  <p>{{ shortText(order.orderRemark || '暂无订单备注，按默认流程处理中。', 78) }}</p>
                  <div class="order-card__stats">
                    <span>数量 {{ order.quantity || 0 }}</span>
                    <span>单价 ￥{{ formatMoney(order.price) }}</span>
                    <strong>总额 ￥{{ formatMoney(order.totalAmount) }}</strong>
                  </div>
                  <div class="order-card__receiver">
                    <span>{{ order.receiverName }} / {{ order.receiverPhone }}</span>
                    <span>{{ order.receiverAddress || '未填写地址' }}</span>
                    <span>{{ formatDateTime(order.createTime) }}</span>
                  </div>
                  <div v-if="canApplyAfterSale(order)" class="action-row order-card__actions">
                    <button class="btn btn--ghost btn--small" @click="goAfterSale(order)">申请售后</button>
                  </div>
                </div>
              </div>
            </article>
          </div>
          <EmptyState
            v-else
            title="暂无配件订单"
            description="去商城下单后，这里会显示你的全部配件订单。"
            action-label="前往商城"
            @action="router.push({ name: 'mall' })"
          />
        </section>

        <section class="surface-card section-card favorites-panel">
          <div class="section-head">
            <div>
              <span class="eyebrow">收藏商品</span>
              <h2>我的收藏</h2>
              <p>保留常看的配件，方便再次查看详情或直接下单。</p>
            </div>
          </div>

          <div v-if="favoriteList.length" class="favorite-list">
            <article v-for="item in favoriteList" :key="item.collectionId" class="favorite-card">
              <img :src="resolveImage(item.coverImage, apiBaseUrl)" :alt="item.accessoryName" />
              <div>
                <RouterLink :to="{ name: 'accessory-detail', params: { id: item.accessoryId } }">
                  <strong>{{ item.accessoryName }}</strong>
                </RouterLink>
                <p>￥{{ formatMoney(item.price) }}</p>
                <button class="btn btn--ghost btn--small" @click="toggleCollection(item.accessoryId, true)">
                  取消收藏
                </button>
              </div>
            </article>
          </div>
          <EmptyState
            v-else
            title="还没有收藏"
            description="在商品详情页点击收藏后，这里会同步显示。"
          />
        </section>
      </section>
    </template>
  </section>
</template>

<style scoped>
.orders-page {
  display: grid;
  gap: 22px;
}

.orders-hero {
  display: flex;
  align-items: end;
  justify-content: space-between;
  gap: 18px;
  padding: 28px;
}

.orders-hero h1 {
  margin: 14px 0 8px;
  font-size: clamp(32px, 4vw, 48px);
  line-height: 1.08;
}

.orders-grid {
  display: grid;
  grid-template-columns: minmax(0, 1.15fr) minmax(320px, 0.85fr);
  gap: 24px;
}

.order-filter {
  margin-bottom: 18px;
}

.order-list,
.favorite-list {
  display: grid;
  gap: 16px;
}

.order-card {
  padding: 18px;
  border-radius: 24px;
  background: linear-gradient(180deg, rgba(255, 255, 255, 0.96), rgba(248, 244, 236, 0.96));
  border: 1px solid rgba(17, 61, 77, 0.08);
}

.order-card--ghost {
  min-height: 220px;
  background: linear-gradient(90deg, rgba(255, 255, 255, 0.7), rgba(237, 245, 247, 0.88), rgba(255, 255, 255, 0.7));
  background-size: 200% 100%;
  animation: orders-pulse 1.8s linear infinite;
}

.order-card__head {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: 12px;
  margin-bottom: 14px;
}

.order-card__head h3 {
  margin: 10px 0 0;
}

.order-card__main {
  display: grid;
  grid-template-columns: 120px minmax(0, 1fr);
  gap: 16px;
}

.order-card__main img,
.favorite-card img {
  width: 120px;
  height: 120px;
  object-fit: cover;
  border-radius: 20px;
}

.order-card__stats,
.order-card__receiver {
  display: flex;
  flex-wrap: wrap;
  gap: 12px;
  margin-top: 12px;
  color: var(--muted);
}

.order-card__actions {
  margin-top: 12px;
}

.order-card__stats strong {
  color: var(--primary-deep);
}

.favorite-card {
  display: grid;
  grid-template-columns: 96px minmax(0, 1fr);
  gap: 14px;
  padding: 14px;
  border-radius: 22px;
  background: linear-gradient(180deg, rgba(255, 255, 255, 0.94), rgba(248, 244, 236, 0.94));
  border: 1px solid rgba(17, 61, 77, 0.08);
}

.favorite-card img {
  width: 96px;
  height: 96px;
}

.favorite-card strong {
  display: block;
  margin-bottom: 8px;
}

@keyframes orders-pulse {
  to {
    background-position: -200% 0;
  }
}

@media (max-width: 980px) {
  .orders-grid {
    grid-template-columns: 1fr;
  }
}

@media (max-width: 720px) {
  .orders-hero,
  .field-row,
  .order-card__head,
  .order-card__main,
  .favorite-card {
    display: grid;
  }
}
</style>
