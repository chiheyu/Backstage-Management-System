<template>
  <view class="home-page">
    <view class="banner-wrap">
      <swiper 
        class="banner" 
        autoplay 
        indicator-dots 
        circular 
        indicator-color="rgba(255,255,255,0.5)" 
        indicator-active-color="#fff"
        duration="500"
        interval="3500"
        indicator-dots-style="bottom: 24rpx; right: 32rpx;"
      >
        <swiper-item v-for="(item, idx) in bannerList" :key="idx">
          <view class="banner-item" @click="handleBannerClick(item)">
            <image 
              :src="item.image" 
              mode="aspectFill" 
              class="banner-img"
              lazy-load
              @error="imgError($event)"
            ></image>
            <view class="banner-mask" v-if="item.title">
              <text class="banner-title">{{ item.title }}</text>
              <text class="banner-subtitle">{{ item.subtitle }}</text>
            </view>
          </view>
        </swiper-item>
      </swiper>
    </view>

    <view class="func-list">
      <view 
        class="func-item" 
        @click="toApplyAfterSale"
        v-if="role === 'user'"
      >
        <view class="icon-wrap">
          <uni-icons type="compose" size="40" color="#2f54eb"></uni-icons>
        </view>
        <text class="func-text">申请售后</text>
      </view>

      <view 
        class="func-item" 
        @click="toAfterSaleAudit"
        v-if="role === 'merchant'"
      >
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

      <!-- 优化：横向滚动列表，更贴合商城商品展示 -->
      <scroll-view class="list-scroll" scroll-x="true" v-else>
        <view class="list">
          <view 
            class="item" 
            v-for="item in hotAccessoryList" 
            :key="item.id" 
            @click="toAccessoryDetail(item)"
          >
            <view class="img-wrap">
              <image 
                :src="item.image" 
                mode="aspectFill" 
                class="item-img"
                lazy-load
                @error="imgError($event)"
              ></image>
              <!-- 新增：价格标签 -->
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
      </scroll-view>
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
  onLoad() {
    setTimeout(() => {
      this.hotAccessoryList = [
        { id: 9, name: "电源适配器", price: 89, originalPrice: 129, image: "/static/images/accessory/adapter.png" },
        { id: 1, name: "显示屏", price: 399, originalPrice: 499, image: "/static/images/accessory/laptop_screen.png" },
        { id: 4, name: "数据线", price: 29, originalPrice: 49, image: "/static/images/accessory/typec_cable.png" }
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
    toAccessoryDetail(item) {
      wx.navigateTo({
        url: `/pages/accessoryDetail/index?id=${item.id}&name=${item.name}&price=${item.price}&image=${item.image}&originalPrice=${item.originalPrice}`
      });
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
  --price-color: #ff4d4f;
  --bg-color: #f8f8f8;
  --white: #fff;
  --shadow: 0 4rpx 12rpx rgba(0, 0, 0, 0.05);
  --shadow-deep: 0 6rpx 16rpx rgba(0, 0, 0, 0.08);
  --radius-sm: 8rpx;
  --radius-md: 12rpx;
  --radius-lg: 16rpx;
  --radius-circle: 50%;
  --transition: all 0.3s ease;
}

.home-page {
  min-height: 100vh;
  background-color: var(--bg-color);
  padding: 0 16rpx 100rpx 16rpx;
  margin-top: 0;
}

.banner-wrap {
  margin: 0 0 20rpx 0;
  overflow: hidden;
  box-shadow: var(--shadow-deep);
  position: relative;
  width: 100vw;
  margin-left: -16rpx;
  border-radius: 0;
}
.banner {
  height: 340rpx;
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
}
.banner-mask {
  position: absolute;
  left: 0;
  bottom: 0;
  width: 100%;
  padding: 40rpx 32rpx;
  background: linear-gradient(transparent, rgba(0,0,0,0.6));
  display: flex;
  flex-direction: column;
  justify-content: flex-end;
}
.banner-title {
  font-size: 40rpx;
  font-weight: bold;
  color: #fff;
  margin-bottom: 8rpx;
  text-shadow: 0 2rpx 4rpx rgba(0,0,0,0.3);
}
.banner-subtitle {
  font-size: 26rpx;
  color: rgba(255,255,255,0.9);
  text-shadow: 0 1rpx 2rpx rgba(0,0,0,0.3);
}

.func-list {
  display: flex;
  justify-content: space-around;
  padding: 30rpx 20rpx;
  background: linear-gradient(120deg, var(--white), #f9fbff);
  margin: 20rpx 0;
  border-radius: var(--radius-lg);
  box-shadow: var(--shadow);
}
.func-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  width: 120rpx;
  padding: 15rpx 10rpx;
  border-radius: var(--radius-md);
  transition: var(--transition);
}
.func-item:active {
  background-color: var(--light-primary);
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
  margin-bottom: 12rpx;
  box-shadow: var(--shadow);
}
.func-text {
  font-size: 26rpx;
  color: var(--text-color);
  font-weight: 500;
}

.hot-accessory {
  background: var(--white);
  padding: 30rpx;
  margin: 20rpx 0;
  border-radius: var(--radius-lg);
  box-shadow: var(--shadow);
}
.title-wrap {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 25rpx;
}
.title {
  font-size: 32rpx;
  font-weight: bold;
  color: var(--text-color);
  position: relative;
}
.title::after {
  content: '';
  position: absolute;
  left: 0;
  bottom: -8rpx;
  width: 40rpx;
  height: 4rpx;
  background-color: var(--primary-color);
  border-radius: 2rpx;
}
.more-text {
  font-size: 24rpx;
  color: var(--text-gray);
}

.empty-wrap {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 60rpx 0;
}
.empty-text {
  font-size: 28rpx;
  color: var(--text-gray);
  margin-top: 20rpx;
}

/* 优化：横向滚动容器 */
.list-scroll {
  white-space: nowrap;
  width: 100%;
}
.list {
  display: flex;
  flex-wrap: nowrap;
  gap: 24rpx;
  padding-bottom: 10rpx;
}
.item {
  width: 200rpx;
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 15rpx;
  border-radius: var(--radius-md);
  background: var(--white);
  box-shadow: var(--shadow);
  transition: var(--transition);
}
.item:active {
  transform: translateY(-4rpx);
  box-shadow: var(--shadow-deep);
}
.img-wrap {
  width: 180rpx;
  height: 180rpx;
  border-radius: var(--radius-sm);
  overflow: hidden;
  margin-bottom: 12rpx;
  background-color: #f5f5f5;
  position: relative;
}
.item-img {
  width: 100%;
  height: 100%;
}
/* 新增：价格标签 */
.price-tag {
  position: absolute;
  top: 8rpx;
  right: 8rpx;
  background-color: var(--price-color);
  color: #fff;
  font-size: 20rpx;
  padding: 4rpx 8rpx;
  border-radius: var(--radius-sm);
}
.item-name {
  font-size: 24rpx;
  color: var(--text-color);
  margin-bottom: 8rpx;
  text-align: center;
  line-height: 1.3;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
  width: 100%;
}
.price-wrap {
  display: flex;
  align-items: baseline;
  gap: 8rpx;
}
.item-price {
  font-size: 28rpx;
  color: var(--price-color);
  font-weight: bold;
}
.original-price {
  font-size: 22rpx;
  color: var(--text-gray);
  text-decoration: line-through;
}
</style>