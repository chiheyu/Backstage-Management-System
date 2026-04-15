<template>
  <view class="home-page">
    <view class="banner-wrap">
      <swiper class="banner" autoplay indicator-dots circular indicator-color="rgba(255,255,255,0.5)" indicator-active-color="#fff" duration="500" interval="3500" indicator-dots-style="bottom: 24rpx; right: 32rpx;">
        <swiper-item v-for="(item, idx) in bannerList" :key="idx">
          <view class="banner-item" @click="handleBannerClick(item)">
            <image :src="item.image" mode="aspectFill" class="banner-img" lazy-load @error="imgError($event)"></image>
            <view class="banner-mask" v-if="item.title">
              <text class="banner-title">{{ item.title }}</text>
              <text class="banner-subtitle">{{ item.subtitle }}</text>
            </view>
          </view>
        </swiper-item>
      </swiper>
    </view>
    <view class="func-list">
      <view class="func-item" @click="toApplyAfterSale" v-if="role === 'user'">
        <view class="icon-wrap">
          <uni-icons type="compose" size="40" color="#2f54eb"></uni-icons>
        </view>
        <text class="func-text">申请售后</text>
      </view>
      <view class="func-item" @click="toAfterSaleAudit" v-if="role === 'merchant'">
        <view class="icon-wrap">
          <uni-icons type="checkbox" size="40" color="#2f54eb"></uni-icons>
        </view>
        <text class="func-text">售后审核</text>
      </view>
      <view class="func-item" @click="toAccessoryMall">
        <view class="icon-wrap">
          <uni-icons type="shop" size="40" color="#2f54eb"></uni-icons>
        </view>
        <text class="func-text">配件商城</text>
      </view>
      <view class="func-item" @click="toMerchantList">
        <view class="icon-wrap">
          <uni-icons :type="role === 'merchant' ? 'shop' : 'location'" size="40" color="#2f54eb"></uni-icons>
        </view>
        <text class="func-text">{{ role === 'merchant' ? '我的店铺' : '附近商家' }}</text>
      </view>
    </view>
    <view class="hot-accessory">
      <view class="title-wrap">
        <text class="title">热门配件</text>
        <text class="more-text" @click="toAccessoryMall">更多 ></text>
      </view>
      <view class="empty-wrap" v-if="!hotAccessoryList.length">
        <uni-icons type="shop" size="60" color="#ccc"></uni-icons>
        <text class="empty-text">暂无热门配件</text>
      </view>
      <view class="goods-grid" v-else>
        <view class="goods-item" v-for="(item, idx) in hotAccessoryList" :key="item.id" @click="toAccessoryDetail(item)" v-if="idx<4">
          <view class="img-wrap">
            <image :src="item.image" mode="aspectFill" class="item-img" lazy-load @error="imgError($event)"></image>
            <view class="price-tag" v-if="item.originalPrice > item.price">
              <text>省¥{{ item.originalPrice - item.price }}</text>
            </view>
          </view>
          <text class="item-name" :title="item.name">{{ item.name }}</text>
          <view class="price-wrap">
            <text class="item-price">¥{{ item.price }}</text>
            <text class="original-price" v-if="item.originalPrice">¥{{ item.originalPrice }}</text>
          </view>
        </view>
      </view>
    </view>
    <view class="back-top" @click="backToTop">
      <uni-icons type="top" size="28" color="#fff"></uni-icons>
    </view>
  </view>
</template>

