<template>
  <view class="merchant-detail">
    <view v-if="showMerchantSwitcher" class="merchant-switch switch-left" @tap="switchMerchant(-1)">
      <uni-icons type="left" size="26" color="#2f54eb"></uni-icons>
    </view>
    <view v-if="showMerchantSwitcher" class="merchant-switch switch-right" @tap="switchMerchant(1)">
      <uni-icons type="right" size="26" color="#2f54eb"></uni-icons>
    </view>

    <view class="merchant-header">
      <image 
        class="merchant-avatar" 
        :src="merchantInfo.avatar || '/static/images/merchant/avatar.png'" 
        mode="aspectFill"
      ></image>
      <view class="merchant-info">
        <text class="merchant-name">{{ merchantInfo.name }}</text>
        <text class="merchant-tag">{{ merchantInfo.tag }}</text>
        <view class="merchant-rating">
          <uni-icons type="star" size="24" color="#ffd100"></uni-icons>
          <uni-icons type="star" size="24" color="#ffd100"></uni-icons>
          <uni-icons type="star" size="24" color="#ffd100"></uni-icons>
          <uni-icons type="star" size="24" color="#ffd100"></uni-icons>
          <uni-icons type="starhalf" size="24" color="#ffd100"></uni-icons>
          <text class="rating-text">{{ merchantInfo.rating }}分</text>
        </view>
      </view>
    </view>

    <view class="merchant-content">
      <view class="info-item" @click="callMerchant" hover-class="info-item-hover">
        <uni-icons type="phone" size="30" color="var(--primary-color)"></uni-icons>
        <text class="info-label">联系电话</text>
        <text class="info-value">{{ merchantInfo.phone }}</text>
        <uni-icons type="arrowright" size="20" color="#ccc"></uni-icons>
      </view>

      <view class="info-item" @click="copyAddress" hover-class="info-item-hover">
        <uni-icons type="location" size="30" color="var(--primary-color)"></uni-icons>
        <text class="info-label">店铺地址</text>
        <text class="info-value">{{ merchantInfo.address }}</text>
        <uni-icons type="arrowright" size="20" color="#ccc"></uni-icons>
      </view>

      <view class="info-item">
        <uni-icons type="calendar" size="30" color="var(--primary-color)"></uni-icons>
        <text class="info-label">营业时间</text>
        <text class="info-value">{{ merchantInfo.businessHours }}</text>
      </view>

      <view class="info-item">
        <uni-icons type="shop" size="30" color="var(--primary-color)"></uni-icons>
        <text class="info-label">主营品类</text>
        <text class="info-value">{{ merchantInfo.businessScope }}</text>
      </view>
    </view>

    <view class="action-bar" v-if="!isMerchantMode">
      <button class="action-btn call-btn" @click="callMerchant">
        <uni-icons type="phone" size="28" color="#fff"></uni-icons>
        <text>电话联系</text>
      </button>
      <button class="action-btn nav-btn" @click="copyAddress">
        <uni-icons type="location" size="28" color="#fff"></uni-icons>
        <text>复制地址</text>
      </button>
    </view>

    <view class="comment-section">
      <view class="section-header">
        <text class="section-title">用户评价</text>
        <text class="comment-count">{{ totalCount }}条评价</text>
      </view>
      
      <view class="empty-comment" v-if="commentList.length === 0">
        <uni-icons type="comment" size="80" color="#ccc"></uni-icons>
        <text class="empty-text">暂无用户评价</text>
      </view>
      
      <view class="comment-list" v-else>
        <view class="comment-item" v-for="(item, idx) in commentList" :key="idx" hover-class="comment-item-hover">
          <view class="avatar-wrapper">
            <image 
              class="user-avatar" 
              :src="item.avatar || '/static/images/avatar.png'" 
              mode="aspectFill"
            ></image>
          </view>
          <view class="comment-content">
            <view class="user-info">
              <text class="user-name">{{ item.username }}</text>
              <view class="comment-rating">
                <uni-icons type="star" size="20" color="#ffd100" v-for="i in item.rating" :key="i"></uni-icons>
              </view>
            </view>
            <text class="comment-text">{{ item.content }}</text>
            <text class="comment-time">{{ item.time }}</text>
          </view>
        </view>
        
        <view class="load-more" v-if="!noMore">
          <uni-icons v-if="loadingMore" type="spinner-cycle" size="24" color="#999" class="loading-icon"></uni-icons>
          <text class="load-text">{{ loadingMore ? '加载中...' : '上拉加载更多' }}</text>
        </view>
        <view class="no-more" v-if="noMore">
          <text class="no-more-text">已经到底啦~</text>
        </view>
      </view>
    </view>
  </view>
