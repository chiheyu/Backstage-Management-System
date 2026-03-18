<template>
  <view class="login-container">
    <view class="hero">
      <text class="title">汉中市电子产品售后服务系统</text>
      <text class="subtitle">手机号登录，支持用户与商家双角色</text>
    </view>

    <view class="card">
      <view class="form-item">
        <text class="label">手机号</text>
        <input v-model="form.phone" type="number" maxlength="11" placeholder="请输入手机号" />
      </view>
      <view class="form-item">
        <text class="label">密码</text>
        <input v-model="form.password" password placeholder="请输入密码" />
      </view>

      <button class="primary-btn" :loading="loading" @click="handleLogin">登录</button>
      <view class="link-row">
        <text class="link" @click="goRegister">没有账号？去注册</text>
      </view>
      <view class="tip-box">
        <text>测试用户手机号：13800001111 / 密码：123456</text>
        <text>测试商家手机号：13800002222 / 密码：123456</text>
      </view>
    </view>
  </view>
</template>

<script>
import { appLogin } from '@/api/common'
import { setToken } from '@/utils/auth'

export default {
  data() {
    return {
      loading: false,
      form: {
        phone: '',
        password: ''
      }
    }
  },
  methods: {
    // 登录并写入本地角色缓存。
    handleLogin() {
      if (!this.form.phone || !this.form.password) {
        uni.showToast({ title: '请输入手机号和密码', icon: 'none' })
        return
      }
      this.loading = true
      appLogin(this.form).then(res => {
        setToken(res.data.token)
        uni.setStorageSync('token', res.data.token)
        uni.setStorageSync('role', res.data.roleType)
        uni.setStorageSync('appUser', res.data.appUser || {})
        uni.setStorageSync('merchantInfo', res.data.merchant || {})
        uni.showToast({ title: '登录成功', icon: 'success' })
        setTimeout(() => {
          this.$tab.reLaunch('/pages/index')
        }, 400)
      }).finally(() => {
        this.loading = false
      })
    },
    // 前往注册页。
    goRegister() {
      this.$tab.navigateTo('/pages/common/register/register')
    }
  }
}
</script>

<style lang="scss" scoped>
.login-container {
  min-height: 100vh;
  padding: 60rpx 32rpx;
  background: linear-gradient(180deg, #0f63ff 0%, #f4f7fb 42%);
}

.hero {
  margin-top: 80rpx;
  color: #fff;

  .title {
    display: block;
    font-size: 44rpx;
    font-weight: 600;
  }

  .subtitle {
    display: block;
    margin-top: 20rpx;
    font-size: 26rpx;
    opacity: 0.9;
  }
}

.card {
  margin-top: 60rpx;
  padding: 40rpx 32rpx;
  border-radius: 24rpx;
  background-color: #fff;
  box-shadow: 0 20rpx 50rpx rgba(15, 99, 255, 0.12);
}

.form-item {
  margin-bottom: 28rpx;

  .label {
    display: block;
    margin-bottom: 14rpx;
    color: #333;
    font-size: 28rpx;
  }

  input {
    height: 84rpx;
    padding: 0 24rpx;
    border-radius: 16rpx;
    background-color: #f6f8fb;
  }
}

.primary-btn {
  margin-top: 20rpx;
  border-radius: 16rpx;
  background: #0f63ff;
  color: #fff;
}

.link-row {
  margin-top: 20rpx;
  text-align: right;
}

.link {
  color: #0f63ff;
  font-size: 26rpx;
}

.tip-box {
  margin-top: 32rpx;
  padding: 24rpx;
  border-radius: 16rpx;
  background-color: #f6f8fb;
  color: #666;
  font-size: 24rpx;

  text {
    display: block;
    line-height: 1.8;
  }
}
</style>
