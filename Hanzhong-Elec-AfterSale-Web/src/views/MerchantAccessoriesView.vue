<script setup>
import { computed, onMounted, reactive, ref } from 'vue'
import { useRouter } from 'vue-router'
import EmptyState from '@/components/EmptyState.vue'
import StatusBadge from '@/components/StatusBadge.vue'
import { apiBaseUrl, merchantApi } from '@/lib/api'
import { formatMoney, getRoleState, resolveImage, safeRows, shortText } from '@/lib/domain'
import { pushNotice } from '@/lib/notice'
import { session } from '@/lib/session'

const PAGE_SIZE = 50
const ALL_CATEGORY = '全部分类'
const ALL_STATUS = 'all'
const DEFAULT_STATUS = '0'

const router = useRouter()

const loading = ref(false)
const saving = ref(false)
const uploading = ref(false)
const deletingId = ref('')
const showEditor = ref(false)
const fileInput = ref(null)
const goodsList = ref([])
const searchKeyword = ref('')
const activeCategory = ref(ALL_CATEGORY)
const activeStatus = ref(ALL_STATUS)

const form = reactive({
  accessoryId: '',
  accessoryName: '',
  categoryName: '',
  accessoryDesc: '',
  coverImage: '',
  price: '',
  stock: '',
  status: DEFAULT_STATUS
})

const roleState = computed(() => getRoleState(session.roleType))
const editorTitle = computed(() => (form.accessoryId ? '编辑商品' : '新增商品'))

const categoryOptions = computed(() => {
  const categories = Array.from(
    new Set(
      goodsList.value
        .map(item => item.categoryName)
        .filter(item => typeof item === 'string' && item.trim())
    )
  )
  return [ALL_CATEGORY, ...categories]
})

const filteredGoods = computed(() => {
  const keyword = searchKeyword.value.trim().toLowerCase()

  return goodsList.value.filter(item => {
    const matchCategory = activeCategory.value === ALL_CATEGORY || item.categoryName === activeCategory.value
    const matchStatus = activeStatus.value === ALL_STATUS || item.status === activeStatus.value
    const matchKeyword =
      !keyword ||
      [item.accessoryName, item.categoryName, item.accessoryDesc]
        .filter(Boolean)
        .some(field => String(field).toLowerCase().includes(keyword))

    return matchCategory && matchStatus && matchKeyword
  })
})

const summary = computed(() => ({
  total: goodsList.value.length,
  onShelf: goodsList.value.filter(item => item.status === '0').length,
  offShelf: goodsList.value.filter(item => item.status === '1').length,
  lowStock: goodsList.value.filter(item => item.stock > 0 && item.stock <= 10).length
}))

function getCatalogStatus(item) {
  return item.status === '0'
    ? { label: '上架中', tone: 'success' }
    : { label: '已下架', tone: 'muted' }
}

function getPreviewImage(path) {
  return path ? resolveImage(path, apiBaseUrl) : ''
}

function normalizeAccessory(item = {}) {
  return {
    ...item,
    accessoryId: item.accessoryId,
    accessoryName: item.accessoryName || '未命名商品',
    categoryName: item.categoryName || '未分类',
    accessoryDesc: item.accessoryDesc || '',
    coverImage: item.coverImage || '',
    price: Number(item.price || 0),
    stock: Number(item.stock || 0),
    salesCount: Number(item.salesCount || 0),
    status: String(item.status ?? DEFAULT_STATUS)
  }
}

function resetEditor() {
  form.accessoryId = ''
  form.accessoryName = ''
  form.categoryName = ''
  form.accessoryDesc = ''
  form.coverImage = ''
  form.price = ''
  form.stock = ''
  form.status = DEFAULT_STATUS
}

function fillEditor(item) {
  form.accessoryId = item.accessoryId ? String(item.accessoryId) : ''
  form.accessoryName = item.accessoryName || ''
  form.categoryName = item.categoryName || ''
  form.accessoryDesc = item.accessoryDesc || ''
  form.coverImage = item.coverImage || ''
  form.price = item.price === 0 ? '0' : String(item.price ?? '')
  form.stock = item.stock === 0 ? '0' : String(item.stock ?? '')
  form.status = String(item.status ?? DEFAULT_STATUS)
}

