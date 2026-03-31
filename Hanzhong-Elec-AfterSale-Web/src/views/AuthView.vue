<script setup>
import { computed, reactive, ref } from 'vue'
import { useRouter } from 'vue-router'
import { authApi } from '@/lib/api'
import { ROLE_OPTIONS, ROLE_TYPES } from '@/lib/domain'
import { pushNotice } from '@/lib/notice'
import { applyLogin, session } from '@/lib/session'

const router = useRouter()

const activeTab = ref('login')
const sendingCode = ref(false)
const authLoading = ref(false)

const loginForm = reactive({
  phone: '',
  password: ''
})

const registerForm = reactive({
  phone: '',
  password: '',
  confirmPassword: '',
  nickName: '',
  code: '',
  roleType: ROLE_TYPES.user,
  merchantName: '',
  contactName: '',
  address: '',
  serviceScope: ''
})

const isMerchantRegister = computed(() => String(registerForm.roleType) === ROLE_TYPES.merchant)

function validatePhone(phone) {
  return /^1\d{10}$/.test(phone)
}

function validateLogin() {
  if (!validatePhone(loginForm.phone)) {
    pushNotice('请输入正确的手机号', 'danger')
    return false
  }
  if (loginForm.password.length < 6) {
    pushNotice('密码至少 6 位', 'danger')
    return false
  }
  return true
}

function validateRegister() {
  if (!validatePhone(registerForm.phone)) {
    pushNotice('请输入正确的手机号', 'danger')
    return false
  }
  if (registerForm.password.length < 6) {
    pushNotice('密码至少 6 位', 'danger')
    return false
  }
  if (registerForm.password !== registerForm.confirmPassword) {
    pushNotice('两次输入的密码不一致', 'danger')
    return false
  }
  if (!registerForm.code.trim()) {
    pushNotice('请填写验证码', 'danger')
    return false
  }
  if (isMerchantRegister.value && !registerForm.merchantName.trim()) {
    pushNotice('商家注册必须填写店铺名称', 'danger')
    return false
  }
  return true
}

async function handleSendCode() {
  if (!validatePhone(registerForm.phone)) {
    pushNotice('先输入正确的手机号再获取验证码', 'danger')
    return
  }

  sendingCode.value = true
  try {
    const payload = await authApi.sendCode(registerForm.phone)
    pushNotice(`验证码：${payload.smsCode || payload.code}`, 'brand', 5000)
  } catch (error) {
    pushNotice(error.message || '验证码发送失败', 'danger')
  } finally {
    sendingCode.value = false
  }
}

async function handleLogin() {
  if (!validateLogin()) {
    return
  }

  authLoading.value = true
  try {
    const payload = await authApi.login({
      phone: loginForm.phone,
      password: loginForm.password
    })
    await applyLogin(payload)
    pushNotice('登录成功，已同步当前会话', 'success')
    router.push({ name: 'home' })
  } catch (error) {
    pushNotice(error.message || '登录失败', 'danger')
  } finally {
    authLoading.value = false
  }
}

async function handleRegister() {
  if (!validateRegister()) {
    return
  }

  authLoading.value = true
  try {
    const payload = await authApi.register({
      ...registerForm
    })
    await applyLogin(payload)
    pushNotice(
      isMerchantRegister.value
        ? '注册成功，商家账号已直接开通'
        : '注册成功，已自动登录',
      'success'
    )
    router.push({
      name: isMerchantRegister.value ? 'merchant-settings' : 'home'
    })
  } catch (error) {
    pushNotice(error.message || '注册失败', 'danger')
  } finally {
    authLoading.value = false
  }
}
</script>

