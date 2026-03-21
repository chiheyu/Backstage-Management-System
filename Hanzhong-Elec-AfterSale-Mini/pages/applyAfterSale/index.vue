<template>
  <view class="aftersale-page">
    <view class="form-container">
      <view class="form-item">
        <view class="label-wrap">
          <text class="label">产品名称</text>
          <text class="required">*</text>
        </view>
        <input 
          v-model="form.productName" 
          placeholder="请输入产品名称" 
          class="input"
          placeholder-class="input-placeholder"
        />
      </view>
      
      <view class="form-item">
        <view class="label-wrap">
          <text class="label">产品型号</text>
          <text class="required">*</text>
        </view>
        <input 
          v-model="form.productModel" 
          placeholder="请输入产品型号" 
          class="input"
          placeholder-class="input-placeholder"
        />
      </view>
      
      <view class="form-item">
        <view class="label-wrap">
          <text class="label">故障描述</text>
          <text class="required">*</text>
          <text class="desc-text">{{ form.faultDesc.length }}/200</text>
        </view>
        <textarea 
          v-model="form.faultDesc" 
          placeholder="请描述故障问题" 
          class="textarea"
          placeholder-class="textarea-placeholder"
          maxlength="200"
        ></textarea>
      </view>

      <view class="form-item">
        <view class="label-wrap">
          <text class="label">收货地址</text>
          <text class="required">*</text>
        </view>
        <view class="address-select" @tap="chooseAddress" hover-class="address-select-hover">
          <view class="address-info" v-if="addressInfo">
            <text class="address-name">{{ addressInfo.name }} {{ addressInfo.phone }}</text>
            <text class="address-detail">{{ addressInfo.region }} {{ addressInfo.detail }}</text>
          </view>
          <text class="address-placeholder" v-else>请选择收货地址</text>
          <uni-icons type="arrowright" size="24" color="#ccc"></uni-icons>
        </view>
      </view>
      
      <view class="form-item">
        <view class="label-wrap">
          <text class="label">故障图片</text>
          <text class="optional">（选填）</text>
        </view>
        <view class="upload-area">
          <view class="upload-item" v-for="(url, idx) in form.imgList" :key="idx" v-if="url">
            <image :src="url" mode="aspectFill" class="upload-img"></image>
            <view class="del-btn" @tap="delImg(idx)" hover-class="del-btn-hover">×</view>
          </view>
          <view class="upload-btn" @tap="chooseImg" v-if="form.imgList.length < 3" hover-class="upload-btn-hover">
            <uni-icons type="plus" size="40" color="#ccc"></uni-icons>
            <text class="upload-tip">上传图片</text>
          </view>
        </view>
        <text class="upload-desc">最多上传3张，支持jpg/png格式</text>
      </view>
      
      <button class="submit-btn" @tap="submit" :disabled="!isFormValid || isSubmitting" hover-class="submit-btn-hover">
        <uni-icons v-if="isSubmitting" type="spinner-cycle" size="20" color="#fff" class="loading-icon"></uni-icons>
        {{ isSubmitting ? '提交中...' : '提交售后申请' }}
      </button>
    </view>
  </view>
</template>

