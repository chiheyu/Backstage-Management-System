<template>
  <view class="detail-page">
    <image
      :src="displayImage"
      mode="aspectFill"
      class="goods-img"
      lazy-load
      @error="imgError"
      placeholder-class="img-placeholder"
    ></image>

    <view class="goods-info" v-if="!isMerchant">
      <text class="goods-name">{{ currentGoods.name }}</text>
      <text class="goods-spec">{{ currentGoods.spec }}</text>
      <view class="price-row">
        <text class="price">¥{{ currentGoods.price }}</text>
        <text class="stock stock-empty" v-if="currentGoods.stock <= 0">已售罄</text>
        <text class="stock" v-else>库存：{{ currentGoods.stock }}件</text>
      </view>
    </view>

    <view class="goods-desc" v-if="!isMerchant">
      <view class="desc-title">商品详情</view>
      <text class="desc-content">{{ currentGoods.desc }}</text>
    </view>

    <view v-if="isMerchant" class="merchant-editor">
      <view class="editor-card">
        <view class="editor-header">
          <text class="editor-title">商品编辑</text>
          <text :class="['status-chip', merchantForm.status === '0' ? 'status-chip-on' : 'status-chip-off']">
            {{ merchantForm.status === '0' ? '上架中' : '已下架' }}
          </text>
        </view>

        <view class="form-item">
          <text class="form-label">商品名称</text>
          <input v-model="merchantForm.accessoryName" class="form-input" placeholder="请输入商品名称" maxlength="40" />
        </view>

        <view class="form-item">
          <text class="form-label">商品类别</text>
          <input v-model="merchantForm.categoryName" class="form-input" placeholder="请输入商品类别" maxlength="30" />
        </view>

        <view class="form-row">
          <view class="form-item half">
            <text class="form-label">售价</text>
            <input v-model="merchantForm.price" class="form-input" type="digit" placeholder="请输入售价" />
          </view>
          <view class="form-item half">
            <text class="form-label">库存</text>
            <input v-model="merchantForm.stock" class="form-input" type="number" placeholder="请输入库存" />
          </view>
        </view>

        <view class="form-item">
          <text class="form-label">图片地址</text>
          <input v-model="merchantForm.coverImage" class="form-input" placeholder="支持输入图片地址或选择上传" />
          <view class="image-actions">
            <button class="secondary-btn" @tap="chooseMerchantImage" :disabled="isUploadingImage">
              {{ isUploadingImage ? '上传中...' : '选择图片' }}
            </button>
          </view>
        </view>

        <view class="form-item">
          <text class="form-label">商品详情</text>
          <textarea
            v-model="merchantForm.accessoryDesc"
            class="form-textarea"
            placeholder="请输入商品详情"
            maxlength="300"
          ></textarea>
        </view>

        <view class="action-row">
          <button class="secondary-btn" @tap="toggleShelfStatus">
            {{ merchantForm.status === '0' ? '下架商品' : '重新上架' }}
          </button>
          <button class="primary-btn" @tap="saveMerchantGoods" :disabled="isSavingGoods">
            {{ isSavingGoods ? '保存中...' : '保存修改' }}
          </button>
        </view>
      </view>
    </view>

    <view class="bottom-bar">
      <view v-if="!isMerchant" class="user-bar">
        <button
          @tap="addToCart"
          class="cart-btn"
          :disabled="currentGoods.stock <= 0"
        >
          <text v-if="currentGoods.stock <= 0">已售罄</text>
          <text v-else>加入购物车</text>
        </button>
        <button @tap="goBack" class="back-btn">返回商城</button>
      </view>

      <view v-else class="merchant-bar">
        <button @tap="goBack" class="back-btn merchant-back-btn">返回商城</button>
      </view>
    </view>
  </view>
</template>

<script>
import { getAccessoryDetail, normalizeAccessory } from '@/api/accessory'
import {
  getMerchantAccessoryDetail,
  updateMerchantAccessory,
  uploadMerchantAccessoryImage
} from '@/api/merchantAccessory'
import { getCartList, setCartList } from '@/utils/cart'

