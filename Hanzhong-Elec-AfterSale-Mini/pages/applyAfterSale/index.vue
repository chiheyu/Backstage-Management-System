<template>
  <merchant-receipt-panel v-if="isMerchant" />

  <view v-else class="aftersale-page">
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
          placeholder="请描述故障现象，方便商家快速判断"
          class="textarea"
          placeholder-class="textarea-placeholder"
          maxlength="200"
        ></textarea>
      </view>

      <view class="form-item">
        <view class="label-wrap">
          <text class="label">服务地址</text>
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
          <view v-for="(url, index) in form.imgList" :key="`${url}-${index}`" class="upload-item">
            <image :src="url" mode="aspectFill" class="upload-img"></image>
            <view class="del-btn" @tap="removeImage(index)" hover-class="del-btn-hover">×</view>
          </view>
          <view
            v-if="form.imgList.length < maxImageCount"
            class="upload-btn"
            @tap="chooseImages"
            hover-class="upload-btn-hover"
          >
            <uni-icons type="plus" size="40" color="#ccc"></uni-icons>
            <text class="upload-tip">上传图片</text>
          </view>
        </view>
        <text class="upload-desc">最多上传 {{ maxImageCount }} 张图片，提交时会自动上传到服务器。</text>
      </view>

      <button
        class="submit-btn"
        @tap="submit"
        :disabled="!isFormValid || isSubmitting"
        hover-class="submit-btn-hover"
      >
        <uni-icons
          v-if="isSubmitting"
          type="spinner-cycle"
          size="20"
          color="#fff"
          class="loading-icon"
        ></uni-icons>
        {{ isSubmitting ? '提交中...' : '提交售后申请' }}
      </button>
    </view>
  </view>
</template>

<script>
import { createAfterSaleOrder, uploadAfterSaleImage } from '@/api/afterSale'
import MerchantReceiptPanel from '@/components/MerchantReceiptPanel.vue'
import { syncRoleTabBar } from '@/utils/tabbar'

const EMPTY_FORM = {
  productName: '',
  productModel: '',
  faultDesc: '',
  imgList: [],
  name: '',
  phone: '',
  region: '',
  detail: ''
}
const AFTER_SALE_PREFILL_KEY = 'afterSalePrefill'