<script>
export default {
  data() {
    return {
      bannerList: [
        { 
          image: "/static/images/banner/banner1.png",
          title: "汉中电子售后",
          subtitle: "专业·快速·贴心",
          link: "/pages/accessoryMall/index",
          type: "switchTab"
        },
        { 
          image: "/static/images/banner/banner2.png",
          title: "配件商城",
          subtitle: "正品保障 极速发货",
          link: "/pages/merchantDetail/index",
          type: "navigateTo"
        }
      ],
      hotAccessoryList: [],
      role: 'user'
    }
  },
  onShow() {
    this.getUserRole();
  },
  onUnload() {
  },
  onLoad() {
    setTimeout(() => {
      this.hotAccessoryList = [
        { id: 1, name: "电源适配器", price: 89, originalPrice: 129, image: "/static/images/accessory/adapter.png" },
        { id: 2, name: "手机电池", price: 129, originalPrice: 169, image: "/static/images/accessory/battery.png" },
        { id: 3, name: "手机壳", price: 39, originalPrice: 59, image: "/static/images/accessory/case.png" },
        { id: 4, name: "充电口", price: 49, originalPrice: 69, image: "/static/images/accessory/charging_port.png" },
        { id: 6, name: "耳机", price: 199, originalPrice: 259, image: "/static/images/accessory/earphone.png" },
        { id: 7, name: "手机膜", price: 29, originalPrice: 49, image: "/static/images/accessory/glass.png" },
        { id: 8, name: "笔记本适配器", price: 129, originalPrice: 169, image: "/static/images/accessory/laptop_adapter.png" },
        { id: 9, name: "笔记本电池", price: 299, originalPrice: 399, image: "/static/images/accessory/laptop_battery.png" },
        { id: 10, name: "笔记本屏幕", price: 599, originalPrice: 799, image: "/static/images/accessory/laptop_screen.png" },
        { id: 11, name: "手机屏幕", price: 399, originalPrice: 499, image: "/static/images/accessory/phone_screen.png" },
        { id: 12, name: "扬声器", price: 89, originalPrice: 119, image: "/static/images/accessory/speaker.png" },
        { id: 13, name: "固态硬盘", price: 399, originalPrice: 499, image: "/static/images/accessory/ssd.png" },
        { id: 14, name: "平板电池", price: 199, originalPrice: 259, image: "/static/images/accessory/tablet_battery.png" },
        { id: 15, name: "平板屏幕", price: 499, originalPrice: 649, image: "/static/images/accessory/tablet_screen.png" },
        { id: 16, name: "Type-C数据线", price: 29, originalPrice: 49, image: "/static/images/accessory/typec_cable.png" },
        { id: 17, name: "无线充电器", price: 129, originalPrice: 169, image: "/static/images/accessory/wireless_charger.png" }
      ]
    }, 300);
  },
  methods: {
    getUserRole() {
      const userInfo = wx.getStorageSync('userInfo');
      this.role = userInfo ? userInfo.role : 'user';
    },
    imgError(e) {
      e.target.src = 'https://picsum.photos/750/300?random=3';
    },
    handleBannerClick(item) {
      if (!item.link) return;
      const navigateConfig = { url: item.link };
      item.type === "switchTab" ? wx.switchTab(navigateConfig) : wx.navigateTo(navigateConfig);
    },
    toApplyAfterSale() {
      wx.switchTab({ url: "/pages/applyAfterSale/index" });
    },
    toAfterSaleAudit() {
      wx.navigateTo({ url: "/pages/afterSaleOrder/index" });
    },
    toAccessoryMall() {
      wx.switchTab({ url: "/pages/accessoryMall/index" });
    },
    toMerchantList() {
      const url = this.role === 'merchant'
        ? '/pages/merchantDetail/index?mode=merchant'
        : '/pages/merchantDetail/index'
      wx.navigateTo({ url });
    },
    toAccessoryDetail(item) {},
    backToTop() {
      wx.pageScrollTo({
        scrollTop: 0,
        duration: 300
      });
    }
  }
}
</script>