async function fetchAllAccessories() {
  let pageNum = 1
  let total = 0
  const rows = []

  while (true) {
    const payload = await merchantApi.listAccessories({
      pageNum,
      pageSize: PAGE_SIZE
    })
    const nextRows = safeRows(payload)
    rows.push(...nextRows)
    total = Number(payload?.total || 0)

    if (!nextRows.length || nextRows.length < PAGE_SIZE || (total > 0 && rows.length >= total)) {
      break
    }

    pageNum += 1
  }

  return Array.from(
    new Map(rows.map(item => [String(item.accessoryId), normalizeAccessory(item)])).values()
  )
}

async function loadGoodsList() {
  if (!session.token || !roleState.value.isMerchant || loading.value) {
    return
  }

  loading.value = true
  try {
    goodsList.value = await fetchAllAccessories()
    if (!categoryOptions.value.includes(activeCategory.value)) {
      activeCategory.value = ALL_CATEGORY
    }
  } catch (error) {
    goodsList.value = []
    pushNotice(error.message || '商品列表加载失败', 'danger')
  } finally {
    loading.value = false
  }
}

function resetFilters() {
  searchKeyword.value = ''
  activeCategory.value = ALL_CATEGORY
  activeStatus.value = ALL_STATUS
}

function openCreateEditor() {
  resetEditor()
  showEditor.value = true
}

async function openEditEditor(accessoryId) {
  try {
    const detail = normalizeAccessory(await merchantApi.getAccessory(accessoryId))
    fillEditor(detail)
    showEditor.value = true
  } catch (error) {
    pushNotice(error.message || '商品详情加载失败', 'danger')
  }
}

function closeEditor() {
  showEditor.value = false
}

function openFilePicker() {
  fileInput.value?.click()
}

async function handleFileChange(event) {
  const file = event.target.files?.[0]
  event.target.value = ''
  if (!file) {
    return
  }

  uploading.value = true
  try {
    const payload = await merchantApi.uploadAccessoryImage(file)
    form.coverImage = payload?.url || form.coverImage
    pushNotice('图片上传成功', 'success')
  } catch (error) {
    pushNotice(error.message || '图片上传失败', 'danger')
  } finally {
    uploading.value = false
  }
}

function validateEditor() {
  if (!form.accessoryName.trim()) {
    return '请输入商品名称'
  }
  if (!form.categoryName.trim()) {
    return '请输入商品分类'
  }
  if (!form.price || Number(form.price) <= 0) {
    return '请输入有效售价'
  }
  if (form.stock === '' || Number(form.stock) < 0) {
    return '请输入有效库存'
  }
  return ''
}

async function saveGoods() {
  const validationMessage = validateEditor()
  if (validationMessage) {
    pushNotice(validationMessage, 'danger')
    return
  }
  if (saving.value) {
    return
  }

  saving.value = true
  try {
    const payload = {
      accessoryName: form.accessoryName.trim(),
      categoryName: form.categoryName.trim(),
      accessoryDesc: form.accessoryDesc.trim(),
      coverImage: form.coverImage.trim(),
      price: Number(form.price),
      stock: Number(form.stock),
      status: form.status
    }

    if (form.accessoryId) {
      await merchantApi.updateAccessory({
        accessoryId: Number(form.accessoryId),
        ...payload
      })
    } else {
      await merchantApi.createAccessory(payload)
    }

    pushNotice(form.accessoryId ? '商品已更新' : '商品已新增', 'success')
    closeEditor()
    await loadGoodsList()
  } catch (error) {
    pushNotice(error.message || '商品保存失败', 'danger')
  } finally {
    saving.value = false
  }
}

async function removeGoods(item) {
  if (!item?.accessoryId || deletingId.value) {
    return
  }

  const confirmed = window.confirm(`确认删除商品“${item.accessoryName}”吗？`)
  if (!confirmed) {
    return
  }

  deletingId.value = String(item.accessoryId)
  try {
    await merchantApi.deleteAccessory(item.accessoryId)
    pushNotice('商品已删除', 'success')
    if (String(form.accessoryId) === String(item.accessoryId)) {
      closeEditor()
    }
    await loadGoodsList()
  } catch (error) {
    pushNotice(error.message || '商品删除失败', 'danger')
  } finally {
    deletingId.value = ''
  }
}

