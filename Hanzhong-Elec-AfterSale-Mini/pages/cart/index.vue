<template>
  <view class="cart-root">
    <view class="merchant-workbench" v-if="isMerchant">
      <view class="workbench-hero">
        <text class="workbench-title">商家工作台</text>
        <text class="workbench-desc">在这里可以进行商品管理、订单处理等操作</text>
      </view>

      <view class="workbench-grid">
        <view class="workbench-item" @tap="goPendingOrders">
          <uni-icons type="list" size="34" color="#2f54eb"></uni-icons>
          <text class="workbench-item-title">售后订单</text>
          <text class="workbench-item-desc">查看售后待处理和已处理订单</text>
        </view>
        <view class="workbench-item" @tap="goAccessoryOrders">
          <uni-icons type="cart" size="34" color="#0f766e"></uni-icons>
          <text class="workbench-item-title">配件订单</text>
          <text class="workbench-item-desc">查看商家收到的配件订单</text>
        </view>
        <view class="workbench-item" @tap="goGoodsManage">
          <uni-icons type="shop" size="34" color="#fa8c16"></uni-icons>
          <text class="workbench-item-title">商品管理</text>
          <text class="workbench-item-desc">查看、编辑和上下架商品</text>
        </view>
        <view class="workbench-item" @tap="goReceiptPage">
          <uni-icons type="compose" size="34" color="#18a058"></uni-icons>
          <text class="workbench-item-title">售后处理</text>
          <text class="workbench-item-desc">处理工单并完成售后</text>
        </view>
      </view>
      <view class="workbench-bottom" @tap="goProfile">
        <view class="bottom-left">
          <uni-icons type="person" size="34" color="#722ed1"></uni-icons>
          <text class="workbench-bottom-title">返回我的</text>
        </view>
        <uni-icons type="right" size="24" color="#646570"></uni-icons>
      </view>
    </view>

    <view v-else class="cart-page">
      <view class="empty-cart" v-if="cartList.length === 0">
        <uni-icons type="cart" size="100" color="#ccc"></uni-icons>
        <text class="empty-text">购物车空空如也~</text>
        <button class="go-shop-btn" @click="goShop">去逛逛</button>
      </view>

      <view class="cart-list" v-else>
        <view class="cart-item" v-for="item in cartList" :key="item.id">
          <image 
            :src="item.image" 
            mode="aspectFill" 
            class="item-img"
            lazy-load
            @error="imgError"
          ></image>
          <view class="item-info">
            <text class="item-name">{{ item.name }}</text>
            <text class="item-spec" v-if="item.spec">{{ item.spec }}</text>
            <text class="item-price">¥{{ item.price }}</text>
            <view class="count-wrap">
              <button @click="minusCount(item)" class="count-btn" :disabled="item.count <= 1">-</button>
              <text class="count">{{ item.count }}</text>
              <button @click="plusCount(item)" class="count-btn" :disabled="item.count >= item.stock">+</button>
            </view>
          </view>
          <button @click="deleteItem(item.id)" class="delete-btn">删除</button>
        </view>

        <view class="total-bar">
          <text class="total-text">合计：¥{{ totalPrice.toFixed(2) }}</text>
          <button class="pay-btn" :disabled="cartList.length === 0" @click="toPay">结算</button>
        </view>
      </view>
    </view>
  </view>
</template>

<script>
import { createAccessoryOrder } from '@/api/accessoryOrder'
import { getCartList, setCartList } from '@/utils/cart'
import { syncRoleTabBar } from '@/utils/tabbar'

