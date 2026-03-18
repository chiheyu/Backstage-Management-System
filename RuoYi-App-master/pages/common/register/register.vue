<template>
  <view class="register-container">
    <view class="header">
      <text class="title">快速注册</text>
      <text class="desc">支持普通用户和商家入驻注册</text>
    </view>

    <view class="type-switch">
      <view class="switch-item" :class="{ active: form.roleType === '1' }" @click="form.roleType = '1'">普通用户</view>
      <view class="switch-item" :class="{ active: form.roleType === '2' }" @click="form.roleType = '2'">商家入驻</view>
    </view>

    <view class="card">
      <view class="form-item">
        <text class="label">手机号</text>
        <input v-model="form.phone" type="number" maxlength="11" placeholder="请输入手机号" />
      </view>
      <view class="form-item">
        <text class="label">昵称</text>
        <input v-model="form.nickName" placeholder="请输入昵称" />
      </view>
      <view class="form-item" v-if="form.roleType === '2'">
        <text class="label">商家名称</text>
        <input v-model="form.merchantName" placeholder="请输入商家名称" />
      </view>
      <view class="form-item" v-if="form.roleType === '2'">
        <text class="label">联系人</text>
        <input v-model="form.contactName" placeholder="请输入联系人" />
      </view>
      <view class="form-item" v-if="form.roleType === '2'">
        <text class="label">服务范围</text>
        <input v-model="form.serviceScope" placeholder="如：手机、平板、笔记本" />
      </view>
      <view class="form-item" v-if="form.roleType === '2'">
        <text class="label">地址</text>
        <input v-model="form.address" placeholder="请输入商家地址" />
      </view>
      <view class="form-item code-row">
        <view class="code-input">
          <text class="label">验证码</text>
          <input v-model="form.code" type="number" maxlength="6" placeholder="请输入验证码" />
        </view>
        <button class="code-btn" :disabled="countdown > 0" @click="handleSendCode">{{ countdown > 0 ? countdown + 's' : '获取验证码' }}</button>
      </view>
      <view class="form-item">
        <text class="label">密码</text>
        <input v-model="form.password" password placeholder="请输入密码" />
      </view>
      <view class="form-item">
        <text class="label">确认密码</text>
        <input v-model="form.confirmPassword" password placeholder="请再次输入密码" />
      </view>
      <button class="primary-btn" :loading="loading" @click="handleRegister">立即注册</button>
      <view class="link-row">
        <text class="link" @click="$tab.navigateBack()">返回登录</text>
      </view>
    </view>
  </view>
</template>

<script>
import { appRegister, sendRegisterCode } from '@/api/common'

export default {
  data() {
    return {
      loading: false,
      countdown: 0,
      timer: null,
      form: {
        phone: '',
        nickName: '',
        roleType: '1',
        merchantName: '',
        contactName: '',
        address: '',
        serviceScope: '',
        code: '',
        password: '',
        confirmPassword: ''
      }
    }
  },
  onUnload() {
    if (this.timer) {
      clearInterval(this.timer)
    }
  },
  methods: {
    // 获取模拟验证码。
    handleSendCode() {
      if (!this.form.phone) {
        uni.showToast({ title: '请先输入手机号', icon: 'none' })
        return
      }
      sendRegisterCode(this.form.phone).then(res => {
        uni.showModal({
          title: '模拟验证码',
          content: '当前验证码：' + res.code,
          showCancel: false
        })
        this.countdown = 60
        this.timer = setInterval(() => {
          this.countdown -= 1
          if (this.countdown <= 0) {
            clearInterval(this.timer)
            this.timer = null
          }
        }, 1000)
      })
    },
    // 提交注册。
    handleRegister() {
      if (!this.form.phone || !this.form.password || !this.form.confirmPassword || !this.form.code) {
        uni.showToast({ title: '请填写完整信息', icon: 'none' })
        return
      }
      this.loading = true
      appRegister(this.form).then(() => {
        uni.showToast({ title: '注册成功，请登录', icon: 'success' })
        setTimeout(() => {
          this.$tab.navigateBack()
        }, 500)
      }).finally(() => {
        this.loading = false
      })
    }
  }
}
</script>

<style lang="scss" scoped>
.register-container {
  min-height: 100vh;
  padding: 32rpx;
  background-color: #f4f7fb;
}

.header {
  padding: 32rpx 0;

  .title {
    display: block;
    font-size: 42rpx;
    font-weight: 600;
    color: #1f2d3d;
  }

  .desc {
    display: block;
    margin-top: 12rpx;
    color: #666;
    font-size: 26rpx;
  }
}

.type-switch {
  display: flex;
  margin-bottom: 24rpx;
  padding: 8rpx;
  border-radius: 20rpx;
  background-color: #fff;
}

.switch-item {
  flex: 1;
  text-align: center;
  line-height: 72rpx;
  border-radius: 16rpx;
  color: #666;

  &.active {
    background-color: #0f63ff;
    color: #fff;
  }
}

.card {
  padding: 32rpx;
  border-radius: 24rpx;
  background-color: #fff;
}

.form-item {
  margin-bottom: 24rpx;

  .label {
    display: block;
    margin-bottom: 10rpx;
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

.code-row {
  display: flex;
  align-items: flex-end;
  gap: 16rpx;
}

.code-input {
  flex: 1;
}

.code-btn,
.primary-btn {
  border-radius: 16rpx;
}

.code-btn {
  width: 220rpx;
  background-color: #eef4ff;
  color: #0f63ff;
}

.primary-btn {
  margin-top: 10rpx;
  background-color: #0f63ff;
  color: #fff;
}

.link-row {
  margin-top: 20rpx;
  text-align: center;
}

.link {
  color: #0f63ff;
  font-size: 26rpx;
}
</style>