function createEmptyGoods(defaultImage) {
  return {
    id: '',
    name: '',
    spec: '',
    price: '',
    stock: 0,
    image: defaultImage,
    desc: ''
  }
}

export default {
  data() {
    const defaultImage = '/static/images/accessory/default-accessory.png'

    return {
      goodsId: '',
      currentGoods: createEmptyGoods(defaultImage),
      isMerchant: false,
      defaultImage,
      isSavingGoods: false,
      isUploadingImage: false,
      merchantForm: {
        accessoryId: '',
        accessoryName: '',
        categoryName: '',
        accessoryDesc: '',
        coverImage: '',
        price: '',
        stock: '',
        status: '0'
      }
    }
  },
  computed: {
    displayImage() {
      return this.isMerchant
        ? (this.merchantForm.coverImage || this.currentGoods.image || this.defaultImage)
        : (this.currentGoods.image || this.defaultImage)
    }
  },
  onLoad(options) {
    this.goodsId = options.id || options.accessoryId || ''
    this.checkUserRole()
    this.loadGoodsDetail()
  },
  methods: {
    checkUserRole() {
      const userInfo = wx.getStorageSync('userInfo')
      this.isMerchant = userInfo?.role === 'merchant' || userInfo?.roleType === '2'
    },
    async loadGoodsDetail() {
      if (!this.goodsId) {
        wx.showToast({
          title: '缺少配件编号',
          icon: 'none'
        })
        return
      }

      try {
        const res = this.isMerchant
          ? await getMerchantAccessoryDetail(this.goodsId)
          : await getAccessoryDetail(this.goodsId)
        const detail = normalizeAccessory(res.data || {})
        if (!detail.id) {
          wx.showToast({
            title: '未找到配件信息',
            icon: 'none'
          })
          return
        }
        this.currentGoods = {
          ...this.currentGoods,
          ...detail
        }
        if (this.isMerchant) {
          this.merchantForm = {
            accessoryId: detail.accessoryId || detail.id,
            accessoryName: detail.accessoryName || detail.name || '',
            categoryName: detail.categoryName || detail.spec || '',
            accessoryDesc: detail.accessoryDesc || detail.desc || '',
            coverImage: detail.coverImage || '',
            price: String(detail.price ?? ''),
            stock: String(detail.stock ?? ''),
            status: String(detail.status || '0')
          }
        }
      } catch (error) {
        this.currentGoods = createEmptyGoods(this.defaultImage)
      }
    },
    imgError() {
      if (this.isMerchant && !this.merchantForm.coverImage) {
        return
      }
      this.currentGoods.image = this.defaultImage
    },
    addToCart() {
      if (this.isMerchant || this.currentGoods.stock <= 0 || !this.currentGoods.id) {
        return
      }

      const cart = getCartList()
      const existIndex = cart.findIndex((item) => item.id === this.currentGoods.id)

      if (existIndex > -1) {
        if (cart[existIndex].count >= this.currentGoods.stock) {
          wx.showToast({
            title: '已达最大库存',
            icon: 'none',
            duration: 1500
          })
          return
        }
        cart[existIndex].count += 1
      } else {
        cart.push({
          ...this.currentGoods,
          count: 1
        })
      }

      setCartList(cart)
      wx.showToast({
        title: '加入购物车成功',
        icon: 'success',
        duration: 1500,
        mask: true
      })
    },
    async chooseMerchantImage() {
      if (!this.isMerchant || this.isUploadingImage) {
        return
      }

      wx.chooseImage({
        count: 1,
        sizeType: ['compressed'],
        sourceType: ['album', 'camera'],
        success: async (res) => {
          const filePath = (res.tempFilePaths || [])[0]
          if (!filePath) {
            return
          }

          this.isUploadingImage = true
          try {
            const uploadRes = await uploadMerchantAccessoryImage(filePath)
            this.merchantForm.coverImage = uploadRes.url || this.merchantForm.coverImage
            wx.showToast({
              title: '图片上传成功',
              icon: 'success'
            })
          } catch (error) {
            wx.showToast({
              title: (error && error.msg) || '图片上传失败',
              icon: 'none'
            })
          } finally {
            this.isUploadingImage = false
          }
        }
      })
    },
    validateMerchantForm() {
      if (!this.merchantForm.accessoryName.trim()) {
        return '请输入商品名称'
      }
      if (!this.merchantForm.categoryName.trim()) {
        return '请输入商品类别'
      }
      if (!this.merchantForm.price || Number(this.merchantForm.price) <= 0) {
        return '请输入有效售价'
      }
      if (this.merchantForm.stock === '' || Number(this.merchantForm.stock) < 0) {
        return '请输入有效库存'
      }
      return ''
    },
    async saveMerchantGoods() {
      if (!this.isMerchant || this.isSavingGoods) {
        return
      }

      const validateMessage = this.validateMerchantForm()
      if (validateMessage) {
        wx.showToast({
          title: validateMessage,
          icon: 'none'
        })
        return
      }

      this.isSavingGoods = true
      try {
        await updateMerchantAccessory({
          accessoryId: this.merchantForm.accessoryId,
          accessoryName: this.merchantForm.accessoryName.trim(),
          categoryName: this.merchantForm.categoryName.trim(),
          accessoryDesc: this.merchantForm.accessoryDesc.trim(),
          coverImage: this.merchantForm.coverImage.trim(),
          price: Number(this.merchantForm.price),
          stock: Number(this.merchantForm.stock),
          status: this.merchantForm.status
        })
        wx.showToast({
          title: '保存成功',
          icon: 'success'
        })
        await this.loadGoodsDetail()
      } catch (error) {
        wx.showToast({
          title: (error && error.msg) || '保存失败',
          icon: 'none'
        })
      } finally {
        this.isSavingGoods = false
      }
    },
    toggleShelfStatus() {
      if (!this.isMerchant) {
        return
      }
      this.merchantForm.status = this.merchantForm.status === '0' ? '1' : '0'
    },
    goBack() {
      const pages = getCurrentPages()
      if (pages.length > 1) {
        wx.navigateBack({
          delta: 1
        })
        return
      }

      wx.switchTab({
        url: '/pages/accessoryMall/index'
      })
    }
  }
}
</script>

