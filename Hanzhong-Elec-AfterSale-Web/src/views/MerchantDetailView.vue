<script setup>
import { computed, onMounted, ref, watch } from 'vue'
import { RouterLink, useRouter } from 'vue-router'
import EmptyState from '@/components/EmptyState.vue'
import StatusBadge from '@/components/StatusBadge.vue'
import { commonApi } from '@/lib/api'
import { MERCHANT_AUDIT_STATUS, formatDateTime, getStatusMeta, shortText } from '@/lib/domain'
import { pushNotice } from '@/lib/notice'
import { session } from '@/lib/session'

const props = defineProps({
  id: {
    type: String,
    required: true
  }
})

const router = useRouter()

const loading = ref(true)
const merchant = ref(null)

const merchantInitial = computed(() => {
  const name = merchant.value?.merchantName || '?'
  return name.slice(0, 1).toUpperCase()
})

async function loadMerchant() {
  loading.value = true
  try {
    merchant.value = await commonApi.getMerchant(props.id)
  } catch (error) {
    merchant.value = null
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
        <div class="merchant-avatar">{{ merchantInitial }}</div>

        <div class="surface-card merchant-detail-main">
          <div class="between-row merchant-detail-main__top">
            <span class="eyebrow">{{ merchant.cityName || '汉中市' }}</span>
            <StatusBadge v-bind="getStatusMeta(MERCHANT_AUDIT_STATUS, merchant.auditStatus)" />
          </div>
          <h1>{{ merchant.merchantName }}</h1>
          <p>{{ merchant.merchantDesc || '提供电子产品检测、维修、保养和配件更换服务。' }}</p>

          <div class="merchant-detail-actions">
            <a class="btn btn--primary" :href="`tel:${merchant.contactPhone || ''}`">拨打电话</a>
            <RouterLink
              class="btn btn--secondary"
              :to="{ name: 'after-sales-apply', query: { merchantName: merchant.merchantName } }"
            >
              提交售后申请
            </RouterLink>
            <RouterLink
              v-if="session.merchant?.merchantId === merchant.merchantId"
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
              <p>查看联系人、电话、地址和门店基础信息。</p>
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
          </div>
        </section>

        <section class="surface-card section-card">
          <div class="section-head">
            <div>
              <span class="eyebrow">服务范围</span>
              <h2>服务范围</h2>
              <p>了解门店擅长的维修项目和服务方向。</p>
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

.merchant-detail-actions {
  display: flex;
  flex-wrap: wrap;
  gap: 12px;
  margin-top: 24px;
}

.merchant-detail-grid {
  display: grid;
  grid-template-columns: minmax(0, 0.95fr) minmax(320px, 1.05fr);
  gap: 24px;
}

.merchant-detail-cards {
  display: grid;
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

@media (max-width: 900px) {
  .merchant-detail-hero,
  .merchant-detail-grid {
    grid-template-columns: 1fr;
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
