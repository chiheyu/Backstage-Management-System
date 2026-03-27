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
:root {
  --primary-color: #2f54eb;
  --price-color: #ff7300;
  --text-color: #333;
  --text-gray: #999;
  --text-light: #666;
  --bg-color: #f8f8f8;
  --white: #fff;
  --red: #ff4d4f;
  --border-color: #eee;
  --radius-md: 12rpx;
  --shadow: 0 4rpx 12rpx rgba(0, 0, 0, 0.05);
  --transition: all 0.3s ease;
}

.detail-page {
  min-height: 100vh;
  background: var(--bg-color);
}

.goods-img {
  width: 100%;
  height: 400rpx;
  border-radius: var(--radius-md) var(--radius-md) 0 0;
  background: var(--bg-color);
}

.img-placeholder {
  width: 100%;
  height: 400rpx;
  background-color: #f5f5f5;
  display: flex;
  align-items: center;
  justify-content: center;
}

.goods-info {
  background: var(--white);
  padding: 30rpx;
  margin: 0 16rpx 20rpx;
  transform: translateY(-10rpx);
  border-radius: var(--radius-md);
  box-shadow: var(--shadow);
  transition: var(--transition);
}

.goods-name {
  font-size: 36rpx;
  font-weight: bold;
  color: var(--text-color);
  display: block;
  margin-bottom: 15rpx;
  line-height: 1.3;
}

.goods-spec {
  font-size: 28rpx;
  color: var(--text-light);
  display: block;
  margin-bottom: 20rpx;
  line-height: 1.4;
}

.price-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.price {
  font-size: 40rpx;
  color: var(--price-color);
  font-weight: bold;
}

.stock {
  font-size: 26rpx;
  color: var(--text-gray);
}

.stock-empty {
  color: var(--red);
  font-weight: 500;
}

.goods-desc {
  background: var(--white);
  padding: 30rpx;
  margin: 0 16rpx 100rpx;
  border-radius: var(--radius-md);
  box-shadow: var(--shadow);
}

.desc-title {
  font-size: 32rpx;
  font-weight: bold;
  color: var(--text-color);
  margin-bottom: 20rpx;
  padding-bottom: 10rpx;
  border-bottom: 1px solid var(--border-color);
}

.desc-content {
  font-size: 28rpx;
  color: var(--text-light);
  line-height: 1.8;
  text-align: justify;
}

.merchant-editor {
  margin: 0 16rpx 180rpx;
}

.editor-card {
  background: var(--white);
  border-radius: var(--radius-md);
  padding: 30rpx;
  box-shadow: var(--shadow);
}

.editor-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24rpx;
}

.editor-title {
  font-size: 34rpx;
  font-weight: 700;
  color: var(--text-color);
}

.status-chip {
  padding: 8rpx 18rpx;
  border-radius: 999rpx;
  font-size: 22rpx;
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
  margin-bottom: 24rpx;
}

.form-row {
  display: flex;
  gap: 20rpx;
}

.half {
  flex: 1;
}

.form-label {
  display: block;
  font-size: 26rpx;
  color: var(--text-light);
  margin-bottom: 12rpx;
}

.form-input,
.form-textarea {
  width: 100%;
  border: 1px solid var(--border-color);
  border-radius: 12rpx;
  box-sizing: border-box;
  background: #fafafa;
  color: var(--text-color);
  font-size: 28rpx;
}

.form-input {
  height: 84rpx;
  padding: 0 20rpx;
}

.form-textarea {
  min-height: 180rpx;
  padding: 20rpx;
}

.image-actions {
  margin-top: 16rpx;
}

.action-row {
  display: flex;
  gap: 20rpx;
  margin-top: 32rpx;
}

.primary-btn,
.secondary-btn {
  flex: 1;
  height: 84rpx;
  line-height: 84rpx;
  border: none;
  border-radius: 42rpx;
  font-size: 28rpx;
}

.primary-btn {
  background: var(--primary-color);
  color: var(--white);
}

.secondary-btn {
  background: #eef2ff;
  color: var(--primary-color);
}

.bottom-bar {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  display: flex;
  height: 100rpx;
  background: var(--white);
  border-top: 1px solid var(--border-color);
  box-shadow: 0 -2rpx 10rpx rgba(0, 0, 0, 0.03);
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
  line-height: 100rpx;
  font-size: 32rpx;
  border: none;
  border-radius: 0;
  transition: var(--transition);
}

.cart-btn {
  background: var(--primary-color);
  color: var(--white);
}

.cart-btn:disabled {
  background: var(--text-gray);
  color: var(--white);
}

.cart-btn:active:not(:disabled) {
  background: #1e42c8;
  transform: scale(0.98);
}

.back-btn {
  background: #f5f5f5;
  color: var(--primary-color);
}

.back-btn:active {
  background: #e8e8e8;
  transform: scale(0.98);
}

.merchant-back-btn {
  background: var(--primary-color);
  color: var(--white);
}
</style>