export default {
  components: {
    MerchantReceiptPanel
  },
  data() {
    return {
      isMerchant: false,
      form: {
        ...EMPTY_FORM
      },
      addressInfo: null,
      isSubmitting: false,
      maxImageCount: 3,
      ADDRESS_PATH: '/pages/address/index',
      LOGIN_PATH: '/pages/profile/login'
    }
  },
  computed: {
    isFormValid() {
      return (
        this.form.productName.trim().length > 0 &&
        this.form.productModel.trim().length > 0 &&
        this.form.faultDesc.trim().length > 0 &&
        this.form.name.trim().length > 0 &&
        /^1[3-9]\d{9}$/.test(this.form.phone.trim()) &&
        this.form.detail.trim().length > 0
      )
    }
  },
  onShow() {
    const userInfo = uni.getStorageSync('userInfo') || {}
    this.isMerchant = userInfo.role === 'merchant' || userInfo.roleType === '2'
    syncRoleTabBar(userInfo)

    uni.setNavigationBarTitle({
      title: this.isMerchant ? '售后回执' : '申请售后'
    })

    if (this.isMerchant) {
      return
    }
    this.loadDefaultAddress()
    this.consumeAfterSalePrefill()
  },
  methods: {
    consumeAfterSalePrefill() {
      const prefill = uni.getStorageSync(AFTER_SALE_PREFILL_KEY)
      if (!prefill || typeof prefill !== 'object') {
        return
      }

      uni.removeStorageSync(AFTER_SALE_PREFILL_KEY)

      this.form.productName = prefill.productName || this.form.productName
      this.form.productModel = prefill.productModel || this.form.productModel

      this.form.name = prefill.name || this.form.name
      this.form.phone = prefill.phone || this.form.phone

      if (prefill.receiverAddress) {
        this.form.region = ''
        this.form.detail = prefill.receiverAddress
        this.addressInfo = {
          name: this.form.name,
          phone: this.form.phone,
          region: '',
          detail: prefill.receiverAddress
        }
      }
    },
    ensureLogin(shouldRedirect = false) {
      const token = uni.getStorageSync('token')
      const userInfo = uni.getStorageSync('userInfo')

      if (token && userInfo) {
        return true
      }

      uni.showToast({
        title: '请先登录后再操作',
        icon: 'none'
      })

      if (shouldRedirect) {
        setTimeout(() => {
          uni.navigateTo({
            url: this.LOGIN_PATH
          })
        }, 600)
      }

      return false
    },
    loadDefaultAddress() {
      const addressList = uni.getStorageSync('addressList') || []
      const defaultAddress = addressList.find((item) => item && item.isDefault)

      if (!defaultAddress) {
        this.addressInfo = null
        return
      }

      this.addressInfo = defaultAddress
      this.form.name = defaultAddress.name || ''
      this.form.phone = defaultAddress.phone || ''
      this.form.region = defaultAddress.region || ''
      this.form.detail = defaultAddress.detail || ''
    },
    chooseAddress() {
      if (!this.ensureLogin(true)) {
        return
      }

      uni.navigateTo({
        url: this.ADDRESS_PATH,
        fail: () => {
          uni.showToast({
            title: '地址页面未找到',
            icon: 'none'
          })
        }
      })
    },
    chooseImages() {
      if (!this.ensureLogin(true)) {
        return
      }

      const remainCount = this.maxImageCount - this.form.imgList.length
      if (remainCount <= 0) {
        return
      }

      uni.chooseImage({
        count: remainCount,
        sizeType: ['compressed'],
        sourceType: ['album', 'camera'],
        success: ({ tempFilePaths = [] }) => {
          this.form.imgList = [...this.form.imgList, ...tempFilePaths].slice(0, this.maxImageCount)
        },
        fail: () => {
          uni.showToast({
            title: '图片选择失败，请重试',
            icon: 'none'
          })
        }
      })
    },
    removeImage(index) {
      uni.showModal({
        title: '确认删除',
        content: '是否删除这张故障图片？',
        confirmText: '删除',
        success: ({ confirm }) => {
          if (confirm) {
            this.form.imgList.splice(index, 1)
          }
        }
      })
    },
    async uploadImages() {
      if (!this.form.imgList.length) {
        return []
      }

      const uploadResults = await Promise.all(
        this.form.imgList.map((filePath) => uploadAfterSaleImage(filePath))
      )

      return uploadResults
        .map((item) => item && item.url)
        .filter((url) => typeof url === 'string' && url.trim())
    },
    buildPayload(imageUrls) {
      const productName = this.form.productName.trim()
      const productModel = this.form.productModel.trim()
      const region = this.form.region.trim()
      const detail = this.form.detail.trim()
      const address = [region, detail].filter(Boolean).join(' ')

      return {
        productType: `${productName} / ${productModel}`,
        faultDesc: this.form.faultDesc.trim(),
        faultImages: imageUrls.join(','),
        contactName: this.form.name.trim(),
        contactPhone: this.form.phone.trim(),
        address
      }
    },
    resetForm() {
      this.form = {
        ...EMPTY_FORM
      }
      this.addressInfo = null
      this.loadDefaultAddress()
    },
    handleRequestError(error, fallbackMessage) {
      if (!error || !error.msg) {
        uni.showToast({
          title: fallbackMessage,
          icon: 'none'
        })
      }
    },
    async submit() {
      if (!this.ensureLogin(true)) {
        return
      }

      if (!this.isFormValid) {
        uni.showToast({
          title: '请完整填写必填信息',
          icon: 'none'
        })
        return
      }

      if (this.isSubmitting) {
        return
      }

      this.isSubmitting = true
      uni.showLoading({
        title: this.form.imgList.length ? '上传并提交中...' : '提交中...',
        mask: true
      })

      try {
        const imageUrls = await this.uploadImages()
        const payload = this.buildPayload(imageUrls)
        await createAfterSaleOrder(payload)

        uni.hideLoading()
        this.resetForm()
        uni.showToast({
          title: '提交成功',
          icon: 'success'
        })

        setTimeout(() => {
          uni.navigateTo({
            url: '/pages/afterSaleOrder/index?type=all&role=user'
          })
        }, 500)
      } catch (error) {
        this.handleRequestError(error, '提交失败，请稍后重试')
      } finally {
        uni.hideLoading()
        this.isSubmitting = false
      }
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
  --bg-color: #f8f8f8;
  --white: #fff;
  --red: #ff3b30;
  --border-color: #eee;
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
}

.form-item {
  margin-bottom: 40rpx;
}

.label-wrap {
  display: flex;
  align-items: center;
  margin-bottom: 15rpx;
  gap: 8rpx;
}

.label {
  font-size: 30rpx;
  color: var(--text-color);
  font-weight: 500;
}

.required {
  color: var(--red);
}

.optional,
.desc-text,
.upload-desc {
  font-size: 24rpx;
  color: var(--text-gray);
}

.desc-text {
  margin-left: auto;
}

.input,
.textarea,
.address-select {
  width: 100%;
  border: 1px solid var(--border-color);
  border-radius: var(--radius-md);
  background-color: #fafafa;
  transition: var(--transition);
  box-sizing: border-box;
}

.input,
.address-select {
  height: 88rpx;
  padding: 0 20rpx;
}

.input {
  font-size: 28rpx;
}

.input-placeholder,
.textarea-placeholder,
.address-placeholder {
  color: var(--text-gray);
  font-size: 26rpx;
}

.textarea {
  min-height: 180rpx;
  padding: 20rpx;
  font-size: 28rpx;
  line-height: 1.6;
}

.address-select {
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.address-select-hover {
  border-color: var(--primary-color);
  background-color: var(--light-primary);
}

.address-info {
  flex: 1;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

.address-name {
  font-size: 28rpx;
  color: var(--text-color);
  margin-bottom: 6rpx;
}

.address-detail {
  font-size: 24rpx;
  color: var(--text-gray);
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.upload-area {
  display: flex;
  flex-wrap: wrap;
  gap: 20rpx;
}

.upload-item,
.upload-btn {
  width: 180rpx;
  height: 180rpx;
  border-radius: var(--radius-md);
}

.upload-item {
  position: relative;
  overflow: hidden;
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
  background: rgba(0, 0, 0, 0.6);
  color: #fff;
  font-size: 28rpx;
  border-radius: 50%;
}

.del-btn-hover {
  background: var(--red);
}

.upload-btn {
  border: 1px dashed var(--text-gray);
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  background: #fafafa;
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
  display: block;
  line-height: 1.5;
  margin-top: 15rpx;
}

.submit-btn {
  width: 100%;
  height: 88rpx;
  line-height: 88rpx;
  background: var(--primary-color);
  color: #fff;
  border-radius: var(--radius-full);
  font-size: 32rpx;
  border: none;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 10rpx;
  margin-top: 20rpx;
  box-shadow: var(--shadow);
}

.submit-btn:disabled {
  background: var(--text-gray) !important;
  color: #fff;
}

.submit-btn-hover {
  background: #1e42d2;
  transform: scale(0.98);
}

.loading-icon {
  animation: spin 1s linear infinite;
}

@keyframes spin {
  0% {
    transform: rotate(0deg);
  }

  100% {
    transform: rotate(360deg);
  }
}
</style>