</template>

<script>
import { getCurrentMerchantInfo, getMerchantDetail, getMerchantList, getMerchantReviewList } from '@/api/merchant'

const DEFAULT_RATING = 4.8

export default {
  data() {
    return {
      isMerchantMode: false,
      merchantList: [],
      currentMerchantIndex: 0,
      merchantInfo: {
        id: null,
        name: "汉中电子售后旗舰店",
        avatar: "/static/images/hz-logo.png",
        tag: "官方认证 | 售后无忧",
        rating: DEFAULT_RATING,
        phone: "400-123-4567",
        address: "陕西省汉中市汉台区XX路XX号电子城1楼",
        businessHours: "09:00 - 21:00 (全年无休)",
        businessScope: "手机配件、电脑配件、电子设备售后、维修服务"
      },
      commentList: [],
      allCommentList: [],
      pageNum: 1,
      pageSize: 3,
      totalCount: 0,
      loadingMore: false,
      noMore: false
    };
  },
  computed: {
    showMerchantSwitcher() {
      return !this.isMerchantMode && this.merchantList.length > 1
    }
  },
  onLoad(options = {}) {
    this.isMerchantMode = options.mode === 'merchant';
    wx.setNavigationBarTitle({ title: this.isMerchantMode ? '我的店铺' : '商家详情' });
    if (this.isMerchantMode) {
      this.loadCurrentMerchantInfo();
      return
    }
    this.loadMerchantList(options.merchantId)
  },
  onReachBottom() {
    if (this.noMore || this.loadingMore) return;
    this.loadMoreComments();
  },
  methods: {
    mapMerchantDetail(data = {}) {
      return {
        id: data.merchantId || null,
        name: data.merchantName || '商家详情',
        avatar: "/static/images/hz-logo.png",
        tag: (data.auditStatus === '1' ? '官方认证' : '店铺信息') + ' | 售后无忧',
        rating: DEFAULT_RATING,
        phone: data.contactPhone || '未填写',
        address: data.address || '未填写',
        businessHours: '09:00 - 21:00 (全年无休)',
        businessScope: data.serviceScope || '未填写',
        desc: data.merchantDesc || '暂无店铺简介'
      }
    },
    async refreshComments(merchantId) {
      this.pageNum = 1
      this.loadingMore = false
      try {
        const res = await getMerchantReviewList(merchantId)
        const data = res.data || {}
        const rows = Array.isArray(data.rows) ? data.rows : []
        this.allCommentList = rows.map((item) => ({
          username: item.userName || '匿名用户',
          avatar: item.avatar || '/static/images/avatar.png',
          rating: Number(item.rating || 5),
          content: item.reviewContent || '',
          time: item.createTime ? String(item.createTime).split(' ')[0] : ''
        }))
        this.totalCount = Number(data.total || this.allCommentList.length || 0)
        this.merchantInfo.rating = Number(data.avgRating || 0) || DEFAULT_RATING
      } catch (error) {
        this.allCommentList = []
        this.totalCount = 0
        this.merchantInfo.rating = DEFAULT_RATING
      }
      this.commentList = this.allCommentList.slice(0, this.pageSize)
      this.noMore = this.commentList.length >= this.totalCount
    },
    async loadCurrentMerchantInfo() {
      try {
        const res = await getCurrentMerchantInfo();
        const data = res.data || {};
        this.merchantInfo = this.mapMerchantDetail(data)
        await this.refreshComments(this.merchantInfo.id)
      } catch (error) {
        wx.showToast({ title: '加载店铺信息失败', icon: "none" });
      }
    },
    async loadMerchantList(targetMerchantId) {
      try {
        const res = await getMerchantList({
          pageNum: 1,
          pageSize: 100
        })
        this.merchantList = Array.isArray(res.rows) ? res.rows : []
        if (!this.merchantList.length) {
          this.totalCount = 0
          this.commentList = []
          this.noMore = true
          return
        }
        const targetIndex = this.merchantList.findIndex((item) => String(item.merchantId || '') === String(targetMerchantId || ''))
        this.currentMerchantIndex = targetIndex >= 0 ? targetIndex : 0
        await this.loadMerchantDetailByIndex(this.currentMerchantIndex)
      } catch (error) {
        wx.showToast({ title: '加载商家列表失败', icon: 'none' })
      }
    },
    async loadMerchantDetailByIndex(index) {
      if (!this.merchantList.length) {
        return
      }
      const normalizedIndex = (index + this.merchantList.length) % this.merchantList.length
      const current = this.merchantList[normalizedIndex]
      if (!current || !current.merchantId) {
        return
      }
      const res = await getMerchantDetail(current.merchantId)
      this.currentMerchantIndex = normalizedIndex
      this.merchantInfo = this.mapMerchantDetail(res.data || current)
      await this.refreshComments(this.merchantInfo.id)
    },
    switchMerchant(offset) {
      if (!this.showMerchantSwitcher) {
        return
      }
      this.loadMerchantDetailByIndex(this.currentMerchantIndex + offset)
    },
    loadMoreComments() {
      this.loadingMore = true;
      setTimeout(() => {
        this.pageNum++;
        const start = (this.pageNum - 1) * this.pageSize;
        const newComments = this.allCommentList.slice(start, start + this.pageSize);
        this.commentList = [...this.commentList, ...newComments];
        this.loadingMore = false;
        if (this.commentList.length >= this.totalCount) this.noMore = true;
      }, 800);
    },
    callMerchant() {
      wx.makePhoneCall({
        phoneNumber: this.merchantInfo.phone,
        success: () => wx.showToast({ title: "正在拨号", icon: "none" }),
        fail: () => wx.showToast({ title: "拨号失败", icon: "none" })
      });
    },
    copyAddress() {
      wx.setClipboardData({
        data: this.merchantInfo.address,
        success: () => {
          wx.showToast({ title: "地址已复制", icon: "success" });
        }
      });
    }
  }
};
</script>

