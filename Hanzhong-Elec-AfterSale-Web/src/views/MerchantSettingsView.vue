<script setup>
import { computed, onMounted, reactive, ref } from 'vue'
import { useRouter } from 'vue-router'
import EmptyState from '@/components/EmptyState.vue'
import StatusBadge from '@/components/StatusBadge.vue'
import { merchantApi } from '@/lib/api'
import { MERCHANT_AUDIT_STATUS, getRoleState, getStatusMeta } from '@/lib/domain'
import { pushNotice } from '@/lib/notice'
import { session } from '@/lib/session'
import { saveStoredSession } from '@/lib/storage'

const router = useRouter()

const loading = ref(false)
const saving = ref(false)

const form = reactive({
  merchantName: '',
  contactName: '',
  contactPhone: '',
  cityName: '',
  address: '',
  serviceScope: '',
  merchantDesc: ''
})

const roleState = computed(() => getRoleState(session.roleType))

function fillForm(source) {
  form.merchantName = source?.merchantName || ''
  form.contactName = source?.contactName || ''
  form.contactPhone = source?.contactPhone || ''
  form.cityName = source?.cityName || '汉中市'
  form.address = source?.address || ''
  form.serviceScope = source?.serviceScope || ''
  form.merchantDesc = source?.merchantDesc || ''
}

async function loadMerchantInfo() {
  if (!session.token || (!roleState.value.isMerchant && !roleState.value.isPendingMerchant)) {
    return
  }

  loading.value = true
  try {
    if (roleState.value.isMerchant) {
      const merchant = await merchantApi.currentInfo()
      session.merchant = merchant
      saveStoredSession({
        token: session.token,
        appUser: session.appUser,
        merchant: session.merchant,
        roleType: session.roleType
      })
      fillForm(merchant)
    } else {
      fillForm(session.merchant)
    }
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

async function submitForm() {
  if (!validateForm()) {
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
      v-else-if="!roleState.isMerchant && !roleState.isPendingMerchant"
      title="当前账号不是商家"
      description="普通用户无法查看店铺设置页，请切换为商家账号。"
      action-label="返回个人中心"
      @action="router.push({ name: 'profile' })"
    />

    <template v-else>
      <section class="glass-card merchant-settings-hero">
        <div>
          <span class="eyebrow">门店设置</span>
          <h1>{{ roleState.isMerchant ? '维护门店资料' : '查看审核中的店铺资料' }}</h1>
          <p v-if="roleState.isMerchant">及时维护联系方式、地址、服务范围和门店简介，方便用户联系和选择服务。</p>
          <p v-else>当前为待审核状态，审核通过后即可开放资料编辑能力。</p>
        </div>

        <div class="surface-card merchant-settings-side">
          <strong>{{ session.merchant?.merchantName || '未命名门店' }}</strong>
          <StatusBadge
            v-bind="getStatusMeta(MERCHANT_AUDIT_STATUS, session.merchant?.auditStatus)"
          />
          <span>{{ session.merchant?.contactPhone || '--' }}</span>
        </div>
      </section>

      <section class="surface-card section-card">
        <div class="section-head">
          <div>
            <span class="eyebrow">门店资料</span>
            <h2>店铺资料</h2>
            <p>保持信息完整，便于用户查看门店详情并联系服务。</p>
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

          <div class="between-row merchant-settings-footer">
            <p v-if="roleState.isMerchant">资料保存后，门店展示信息会同步更新。</p>
            <p v-else>当前阶段只能查看资料，等待后台审核通过后再进行编辑。</p>
            <button v-if="roleState.isMerchant" class="btn btn--primary" :disabled="saving || loading">
              {{ saving ? '保存中...' : '保存店铺资料' }}
            </button>
          </div>
        </form>
      </section>
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

.merchant-settings-footer p {
  max-width: 560px;
}

@media (max-width: 980px) {
  .merchant-settings-hero {
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