<template>
  <section class="page-shell auth-page">
    <section class="glass-card auth-hero">
      <div class="auth-hero__copy">
        <span class="eyebrow">账号入口</span>
        <h1>登录后即可使用配件、售后和门店服务</h1>
        <p>
          普通用户可提交售后、购买配件并查看订单；
          商家入驻后可直接进入商家工作台并完善门店资料。
        </p>

        <div class="auth-highlight">
          <article>
            <strong>普通用户</strong>
            <span>购买配件、查看订单、发起售后</span>
          </article>
          <article>
            <strong>商家入驻</strong>
            <span>注册后直接可用，立即进入商品与订单管理</span>
          </article>
        </div>
      </div>

      <div class="surface-card auth-panel">
        <div class="auth-tabs">
          <button
            class="auth-tab"
            :class="{ active: activeTab === 'login' }"
            @click="activeTab = 'login'"
          >
            登录
          </button>
          <button
            class="auth-tab"
            :class="{ active: activeTab === 'register' }"
            @click="activeTab = 'register'"
          >
            注册
          </button>
        </div>

        <form v-if="activeTab === 'login'" class="auth-form" @submit.prevent="handleLogin">
          <label>
            <span>手机号</span>
            <input v-model.trim="loginForm.phone" class="field" placeholder="请输入手机号" />
          </label>
          <label>
            <span>密码</span>
            <input
              v-model="loginForm.password"
              class="field"
              type="password"
              placeholder="请输入登录密码"
            />
          </label>
          <button class="btn btn--primary auth-submit" :disabled="authLoading">
            {{ authLoading ? '登录中...' : '立即登录' }}
          </button>
        </form>

        <form v-else class="auth-form" @submit.prevent="handleRegister">
          <div class="field-row">
            <label>
              <span>手机号</span>
              <input v-model.trim="registerForm.phone" class="field" placeholder="用于登录和收码" />
            </label>
            <label>
              <span>昵称</span>
              <input v-model.trim="registerForm.nickName" class="field" placeholder="页面展示名称" />
            </label>
          </div>

          <div class="field-row">
            <label>
              <span>密码</span>
              <input
                v-model="registerForm.password"
                class="field"
                type="password"
                placeholder="至少 6 位"
              />
            </label>
            <label>
              <span>确认密码</span>
              <input
                v-model="registerForm.confirmPassword"
                class="field"
                type="password"
                placeholder="再次输入密码"
              />
            </label>
          </div>

          <div class="field-row auth-code-row">
            <label>
              <span>验证码</span>
              <input v-model.trim="registerForm.code" class="field" placeholder="输入 6 位验证码" />
            </label>
            <button
              type="button"
              class="btn btn--ghost btn--small"
              :disabled="sendingCode"
              @click="handleSendCode"
            >
              {{ sendingCode ? '发送中...' : '获取验证码' }}
            </button>
          </div>

          <div class="auth-role-grid">
            <button
              v-for="item in ROLE_OPTIONS"
              :key="item.value"
              type="button"
              class="auth-role-card"
              :class="{ active: String(registerForm.roleType) === item.value }"
              @click="registerForm.roleType = item.value"
            >
              <strong>{{ item.label }}</strong>
              <span>{{ item.desc }}</span>
            </button>
          </div>

          <div v-if="isMerchantRegister" class="merchant-fields">
            <div class="field-row">
              <label>
                <span>商家名称</span>
                <input v-model.trim="registerForm.merchantName" class="field" placeholder="例如 汉中数码快修" />
              </label>
              <label>
                <span>联系人</span>
                <input v-model.trim="registerForm.contactName" class="field" placeholder="门店负责人" />
              </label>
            </div>
            <label>
              <span>门店地址</span>
              <input v-model.trim="registerForm.address" class="field" placeholder="用于生成服务商详情页" />
            </label>
            <label>
              <span>服务范围</span>
              <textarea
                v-model.trim="registerForm.serviceScope"
                class="textarea"
                placeholder="例如 手机维修、电脑清灰、主板检测、屏幕更换"
              ></textarea>
            </label>
          </div>

          <button class="btn btn--primary auth-submit" :disabled="authLoading">
            {{ authLoading ? '注册中...' : '创建账号' }}
          </button>
        </form>
      </div>
    </section>
  </section>
</template>

<style scoped>
.auth-page {
  padding-top: 8px;
}

.auth-hero {
  display: grid;
  grid-template-columns: minmax(0, 1fr) minmax(360px, 480px);
  gap: 26px;
  padding: 28px;
}

.auth-hero__copy h1 {
  margin: 18px 0 16px;
  font-size: clamp(32px, 4.5vw, 54px);
  line-height: 1.06;
  letter-spacing: -0.04em;
}

.auth-highlight {
  display: grid;
  gap: 14px;
  margin-top: 28px;
}

.auth-highlight article {
  padding: 18px 20px;
  border-radius: 22px;
  background: rgba(255, 255, 255, 0.66);
  border: 1px solid rgba(17, 61, 77, 0.08);
}

.auth-highlight strong,
.auth-role-card strong {
  display: block;
  margin-bottom: 8px;
}

.auth-panel {
  padding: 22px;
}

.auth-tabs {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 10px;
  margin-bottom: 18px;
}

.auth-tab,
.auth-role-card {
  border: 1px solid rgba(17, 61, 77, 0.12);
  background: rgba(255, 255, 255, 0.84);
}

.auth-tab {
  min-height: 48px;
  border-radius: 999px;
  font-weight: 700;
}

.auth-tab.active,
.auth-role-card.active {
  background: rgba(14, 116, 144, 0.1);
  color: var(--primary-deep);
  border-color: rgba(14, 116, 144, 0.22);
}

.auth-form {
  display: grid;
  gap: 16px;
}

.auth-form label {
  display: grid;
  gap: 8px;
  min-width: 0;
}

.auth-form span {
  font-size: 14px;
  font-weight: 700;
  color: var(--primary-deep);
}

.auth-code-row {
  align-items: end;
}

.auth-code-row label {
  flex: 1;
}

.auth-role-grid {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 12px;
}

.auth-role-card {
  padding: 16px;
  border-radius: 22px;
  text-align: left;
}

.merchant-fields {
  display: grid;
  gap: 16px;
  padding: 18px;
  border-radius: 24px;
  background: linear-gradient(180deg, rgba(241, 247, 249, 0.84), rgba(255, 248, 235, 0.92));
}

.auth-submit {
  width: 100%;
  margin-top: 4px;
}

@media (max-width: 980px) {
  .auth-hero {
    grid-template-columns: 1fr;
  }
}

@media (max-width: 720px) {
  .auth-role-grid,
  .field-row {
    grid-template-columns: 1fr;
    display: grid;
  }

  .auth-code-row {
    display: grid;
  }
}
</style>