<style scoped>
:root {
  --primary-color: #2f54eb;
  --success-color: #07c160;
  --text-color: #1d2129;
  --text-light: #4e5969;
  --text-gray: #86909c;
  --bg-color: #f7f8fa;
  --white: #ffffff;
  --border-color: #e5e6eb;
  --light-primary: #f0f5ff;
  --avatar-border: #cce5ff;
  --radius-md: 20rpx;
  --radius-lg: 24rpx;
  --shadow: 0 8rpx 24rpx rgba(0, 0, 0, 0.06);
  --transition: all 0.3s cubic-bezier(0.25, 0.8, 0.25, 1);
}
.merchant-detail {
  min-height: 100vh;
  background: var(--bg-color);
  padding-bottom: 40rpx;
  position: relative;
}

.merchant-switch {
  position: fixed;
  top: 50%;
  width: 72rpx;
  height: 72rpx;
  margin-top: -36rpx;
  border-radius: 999rpx;
  background: rgba(255, 255, 255, 0.94);
  box-shadow: var(--shadow);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 20;
}

.switch-left {
  left: 20rpx;
}

.switch-right {
  right: 20rpx;
}

.switch-icon {
  font-size: 34rpx;
  color: var(--primary-color);
  font-weight: 700;
}

.merchant-header {
  background: var(--white);
  padding: 40rpx 32rpx;
  display: flex;
  align-items: center;
  box-shadow: var(--shadow);
  margin-bottom: 24rpx;
}
.merchant-avatar {
  width: 130rpx;
  height: 130rpx;
  border-radius: 50%;
  margin-right: 32rpx;
  border: 4rpx solid var(--light-primary);
  box-shadow: 0 4rpx 12rpx rgba(47, 84, 235, 0.1);
}
.merchant-name {
  font-size: 36rpx;
  font-weight: 700;
  color: var(--text-color);
  display: block;
  margin-bottom: 12rpx;
  letter-spacing: 1rpx;
}
.merchant-tag {
  font-size: 26rpx;
  color: var(--text-light);
  display: block;
  margin-bottom: 16rpx;
}
.merchant-rating {
  display: flex;
  align-items: center;
  gap: 6rpx;
}
.rating-text {
  font-size: 26rpx;
  color: var(--text-light);
  margin-left: 12rpx;
  font-weight: 500;
}

