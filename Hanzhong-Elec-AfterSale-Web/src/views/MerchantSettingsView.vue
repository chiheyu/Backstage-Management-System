<script setup>
import { computed, onMounted, reactive, ref } from 'vue'
import { useRouter } from 'vue-router'
import EmptyState from '@/components/EmptyState.vue'
import StatusBadge from '@/components/StatusBadge.vue'
import { apiBaseUrl, commonApi, merchantApi } from '@/lib/api'
import { MERCHANT_AUDIT_STATUS, getRoleState, getStatusMeta, resolveImage } from '@/lib/domain'
import { pushNotice } from '@/lib/notice'
import { session } from '@/lib/session'
import { loadMerchantShopMeta, saveMerchantShopMeta, saveStoredSession } from '@/lib/storage'

const router = useRouter()

const loading = ref(false)
const saving = ref(false)
const uploading = ref(false)
const fileInput = ref(null)

const form = reactive({
  merchantName: '',
  contactName: '',
  contactPhone: '',
  cityName: '',
  address: '',
  serviceScope: '',
  merchantDesc: ''
})

const localForm = reactive({
  logo: '',
  businessTime: '09:00',
  isOpen: true
})

const roleState = computed(() => getRoleState(session.roleType))
const currentMerchantId = computed(() => session.merchant?.merchantId || '')
const logoPreview = computed(() => resolveImage(localForm.logo, apiBaseUrl))
const businessStatusBadge = computed(() => (
  localForm.isOpen
    ? { label: '营业中', tone: 'success' }
    : { label: '暂停营业', tone: 'muted' }
))

function fillForm(source) {
  form.merchantName = source?.merchantName || ''
  form.contactName = source?.contactName || ''
  form.contactPhone = source?.contactPhone || ''
  form.cityName = source?.cityName || '汉中市'
  form.address = source?.address || ''
  form.serviceScope = source?.serviceScope || ''
  form.merchantDesc = source?.merchantDesc || ''
}

function fillLocalForm(source = {}) {
  localForm.logo = source.logo || ''
  localForm.businessTime = source.businessTime || '09:00'
  localForm.isOpen = source.isOpen !== false
}

function loadLocalConfig(merchantId) {
  fillLocalForm(loadMerchantShopMeta(merchantId))
}

async function loadMerchantInfo() {
  if (!session.token || !roleState.value.isMerchant) {
    return
  }

  loading.value = true
  try {
    const merchant = await merchantApi.currentInfo()
    session.merchant = merchant
    saveStoredSession({
      token: session.token,
      appUser: session.appUser,
      merchant: session.merchant,
      roleType: session.roleType
    })
    fillForm(merchant)
    loadLocalConfig(merchant?.merchantId)
  } catch (error) {
    pushNotice(error.message || '商家资料加载失败', 'danger')
  } finally {
    loading.value = false
  }
}

function validateForm() {
  if (!form.merchantName.trim()) {
    pushNotice('请填写商家名称', 'danger')
    return false
  }
  if (!form.contactName.trim()) {
    pushNotice('请填写联系人', 'danger')
    return false
  }
  if (!/^1\d{10}$/.test(form.contactPhone)) {
    pushNotice('请输入正确的联系电话', 'danger')
    return false
  }
  if (!form.address.trim()) {
    pushNotice('请填写服务地址', 'danger')
    return false
  }
  return true
}

function openLogoPicker() {
  fileInput.value?.click()
}

async function handleLogoChange(event) {
  const file = event.target.files?.[0]
  event.target.value = ''
  if (!file) {
    return
  }

  uploading.value = true
  try {
    const payload = await commonApi.uploadFile(file)
    localForm.logo = payload?.url || localForm.logo
    pushNotice('店铺 Logo 上传成功', 'success')
  } catch (error) {
    pushNotice(error.message || '店铺 Logo 上传失败', 'danger')
  } finally {
    uploading.value = false
  }
}

async function submitForm() {
  if (!validateForm()) {
    return
  }
  if (saving.value) {
    return
  }

  saving.value = true
  try {
    await merchantApi.updateInfo({
      merchantName: form.merchantName,
      contactName: form.contactName,
      contactPhone: form.contactPhone,
      cityName: form.cityName,
      address: form.address,
      serviceScope: form.serviceScope,
      merchantDesc: form.merchantDesc
    })

    const merchant = await merchantApi.currentInfo()
    session.merchant = merchant
    saveStoredSession({
      token: session.token,
      appUser: session.appUser,
      merchant: session.merchant,
      roleType: session.roleType
    })
    saveMerchantShopMeta(merchant?.merchantId || currentMerchantId.value, localForm)
    pushNotice('店铺资料已更新', 'success')
  } catch (error) {
    pushNotice(error.message || '店铺资料保存失败', 'danger')
  } finally {
    saving.value = false
  }
}

