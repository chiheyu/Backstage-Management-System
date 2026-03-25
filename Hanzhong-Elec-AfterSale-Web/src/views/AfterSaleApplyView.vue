<script setup>
import { computed, reactive } from 'vue'
import { RouterLink, useRoute, useRouter } from 'vue-router'
import EmptyState from '@/components/EmptyState.vue'
import { getRoleState } from '@/lib/domain'
import { pushNotice } from '@/lib/notice'
import { session } from '@/lib/session'
import { userApi } from '@/lib/api'

const router = useRouter()
const route = useRoute()

const productHints = ['手机', '平板', '笔记本电脑', '显示器', '路由器', '配件相关']
const saving = reactive({ value: false })

const form = reactive({
  productType: String(route.query.productType || ''),
  faultDesc: '',
  faultImages: '',
  contactName: session.appUser?.nickName || '',
  contactPhone: session.appUser?.phone || '',
  address: ''
})

const roleState = computed(() => getRoleState(session.roleType))
const targetMerchantName = computed(() => String(route.query.merchantName || ''))

function fillHint(name) {
  form.productType = name
}

function validateForm() {
  if (!session.token) {
    pushNotice('请先登录普通用户账号', 'danger')
    return false
  }
  if (!roleState.value.isUser) {
    pushNotice('只有普通用户可以提交售后申请', 'danger')
    return false
  }
  if (!form.productType.trim()) {
    pushNotice('请填写产品类型', 'danger')
    return false
  }
  if (!form.faultDesc.trim()) {
    pushNotice('请描述故障现象', 'danger')
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
    await userApi.createAfterSalesOrder({
      productType: form.productType,
      faultDesc: form.faultDesc,
      faultImages: form.faultImages,
      contactName: form.contactName,
      contactPhone: form.contactPhone,
      address: form.address
    })
    pushNotice('售后申请已提交，等待商家接单', 'success')
    router.push({ name: 'after-sales-orders' })
  } catch (error) {
    pushNotice(error.message || '售后申请提交失败', 'danger')
  } finally {
    saving.value = false
  }
}
</script>

<template>
  <section class="page-shell after-sale-apply-page">
    <EmptyState
      v-if="!session.token"
      title="提交售后前需要登录"
      description="售后申请会绑定当前用户账号，请先登录再继续。"
      action-label="前往登录"
      @action="router.push({ name: 'auth' })"
    />

    <EmptyState
      v-else-if="!roleState.isUser"
      title="当前账号不能提交售后申请"
      description="商家账号用于接单和处理维修工单，请切换普通用户账号后再提交。"
      action-label="查看个人中心"
      @action="router.push({ name: 'profile' })"
    />

    <template v-else>
      <section class="glass-card apply-hero">
        <div>
          <span class="eyebrow">售后申请</span>
          <h1>提交设备报修与售后需求</h1>
          <p>
            填写设备类型、故障情况和联系信息后，
            门店会尽快接单并持续更新处理进度。
          </p>
        </div>

        <div class="surface-card apply-side-card">
          <strong>处理流程</strong>
          <span>待接单</span>
          <span>已接单</span>
          <span>维修中</span>
          <span>已完成 / 已取消</span>
        </div>
      </section>

      <section class="apply-grid">
        <section class="surface-card section-card">
          <div class="section-head">
            <div>
              <span class="eyebrow">填写信息</span>
              <h2>售后申请表</h2>
              <p>尽量完整描述故障情况，方便门店尽快判断处理方式。</p>
            </div>
          </div>

          <form class="apply-form" @submit.prevent="submitForm">
            <label v-if="targetMerchantName" class="apply-form__hint">
              <span>意向门店</span>
              <strong>{{ targetMerchantName }}</strong>
              <small>当前记录为意向门店，提交后可在售后单中继续跟进。</small>
            </label>

            <label>
              <span>产品类型</span>
              <input v-model.trim="form.productType" class="field" placeholder="例如 手机、笔记本、路由器、电池配件" />
            </label>

            <div class="chip-row">
              <button v-for="item in productHints" :key="item" type="button" class="chip" @click="fillHint(item)">
                {{ item }}
              </button>
            </div>

            <label>
              <span>故障描述</span>
              <textarea
                v-model.trim="form.faultDesc"
                class="textarea"
                placeholder="尽量描述故障表现、出现时间、是否摔落进水、是否已自行拆机等"
              ></textarea>
            </label>

            <label>
              <span>故障图片地址</span>
              <textarea
                v-model.trim="form.faultImages"
                class="textarea"
                placeholder="可选。如已有图片链接，可使用逗号分隔填写多张。"
              ></textarea>
            </label>

            <div class="field-row">
              <label>
                <span>联系人</span>
                <input v-model.trim="form.contactName" class="field" placeholder="服务联系人" />
              </label>
              <label>
                <span>联系电话</span>
                <input v-model.trim="form.contactPhone" class="field" placeholder="11 位手机号" />
              </label>
            </div>

            <label>
              <span>服务地址</span>
              <input v-model.trim="form.address" class="field" placeholder="上门地址或设备送修地址" />
            </label>

            <div class="between-row apply-form__footer">
              <p>提交后可在“售后订单”页面查看状态变化，并在未完成前随时跟进。</p>
              <button class="btn btn--primary" :disabled="saving.value">
                {{ saving.value ? '提交中...' : '提交售后申请' }}
              </button>
            </div>
          </form>
        </section>

        <section class="surface-card section-card">
          <div class="section-head">
            <div>
              <span class="eyebrow">常用入口</span>
              <h2>相关入口</h2>
              <p>申请前后最常用的几个操作集中在这里。</p>
            </div>
          </div>

          <div class="apply-side-links">
            <RouterLink class="apply-link-card" :to="{ name: 'after-sales-orders' }">
              <strong>查看我的售后单</strong>
              <span>提交后在这里跟踪接单、维修和完成状态。</span>
            </RouterLink>
            <RouterLink class="apply-link-card" :to="{ name: 'merchants' }">
              <strong>浏览服务商家</strong>
              <span>先查看门店服务范围，再决定是否发起申请。</span>
            </RouterLink>
            <RouterLink class="apply-link-card" :to="{ name: 'mall' }">
              <strong>进入配件商城</strong>
              <span>如果问题只需要更换配件，也可以直接在线下单。</span>
            </RouterLink>
          </div>
        </section>
      </section>
    </template>
  </section>