export default {
  data() {
    return {
      cartList: [],
      defaultImage: '/static/images/default-img.png',
      isMerchant: false
    }
  },
  onShow() {
    const userInfo = wx.getStorageSync('userInfo') || {}
    this.isMerchant = userInfo.role === 'merchant' || userInfo.roleType === '2'
    syncRoleTabBar(userInfo)
    wx.setNavigationBarTitle({
      title: this.isMerchant ? '商家工作台' : '我的购物车'
    })
    if (this.isMerchant) {
      return
    }
    this.cartList = getCartList();
  },
  computed: {
    totalPrice() {
      return this.cartList.reduce((sum, item) => sum + item.price * item.count, 0);
    }
  },
  methods: {
    getDefaultAddress() {
      const addressList = wx.getStorageSync('addressList') || []
      return addressList.find((item) => item && item.isDefault) || addressList[0] || null
    },
    ensureLogin() {
      const token = wx.getStorageSync('token')
      const userInfo = wx.getStorageSync('userInfo')
      if (token && userInfo) {
        return true
      }
      wx.showToast({
        title: '请先登录',
        icon: 'none'
      })
      setTimeout(() => {
        wx.navigateTo({
          url: '/pages/profile/login'
        })
      }, 500)
      return false
    },
    async submitAccessoryOrders() {
      const defaultAddress = this.getDefaultAddress()
      if (!defaultAddress) {
        wx.showModal({
          title: '缺少收货地址',
          content: '请先添加并选择默认收货地址后再结算',
          success: (res) => {
            if (res.confirm) {
              wx.navigateTo({ url: '/pages/address/index' })
            }
          }
        })
        return
      }
      const failedItems = []
      const paidItems = []
      for (const item of this.cartList) {
        try {
          await createAccessoryOrder({
            accessoryId: item.id,
            quantity: item.count,
            receiverName: defaultAddress.name,
            receiverPhone: defaultAddress.phone,
            receiverAddress: `${defaultAddress.region} ${defaultAddress.detail}`.trim(),
            orderRemark: ''
          })
          paidItems.push(item.id)
        } catch (error) {
          failedItems.push({
            item,
            msg: (error && error.msg) || '下单失败'
          })
        }
      }
      if (failedItems.length) {
        this.cartList = this.cartList.filter((item) => !paidItems.includes(item.id))
        this.updateCart()
        wx.showToast({
          title: failedItems[0].msg,
          icon: 'none',
          duration: 2000
        })
        return
      }
      this.cartList = []
      this.updateCart()
      wx.showToast({
        title: '下单成功',
        icon: 'success',
        duration: 1500
      })
      setTimeout(() => {
        wx.navigateTo({ url: '/pages/accessoryOrder/index?type=pending' })
      }, 500)
    },
    toPay() {
      if (!this.ensureLogin()) {
        return
      }
      wx.showModal({
        title: '确认结算',
        content: `共计¥${this.totalPrice.toFixed(2)}，确认提交订单？`,
        success: async (res) => {
          if (res.confirm) {
            wx.showLoading({
              title: '下单中...',
              mask: true
            })
            try {
              await this.submitAccessoryOrders()
            } finally {
              wx.hideLoading()
            }
          }
        }
      });
    },
    goShop() {
      wx.switchTab({ url: "/pages/accessoryMall/index" });
    },
    goPendingOrders() {
      wx.navigateTo({
        url: '/pages/afterSaleOrder/index?type=all&audit=1&role=merchant'
      })
    },
    goAccessoryOrders() {
      wx.navigateTo({
        url: '/pages/merchantAccessoryOrder/index?type=pending'
      })
    },
    goGoodsManage() {
      wx.switchTab({ url: '/pages/accessoryMall/index' })
    },
    goReceiptPage() {
      wx.switchTab({ url: '/pages/applyAfterSale/index' })
    },
    goProfile() {
      wx.switchTab({ url: '/pages/profile/index' })
    },
    imgError(e) {
      e.target.src = this.defaultImage;
    },
    minusCount(item) {
      if (item.count <= 1) return;
      item.count--;
      this.updateCart();
    },
    plusCount(item) {
      if (item.count >= item.stock) {
        wx.showToast({ title: '已达最大库存', icon: 'none', duration: 1500 });
        return;
      }
      item.count++;
      this.updateCart();
    },
    deleteItem(id) {
      wx.showModal({
        title: '提示',
        content: '确定要删除该商品吗？',
        success: (res) => {
          if (res.confirm) {
            this.cartList = this.cartList.filter(item => item.id !== id);
            this.updateCart();
            wx.showToast({ title: '删除成功', icon: 'success', duration: 1500 });
          }
        }
      });
    },
    updateCart() {
      if (!Array.isArray(this.cartList)) {
        this.cartList = [];
      }
      setCartList(this.cartList);
    }
  }
}
</script>