onMounted(() => {
  loadMerchantInfo()
})
</script>

<template>
  <section class="page-shell merchant-settings-page">
    <EmptyState
      v-if="!session.token"
      title="请先登录商家账号"
      description="店铺设置页只对商家相关账号开放。"
      action-label="前往登录"
      @action="router.push({ name: 'auth' })"
    />

    <EmptyState
      v-else-if="!roleState.isMerchant"
      title="当前账号不是商家"
      description="普通用户无法查看店铺设置页，请切换为商家账户。"
      action-label="返回个人中心"
      @action="router.push({ name: 'profile' })"
    />

    <template v-else>
      <section class="glass-card merchant-settings-hero">
        <div>
          <span class="eyebrow">店铺设置</span>
          <h1>维护门店资料</h1>
          <p>网页端这里同时维护后端门店资料和本地展示配置，后者专门用来补齐小程序端已有的店铺 Logo、营业时间和营业状态能力。</p>
        </div>

        <div class="surface-card merchant-settings-side">
          <div class="merchant-settings-side__logo">
            <img v-if="logoPreview" :src="logoPreview" alt="店铺 Logo" />
            <span v-else>{{ (session.merchant?.merchantName || '店').slice(0, 1) }}</span>
          </div>
          <strong>{{ session.merchant?.merchantName || '未命名门店' }}</strong>
          <StatusBadge v-bind="getStatusMeta(MERCHANT_AUDIT_STATUS, session.merchant?.auditStatus)" />
          <StatusBadge v-bind="businessStatusBadge" />
          <span>{{ session.merchant?.contactPhone || '--' }}</span>
          <span>{{ localForm.businessTime || '未设置营业时间' }}</span>
        </div>
      </section>

      <section class="surface-card section-card">
        <div class="section-head">
          <div>
            <span class="eyebrow">门店资料</span>
            <h2>后端店铺资料</h2>
            <p>这些字段会直接同步到现有后端接口，用于用户端查看门店信息和联系商家。</p>
          </div>
        </div>

        <form class="merchant-settings-form" @submit.prevent="submitForm">
          <div class="field-row">
            <label>
              <span>商家名称</span>
              <input v-model.trim="form.merchantName" class="field" :disabled="!roleState.isMerchant || loading" />
            </label>
            <label>
              <span>联系人</span>
              <input v-model.trim="form.contactName" class="field" :disabled="!roleState.isMerchant || loading" />
            </label>
          </div>

          <div class="field-row">
            <label>
              <span>联系电话</span>
              <input v-model.trim="form.contactPhone" class="field" :disabled="!roleState.isMerchant || loading" />
            </label>
            <label>
              <span>所在城市</span>
              <input v-model.trim="form.cityName" class="field" :disabled="!roleState.isMerchant || loading" />
            </label>
          </div>

          <label>
            <span>门店地址</span>
            <input v-model.trim="form.address" class="field" :disabled="!roleState.isMerchant || loading" />
          </label>

          <label>
            <span>服务范围</span>
            <textarea
              v-model.trim="form.serviceScope"
              class="textarea"
              :disabled="!roleState.isMerchant || loading"
              placeholder="例如 手机维修、电脑清灰、主板检测、屏幕更换"
            ></textarea>
          </label>

          <label>
            <span>门店简介</span>
            <textarea
              v-model.trim="form.merchantDesc"
              class="textarea"
              :disabled="!roleState.isMerchant || loading"
              placeholder="补充门店优势、服务承诺、营业说明等"
            ></textarea>
          </label>

          <div class="merchant-settings-divider"></div>

          <div class="section-head merchant-settings-subhead">
            <div>
              <span class="eyebrow">本地展示配置</span>
              <h2>网页端补齐字段</h2>
            </div>
          </div>

          <div class="merchant-logo-block">
            <div class="merchant-logo-preview">
              <img v-if="logoPreview" :src="logoPreview" alt="店铺 Logo 预览" />
              <div v-else class="merchant-logo-placeholder">未设置 Logo</div>
            </div>

            <div class="merchant-logo-fields">
              <label>
                <span>店铺 Logo 地址</span>
                <div class="field-row">
                  <input
                    v-model.trim="localForm.logo"
                    class="field"
                    :disabled="!roleState.isMerchant || loading"
                    placeholder="支持直接填写图片地址或上传图片"
                  />
                  <button
                    type="button"
                    class="btn btn--ghost btn--small"
                    :disabled="!roleState.isMerchant || loading || uploading"
                    @click="openLogoPicker"
                  >
                    {{ uploading ? '上传中...' : '上传 Logo' }}
                  </button>
                </div>
              </label>
            </div>
          </div>

          <div class="field-row">
            <label>
              <span>营业时间</span>
              <input
                v-model="localForm.businessTime"
                class="field"
                type="time"
                :disabled="!roleState.isMerchant || loading"
              />
            </label>

            <label>
              <span>营业状态</span>
              <button
                type="button"
                class="merchant-status-toggle"
                :class="{ active: localForm.isOpen }"
                :disabled="!roleState.isMerchant || loading"
                @click="localForm.isOpen = !localForm.isOpen"
              >
                {{ localForm.isOpen ? '营业中' : '暂停营业' }}
              </button>
            </label>
          </div>

          <div class="between-row merchant-settings-footer">
            <p>保存时会同时更新后端门店资料，并把网页端本地展示配置写入当前浏览器。</p>
            <button class="btn btn--primary" :disabled="saving || loading">
              {{ saving ? '保存中...' : '保存店铺资料' }}
            </button>
          </div>
        </form>
      </section>

      <input
        ref="fileInput"
        class="file-input"
        type="file"
        accept="image/*"
        @change="handleLogoChange"
      />
    </template>
  </section>
