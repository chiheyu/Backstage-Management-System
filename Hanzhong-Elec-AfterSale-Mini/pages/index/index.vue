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
        <text class="title">{{ hotAccessoryTitle }}</text>
        <text class="more-text" @click="toAccessoryMall">更多 ></text>
      </view>
      
      <view class="empty-wrap" v-if="!hotAccessoryList.length">
        <uni-icons type="shop" size="60" color="#ccc"></uni-icons>
        <text class="empty-text">{{ hotAccessoryEmptyText }}</text>
      </view>

      <swiper 
        class="goods-swiper" 
        autoplay 
        circular 
        indicator-dots
        indicator-color="#e0e6f6"
        indicator-active-color="#2f54eb"
        interval="4000"
        duration="800"
        v-else
      >
        <swiper-item v-for="item in hotAccessoryList" :key="item.id">
          <view class="swiper-item-box">
            <view class="img-wrap">
              <image 
                :src="item.image" 
                mode="aspectFill" 
                class="item-img"
                lazy-load
                @error="imgError($event)"
              ></image>
              <view class="price-tag">
                <text>销量 {{ item.salesCount || 0 }}</text>
              </view>
            </view>
            <text class="item-name" :title="item.name">{{ item.name }}</text>
            <view class="price-wrap">
              <text class="item-price">¥{{ Number(item.price || 0).toFixed(2) }}</text>
              <text class="original-price" v-if="item.originalPrice">¥{{ item.originalPrice }}</text>
            </view>
          </view>
        </swiper-item>
      </swiper>
    </view>
  </view>
</template>

<script>
import { getAccessoryList, normalizeAccessory } from '@/api/accessory'
import { getMerchantAccessoryList } from '@/api/merchantAccessory'

const HOT_ACCESSORY_LIMIT = 5

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
  computed: {
    hotAccessoryTitle() {
      return this.role === 'merchant' ? '我的配件' : '热门配件'
    },
    hotAccessoryEmptyText() {
      return this.role === 'merchant' ? '暂无已上架的我的配件' : '暂无热门配件'
    }
  },
  onShow() {
    this.getUserRole();
    this.loadHotAccessories();
  },
  methods: {
    getUserRole() {
      const userInfo = wx.getStorageSync('userInfo');
      this.role = userInfo?.role || (userInfo?.roleType === '2' ? 'merchant' : 'user');
    },
    shuffleList(list = []) {
      const clonedList = [...list]
      for (let i = clonedList.length - 1; i > 0; i -= 1) {
        const randomIndex = Math.floor(Math.random() * (i + 1))
        const currentItem = clonedList[i]
        clonedList[i] = clonedList[randomIndex]
        clonedList[randomIndex] = currentItem
      }
      return clonedList
    },
    formatHotAccessory(accessory = {}) {
      const normalizedAccessory = normalizeAccessory(accessory)
      return {
        ...normalizedAccessory,
        originalPrice: normalizedAccessory.originalPrice || '',
        image: normalizedAccessory.image,
        accessoryId: normalizedAccessory.accessoryId || normalizedAccessory.id,
        id: normalizedAccessory.id || normalizedAccessory.accessoryId
      }
    },
    async loadHotAccessories() {
      try {
        const accessoryRows = this.role === 'merchant'
          ? await this.loadMerchantHotAccessories()
          : await this.loadUserHotAccessories()
        this.hotAccessoryList = accessoryRows.map((item) => this.formatHotAccessory(item))
      } catch (error) {
        this.hotAccessoryList = []
        wx.showToast({
          title: (error && error.msg) || '加载热门配件失败',
          icon: 'none'
        })
      }
    },
    async loadMerchantHotAccessories() {
      const res = await getMerchantAccessoryList({
        status: '0'
      })
      const rows = Array.isArray(res.rows) ? res.rows : []
      return [...rows]
        .sort((left, right) => Number(right.salesCount || 0) - Number(left.salesCount || 0))
        .slice(0, HOT_ACCESSORY_LIMIT)
    },
    async loadUserHotAccessories() {
      const res = await getAccessoryList({
        status: '0'
      })
      const rows = Array.isArray(res.rows) ? res.rows : []
      return this.shuffleList(rows).slice(0, HOT_ACCESSORY_LIMIT)
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
      const accessoryId = item.accessoryId || item.id
      if (!accessoryId) {
        wx.showToast({
          title: '缺少配件编号',
          icon: 'none'
        })
        return
      }

      wx.navigateTo({
        url: `/pages/accessoryDetail/index?id=${accessoryId}`
      })
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

.goods-swiper {
  height: 460rpx;
}
.swiper-item-box {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 20rpx 40rpx;
}
.img-wrap {
  width: 280rpx;
  height: 280rpx;
  border-radius: var(--radius-md);
  overflow: hidden;
  margin-bottom: 24rpx;
  background-color: #f7f8fa;
  position: relative;
  box-shadow: var(--shadow);
  transition: var(--transition);
}
.img-wrap:active {
  transform: scale(0.96);
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
  box-shadow: 0 4rpx 8rpx rgba(255,61,61,0.3);
}
.item-name {
  font-size: 28rpx;
  color: var(--text-color);
  margin-bottom: 12rpx;
  text-align: center;
  font-weight: 500;
  line-height: 1.4;
  max-width: 280rpx;
}
.price-wrap {
  display: flex;
  align-items: baseline;
  gap: 12rpx;
}
.item-price {
  font-size: 34rpx;
  color: var(--price-color);
  font-weight: 700;
}
.original-price {
  font-size: 24rpx;
  color: var(--text-gray);
  text-decoration: line-through;
  font-weight: 400;
}
</style>
