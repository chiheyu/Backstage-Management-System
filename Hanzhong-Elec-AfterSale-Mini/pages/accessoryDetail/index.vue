<template>
  <view class="detail-page">
    <image
      :src="currentGoods.image"
      mode="aspectFill"
      class="goods-img"
      lazy-load
      @error="imgError"
      placeholder-class="img-placeholder"
    ></image>

    <view class="goods-info">
      <text class="goods-name">{{ currentGoods.name }}</text>
      <text class="goods-spec">{{ currentGoods.spec }}</text>
      <view class="price-row">
        <text class="price">¥{{ currentGoods.price }}</text>
        <text class="stock stock-empty" v-if="currentGoods.stock <= 0">已售罄</text>
        <text class="stock" v-else>库存：{{ currentGoods.stock }}件</text>
      </view>
    </view>

    <view class="goods-desc">
      <view class="desc-title">商品详情</view>
      <text class="desc-content">{{ currentGoods.desc }}</text>
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
      defaultImage
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
        const res = await getAccessoryDetail(this.goodsId)
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
      } catch (error) {
        this.currentGoods = createEmptyGoods(this.defaultImage)
      }
    },
    imgError() {
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
