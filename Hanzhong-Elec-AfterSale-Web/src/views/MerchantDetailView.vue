<script setup>
import { computed, onMounted, ref, watch } from 'vue'
import { RouterLink, useRouter } from 'vue-router'
import EmptyState from '@/components/EmptyState.vue'
import StatusBadge from '@/components/StatusBadge.vue'
import { apiBaseUrl, commonApi } from '@/lib/api'
import { MERCHANT_AUDIT_STATUS, formatDateTime, getStatusMeta, resolveImage, shortText } from '@/lib/domain'
import { pushNotice } from '@/lib/notice'
import { session } from '@/lib/session'
import { loadMerchantShopMeta } from '@/lib/storage'

const props = defineProps({
  id: {
    type: String,
    required: true
  }
})

const router = useRouter()

const loading = ref(true)
const merchant = ref(null)
const merchantLocalConfig = ref(loadMerchantShopMeta(''))
const reviewsLoading = ref(false)
const reviewList = ref([])
const reviewTotal = ref(0)
const reviewAvgRating = ref(0)

const merchantInitial = computed(() => {
  const name = merchant.value?.merchantName || '?'
  return name.slice(0, 1).toUpperCase()
})

const isOwnMerchant = computed(() => {
  return String(session.merchant?.merchantId || '') === String(merchant.value?.merchantId || '')
})

const merchantLogo = computed(() => {
  return merchantLocalConfig.value.logo
    ? resolveImage(merchantLocalConfig.value.logo, apiBaseUrl)
    : ''
})

const hasLocalDisplayConfig = computed(() => {
  return Boolean(
    merchantLocalConfig.value.logo ||
    merchantLocalConfig.value.businessTime ||
    merchantLocalConfig.value.isOpen === false
  )
})

const businessStatus = computed(() => (
  merchantLocalConfig.value.isOpen
    ? { label: '营业中', tone: 'success' }
    : { label: '暂停营业', tone: 'muted' }
))

const reviewSummary = computed(() => {
  const avgRating = Number(reviewAvgRating.value || 0)
  if (avgRating <= 0) {
    return '暂无评分'
  }
  return `${avgRating.toFixed(1)} 分`
})

const reviewStars = computed(() => {
  const avgRating = Math.round(Number(reviewAvgRating.value || 0))
  return Array.from({ length: 5 }, (_, index) => index < avgRating)
})

function syncMerchantLocalConfig(merchantId) {
  merchantLocalConfig.value = loadMerchantShopMeta(merchantId)
}

async function loadMerchantReviews(merchantId) {
  if (!merchantId) {
    reviewList.value = []
    reviewTotal.value = 0
    reviewAvgRating.value = 0
    return
  }

  reviewsLoading.value = true
  try {
    const reviewPayload = await commonApi.listMerchantReviews(merchantId)
    const rows = Array.isArray(reviewPayload?.rows) ? reviewPayload.rows : []
    reviewList.value = rows
    reviewTotal.value = Number(reviewPayload?.total || rows.length || 0)
    reviewAvgRating.value = Number(reviewPayload?.avgRating || 0)
  } catch (error) {
    reviewList.value = []
    reviewTotal.value = 0
    reviewAvgRating.value = 0
    pushNotice(error.message || '商家评价加载失败', 'danger')
  } finally {
    reviewsLoading.value = false
  }
}

async function loadMerchant() {
  loading.value = true
  try {
    merchant.value = await commonApi.getMerchant(props.id)
    syncMerchantLocalConfig(merchant.value?.merchantId)
    await loadMerchantReviews(merchant.value?.merchantId)
  } catch (error) {
    merchant.value = null
    merchantLocalConfig.value = loadMerchantShopMeta('')
    reviewList.value = []
    reviewTotal.value = 0
    reviewAvgRating.value = 0
    pushNotice(error.message || '商家详情加载失败', 'danger')
  } finally {
    loading.value = false
  }
}

watch(
  () => props.id,
  () => {
    loadMerchant()
  }
)

onMounted(() => {
  loadMerchant()
})
</script>