<script>
export default {
  data() {
    return {
      form: {
        productName: '',
        productModel: '',
        faultDesc: '',
        imgList: [],
        name: '',
        phone: '',
        region: '',
        detail: ''
      },
      addressInfo: null,
      isSubmitting: false,
      isFormValid: false,
      ADDRESS_PATH: '/pages/address/index'
    }
  },
  watch: {
    'form.productName': 'checkFormValid',
    'form.productModel': 'checkFormValid',
    'form.faultDesc': 'checkFormValid',
    'form.name': 'checkFormValid',
    'form.phone': 'checkFormValid',
    'form.region': 'checkFormValid',
    'form.detail': 'checkFormValid'
  },
  onShow() {
    this.loadDefaultAddress()
    this.checkLoginStatus()
  },
  methods: {
    checkLoginStatus() {
      const token = wx.getStorageSync('token')
      const userInfo = wx.getStorageSync('userInfo')
      if (!token || !userInfo) {
        wx.showToast({
          title: '请先登录后再操作',
          icon: 'none',
          duration: 2000
        })
      }
    },
    loadDefaultAddress() {
      const addressList = wx.getStorageSync('addressList') || []
      const defaultAddr = addressList.find(item => item.isDefault)
      if (defaultAddr) {
        this.addressInfo = defaultAddr
        this.form.name = defaultAddr.name
        this.form.phone = defaultAddr.phone
        this.form.region = defaultAddr.region
        this.form.detail = defaultAddr.detail
      }
    },
    checkFormValid() {
      const nameValid = this.form.productName.trim().length > 0
      const modelValid = this.form.productModel.trim().length > 0
      const descValid = this.form.faultDesc.trim().length > 0
      const addressNameValid = this.form.name.trim().length > 0
      const addressPhoneValid = /^1[3-9]\d{9}$/.test(this.form.phone.trim())
      const addressRegionValid = this.form.region.trim().length > 0
      const addressDetailValid = this.form.detail.trim().length > 0

      this.isFormValid = nameValid && modelValid && descValid && addressNameValid && addressPhoneValid && addressRegionValid && addressDetailValid
    },
    chooseAddress() {
      const token = wx.getStorageSync('token')
      const userInfo = wx.getStorageSync('userInfo')
      if (!token || !userInfo) {
        wx.showToast({
          title: '请先登录',
          icon: 'none',
          duration: 1500
        })
        return
      }
      wx.navigateTo({
        url: this.ADDRESS_PATH,
        fail: () => {
          wx.showToast({ title: '地址页未找到', icon: 'none' })
        }
      })
    },
    chooseImg() {
      const token = wx.getStorageSync('token')
      const userInfo = wx.getStorageSync('userInfo')
      if (!token || !userInfo) {
        wx.showToast({
          title: '请先登录',
          icon: 'none',
          duration: 1500
        })
        return
      }
      const remainCount = 3 - this.form.imgList.length
      if (remainCount <= 0) return
      wx.showLoading({ title: '图片加载中...' })
      wx.chooseImage({
        count: remainCount,
        sizeType: ['compressed'],
        sourceType: ['album', 'camera'],
        success: (res) => {
          this.form.imgList = [...this.form.imgList, ...res.tempFilePaths]
        },
        fail: () => {
          wx.showToast({ title: '图片选择失败，请重试', icon: 'none' })
        },
        complete: () => {
          wx.hideLoading()
        }
      })
    },
    delImg(idx) {
      if (idx < 0 || idx >= this.form.imgList.length) return
      wx.showModal({
        title: '确认删除',
        content: '是否删除这张故障图片？',
        confirmText: '删除',
        cancelText: '取消',
        success: (res) => {
          if (res.confirm) {
            this.form.imgList.splice(idx, 1)
          }
        }
      })
    },
    submit() {
      const token = wx.getStorageSync('token')
      const userInfo = wx.getStorageSync('userInfo')
      
      if (!token || !userInfo) {
        wx.showToast({
          title: '请先登录后提交售后申请',
          icon: 'none',
          duration: 1500
        })
        return
      }
      
      if (!this.isFormValid) {
        wx.showToast({ title: '请填写所有必填项', icon: 'none' })
        return
      }
      
      if (this.isSubmitting) return
      this.isSubmitting = true
      
      const afterSaleOrder = {
        id: Date.now(),
        orderNo: 'SH' + Date.now().toString().slice(-8),
        userId: userInfo.username,
        productName: this.form.productName,
        productModel: this.form.productModel,
        faultDesc: this.form.faultDesc,
        faultImages: this.form.imgList.join(','),
        receiverName: this.form.name,
        receiverPhone: this.form.phone,
        receiverRegion: this.form.region,
        receiverDetail: this.form.detail,
        status: 0,
        createTime: new Date().toLocaleString()
      }

      const afterSaleOrders = wx.getStorageSync('afterSaleOrders') || []
      afterSaleOrders.unshift(afterSaleOrder)
      wx.setStorageSync('afterSaleOrders', afterSaleOrders)
      
      setTimeout(() => {
        this.isSubmitting = false
        wx.showToast({ 
          title: '售后申请提交成功', 
          icon: 'success', 
          duration: 2000 
        })
        setTimeout(() => {
          wx.switchTab({ url: '/pages/afterSaleOrder/index' })
          this.form = {
            productName: '',
            productModel: '',
            faultDesc: '',
            imgList: [],
            name: '',
            phone: '',
            region: '',
            detail: ''
          }
          this.addressInfo = null
        }, 1500)
      }, 800)
    }
  }
}
</script>

<style scoped>
:root {
  --primary-color: #2f54eb;
  --light-primary: #f0f5ff;
  --text-color: #333;
  --text-gray: #999;
  --text-light: #666;
  --bg-color: #f8f8f8;
  --white: #fff;
  --red: #ff3b30;
  --border-color: #eee;
  --radius-sm: 8rpx;
  --radius-md: 12rpx;
  --radius-lg: 16rpx;
  --radius-full: 999rpx;
  --shadow: 0 4rpx 12rpx rgba(0, 0, 0, 0.05);
  --transition: all 0.3s ease;
}

