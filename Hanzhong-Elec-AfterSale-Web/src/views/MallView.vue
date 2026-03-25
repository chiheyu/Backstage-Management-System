<script setup>
import { computed, onMounted, reactive, ref, watch } from 'vue'
import { RouterLink } from 'vue-router'
import EmptyState from '@/components/EmptyState.vue'
import StatusBadge from '@/components/StatusBadge.vue'
import { apiBaseUrl, commonApi } from '@/lib/api'
import { formatMoney, resolveImage, safeRows, shortText } from '@/lib/domain'
import { pushNotice } from '@/lib/notice'
import { session } from '@/lib/session'

const loading = ref(false)
const accessoryList = ref([])
const total = ref(0)

const filters = reactive({
  accessoryName: '',
  categoryName: '',
  beginPrice: '',
  endPrice: '',
  pageNum: 1,
  pageSize: 9
})

const categoryOptions = computed(() => {
  const all = ['全部']
  accessoryList.value.forEach(item => {
    if (item.categoryName && !all.includes(item.categoryName)) {
      all.push(item.categoryName)
    }
  })
  return all
})

const paginationSummary = computed(() => {
  const start = (filters.pageNum - 1) * filters.pageSize + 1
  const end = Math.min(filters.pageNum * filters.pageSize, total.value)
  if (!total.value) {
    return '暂无结果'
  }
  return `${start}-${end} / ${total.value}`
})

function buildParams() {
  return {
    accessoryName: filters.accessoryName,
    categoryName: filters.categoryName === '全部' ? '' : filters.categoryName,
    status: '0',
    pageNum: filters.pageNum,
    pageSize: filters.pageSize,
    params: {
      beginPrice: filters.beginPrice,
      endPrice: filters.endPrice,
      appUserId: session.appUser?.appUserId
    }
  }
}

async function loadAccessories() {
  loading.value = true
  try {
    const payload = await commonApi.listAccessories(buildParams())
    accessoryList.value = safeRows(payload)
    total.value = Number(payload?.total || 0)
  } catch (error) {
    pushNotice(error.message || '配件列表加载失败', 'danger')
  } finally {
    loading.value = false
  }
}

function resetFilters() {
  filters.accessoryName = ''
  filters.categoryName = ''
  filters.beginPrice = ''
  filters.endPrice = ''
  filters.pageNum = 1
  loadAccessories()
}

function applyCategory(name) {
  filters.categoryName = name === '全部' ? '' : name
  filters.pageNum = 1
  loadAccessories()
}

function changePage(offset) {
  const nextPage = filters.pageNum + offset
  const maxPage = Math.max(1, Math.ceil(total.value / filters.pageSize))
  if (nextPage < 1 || nextPage > maxPage) {
    return
  }
  filters.pageNum = nextPage
  loadAccessories()
}

watch(
  () => session.appUser?.appUserId,
  () => {
    loadAccessories()
  }
)

onMounted(() => {
  loadAccessories()
})
</script>