<template>
  <section class="page-shell merchant-detail-page">
    <section v-if="loading" class="surface-card section-card">
      <h1>正在加载商家详情...</h1>
      <p>正在同步门店资料、服务范围和联系方式。</p>
    </section>

    <EmptyState
      v-else-if="!merchant"
      title="商家不存在"
      description="该商家可能未审核通过，或门店编号已失效。"
      action-label="返回商家列表"
      @action="router.push({ name: 'merchants' })"
    />

    <template v-else>
      <section class="glass-card merchant-detail-hero">
        <div class="merchant-avatar" :class="{ 'merchant-avatar--image': merchantLogo }">
          <img v-if="merchantLogo" :src="merchantLogo" alt="门店 Logo" />
          <template v-else>{{ merchantInitial }}</template>
        </div>

        <div class="surface-card merchant-detail-main">
          <div class="between-row merchant-detail-main__top">
            <span class="eyebrow">{{ merchant.cityName || '汉中市' }}</span>
            <div class="action-row merchant-detail-badges">
              <StatusBadge v-bind="getStatusMeta(MERCHANT_AUDIT_STATUS, merchant.auditStatus)" />
              <StatusBadge v-if="hasLocalDisplayConfig" v-bind="businessStatus" />
            </div>
          </div>
          <h1>{{ merchant.merchantName }}</h1>
          <p>{{ merchant.merchantDesc || '提供电子产品检测、维修、保养和配件更换服务。' }}</p>

          <div class="merchant-rating-inline">
            <div class="merchant-rating-stars">
              <span
                v-for="(filled, index) in reviewStars"
                :key="`star-${index}`"
                :class="['merchant-rating-star', { filled }]"
              >
                ★
              </span>
            </div>
            <strong>{{ reviewSummary }}</strong>
            <span>{{ reviewTotal }} 条评价</span>
          </div>

          <div class="merchant-detail-actions">
            <a class="btn btn--primary" :href="`tel:${merchant.contactPhone || ''}`">拨打电话</a>
            <RouterLink
              class="btn btn--secondary"
              :to="{ name: 'after-sales-apply', query: { merchantName: merchant.merchantName } }"
            >
              提交售后申请
            </RouterLink>
            <RouterLink
              v-if="isOwnMerchant"
              class="btn btn--ghost"
              :to="{ name: 'merchant-settings' }"
            >
              编辑我的门店
            </RouterLink>
          </div>
        </div>
      </section>

      <section class="merchant-detail-grid">
        <section class="surface-card section-card">
          <div class="section-head">
            <div>
              <span class="eyebrow">门店资料</span>
              <h2>服务信息</h2>
            </div>
          </div>

          <div class="merchant-detail-cards">
            <article>
              <strong>联系人</strong>
              <span>{{ merchant.contactName || '商家客服' }}</span>
            </article>
            <article>
              <strong>联系电话</strong>
              <span>{{ merchant.contactPhone || '--' }}</span>
            </article>
            <article>
              <strong>服务地址</strong>
              <span>{{ merchant.address || '暂未填写' }}</span>
            </article>
            <article>
              <strong>入驻时间</strong>
              <span>{{ formatDateTime(merchant.createTime) }}</span>
            </article>
            <article v-if="hasLocalDisplayConfig || isOwnMerchant">
              <strong>营业时间</strong>
              <span>{{ merchantLocalConfig.businessTime || '未设置' }}</span>
            </article>
            <article v-if="hasLocalDisplayConfig || isOwnMerchant">
              <strong>营业状态</strong>
              <span>{{ businessStatus.label }}</span>
            </article>
          </div>
        </section>

        <section class="surface-card section-card">
          <div class="section-head">
            <div>
              <span class="eyebrow">服务范围</span>
              <h2>服务范围</h2>
            </div>
          </div>

          <div class="merchant-scope">
            <p>{{ merchant.serviceScope || '暂未填写详细服务范围。' }}</p>
            <div class="merchant-scope__tips">
              <article>
                <strong>适用场景</strong>
                <span>{{ shortText(merchant.serviceScope || '手机维修、配件更换、检测保养、系统排障。', 34) }}</span>
              </article>
              <article>
                <strong>处理方式</strong>
                <span>提交售后申请后，门店可接单并持续更新维修进度。</span>
              </article>
            </div>
          </div>
        </section>
      </section>

      <section class="surface-card section-card review-section">
        <div class="section-head">
          <div>
            <span class="eyebrow">用户评价</span>
            <h2>用户评价</h2>
            <p>这里展示当前商家在已完成配件订单上的真实评价记录。</p>
          </div>
          <div class="review-summary-chip">
            <strong>{{ reviewSummary }}</strong>
            <span>{{ reviewTotal }} 条</span>
          </div>
        </div>

        <div v-if="reviewsLoading" class="review-loading">正在同步评价列表...</div>

        <div v-else-if="reviewList.length" class="review-list">
          <article v-for="item in reviewList" :key="item.reviewId" class="review-card">
            <div class="review-card__head">
              <div>
                <strong>{{ item.userName || '匿名用户' }}</strong>
                <div class="review-card__stars">
                  <span
                    v-for="starIndex in 5"
                    :key="`${item.reviewId}-${starIndex}`"
                    :class="['merchant-rating-star', { filled: starIndex <= Number(item.rating || 0) }]"
                  >
                    ★
                  </span>
                </div>
              </div>
              <span>{{ formatDateTime(item.createTime) }}</span>
            </div>
            <p>{{ item.reviewContent || '用户未填写评价内容。' }}</p>
          </article>
        </div>

        <EmptyState
          v-else
          title="暂无用户评价"
          description="当前商家还没有已公开展示的评价记录。"
        />
      </section>
    </template>
  </section>
