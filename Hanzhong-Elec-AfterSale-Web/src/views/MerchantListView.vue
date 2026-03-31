<script setup>
import { computed, onMounted, reactive, ref } from 'vue'
import { RouterLink } from 'vue-router'
import EmptyState from '@/components/EmptyState.vue'
import StatusBadge from '@/components/StatusBadge.vue'
import { commonApi } from '@/lib/api'
import { MERCHANT_AUDIT_STATUS, formatDateTime, getStatusMeta, safeRows, shortText } from '@/lib/domain'
import { pushNotice } from '@/lib/notice'

const loading = ref(false)
const merchantList = ref([])
const total = ref(0)

const filters = reactive({
  merchantName: '',
  cityName: '汉中市',
  pageNum: 1,
  pageSize: 8
})

const pageText = computed(() => {
  if (!total.value) {
    return '暂无门店'
  }
  const maxPage = Math.max(1, Math.ceil(total.value / filters.pageSize))
  return `第 ${filters.pageNum} / ${maxPage} 页，共 ${total.value} 家`
})

async function loadMerchants() {
  loading.value = true
  try {
    const payload = await commonApi.listMerchants({
      merchantName: filters.merchantName,
      cityName: filters.cityName,
      auditStatus: '1',
      pageNum: filters.pageNum,
      pageSize: filters.pageSize
    })
    merchantList.value = safeRows(payload)
    total.value = Number(payload?.total || 0)
  } catch (error) {
    pushNotice(error.message || '服务商家加载失败', 'danger')
  } finally {
    loading.value = false
  }
}

function changePage(offset) {
  const maxPage = Math.max(1, Math.ceil(total.value / filters.pageSize))
  const nextPage = filters.pageNum + offset
  if (nextPage < 1 || nextPage > maxPage) {
    return
  }
  filters.pageNum = nextPage
  loadMerchants()
}

function resetFilters() {
  filters.merchantName = ''
  filters.cityName = '汉中市'
  filters.pageNum = 1
  loadMerchants()
}

onMounted(() => {
  loadMerchants()
})
</script>

<template>
  <section class="page-shell merchant-list-page">
    <section class="glass-card merchant-list-hero">
      <div>
        <span class="eyebrow">门店服务</span>
        <h1>浏览维修服务门店</h1>
      </div>
      <StatusBadge :label="pageText" tone="brand" />
    </section>

    <section class="surface-card section-card merchant-filter">
      <div class="field-row">
        <input
          v-model.trim="filters.merchantName"
          class="field"
          placeholder="搜索商家名称"
          @keyup.enter="filters.pageNum = 1; loadMerchants()"
        />
        <input
          v-model.trim="filters.cityName"
          class="field"
          placeholder="城市，默认汉中市"
          @keyup.enter="filters.pageNum = 1; loadMerchants()"
        />
        <button class="btn btn--primary btn--small" @click="filters.pageNum = 1; loadMerchants()">查询门店</button>
        <button class="btn btn--ghost btn--small" @click="resetFilters">重置</button>
      </div>
    </section>

    <section v-if="loading" class="merchant-grid">
      <article v-for="item in 4" :key="item" class="merchant-card merchant-card--ghost"></article>
    </section>

    <section v-else-if="merchantList.length" class="merchant-grid">
      <RouterLink
        v-for="item in merchantList"
        :key="item.merchantId"
        class="merchant-card"
        :to="{ name: 'merchant-detail', params: { id: item.merchantId } }"
      >
        <div class="merchant-card__head">
          <div>
            <span class="merchant-card__city">{{ item.cityName || '汉中市' }}</span>
            <h2>{{ item.merchantName }}</h2>
          </div>
          <StatusBadge v-bind="getStatusMeta(MERCHANT_AUDIT_STATUS, item.auditStatus)" />
        </div>
        <p>{{ shortText(item.serviceScope || item.merchantDesc || '电子产品维修、检测与配件更换。', 76) }}</p>
        <dl class="merchant-card__meta">
          <div>
            <dt>联系人</dt>
            <dd>{{ item.contactName || '门店客服' }}</dd>
          </div>
          <div>
            <dt>电话</dt>
            <dd>{{ item.contactPhone || '--' }}</dd>
          </div>
          <div>
            <dt>地址</dt>
            <dd>{{ shortText(item.address || '未填写地址', 44) }}</dd>
          </div>
          <div>
            <dt>更新时间</dt>
            <dd>{{ formatDateTime(item.updateTime || item.createTime) }}</dd>
          </div>
        </dl>
      </RouterLink>
    </section>

    <EmptyState
      v-else
      title="没有找到服务商"
      description="可以清空关键词，或者把城市切回汉中市后重新查询。"
      action-label="重置查询"
      @action="resetFilters"
    />

    <section class="surface-card section-card merchant-pagination">
      <div>
        <h2>门店说明</h2>
        <p>这里只展示当前可对外服务的门店，方便用户直接联系和提交售后。</p>
      </div>
      <div class="action-row">
        <button class="btn btn--ghost btn--small" :disabled="filters.pageNum <= 1" @click="changePage(-1)">上一页</button>
        <button
          class="btn btn--primary btn--small"
          :disabled="filters.pageNum >= Math.max(1, Math.ceil(total / filters.pageSize))"
          @click="changePage(1)"
        >
          下一页
        </button>
      </div>
    </section>
  </section>
</template>

<style scoped>
.merchant-list-page {
  display: grid;
  gap: 22px;
}

.merchant-list-hero {
  display: flex;
  align-items: end;
  justify-content: space-between;
  gap: 18px;
  padding: 28px;
}

.merchant-list-hero h1 {
  margin: 14px 0 8px;
  font-size: clamp(32px, 4.2vw, 50px);
  line-height: 1.08;
}

.merchant-grid {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 18px;
}

.merchant-card {
  display: grid;
  gap: 16px;
  padding: 22px;
  border-radius: 28px;
  background: linear-gradient(180deg, rgba(255, 255, 255, 0.96), rgba(248, 244, 236, 0.96));
  border: 1px solid rgba(17, 61, 77, 0.08);
  box-shadow: var(--shadow);
  transition: transform 0.2s ease, box-shadow 0.2s ease;
}

.merchant-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 28px 56px rgba(17, 61, 77, 0.14);
}

.merchant-card--ghost {
  min-height: 260px;
  background: linear-gradient(90deg, rgba(255, 255, 255, 0.7), rgba(237, 245, 247, 0.88), rgba(255, 255, 255, 0.7));
  background-size: 200% 100%;
  animation: merchant-pulse 1.8s linear infinite;
}

.merchant-card__head {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: 12px;
}

.merchant-card__city {
  color: var(--primary);
  font-size: 13px;
  font-weight: 700;
}

.merchant-card__head h2 {
  margin: 8px 0 0;
}

.merchant-card__meta {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 14px;
  margin: 0;
}

.merchant-card__meta dt {
  font-size: 12px;
  color: var(--muted);
  text-transform: uppercase;
  letter-spacing: 0.08em;
}

.merchant-card__meta dd {
  margin: 6px 0 0;
  font-weight: 700;
  color: var(--primary-deep);
}

.merchant-pagination {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 18px;
}

@keyframes merchant-pulse {
  to {
    background-position: -200% 0;
  }
}

@media (max-width: 900px) {
  .merchant-grid {
    grid-template-columns: 1fr;
  }
}

@media (max-width: 720px) {
  .merchant-list-hero,
  .merchant-pagination,
  .field-row,
  .merchant-card__meta {
    display: grid;
  }
}
</style>
