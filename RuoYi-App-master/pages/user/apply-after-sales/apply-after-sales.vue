<template>
  <view class="page">
    <view class="card">
      <view class="form-item">
        <text class="label">电子产品类型</text>
        <input v-model="form.productType" placeholder="如：手机、平板、笔记本" />
      </view>
      <view class="form-item">
        <text class="label">故障描述</text>
        <textarea v-model="form.faultDesc" placeholder="请详细描述故障现象" />
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
        <text class="label">服务地址</text>
        <input v-model="form.address" placeholder="请输入上门或联系地址" />
      </view>
      <view class="form-item">
        <text class="label">故障图片</text>
        <view class="upload-list">
          <view v-for="(item, index) in fileList" :key="index" class="image-box">
            <image :src="item" mode="aspectFill"></image>
          </view>
          <view class="upload-btn" @click="chooseImages">+</view>
        </view>
      </view>
      <button class="primary-btn" :loading="loading" @click="submitForm">提交售后申请</button>
    </view>
  </view>
</template>

<script>
import { uploadFile } from '@/api/request'
import { createAfterSalesOrder } from '@/api/user'

export default {
  data() {
    return {
      loading: false,
      fileList: [],
      form: {
        productType: '',
        faultDesc: '',
        contactName: '',
        contactPhone: '',
        address: ''
      }
    }
  },
  methods: {
    // 选择并上传图片。
    chooseImages() {
      uni.chooseImage({
        count: 3,
        success: async (res) => {
          this.loading = true
          try {
            for (const filePath of res.tempFilePaths) {
              const uploadRes = await uploadFile(filePath)
              this.fileList.push(uploadRes.url)
            }
          } finally {
            this.loading = false
          }
        }
      })
    },
    // 提交售后单。
    submitForm() {
      if (!this.form.productType || !this.form.faultDesc || !this.form.contactName || !this.form.contactPhone) {
        uni.showToast({ title: '请先填写完整表单', icon: 'none' })
        return
      }
      this.loading = true
      createAfterSalesOrder({
        ...this.form,
        faultImages: this.fileList.join(',')
      }).then(() => {
        uni.showToast({ title: '提交成功', icon: 'success' })
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

.upload-list {
  display: flex;
  flex-wrap: wrap;
  gap: 16rpx;
}

.image-box,
.upload-btn {
  width: 160rpx;
  height: 160rpx;
  border-radius: 16rpx;
  overflow: hidden;
}

.image-box image {
  width: 100%;
  height: 100%;
}

.upload-btn {
  display: flex;
  align-items: center;
  justify-content: center;
  background-color: #f6f8fb;
  color: #0f63ff;
  font-size: 60rpx;
}

.primary-btn {
  border-radius: 16rpx;
  background-color: #0f63ff;
  color: #fff;
}
</style>