</template>

<style scoped>
.merchant-detail-page {
  display: grid;
  gap: 24px;
}

.merchant-detail-hero {
  display: grid;
  grid-template-columns: 160px minmax(0, 1fr);
  gap: 24px;
  padding: 28px;
}

.merchant-avatar {
  display: flex;
  align-items: center;
  justify-content: center;
  min-height: 160px;
  border-radius: 36px;
  background: linear-gradient(135deg, var(--primary), var(--primary-deep));
  color: #fff;
  font-size: 62px;
  font-weight: 800;
  overflow: hidden;
}

.merchant-avatar--image {
  background: linear-gradient(135deg, rgba(18, 105, 93, 0.12), rgba(215, 141, 43, 0.16));
}

.merchant-avatar img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.merchant-detail-main {
  padding: 24px;
}

.merchant-detail-main__top {
  margin-bottom: 16px;
}

.merchant-detail-main h1 {
  margin: 0 0 12px;
  font-size: clamp(30px, 4vw, 48px);
  line-height: 1.08;
}

.merchant-detail-badges {
  flex-wrap: wrap;
}

.merchant-detail-actions {
  display: flex;
  flex-wrap: wrap;
  gap: 12px;
  margin-top: 24px;
}

.merchant-rating-inline {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: 12px;
  margin-top: 18px;
  color: var(--muted);
}

.merchant-rating-stars,
.review-card__stars {
  display: inline-flex;
  gap: 4px;
}

.merchant-rating-star {
  color: rgba(200, 128, 36, 0.26);
  font-size: 18px;
  line-height: 1;
}

.merchant-rating-star.filled {
  color: var(--accent);
}

.merchant-detail-grid {
  display: grid;
  grid-template-columns: minmax(0, 0.95fr) minmax(320px, 1.05fr);
  gap: 24px;
}

.merchant-detail-cards {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 14px;
}

.merchant-detail-cards article,
.merchant-scope__tips article {
  padding: 18px;
  border-radius: 22px;
  background: linear-gradient(180deg, rgba(255, 255, 255, 0.92), rgba(247, 243, 235, 0.92));
  border: 1px solid rgba(17, 61, 77, 0.08);
}

.merchant-detail-cards strong,
.merchant-scope strong {
  display: block;
  margin-bottom: 8px;
}

.merchant-scope {
  display: grid;
  gap: 18px;
}

.merchant-scope__tips {
  display: grid;
  gap: 14px;
}

.review-section {
  display: grid;
  gap: 18px;
}

.review-summary-chip {
  display: inline-flex;
  align-items: center;
  gap: 12px;
  padding: 10px 14px;
  border-radius: 999px;
  background: rgba(17, 117, 101, 0.08);
  color: var(--primary-deep);
}

.review-summary-chip strong {
  color: var(--accent-deep);
}

.review-loading {
  color: var(--muted);
}

.review-list {
  display: grid;
  gap: 14px;
}

.review-card {
  padding: 18px;
  border-radius: 22px;
  background: linear-gradient(180deg, rgba(255, 255, 255, 0.94), rgba(247, 243, 235, 0.94));
  border: 1px solid rgba(17, 61, 77, 0.08);
}

.review-card__head {
  display: flex;
  justify-content: space-between;
  gap: 12px;
  align-items: flex-start;
  margin-bottom: 10px;
}

.review-card__head strong {
  display: block;
  margin-bottom: 8px;
}

.review-card__head span {
  color: var(--muted);
  font-size: 14px;
}

@media (max-width: 900px) {
  .merchant-detail-hero,
  .merchant-detail-grid,
  .merchant-detail-cards {
    grid-template-columns: 1fr;
  }

  .review-card__head {
    display: grid;
  }
}

@media (max-width: 720px) {
  .merchant-detail-hero {
    padding: 18px;
  }

  .merchant-detail-main__top {
    display: grid;
  }
}
</style>