function toggleShelfStatus() {
  form.status = form.status === '0' ? '1' : '0'
}

function goPreview(item) {
  router.push({
    name: 'accessory-detail',
    params: { id: item.accessoryId }
  })
}

onMounted(() => {
  loadGoodsList()
})
</script>

<template>
  <section class="page-shell merchant-accessories-page">
    <EmptyState
      v-if="!session.token"
      title="请先登录商家账号"
      description="商品管理页只对已登录商家开放。"
      action-label="前往登录"
      @action="router.push({ name: 'auth' })"
    />

    <EmptyState
      v-else-if="!roleState.isMerchant"
      title="当前账号不是商家"
      description="普通用户和待审核商家不能进入商品管理页。"
      action-label="返回个人中心"
      @action="router.push({ name: 'profile' })"
    />

    <template v-else>
      <section class="glass-card catalog-hero">
        <div>
          <span class="eyebrow">商品管理</span>
          <h1>维护商家配件商品</h1>
          <p>这里接入了网页端商家商品列表、图片上传、新增、编辑和删除能力，数据直接写入现有后端接口。</p>
        </div>

        <div class="catalog-hero__actions">
          <button class="btn btn--primary" @click="openCreateEditor">新增商品</button>
          <button class="btn btn--ghost" @click="loadGoodsList">刷新列表</button>
        </div>
      </section>

      <section class="summary-grid">
        <article class="surface-card summary-card">
          <span>商品总数</span>
          <strong>{{ summary.total }}</strong>
          <p>当前商家可见的全部配件商品。</p>
        </article>
        <article class="surface-card summary-card">
          <span>上架商品</span>
          <strong>{{ summary.onShelf }}</strong>
          <p>正在对外展示、可下单的商品数量。</p>
        </article>
        <article class="surface-card summary-card">
          <span>下架商品</span>
          <strong>{{ summary.offShelf }}</strong>
          <p>暂不展示给用户的商品数量。</p>
        </article>
        <article class="surface-card summary-card">
          <span>低库存</span>
          <strong>{{ summary.lowStock }}</strong>
          <p>库存大于 0 且不超过 10 的商品。</p>
        </article>
      </section>

      <section class="surface-card section-card">
        <div class="catalog-toolbar">
          <input
            v-model.trim="searchKeyword"
            class="field"
            placeholder="搜索商品名称、分类或描述"
          />
          <select v-model="activeStatus" class="field status-select">
            <option value="all">全部状态</option>
            <option value="0">上架中</option>
            <option value="1">已下架</option>
          </select>
          <button class="btn btn--ghost btn--small" @click="resetFilters">清空筛选</button>
        </div>

        <div class="chip-row catalog-chip-row">
          <button
            v-for="item in categoryOptions"
            :key="item"
            class="chip"
            :class="{ active: activeCategory === item }"
            @click="activeCategory = item"
          >
            {{ item }}
          </button>
        </div>
      </section>

      <section v-if="loading" class="catalog-grid">
        <article v-for="item in 6" :key="item" class="catalog-card catalog-card--ghost"></article>
      </section>

      <section v-else-if="filteredGoods.length" class="catalog-grid">
        <article v-for="item in filteredGoods" :key="item.accessoryId" class="catalog-card">
          <div class="catalog-card__media">
            <img
              v-if="item.coverImage"
              :src="getPreviewImage(item.coverImage)"
              :alt="item.accessoryName"
            />
            <div v-else class="catalog-card__placeholder">暂无图片</div>
            <StatusBadge v-bind="getCatalogStatus(item)" />
          </div>

          <div class="catalog-card__content">
            <div class="between-row">
              <span class="catalog-card__category">{{ item.categoryName }}</span>
              <span class="catalog-card__sales">销量 {{ item.salesCount }}</span>
            </div>

            <h2>{{ item.accessoryName }}</h2>
            <p>{{ shortText(item.accessoryDesc || '暂无商品描述。', 88) }}</p>

            <div class="catalog-card__meta">
              <div>
                <strong>¥{{ formatMoney(item.price) }}</strong>
                <span>库存 {{ item.stock }}</span>
              </div>
              <div class="catalog-card__meta-right">
                <span>商品编号 {{ item.accessoryId }}</span>
              </div>
            </div>

            <div class="action-row">
              <button class="btn btn--ghost btn--small" @click="goPreview(item)">预览详情</button>
              <button class="btn btn--ghost btn--small" @click="openEditEditor(item.accessoryId)">编辑商品</button>
              <button
                class="btn btn--secondary btn--small"
                :disabled="deletingId === String(item.accessoryId)"
                @click="removeGoods(item)"
              >
                {{ deletingId === String(item.accessoryId) ? '删除中...' : '删除商品' }}
              </button>
            </div>
          </div>
        </article>
      </section>

      <EmptyState
        v-else
        title="当前没有匹配的商品"
        description="可以清空筛选条件，或者直接新增一个商品。"
        action-label="新增商品"
        @action="openCreateEditor"
      />

      <div v-if="showEditor" class="editor-mask" @click="closeEditor">
        <section class="surface-card editor-panel" @click.stop>
          <div class="between-row editor-panel__head">
            <div>
              <span class="eyebrow">商品编辑</span>
              <h2>{{ editorTitle }}</h2>
            </div>
            <StatusBadge :label="form.status === '0' ? '上架中' : '已下架'" :tone="form.status === '0' ? 'success' : 'muted'" />
          </div>

          <div class="editor-preview">
            <img v-if="form.coverImage" :src="getPreviewImage(form.coverImage)" alt="商品预览" />
            <div v-else class="catalog-card__placeholder">暂无图片</div>
          </div>

          <form class="editor-form" @submit.prevent="saveGoods">
            <div class="field-row">
              <label>
                <span>商品名称</span>
                <input v-model.trim="form.accessoryName" class="field" placeholder="请输入商品名称" />
              </label>
              <label>
                <span>商品分类</span>
                <input v-model.trim="form.categoryName" class="field" placeholder="请输入商品分类" />
              </label>
            </div>

            <div class="field-row">
              <label>
                <span>售价</span>
                <input v-model.trim="form.price" class="field" type="number" min="0" step="0.01" placeholder="请输入售价" />
              </label>
              <label>
                <span>库存</span>
                <input v-model.trim="form.stock" class="field" type="number" min="0" step="1" placeholder="请输入库存" />
              </label>
            </div>

            <label>
              <span>图片地址</span>
              <div class="field-row">
                <input v-model.trim="form.coverImage" class="field" placeholder="支持直接填写图片地址或上传图片" />
                <button type="button" class="btn btn--ghost btn--small" :disabled="uploading" @click="openFilePicker">
                  {{ uploading ? '上传中...' : '选择图片' }}
                </button>
              </div>
            </label>

            <label>
              <span>商品描述</span>
              <textarea
                v-model.trim="form.accessoryDesc"
                class="textarea"
                placeholder="请输入商品描述、适配型号或售后说明"
              ></textarea>
            </label>

            <div class="action-row editor-form__footer">
              <button type="button" class="btn btn--ghost" @click="toggleShelfStatus">
                {{ form.status === '0' ? '切换为下架' : '切换为上架' }}
              </button>
              <button type="button" class="btn btn--ghost" @click="closeEditor">取消</button>
              <button class="btn btn--primary" :disabled="saving">
                {{ saving ? '保存中...' : '保存商品' }}
              </button>
            </div>
          </form>
        </section>
      </div>

      <input
        ref="fileInput"
        class="file-input"
        type="file"
        accept="image/*"
        @change="handleFileChange"
      />
    </template>
  </section>