<template>
  <section class="page-shell mall-page">
    <section class="surface-card section-card mall-filter-card">
      <div class="section-head">
        <div>
          <span class="eyebrow">配件商城</span>
          <h1>筛选在售配件</h1>
          <p>按名称、分类和价格区间筛选，快速找到合适的维修配件。</p>
        </div>
        <StatusBadge :label="paginationSummary" tone="brand" />
      </div>

      <div class="mall-toolbar">
        <input
          v-model.trim="filters.accessoryName"
          class="field"
          placeholder="搜索配件名称，例如 屏幕、电池、数据线"
          @keyup.enter="filters.pageNum = 1; loadAccessories()"
        />
        <input
          v-model.trim="filters.beginPrice"
          class="field"
          placeholder="最低价格"
          @keyup.enter="filters.pageNum = 1; loadAccessories()"
        />
        <input
          v-model.trim="filters.endPrice"
          class="field"
          placeholder="最高价格"
          @keyup.enter="filters.pageNum = 1; loadAccessories()"
        />
        <button class="btn btn--primary btn--small" @click="filters.pageNum = 1; loadAccessories()">开始筛选</button>
        <button class="btn btn--ghost btn--small" @click="resetFilters">重置</button>
      </div>

      <div class="chip-row mall-chip-row">
        <button
          v-for="item in categoryOptions"
          :key="item"
          class="chip"
          :class="{ active: (filters.categoryName || '全部') === item }"
          @click="applyCategory(item)"
        >
          {{ item }}
        </button>
      </div>
    </section>

    <section v-if="loading" class="mall-grid">
      <article v-for="item in 6" :key="item" class="mall-card mall-card--ghost"></article>
    </section>

    <section v-else-if="accessoryList.length" class="mall-grid">
      <RouterLink
        v-for="item in accessoryList"
        :key="item.accessoryId"
        class="mall-card"
        :to="{ name: 'accessory-detail', params: { id: item.accessoryId } }"
      >
        <div class="mall-card__cover">
          <img :src="resolveImage(item.coverImage, apiBaseUrl)" :alt="item.accessoryName" />
        </div>

          <div class="mall-card__content">
            <div class="between-row">
              <span class="mall-card__tag">{{ item.categoryName || '通用配件' }}</span>
              <StatusBadge :label="item.collected ? '已收藏' : '可下单'" :tone="item.collected ? 'warm' : 'brand'" />
            </div>
            <h3>{{ item.accessoryName }}</h3>
            <p>{{ shortText(item.accessoryDesc || '适用于常见电子产品维修、更换和保养场景。', 60) }}</p>

          <div class="mall-card__stats">
            <div>
              <strong>￥{{ formatMoney(item.price) }}</strong>
              <span>库存 {{ item.stock || 0 }}</span>
            </div>
            <small>销量 {{ item.salesCount || 0 }}</small>
          </div>
        </div>
      </RouterLink>
    </section>

    <EmptyState
      v-else
      title="没有找到匹配配件"
      description="可以尝试切换分类、降低价格筛选条件，或清空关键词。"
      action-label="重置筛选"
      @action="resetFilters"
    />

    <section class="surface-card section-card mall-footer-card">
      <div>
        <h2>下单提示</h2>
        <p>普通用户可直接下单和收藏商品，商家账号主要用于处理售后工单。</p>
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
.mall-page {
  display: grid;
  gap: 22px;
}

.mall-filter-card h1 {
  margin-bottom: 8px;
}

.mall-toolbar {
  display: grid;
  grid-template-columns: minmax(0, 2fr) repeat(2, minmax(0, 1fr)) auto auto;
  gap: 12px;
}

.mall-chip-row {
  margin-top: 18px;
}

.mall-grid {
  display: grid;
  grid-template-columns: repeat(3, minmax(0, 1fr));
  gap: 18px;
}

.mall-card {
  overflow: hidden;
  border-radius: 26px;
  border: 1px solid rgba(17, 61, 77, 0.1);
  background: linear-gradient(180deg, rgba(255, 255, 255, 0.94), rgba(248, 244, 236, 0.94));
  box-shadow: var(--shadow);
  transition: transform 0.2s ease, box-shadow 0.2s ease;
}

.mall-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 28px 52px rgba(17, 61, 77, 0.14);
}

.mall-card--ghost {
  min-height: 360px;
  background: linear-gradient(90deg, rgba(255, 255, 255, 0.7), rgba(237, 245, 247, 0.9), rgba(255, 255, 255, 0.7));
  background-size: 200% 100%;
  animation: mall-pulse 1.8s linear infinite;
}

.mall-card__cover {
  aspect-ratio: 5 / 4;
  background: linear-gradient(135deg, rgba(14, 116, 144, 0.14), rgba(245, 158, 11, 0.16));
}

.mall-card__cover img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.mall-card__content {
  display: grid;
  gap: 12px;
  padding: 18px;
}

.mall-card__tag {
  display: inline-flex;
  align-items: center;
  color: var(--primary);
  font-weight: 700;
}

.mall-card__content h3 {
  margin: 0;
}

.mall-card__stats {
  display: flex;
  align-items: end;
  justify-content: space-between;
  gap: 12px;
}

.mall-card__stats strong {
  display: block;
  font-size: 24px;
  color: var(--primary-deep);
}

.mall-card__stats span,
.mall-card__stats small {
  color: var(--muted);
}

.mall-footer-card {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 16px;
}

@keyframes mall-pulse {
  to {
    background-position: -200% 0;
  }
}

@media (max-width: 1080px) {
  .mall-grid {
    grid-template-columns: repeat(2, minmax(0, 1fr));
  }

  .mall-toolbar {
    grid-template-columns: repeat(2, minmax(0, 1fr));
  }
}

@media (max-width: 720px) {
  .mall-grid,
  .mall-toolbar {
    grid-template-columns: 1fr;
  }

  .mall-footer-card {
    flex-direction: column;
    align-items: stretch;
  }
}
</style>
