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
  shortText
} from '@/lib/domain'
import { saveAfterSalePrefill } from '@/lib/localData'
import { pushNotice } from '@/lib/notice'
import { fetchAllPagedRows } from '@/lib/pagination'
import { session } from '@/lib/session'

const PAGE_SIZE = 50

const router = useRouter()

const loading = ref(false)
const orderList = ref([])
const favoriteList = ref([])
const reviewModalVisible = ref(false)
const reviewSubmitting = ref(false)
const currentReviewOrder = ref(null)

const filters = reactive({
  orderNo: '',
  status: ''
})

const reviewForm = reactive({
  rating: 5,
  reviewContent: ''
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
    const [orders, favorites] = await Promise.all([
      fetchAllPagedRows(params => userApi.listAccessoryOrders(params), {
        params: {
          orderNo: filters.orderNo,
          status: filters.status
        },
        pageSize: PAGE_SIZE,
        dedupeKey: 'accessoryOrderId'
      }),
      fetchAllPagedRows(params => userApi.listAccessoryCollections(params), {
        pageSize: PAGE_SIZE,
        dedupeKey: 'collectionId'
      })
    ])

    orderList.value = orders
    favoriteList.value = favorites
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

function canReview(order) {
  return String(order.status) === '2' && !order.reviewed
}

function isReviewed(order) {
  return !!order.reviewed
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

function openReview(order) {
  if (!canReview(order)) {
    return
  }

  currentReviewOrder.value = order
  reviewForm.rating = 5
  reviewForm.reviewContent = ''
  reviewModalVisible.value = true
}

function closeReview() {
  reviewModalVisible.value = false
  currentReviewOrder.value = null
  reviewForm.rating = 5
  reviewForm.reviewContent = ''
}

function setReviewRating(value) {
  reviewForm.rating = value
}

async function submitReview() {
  if (!currentReviewOrder.value || reviewSubmitting.value) {
    return
  }

  const reviewContent = reviewForm.reviewContent.trim()
  if (!reviewContent) {
    pushNotice('请先填写评价内容', 'danger')
    return
  }

  reviewSubmitting.value = true
  try {
    await userApi.createMerchantReview({
      accessoryOrderId: currentReviewOrder.value.accessoryOrderId,
      rating: reviewForm.rating || 5,
      reviewContent
    })
    pushNotice('评价成功', 'success')
    closeReview()
    await loadData()
  } catch (error) {
    pushNotice(error.message || '评价失败', 'danger')
  } finally {
    reviewSubmitting.value = false
  }
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
      description="商家账号可以前往商家配件订单页处理商城订单；当前这个订单中心仍只展示普通用户自己的下单记录。"
      action-label="前往商家配件订单"
      @action="router.push({ name: 'merchant-accessory-orders' })"
    />

    <template v-else>
      <section class="glass-card orders-hero">
        <div>
          <span class="eyebrow">订单中心</span>
          <h1>我的配件订单与收藏</h1>
        </div>
        <StatusBadge :label="`订单 ${orderList.length} 条 / 收藏 ${favoriteList.length} 件`" tone="brand" />
      </section>

      <section class="orders-grid">
        <section class="surface-card section-card">
          <div class="section-head">
            <div>
              <span class="eyebrow">配件订单</span>
              <h2>配件订单</h2>
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
                    <button
                      v-if="canReview(order)"
                      class="btn btn--secondary btn--small"
                      @click="openReview(order)"
                    >
                      评价商家
                    </button>
                    <button
                      v-else-if="isReviewed(order)"
                      class="btn btn--ghost btn--small"
                      disabled
                    >
                      已评价
                    </button>
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
            description="遇到喜欢的东西记的点收藏哦"
          />
        </section>
      </section>

      <section v-if="reviewModalVisible" class="review-mask" @click.self="closeReview">
        <div class="surface-card review-dialog">
          <div class="between-row review-dialog__head">
            <div>
              <span class="eyebrow">订单评价</span>
              <h2>{{ currentReviewOrder?.accessoryName || '评价商家' }}</h2>
            </div>
            <button class="btn btn--ghost btn--small" @click="closeReview">关闭</button>
          </div>

          <div class="review-dialog__stars">
            <button
              v-for="value in 5"
              :key="value"
              type="button"
              class="review-star"
              :class="{ active: value <= reviewForm.rating }"
              @click="setReviewRating(value)"
            >
              ★
            </button>
            <span>{{ reviewForm.rating }} 分</span>
          </div>

          <label class="review-dialog__field">
            <span>评价内容</span>
            <textarea
              v-model.trim="reviewForm.reviewContent"
              class="textarea"
              placeholder="请输入对商家服务、发货速度和商品质量的评价"
            ></textarea>
          </label>

          <div class="action-row review-dialog__actions">
            <button class="btn btn--primary" :disabled="reviewSubmitting" @click="submitReview">
              {{ reviewSubmitting ? '提交中...' : '提交评价' }}
            </button>
            <button class="btn btn--ghost" @click="closeReview">取消</button>
          </div>
        </div>
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

.review-mask {
  position: fixed;
  inset: 0;
  z-index: 40;
  background: rgba(15, 23, 42, 0.44);
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 24px;
}

.review-dialog {
  width: min(560px, 100%);
  padding: 24px;
}

.review-dialog__head {
  margin-bottom: 18px;
}

.review-dialog__head h2 {
  margin: 10px 0 0;
}

.review-dialog__stars {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: 10px;
  margin-bottom: 20px;
}

.review-star {
  border: none;
  background: transparent;
  color: rgba(200, 128, 36, 0.24);
  font-size: 28px;
  line-height: 1;
  padding: 0;
}

.review-star.active {
  color: var(--accent);
}

.review-dialog__field {
  display: grid;
  gap: 10px;
}

.review-dialog__field span {
  font-size: 14px;
  font-weight: 700;
  color: var(--primary-deep);
}

.review-dialog__actions {
  margin-top: 18px;
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
