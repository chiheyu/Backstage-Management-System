<template>
  <view class="page">
    <view class="card">
      <view class="form-item">
        <text class="label">商家名称</text>
        <input v-model="form.merchantName" placeholder="请输入商家名称" />
      </view>
      <view class="form-item">
        <text class="label">联系人</text>
        <input v-model="form.contactName" placeholder="请输入联系人" />
      </view>
      <view class="form-item">
        <text class="label">联系电话</text>
        <input v-model="form.contactPhone" type="number" maxlength="11" placeholder="请输入联系电话" />
      </view>
      <view class="form-item">
        <text class="label">商家地址</text>
        <input v-model="form.address" placeholder="请输入商家地址" />
      </view>
      <view class="form-item">
        <text class="label">服务范围</text>
        <input v-model="form.serviceScope" placeholder="请输入服务范围" />
      </view>
      <view class="form-item">
        <text class="label">商家简介</text>
        <textarea v-model="form.merchantDesc" placeholder="请输入商家简介" />
      </view>
      <button class="primary-btn" :loading="loading" @click="submitForm">保存商家信息</button>
    </view>
  </view>
</template>

<script>
import { getMerchantProfile, updateMerchantProfile } from '@/api/merchant'

export default {
  data() {
    return {
      loading: false,
      form: {
        merchantId: undefined,
        merchantName: '',
        contactName: '',
        contactPhone: '',
        address: '',
        serviceScope: '',
        merchantDesc: ''
      }
    }
  },
  onShow() {
    this.getInfo()
  },
  methods: {
    // 查询当前商家资料。
    getInfo() {
      getMerchantProfile().then(res => {
        this.form = res.data || this.form
      })
    },
    // 保存资料。
    submitForm() {
      this.loading = true
      updateMerchantProfile(this.form).then(() => {
        uni.showToast({ title: '保存成功', icon: 'success' })
      }).finally(() => {
        this.loading = false
      })
    }
  }
}
</script>

<style lang="scss" scoped>
.page {
  min-height: 100vh;
  padding: 24rpx;
  background-color: #f5f7fb;
}

.card {
  padding: 24rpx;
  border-radius: 24rpx;
  background-color: #fff;
}

.form-item {
  margin-bottom: 24rpx;

  .label {
    display: block;
    margin-bottom: 12rpx;
    font-size: 28rpx;
    color: #333;
  }

  input,
  textarea {
    width: 100%;
    padding: 20rpx;
    border-radius: 16rpx;
    background-color: #f6f8fb;
  }

  textarea {
    min-height: 180rpx;
  }
}

.primary-btn {
  border-radius: 16rpx;
  background-color: #15a36d;
  color: #fff;
}
</style>