.merchant-content {
  background: var(--white);
  margin: 0 32rpx 24rpx;
  border-radius: var(--radius-lg);
  padding: 20rpx 32rpx;
  box-shadow: var(--shadow);
}
.info-item {
  display: flex;
  align-items: center;
  padding: 32rpx 0;
  border-bottom: 1rpx solid var(--border-color);
  position: relative;
  transition: var(--transition);
}
.info-item:last-child { border-bottom: none; }
.info-item-hover {
  background: var(--light-primary);
  transform: scale(0.98);
  border-radius: 16rpx;
  padding-left: 16rpx;
  padding-right: 16rpx;
}
.info-label {
  font-size: 28rpx;
  color: var(--text-light);
  width: 150rpx;
  margin-left: 24rpx;
  font-weight: 500;
}
.info-value {
  font-size: 28rpx;
  color: var(--text-color);
  flex: 1;
  line-height: 1.5;
  font-weight: 400;
}

.action-bar {
  display: flex;
  padding: 0 32rpx 32rpx;
  gap: 24rpx;
}
.action-btn {
  flex: 1;
  height: 88rpx;
  border-radius: var(--radius-md);
  font-size: 30rpx;
  font-weight: 500;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 12rpx;
  border: none;
  box-shadow: var(--shadow);
  transition: var(--transition);
}
.action-btn:active { transform: scale(0.96); }
.call-btn { background: var(--primary-color); color: #fff; }
.nav-btn { background: var(--success-color); color: #fff; }

.comment-section {
  background: var(--white);
  margin: 0 32rpx;
  border-radius: var(--radius-lg);
  padding: 40rpx 32rpx;
  box-shadow: var(--shadow);
}
.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 32rpx;
}
.section-title {
  font-size: 34rpx;
  font-weight: 700;
  color: var(--text-color);
}
.comment-count {
  font-size: 26rpx;
  color: var(--text-gray);
  font-weight: 400;
}

.empty-comment {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 60rpx 0;
}
.empty-text {
  font-size: 28rpx;
  color: var(--text-gray);
  margin-top: 24rpx;
}

.comment-list {
  display: flex;
  flex-direction: column;
  gap: 24rpx;
}
.comment-item {
  display: flex;
  padding: 24rpx 0;
  border-bottom: 1rpx solid var(--border-color);
  transition: var(--transition);
}
.comment-item:last-child { border-bottom: none; }
.comment-item-hover {
  background: var(--light-primary);
  border-radius: 16rpx;
  padding: 24rpx;
  margin: -24rpx 0;
}
.avatar-wrapper {
  width: 70rpx;
  height: 70rpx;
  border-radius: 50%;
  background: var(--avatar-border);
  display: flex;
  align-items: center;
  justify-content: center;
  margin-right: 24rpx;
  flex-shrink: 0;
}
.user-avatar {
  width: 50rpx;
  height: 50rpx;
  border-radius: 50%;
  display: block;
}
.user-info {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12rpx;
}
.user-name {
  font-size: 28rpx;
  font-weight: 500;
  color: var(--text-color);
}
.comment-text {
  font-size: 28rpx;
  color: var(--text-light);
  line-height: 1.6;
  margin-bottom: 12rpx;
}
.comment-time {
  font-size: 24rpx;
  color: var(--text-gray);
}

.load-more, .no-more {
  display: flex;
  justify-content: center;
  align-items: center;
  padding: 32rpx 0;
}
.loading-icon {
  animation: spin 1s linear infinite;
}
.load-text, .no-more-text {
  font-size: 26rpx;
  color: var(--text-gray);
}
@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}
</style>