</template>

<style scoped>
.merchant-settings-page {
  display: grid;
  gap: 22px;
}

.merchant-settings-hero {
  display: grid;
  grid-template-columns: minmax(0, 1fr) 320px;
  gap: 22px;
  padding: 28px;
}

.merchant-settings-hero h1 {
  margin: 14px 0 8px;
  font-size: clamp(32px, 4vw, 50px);
  line-height: 1.08;
}

.merchant-settings-side {
  display: grid;
  gap: 12px;
  align-content: start;
  padding: 22px;
}

.merchant-settings-side strong {
  font-size: 22px;
  color: var(--primary-deep);
}

.merchant-settings-side__logo,
.merchant-logo-preview {
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 24px;
  overflow: hidden;
  background: linear-gradient(135deg, rgba(18, 105, 93, 0.14), rgba(215, 141, 43, 0.18));
}

.merchant-settings-side__logo {
  width: 96px;
  height: 96px;
}

.merchant-settings-side__logo img,
.merchant-logo-preview img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.merchant-settings-side__logo span {
  font-size: 40px;
  font-weight: 800;
  color: var(--primary-deep);
  text-transform: uppercase;
}

.merchant-settings-form {
  display: grid;
  gap: 16px;
}

.merchant-settings-form label {
  display: grid;
  gap: 8px;
  min-width: 0;
}

.merchant-settings-form span {
  font-size: 14px;
  font-weight: 700;
  color: var(--primary-deep);
}

.merchant-settings-divider {
  height: 1px;
  background: rgba(24, 48, 43, 0.08);
  margin: 8px 0 2px;
}

.merchant-settings-subhead {
  margin-bottom: 0;
}

.merchant-logo-block {
  display: grid;
  grid-template-columns: 220px minmax(0, 1fr);
  gap: 18px;
  align-items: start;
}

.merchant-logo-preview {
  min-height: 180px;
}

.merchant-logo-placeholder {
  color: var(--muted);
  font-weight: 700;
}

.merchant-logo-fields {
  display: grid;
  gap: 12px;
}

.merchant-status-toggle {
  min-height: 48px;
  width: 100%;
  border-radius: var(--radius-md);
  border: 1px solid rgba(24, 48, 43, 0.14);
  background: rgba(255, 255, 255, 0.92);
  color: var(--ink);
  font-weight: 700;
}

.merchant-status-toggle.active {
  background: rgba(18, 105, 93, 0.12);
  color: var(--primary-deep);
}

.merchant-settings-footer p {
  max-width: 620px;
}

.file-input {
  display: none;
}

@media (max-width: 980px) {
  .merchant-settings-hero,
  .merchant-logo-block {
    grid-template-columns: 1fr;
  }
}

@media (max-width: 720px) {
  .merchant-settings-hero {
    padding: 18px;
  }

  .field-row,
  .merchant-settings-footer {
    display: grid;
  }
}
</style>