<style scoped>
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
  -webkit-tap-highlight-color: transparent;
}

page {
  background: #f8f8f8;
}

.detail-page {
  min-height: 100vh;
  background: #f8f8f8;
  padding-bottom: 120rpx;
}

.goods-img {
  width: 100%;
  height: 460rpx;
  border-radius: 0 0 24rpx 24rpx;
  background: #f5f5f5;
  object-fit: cover;
}

.img-placeholder {
  width: 100%;
  height: 460rpx;
  background-color: #f5f5f5;
  display: flex;
  align-items: center;
  justify-content: center;
}

.goods-info {
  background: #ffffff;
  padding: 40rpx 32rpx;
  margin: -40rpx 24rpx 24rpx;
  border-radius: 24rpx;
  box-shadow: 0 8rpx 24rpx rgba(0, 0, 0, 0.06);
  transition: all 0.3s ease;
}

.goods-name {
  font-size: 38rpx;
  font-weight: 700;
  color: #333333;
  display: block;
  margin-bottom: 16rpx;
  line-height: 1.4;
}

.goods-spec {
  font-size: 28rpx;
  color: #666666;
  display: block;
  margin-bottom: 24rpx;
  line-height: 1.5;
}

.price-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.price {
  font-size: 44rpx;
  color: #ff7300;
  font-weight: 700;
}

.stock {
  font-size: 26rpx;
  color: #999999;
}

.stock-empty {
  color: #ff4d4f;
  font-weight: 500;
}