<style scoped>
:root {
  --primary-color: #2f54eb;
  --light-primary: #f0f5ff;
  --price-color: #ff7300;
  --text-color: #1d2129;
  --text-gray: #999;
  --text-light: #646570;
  --bg-color: #f7f8fa;
  --white: #ffffff;
  --red: #ff4d4f;
  --border-color: #e5e6eb;
  --radius-sm: 10rpx;
  --radius-md: 16rpx;
  --radius-lg: 20rpx;
  --radius-full: 999rpx;
  --shadow: 0 2rpx 12rpx rgba(0, 0, 0, 0.06);
  --shadow-deep: 0 6rpx 20rpx rgba(0, 0, 0, 0.08);
  --transition: all 0.2s ease;
}
.cart-root {
  min-height: 100vh;
  background: var(--bg-color);
}
.merchant-workbench {
  padding: 24rpx;
}
.workbench-hero {
  padding: 32rpx 28rpx;
  border-radius: var(--radius-lg);
  background: linear-gradient(135deg, #0d2fa8 0%, #2f54eb 100%);
  color: var(--white);
  box-shadow: var(--shadow-deep);
  margin-bottom: 32rpx;
}
.workbench-title {
  font-size: 36rpx;
  font-weight: 700;
  margin-bottom: 16rpx;
  display: block;
}
.workbench-desc {
  font-size: 24rpx;
  line-height: 1.6;
  opacity: 0.9;
  display: block;
}
.workbench-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 24rpx;
}
.workbench-item {
  background: var(--white);
  border-radius: var(--radius-lg);
  padding: 36rpx 32rpx;
  box-shadow: var(--shadow);
  display: flex;
  flex-direction: column;
  gap: 18rpx;
  transition: var(--transition);
}
.workbench-item:active {
  transform: scale(0.97);
  box-shadow: var(--shadow-deep);
}
.workbench-item-title {
  font-size: 32rpx;
  font-weight: 600;
  color: var(--text-color);
}
.workbench-item-desc {
  font-size: 24rpx;
  color: var(--text-light);
  line-height: 1.5;
}
/* 底部按钮：左右布局，图标+文字居中，箭头靠右 */
.workbench-bottom {
  background: var(--white);
  border-radius: var(--radius-lg);
  padding: 28rpx 32rpx;
  box-shadow: var(--shadow);
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-top: 24rpx;
  transition: var(--transition);
}
.workbench-bottom:active {
  transform: scale(0.97);
  box-shadow: var(--shadow-deep);
}
.bottom-left {
  display: flex;
  align-items: center;
  gap: 16rpx;
}
.workbench-bottom-title {
  font-size: 30rpx;
  font-weight: 600;
  color: var(--text-color);
}
.cart-page {
  padding: 24rpx;
  padding-bottom: 130rpx;
}
.empty-cart {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 180rpx 0;
}
.empty-text {
  font-size: 32rpx;
  color: var(--text-gray);
  margin: 40rpx 0;
}
.go-shop-btn {
  background: var(--primary-color);
  color: var(--white);
  border-radius: var(--radius-full);
  padding: 24rpx 60rpx;
  font-size: 30rpx;
  border: none;
  transition: var(--transition);
  box-shadow: var(--shadow);
}
.go-shop-btn:active {
  transform: scale(0.96);
}
.cart-list {
  margin-top: 24rpx;
}
.cart-item {
  display: flex;
  background: var(--white);
  padding: 28rpx;
  border-radius: var(--radius-md);
  margin-bottom: 24rpx;
  align-items: center;
  box-shadow: var(--shadow);
  transition: var(--transition);
}
.cart-item:active {
  transform: scale(0.98);
}
.item-img {
  width: 150rpx;
  height: 150rpx;
  border-radius: var(--radius-sm);
  margin-right: 28rpx;
  background: var(--bg-color);
  object-fit: cover;
}
.item-info {
  flex: 1;
}
.item-name {
  font-size: 32rpx;
  color: var(--text-color);
  font-weight: 600;
  display: block;
  margin-bottom: 12rpx;
  line-height: 1.4;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}
.item-spec {
  font-size: 24rpx;
  color: var(--text-light);
  display: block;
  margin-bottom: 16rpx;
}
.item-price {
  font-size: 34rpx;
  color: var(--price-color);
  font-weight: 700;
  display: block;
  margin-bottom: 24rpx;
}
.count-wrap {
  display: flex;
  align-items: center;
}
.count-btn {
  width: 56rpx;
  height: 56rpx;
  line-height: 56rpx;
  text-align: center;
  border: 1rpx solid var(--border-color);
  border-radius: var(--radius-sm);
  font-size: 28rpx;
  color: var(--text-color);
  background: var(--bg-color);
  transition: var(--transition);
}
.count-btn:disabled {
  color: var(--text-gray);
  background: var(--white);
}
.count-btn:active:not(:disabled) {
  background: var(--light-primary);
  border-color: var(--primary-color);
}
.count {
  margin: 0 24rpx;
  font-size: 30rpx;
  color: var(--text-color);
  font-weight: 500;
}
.delete-btn {
  color: var(--red);
  border: 1rpx solid var(--red);
  border-radius: var(--radius-sm);
  padding: 16rpx 28rpx;
  font-size: 26rpx;
  background: transparent;
  transition: var(--transition);
}
.delete-btn:active {
  background: var(--red);
  color: var(--white);
}
.total-bar {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  background: var(--white);
  padding: 24rpx 32rpx;
  display: flex;
  align-items: center;
  justify-content: space-between;
  border-top: 1rpx solid var(--border-color);
  box-shadow: 0 -2rpx 12rpx rgba(0, 0, 0, 0.04);
  z-index: 99;
}
.total-text {
  font-size: 36rpx;
  font-weight: 700;
  color: var(--text-color);
}
.pay-btn {
  background: var(--primary-color);
  color: var(--white);
  border-radius: var(--radius-full);
  padding: 24rpx 60rpx;
  font-size: 30rpx;
  border: none;
  transition: var(--transition);
  box-shadow: var(--shadow);
}
.pay-btn:disabled {
  background: var(--text-gray);
}
.pay-btn:active:not(:disabled) {
  transform: scale(0.96);
}
</style>