</template>

<style scoped>
.merchant-accessories-page {
  display: grid;
  gap: 22px;
}

.catalog-hero {
  display: flex;
  align-items: end;
  justify-content: space-between;
  gap: 18px;
  padding: 28px;
}

.catalog-hero h1 {
  margin: 14px 0 8px;
  font-size: clamp(32px, 4vw, 48px);
  line-height: 1.08;
}

.catalog-hero__actions {
  display: flex;
  gap: 12px;
  flex-wrap: wrap;
}

.summary-grid {
  display: grid;
  grid-template-columns: repeat(4, minmax(0, 1fr));
  gap: 16px;
}

.summary-card {
  padding: 20px;
}

.summary-card span {
  color: var(--muted);
}

.summary-card strong {
  display: block;
  margin-top: 10px;
  font-size: 28px;
  color: var(--primary-deep);
}

.catalog-toolbar {
  display: grid;
  grid-template-columns: minmax(0, 1fr) 180px auto;
  gap: 12px;
}

.status-select {
  min-width: 0;
}

.catalog-chip-row {
  margin-top: 18px;
}

.catalog-grid {
  display: grid;
  grid-template-columns: repeat(3, minmax(0, 1fr));
  gap: 18px;
}

.catalog-card {
  overflow: hidden;
  border-radius: 26px;
  border: 1px solid rgba(17, 61, 77, 0.1);
  background: linear-gradient(180deg, rgba(255, 255, 255, 0.94), rgba(248, 244, 236, 0.94));
  box-shadow: var(--shadow);
}