.aftersale-page {
  min-height: 100vh;
  background: var(--bg-color);
  padding: 0;
  box-sizing: border-box;
}
.form-container {
  background: var(--white);
  margin: 20rpx;
  padding: 40rpx 30rpx;
  border-radius: var(--radius-lg);
  box-shadow: var(--shadow);
  margin-top: 20rpx;
}
.form-item {
  margin-bottom: 40rpx;
}
.label-wrap {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 15rpx;
}
.label {
  font-size: 30rpx;
  color: var(--text-color);
  font-weight: 500;
}
.required {
  color: var(--red);
  margin-left: 8rpx;
}
.optional {
  font-size: 24rpx;
  color: var(--text-gray);
}
.desc-text {
  font-size: 24rpx;
  color: var(--text-gray);
}
.input {
  width: 100%;
  height: 80rpx;
  border: 1px solid var(--border-color);
  border-radius: var(--radius-md);
  padding: 0 20rpx;
  font-size: 28rpx;
  background-color: #fafafa;
  transition: var(--transition);
}
.input:focus {
  border-color: var(--primary-color);
  background-color: var(--white);
  outline: none;
  box-shadow: 0 0 0 4rpx rgba(47, 84, 235, 0.1);
}
.input-placeholder {
  color: var(--text-gray);
  font-size: 26rpx;
}
.textarea {
  width: 100%;
  min-height: 180rpx;
  border: 1px solid var(--border-color);
  border-radius: var(--radius-md);
  padding: 20rpx;
  font-size: 28rpx;
  background-color: #fafafa;
  resize: none;
  transition: var(--transition);
  line-height: 1.6;
}
.textarea:focus {
  border-color: var(--primary-color);
  background-color: var(--white);
  outline: none;
  box-shadow: 0 0 0 4rpx rgba(47, 84, 235, 0.1);
}
.textarea-placeholder {
  color: var(--text-gray);
  font-size: 26rpx;
}
.address-select {
  display: flex;
  align-items: center;
  justify-content: space-between;
  width: 100%;
  height: 80rpx;
  border: 1px solid var(--border-color);
  border-radius: var(--radius-md);
  padding: 0 20rpx;
  background-color: #fafafa;
  transition: var(--transition);
}
.address-select-hover {
  border-color: var(--primary-color);
  background-color: var(--light-primary);
}
.address-info {
  flex: 1;
  display: flex;
  flex-direction: column;
}
.address-name {
  font-size: 28rpx;
  color: var(--text-color);
  margin-bottom: 5rpx;
}
.address-detail {
  font-size: 24rpx;
  color: var(--text-gray);
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
.address-placeholder {
  font-size: 26rpx;
  color: var(--text-gray);
}
.upload-area {
  display: flex;
  flex-wrap: wrap;
  gap: 20rpx;
  margin-top: 15rpx;
}
.upload-item {
  position: relative;
  width: 180rpx;
  height: 180rpx;
  border-radius: var(--radius-md);
  overflow: hidden;
  box-shadow: 0 2rpx 8rpx rgba(0,0,0,0.05);
}
.upload-img {
  width: 100%;
  height: 100%;
}
.del-btn {
  position: absolute;
  top: 10rpx;
  right: 10rpx;
  width: 40rpx;
  height: 40rpx;
  line-height: 40rpx;
  text-align: center;
  background: rgba(0,0,0,0.6);
  color: var(--white);
  font-size: 28rpx;
  border-radius: 50%;
  z-index: 10;
  transition: var(--transition);
}
.del-btn-hover {
  background: var(--red);
}
.upload-btn {
  width: 180rpx;
  height: 180rpx;
  border: 1px dashed var(--text-gray);
  border-radius: var(--radius-md);
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  background: #fafafa;
  transition: var(--transition);
}
.upload-btn-hover {
  border-color: var(--primary-color);
  background: var(--light-primary);
}
.upload-tip {
  font-size: 24rpx;
  color: var(--text-gray);
  margin-top: 10rpx;
}
.upload-desc {
  font-size: 22rpx;
  color: var(--text-gray);
  margin-top: 15rpx;
  display: block;
  line-height: 1.5;
}
.submit-btn {
  width: 100%;
  height: 88rpx;
  line-height: 88rpx;
  background: var(--primary-color);
  color: var(--white);
  border-radius: var(--radius-full);
  font-size: 32rpx;
  border: none;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 10rpx;
  margin-top: 20rpx;
  transition: var(--transition);
  box-shadow: var(--shadow);
}
.submit-btn:disabled {
  background: var(--text-gray) !important;
  color: var(--white);
}
.submit-btn-hover {
  background: #1e42d2;
  transform: scale(0.98);
}
.loading-icon {
  animation: spin 1s linear infinite;
}
@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}
</style>