.goods-desc {
  background: #ffffff;
  padding: 40rpx 32rpx;
  margin: 0 24rpx 40rpx;
  border-radius: 24rpx;
  box-shadow: 0 4rpx 16rpx rgba(0, 0, 0, 0.04);
}

.desc-title {
  font-size: 34rpx;
  font-weight: 700;
  color: #333333;
  margin-bottom: 24rpx;
  padding-bottom: 16rpx;
  border-bottom: 1rpx solid #f0f0f0;
}

.desc-content {
  font-size: 28rpx;
  color: #666666;
  line-height: 1.8;
  text-align: justify;
}

.merchant-editor {
  margin: 24rpx 24rpx 140rpx;
}

.editor-card {
  background: #ffffff;
  border-radius: 24rpx;
  padding: 40rpx 32rpx;
  box-shadow: 0 8rpx 24rpx rgba(0, 0, 0, 0.06);
}

.editor-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 32rpx;
}

.editor-title {
  font-size: 36rpx;
  font-weight: 700;
  color: #333333;
}

.status-chip {
  padding: 10rpx 22rpx;
  border-radius: 999rpx;
  font-size: 24rpx;
  font-weight: 500;
}

.status-chip-on {
  background: #edf9f0;
  color: #18a058;
}

.status-chip-off {
  background: #fff1f0;
  color: #d4380d;
}

.form-item {
  margin-bottom: 32rpx;
}

.form-row {
  display: flex;
  gap: 24rpx;
}

.half {
  flex: 1;
}

.form-label {
  display: block;
  font-size: 28rpx;
  color: #666666;
  margin-bottom: 16rpx;
  font-weight: 500;
}

.form-input,
.form-textarea {
  width: 100%;
  border: 1rpx solid #f0f0f0;
  border-radius: 16rpx;
  background: #fafafa;
  color: #333333;
  font-size: 28rpx;
  transition: all 0.2s ease;
}

.form-input:focus,
.form-textarea:focus {
  border-color: #2f54eb;
  background: #ffffff;
  box-shadow: 0 0 0 6rpx rgba(47, 84, 235, 0.1);
}

.form-input {
  height: 88rpx;
  padding: 0 24rpx;
}

.form-textarea {
  min-height: 200rpx;
  padding: 24rpx;
}

.image-actions {
  margin-top: 20rpx;
}

.action-row {
  display: flex;
  gap: 24rpx;
  margin-top: 40rpx;
}

.primary-btn,
.secondary-btn {
  flex: 1;
  height: 88rpx;
  line-height: 88rpx;
  border: none;
  border-radius: 44rpx;
  font-size: 28rpx;
  transition: all 0.2s ease;
  font-weight: 500;
}

.primary-btn {
  background: #2f54eb;
  color: #ffffff;
}

.secondary-btn {
  background: #eef2ff;
  color: #2f54eb;
}

.primary-btn:active,
.secondary-btn:active {
  transform: scale(0.96);
}

.bottom-bar {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  display: flex;
  height: 112rpx;
  background: #ffffff;
  border-top: 1rpx solid #f0f0f0;
  box-shadow: 0 -4rpx 12rpx rgba(0, 0, 0, 0.05);
  z-index: 99;
}

.user-bar,
.merchant-bar {
  display: flex;
  width: 100%;
  height: 100%;
}

.cart-btn,
.back-btn {
  flex: 1;
  height: 100%;
  line-height: 112rpx;
  font-size: 32rpx;
  border: none;
  border-radius: 0;
  transition: all 0.2s ease;
  font-weight: 500;
}

.cart-btn {
  background: #2f54eb;
  color: #ffffff;
}

.cart-btn:disabled {
  background: #999999;
  color: #ffffff;
}

.cart-btn:active:not(:disabled) {
  background: #1e42c8;
  transform: scale(0.98);
}

.back-btn {
  background: #f5f5f5;
  color: #2f54eb;
}

.back-btn:active {
  background: #e8e8e8;
  transform: scale(0.98);
}

.merchant-back-btn {
  background: #2f54eb;
  color: #ffffff;
}
</style>