.catalog-card--ghost {
  min-height: 360px;
  background: linear-gradient(90deg, rgba(255, 255, 255, 0.7), rgba(237, 245, 247, 0.9), rgba(255, 255, 255, 0.7));
  background-size: 200% 100%;
  animation: catalog-pulse 1.8s linear infinite;
}

.catalog-card__media {
  position: relative;
  display: grid;
  align-items: start;
  gap: 12px;
  padding: 18px 18px 0;
}

.catalog-card__media img,
.editor-preview img {
  width: 100%;
  aspect-ratio: 5 / 4;
  object-fit: cover;
  border-radius: 22px;
}

.catalog-card__media :deep(.status-badge) {
  position: absolute;
  top: 30px;
  right: 30px;
}

.catalog-card__placeholder {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 100%;
  aspect-ratio: 5 / 4;
  border-radius: 22px;
  background: linear-gradient(135deg, rgba(18, 105, 93, 0.14), rgba(215, 141, 43, 0.16));
  color: var(--primary-deep);
  font-weight: 700;
}

.catalog-card__content {
  display: grid;
  gap: 12px;
  padding: 18px;
}

.catalog-card__category,
.catalog-card__sales,
.catalog-card__meta span {
  color: var(--muted);
}

.catalog-card__content h2 {
  margin: 0;
  font-size: 24px;
}

.catalog-card__meta {
  display: flex;
  align-items: end;
  justify-content: space-between;
  gap: 12px;
}

.catalog-card__meta strong {
  display: block;
  font-size: 24px;
  color: var(--primary-deep);
}

.catalog-card__meta-right {
  text-align: right;
}

.editor-mask {
  position: fixed;
  inset: 0;
  z-index: 18;
  display: grid;
  place-items: center;
  padding: 24px;
  background: rgba(10, 23, 21, 0.36);
  backdrop-filter: blur(8px);
}

.editor-panel {
  width: min(860px, 100%);
  max-height: calc(100vh - 48px);
  overflow: auto;
  padding: 28px;
}

.editor-panel__head {
  margin-bottom: 22px;
}

.editor-preview {
  margin-bottom: 18px;
}

.editor-form {
  display: grid;
  gap: 16px;
}

.editor-form label {
  display: grid;
  gap: 8px;
  min-width: 0;
}

.editor-form span {
  font-size: 14px;
  font-weight: 700;
  color: var(--primary-deep);
}

.editor-form__footer {
  justify-content: flex-end;
}

.file-input {
  display: none;
}

@keyframes catalog-pulse {
  to {
    background-position: -200% 0;
  }
}

@media (max-width: 1080px) {
  .summary-grid,
  .catalog-grid {
    grid-template-columns: repeat(2, minmax(0, 1fr));
  }
}

@media (max-width: 820px) {
  .catalog-hero,
  .catalog-toolbar,
  .summary-grid,
  .catalog-grid,
  .field-row {
    grid-template-columns: 1fr;
    display: grid;
  }

  .catalog-card__meta,
  .editor-form__footer {
    display: grid;
  }

  .editor-mask {
    padding: 12px;
  }
}
</style>