<style scoped>
:root {
  --primary-color: #2f54eb;
  --light-primary: #f0f5ff;
  --grad-primary: linear-gradient(135deg, #4d6fff, #2f54eb);
  --text-color: #1d2129;
  --text-gray: #86909c;
  --price-color: #ff3d3d;
  --bg-color: linear-gradient(135deg, #f7f8fa, #f0f2f5);
  --white: #ffffff;
  --shadow: 0 4rpx 12rpx rgba(0, 0, 0, 0.04);
  --shadow-deep: 0 6rpx 16rpx rgba(0, 0, 0, 0.06);
  --radius-sm: 12rpx;
  --radius-md: 18rpx;
  --radius-lg: 24rpx;
  --radius-circle: 50%;
  --transition: all 0.3s cubic-bezier(0.2, 0.8, 0.3, 1);
}
.home-page {
  min-height: 100vh;
  background: var(--bg-color);
  padding: 0 24rpx 120rpx 24rpx;
  margin-top: 0;
  position: relative;
}
.banner-wrap {
  margin: 0 0 32rpx 0;
  overflow: hidden;
  box-shadow: var(--shadow);
  position: relative;
  width: 100vw;
  margin-left: -24rpx;
  border-radius: 0 0 var(--radius-lg) var(--radius-lg);
}
.banner {
  height: 380rpx;
  width: 100%;
}
.banner-item {
  width: 100%;
  height: 100%;
  position: relative;
}
.banner-img {
  width: 100%;
  height: 100%;
  display: block;
  object-fit: cover;
}
.banner-mask {
  position: absolute;
  left: 0;
  bottom: 0;
  width: 100%;
  padding: 60rpx 40rpx;
  background: linear-gradient(transparent, rgba(0,0,0,0.7));
  display: flex;
  flex-direction: column;
  justify-content: flex-end;
}
.banner-title {
  font-size: 44rpx;
  font-weight: 700;
  color: #fff;
  margin-bottom: 12rpx;
  text-shadow: 0 4rpx 8rpx rgba(0,0,0,0.4);
  letter-spacing: 2rpx;
}
.banner-subtitle {
  font-size: 28rpx;
  color: rgba(255,255,255,0.95);
  text-shadow: 0 2rpx 4rpx rgba(0,0,0,0.4);
  font-weight: 300;
}
.func-list {
  display: flex;
  justify-content: space-around;
  padding: 40rpx 24rpx;
  background: var(--white);
  margin: 0 0 32rpx 0;
  border-radius: var(--radius-lg);
  box-shadow: var(--shadow);
}
.func-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  width: 150rpx;
  padding: 20rpx;
  border-radius: var(--radius-md);
  transition: var(--transition);
}
.func-item:active {
  background: var(--light-primary);
  transform: scale(0.95);
}
.icon-wrap {
  width: 80rpx;
  height: 80rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  background-color: var(--light-primary);
  border-radius: var(--radius-circle);
  margin-bottom: 16rpx;
  box-shadow: var(--shadow);
}
.func-text {
  font-size: 26rpx;
  color: var(--text-color);
  font-weight: 500;
  letter-spacing: 1rpx;
  white-space: nowrap;
}
.hot-accessory {
  background: var(--white);
  padding: 40rpx;
  margin: 0 0 32rpx 0;
  border-radius: var(--radius-lg);
  box-shadow: var(--shadow);
}
.title-wrap {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 40rpx;
}
.title {
  font-size: 36rpx;
  font-weight: 700;
  color: var(--text-color);
  position: relative;
  letter-spacing: 1rpx;
}
.title::after {
  content: '';
  position: absolute;
  left: 0;
  bottom: -10rpx;
  width: 48rpx;
  height: 6rpx;
  background: var(--grad-primary);
  border-radius: 3rpx;
}
.more-text {
  font-size: 26rpx;
  color: var(--text-gray);
  font-weight: 400;
}
.empty-wrap {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 80rpx 0;
}
.empty-text {
  font-size: 28rpx;
  color: var(--text-gray);
  margin-top: 24rpx;
}
.goods-grid {
  display: flex;
  flex-wrap: wrap;
  justify-content: space-between;
}
.goods-item {
  width: 48%;
  margin-bottom: 24rpx;
  border-radius: var(--radius-sm);
  overflow: hidden;
}
.img-wrap {
  width: 100%;
  height: 280rpx;
  border-radius: var(--radius-sm);
  overflow: hidden;
  margin-bottom: 16rpx;
  background: #f7f8fa;
  position: relative;
}
.item-img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}
.price-tag {
  position: absolute;
  top: 12rpx;
  right: 12rpx;
  background: var(--price-color);
  color: #fff;
  font-size: 22rpx;
  padding: 6rpx 12rpx;
  border-radius: var(--radius-sm);
  font-weight: 500;
}
.item-name {
  font-size: 26rpx;
  color: var(--text-color);
  line-height: 1.4;
  margin-bottom: 8rpx;
  display: -webkit-box;
  -webkit-box-orient: vertical;
  -webkit-line-clamp: 2;
  overflow: hidden;
}
.price-wrap {
  display: flex;
  align-items: baseline;
  gap: 8rpx;
}
.item-price {
  font-size: 30rpx;
  color: var(--price-color);
  font-weight: 700;
}
.original-price {
  font-size: 22rpx;
  color: var(--text-gray);
  text-decoration: line-through;
}
.back-top {
  position: fixed;
  bottom: 130rpx;
  right: 32rpx;
  width: 72rpx;
  height: 72rpx;
  background: linear-gradient(135deg, #5a7dff, #2f54eb);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0 8rpx 24rpx rgba(47, 84, 235, 0.2);
  z-index: 9999;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  border: 1rpx solid rgba(255,255,255,0.15);
}
.back-top:active {
  transform: scale(0.95);
  opacity: 0.9;
  box-shadow: 0 4rpx 12rpx rgba(47, 84, 235, 0.25);
}
</style>