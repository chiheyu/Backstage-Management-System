<script setup>
import { computed, onMounted, reactive, watch } from 'vue'
import { RouterLink, useRouter } from 'vue-router'
import EmptyState from '@/components/EmptyState.vue'
import StatusBadge from '@/components/StatusBadge.vue'
import { apiBaseUrl, commonApi } from '@/lib/api'
import { formatMoney, getRoleState, resolveImage, safeRows, shortText } from '@/lib/domain'
import { addCartItem } from '@/lib/localData'
import { pushNotice } from '@/lib/notice'
import { session } from '@/lib/session'

const router = useRouter()
const accessoryList = reactive([])
const state = reactive({
  loading: false,
  total: 0
})

const filters = reactive({
  accessoryName: '',
  categoryName: '',
  beginPrice: '',
  endPrice: '',
  pageNum: 1,
  pageSize: 9
})

const roleState = computed(() => getRoleState(session.roleType))

const categoryOptions = computed(() => {
  const all = ['全部']
  accessoryList.forEach(item => {
    if (item.categoryName && !all.includes(item.categoryName)) {
      all.push(item.categoryName)
    }
  })
  return all
})

const paginationSummary = computed(() => {
  const start = (filters.pageNum - 1) * filters.pageSize + 1
  const end = Math.min(filters.pageNum * filters.pageSize, state.total)
  if (!state.total) {
    return '暂无结果'
  }
  return `${start}-${end} / ${state.total}`
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
  state.loading = true
  try {
    const payload = await commonApi.listAccessories(buildParams())
    accessoryList.splice(0, accessoryList.length, ...safeRows(payload))
    state.total = Number(payload?.total || 0)
  } catch (error) {
    pushNotice(error.message || '配件列表加载失败', 'danger')
  } finally {
    state.loading = false
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
  const maxPage = Math.max(1, Math.ceil(state.total / filters.pageSize))
  if (nextPage < 1 || nextPage > maxPage) {
    return
  }
  filters.pageNum = nextPage
  loadAccessories()
}

function handleAddCart(item) {
  if (roleState.value.isMerchant) {
    router.push({ name: 'accessory-detail', params: { id: item.accessoryId } })
    return
  }

  if (Number(item.stock || 0) <= 0) {
    pushNotice('当前商品库存不足', 'danger')
    return
  }

  addCartItem({
    id: item.accessoryId,
    accessoryId: item.accessoryId,
    name: item.accessoryName,
    spec: item.categoryName,
    desc: item.accessoryDesc,
    image: resolveImage(item.coverImage, apiBaseUrl),
    price: item.price,
    stock: item.stock,
    count: 1
  })
  pushNotice('已加入购物车', 'success')
}

watch(
  () => session.roleType,
  () => {
    filters.pageNum = 1
    loadAccessories()
  }
)

onMounted(() => {
  loadAccessories()
})
</script>

<template>
  <section class="page-shell mall-page">
    <section class="glass-card merchant-mall-hero">
      <div>
        <span class="eyebrow">{{ roleState.isMerchant ? '配件浏览' : '配件商城' }}</span>
        <h1>{{ roleState.isMerchant ? '商家浏览公共配件数据' : '筛选在售配件' }}</h1>
        
      </div>
      <div class="merchant-mall-stats">
        <article class="surface-card merchant-mall-stat">
          <span>当前结果</span>
          <strong>{{ state.total }}</strong>
        </article>
        <article class="surface-card merchant-mall-stat">
          <span>库存充足</span>
          <strong>{{ accessoryList.filter(item => Number(item.stock || 0) > 0).length }}</strong>
        </article>
        <article class="surface-card merchant-mall-stat">
          <span>分页</span>
          <strong>{{ paginationSummary }}</strong>
        </article>
      </div>
    </section>

    <section class="surface-card section-card mall-filter-card">
      <div class="mall-toolbar">
        <input
          v-model.trim="filters.accessoryName"
          class="field"
          placeholder="搜索配件名称，例如：屏幕、电池、数据线"
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

    <section v-if="state.loading" class="mall-grid">
      <article v-for="item in 6" :key="item" class="mall-card mall-card--ghost"></article>
    </section>

    <section v-else-if="accessoryList.length" class="mall-grid">
      <article v-for="item in accessoryList" :key="item.accessoryId" class="mall-card">
        <RouterLink class="mall-card__cover" :to="{ name: 'accessory-detail', params: { id: item.accessoryId } }">
          <img :src="resolveImage(item.coverImage, apiBaseUrl)" :alt="item.accessoryName" />
        </RouterLink>

        <div class="mall-card__content">
          <div class="between-row">
            <span class="mall-card__tag">{{ item.categoryName || '通用配件' }}</span>
            <StatusBadge
              :label="roleState.isMerchant ? '公开视图' : item.collected ? '已收藏' : '可加购'"
              :tone="roleState.isMerchant ? 'muted' : item.collected ? 'warm' : 'brand'"
            />
          </div>

          <RouterLink :to="{ name: 'accessory-detail', params: { id: item.accessoryId } }">
            <h3>{{ item.accessoryName }}</h3>
          </RouterLink>

          <p>{{ shortText(item.accessoryDesc || '适用于常见电子产品维修、更换和保养场景。', 60) }}</p>

          <div class="merchant-meta">
            <span>库存 {{ item.stock || 0 }}</span>
            <span>销量 {{ item.salesCount || 0 }}</span>
          </div>

          <div class="mall-card__stats">
            <div>
              <strong>￥{{ formatMoney(item.price) }}</strong>
              <span>库存 {{ item.stock || 0 }}</span>
            </div>
            <button
              class="btn"
              :class="roleState.isMerchant ? 'btn--ghost btn--small' : 'btn--primary btn--small'"
              :disabled="!roleState.isMerchant && Number(item.stock || 0) <= 0"
              @click="handleAddCart(item)"
            >
              {{ roleState.isMerchant ? '查看详情' : Number(item.stock || 0) <= 0 ? '已售罄' : '加入购物车' }}
            </button>
          </div>
        </div>
      </article>
    </section>

    <EmptyState
      v-else
      title="没有找到匹配配件"
      description="可以尝试切换分类、放宽价格筛选条件，或清空关键词。"
      action-label="重置筛选"
      @action="resetFilters"
    />

    <section class="surface-card section-card mall-footer-card">
      <div>
        <h2>{{ roleState.isMerchant ? '商家说明' : '下单提示' }}</h2>
        <p v-if="roleState.isMerchant">这里继续保留公开商城预览；商品维护和商家订单处理请分别前往“商品管理”和“配件订单”页面。</p>
        <p v-else>普通用户可先加入购物车再统一结算，也可以直接在详情页下单和收藏。</p>
      </div>
      <div class="action-row">
        <template v-if="roleState.isMerchant">
          <button class="btn btn--ghost btn--small" @click="router.push({ name: 'merchant-accessories' })">前往商品管理</button>
          <button class="btn btn--primary btn--small" @click="router.push({ name: 'merchant-accessory-orders' })">前往配件订单</button>
        </template>
        <template v-else>
          <button class="btn btn--ghost btn--small" :disabled="filters.pageNum <= 1" @click="changePage(-1)">上一页</button>
          <button
            class="btn btn--primary btn--small"
            :disabled="filters.pageNum >= Math.max(1, Math.ceil(state.total / filters.pageSize))"
            @click="changePage(1)"
          >
            下一页
          </button>
        </template>
      </div>
    </section>
  </section>
</template>

<style scoped>
.mall-page {
  display: grid;
  gap: 22px;
}

.merchant-mall-hero {
  display: grid;
  grid-template-columns: minmax(0, 1fr) 440px;
  gap: 22px;
  padding: 28px;
}

.merchant-mall-hero h1,
.mall-filter-card h1 {
  margin-bottom: 8px;
}

.merchant-mall-stats {
  display: grid;
  grid-template-columns: repeat(3, minmax(0, 1fr));
  gap: 14px;
}

.merchant-mall-stat {
  padding: 18px;
}

.merchant-mall-stat span,
.merchant-meta span {
  color: var(--muted);
}

.merchant-mall-stat strong {
  display: block;
  margin-top: 10px;
  font-size: 26px;
  color: var(--primary-deep);
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
  display: block;
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

.mall-card__stats span {
  color: var(--muted);
}

.merchant-meta {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
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
  .merchant-mall-hero,
  .mall-grid {
    grid-template-columns: repeat(2, minmax(0, 1fr));
  }

  .mall-toolbar {
    grid-template-columns: repeat(2, minmax(0, 1fr));
  }
}

@media (max-width: 720px) {
  .merchant-mall-hero,
  .merchant-mall-stats,
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
