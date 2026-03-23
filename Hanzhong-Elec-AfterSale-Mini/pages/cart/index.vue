<template>
  <view class="cart-page">
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
</template>

<script>
import { getCartList, setCartList } from '@/utils/cart'

export default {
  data() {
    return {
      cartList: [],
      defaultImage: '/static/images/default-img.png'
    }
  },
  onShow() {
    this.cartList = getCartList();
  },
  computed: {
    totalPrice() {
      return this.cartList.reduce((sum, item) => sum + item.price * item.count, 0);
    }
  },
  methods: {
	  toPay() {
	    wx.showModal({
	      title: '确认结算',
	      content: `共计¥${this.totalPrice.toFixed(2)}，确认提交订单？`,
	      success: (res) => {
	        if (res.confirm) {
	          // 模拟支付成功
	          wx.showToast({ title: '支付成功', icon: 'success', duration: 2000 });
	          // 支付后清空购物车
	          this.cartList = [];
	          this.updateCart();
	          // 跳转到订单页（你有售后/订单页就跳，没有就留空）
	          setTimeout(() => {
	            wx.switchTab({ url: "/pages/afterSaleOrder/index" });
	          }, 2000);
	        }
	      }
	    });
	  },
    goShop() {
      wx.switchTab({ url: "/pages/accessoryMall/index" });
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
  --text-color: #333;
  --text-gray: #999;
  --text-light: #666;
  --bg-color: #f8f8f8;
  --white: #fff;
  --red: #ff4d4f;
  --border-color: #eee;
  --radius-sm: 8rpx;
  --radius-md: 12rpx;
  --radius-lg: 16rpx;
  --radius-full: 999rpx;
  --shadow: 0 4rpx 12rpx rgba(0, 0, 0, 0.05);
  --shadow-deep: 0 6rpx 16rpx rgba(0, 0, 0, 0.08);
  --transition: all 0.3s ease;
}

.cart-page {
  min-height: 100vh;
  background: var(--bg-color);
  padding: 20rpx;
  padding-bottom: 120rpx;
}

.empty-cart {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 150rpx 0;
}
.empty-text {
  font-size: 32rpx;
  color: var(--text-gray);
  margin: 30rpx 0;
}
.go-shop-btn {
  background: var(--primary-color);
  color: var(--white);
  border-radius: var(--radius-full);
  padding: 20rpx 50rpx;
  font-size: 30rpx;
  border: none;
  transition: var(--transition);
  box-shadow: var(--shadow);
}
.go-shop-btn:active {
  background: #1e42c8;
  transform: scale(0.98);
}

.cart-list {
  margin-top: 20rpx;
}
.cart-item {
  display: flex;
  background: var(--white);
  padding: 24rpx;
  border-radius: var(--radius-md);
  margin-bottom: 20rpx;
  align-items: center;
  box-shadow: var(--shadow);
  transition: var(--transition);
}
.cart-item:active {
  transform: scale(0.98);
  box-shadow: var(--shadow-deep);
}
.item-img {
  width: 140rpx;
  height: 140rpx;
  border-radius: var(--radius-sm);
  margin-right: 24rpx;
  background: var(--bg-color);
}
.item-info {
  flex: 1;
}
.item-name {
  font-size: 32rpx;
  color: var(--text-color);
  font-weight: bold;
  display: block;
  margin-bottom: 10rpx;
  line-height: 1.3;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}
.item-spec {
  font-size: 24rpx;
  color: var(--text-light);
  display: block;
  margin-bottom: 15rpx;
  line-height: 1.4;
  display: -webkit-box;
  -webkit-line-clamp: 1;
  -webkit-box-orient: vertical;
  overflow: hidden;
}
.item-price {
  font-size: 32rpx;
  color: var(--price-color);
  font-weight: bold;
  display: block;
  margin-bottom: 20rpx;
}
.count-wrap {
  display: flex;
  align-items: center;
}
.count-btn {
  width: 50rpx;
  height: 50rpx;
  line-height: 50rpx;
  text-align: center;
  border: 1px solid var(--border-color);
  border-radius: var(--radius-sm);
  font-size: 28rpx;
  color: var(--text-color);
  background: var(--bg-color);
  transition: var(--transition);
}
.count-btn:disabled {
  color: var(--text-gray);
  background: var(--white);
  border-color: var(--border-color);
}
.count-btn:active:not(:disabled) {
  background: var(--light-primary);
  border-color: var(--primary-color);
}
.count {
  margin: 0 20rpx;
  font-size: 28rpx;
  color: var(--text-color);
  font-weight: 500;
}
.delete-btn {
  color: var(--red);
  border: 1px solid var(--red);
  border-radius: var(--radius-sm);
  padding: 12rpx 24rpx;
  font-size: 26rpx;
  background: var(--white);
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
  padding: 20rpx 30rpx;
  display: flex;
  align-items: center;
  justify-content: space-between;
  border-top: 1px solid var(--border-color);
  box-shadow: 0 -2rpx 10rpx rgba(0, 0, 0, 0.03);
  z-index: 99;
}
.total-text {
  font-size: 34rpx;
  font-weight: bold;
  color: var(--text-color);
}
.pay-btn {
  background: var(--primary-color);
  color: var(--white);
  border-radius: var(--radius-full);
  padding: 20rpx 50rpx;
  font-size: 30rpx;
  border: none;
  transition: var(--transition);
  box-shadow: var(--shadow);
}
.pay-btn:disabled {
  background: var(--text-gray);
  color: var(--white);
}
.pay-btn:active:not(:disabled) {
  background: #1e42c8;
  transform: scale(0.98);
}
</style>