</template>

<style scoped>
.after-sale-apply-page {
  display: grid;
  gap: 24px;
}

.apply-hero {
  display: grid;
  grid-template-columns: minmax(0, 1fr) 260px;
  gap: 22px;
  padding: 28px;
}

.apply-hero h1 {
  margin: 16px 0 10px;
  font-size: clamp(32px, 4.2vw, 52px);
  line-height: 1.08;
}

.apply-side-card {
  display: grid;
  gap: 12px;
  padding: 22px;
  align-content: start;
}

.apply-side-card strong {
  font-size: 18px;
  color: var(--primary-deep);
}

.apply-side-card span {
  display: inline-flex;
  align-items: center;
  min-height: 44px;
  padding: 0 16px;
  border-radius: 999px;
  background: rgba(14, 116, 144, 0.08);
  color: var(--primary-deep);
  font-weight: 700;
}

.apply-grid {
  display: grid;
  grid-template-columns: minmax(0, 1.15fr) minmax(300px, 0.85fr);
  gap: 24px;
}

.apply-form {
  display: grid;
  gap: 16px;
}

.apply-form label {
  display: grid;
  gap: 8px;
  min-width: 0;
}

.apply-form span {
  font-size: 14px;
  font-weight: 700;
  color: var(--primary-deep);
}

.apply-form__hint {
  padding: 16px;
  border-radius: 22px;
  background: linear-gradient(180deg, rgba(241, 247, 249, 0.9), rgba(255, 248, 235, 0.92));
}

.apply-form__hint strong {
  font-size: 20px;
}

.apply-form__hint small {
  color: var(--muted);
  line-height: 1.7;
}

.apply-form__footer p {
  max-width: 520px;
}

.apply-side-links {
  display: grid;
  gap: 14px;
}

.apply-link-card {
  display: block;
  padding: 18px;
  border-radius: 22px;
  background: linear-gradient(180deg, rgba(255, 255, 255, 0.94), rgba(248, 244, 236, 0.94));
  border: 1px solid rgba(17, 61, 77, 0.08);
}

.apply-link-card strong {
  display: block;
  margin-bottom: 8px;
}

@media (max-width: 980px) {
  .apply-hero,
  .apply-grid {
    grid-template-columns: 1fr;
  }
}

@media (max-width: 720px) {
  .apply-hero {
    padding: 18px;
  }

  .apply-form__footer,
  .field-row {
    display: grid;
  }
}
</style>
