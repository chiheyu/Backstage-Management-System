<template>
  <view class="merchant-detail">
    <!-- 商家头部信息 -->
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

    <!-- 商家核心信息 -->
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
        <uni-icons type="time" size="30" color="var(--primary-color)"></uni-icons>
        <text class="info-label">营业时间</text>
        <text class="info-value">{{ merchantInfo.businessHours }}</text>
      </view>

      <view class="info-item">
        <uni-icons type="shop" size="30" color="var(--primary-color)"></uni-icons>
        <text class="info-label">主营品类</text>
        <text class="info-value">{{ merchantInfo.businessScope }}</text>
      </view>
    </view>

    <!-- 快速操作按钮 -->
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

    <!-- 用户评价区 -->
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
          <image 
            class="user-avatar" 
            :src="item.avatar || '/static/images/avatar.png'" 
            mode="aspectFill"
          ></image>
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
import { getCurrentMerchantInfo } from '@/api/merchant'

export default {
  data() {
    return {
      isMerchantMode: false,
      merchantInfo: {
        name: "汉中电子售后旗舰店",
        avatar: "/static/images/hz-logo.png",
        tag: "官方认证 | 售后无忧",
        rating: 4.8,
        phone: "400-123-4567",
        address: "陕西省汉中市汉台区XX路XX号电子城1楼",
        businessHours: "09:00 - 21:00 (全年无休)",
        businessScope: "手机配件、电脑配件、电子设备售后、维修服务"
      },
      commentList: [],
      allCommentList: [
        { username: "张先生", avatar: "/static/images/avatar.png", rating: 5, content: "售后速度很快，换了个显示屏，半小时就搞定了，价格也合理！", time: "2026-03-10" },
        { username: "李女士", avatar: "/static/images/avatar.png", rating: 4, content: "配件质量不错，商家服务态度很好，就是位置稍微有点偏。", time: "2026-03-08" },
        { username: "王先生", avatar: "/static/images/avatar.png", rating: 5, content: "数据线用着很稳定，售后小哥很专业，点赞！", time: "2026-03-05" },
        { username: "赵女士", avatar: "/static/images/avatar.png", rating: 5, content: "维修师傅技术很好，手机进水很快就修好了，收费透明！", time: "2026-03-02" },
        { username: "刘先生", avatar: "/static/images/avatar.png", rating: 4, content: "店铺环境干净整洁，售后流程规范，值得推荐。", time: "2026-02-28" },
        { username: "陈女士", avatar: "/static/images/avatar.png", rating: 5, content: "买的配件质保一年，售后有保障，非常放心。", time: "2026-02-25" },
        { username: "周先生", avatar: "/static/images/avatar.png", rating: 4, content: "服务态度很好，就是等待时间稍微长了一点。", time: "2026-02-20" },
        { username: "吴女士", avatar: "/static/images/avatar.png", rating: 5, content: "电子设备维修专业，价格公道，强烈推荐！", time: "2026-02-18" }
      ],
      pageNum: 1,
      pageSize: 3,
      totalCount: 0,
      loadingMore: false,
      noMore: false
    };
  },
  onLoad(options = {}) {
    this.isMerchantMode = options.mode === 'merchant';
    wx.setNavigationBarTitle({ title: this.isMerchantMode ? '我的店铺' : '商家详情' });
    this.totalCount = this.allCommentList.length;
    this.loadInitComments();
    if (this.isMerchantMode) {
      this.loadCurrentMerchantInfo();
    }
  },
  onReachBottom() {
    if (this.noMore || this.loadingMore) return;
    this.loadMoreComments();
  },
  methods: {
    async loadCurrentMerchantInfo() {
      try {
        const res = await getCurrentMerchantInfo();
        const data = res.data || {};
        this.merchantInfo = {
          name: data.merchantName || '我的店铺',
          avatar: "/static/images/hz-logo.png",
          tag: (data.auditStatus === '1' ? '官方认证' : '待审核') + ' | 售后无忧',
          rating: 4.8,
          phone: data.contactPhone || '未填写',
          address: data.address || '未填写',
          businessHours: '09:00 - 21:00 (全年无休)',
          businessScope: data.serviceScope || '未填写',
          desc: data.merchantDesc || '暂无店铺简介'
        };
      } catch (error) {
        wx.showToast({ title: '加载店铺信息失败', icon: 'none' });
      }
    },
    loadInitComments() {
      this.commentList = this.allCommentList.slice(0, this.pageSize);
    },
    loadMoreComments() {
      this.loadingMore = true;
      setTimeout(() => {
        this.pageNum++;
        const start = this.pageNum * this.pageSize;
        const newComments = this.allCommentList.slice(start, start + this.pageSize);
        this.commentList = [...this.commentList, ...newComments];
        this.loadingMore = false;
        if (this.commentList.length >= this.totalCount) this.noMore = true;
      }, 800);
    },
    // 拨打电话
    callMerchant() {
      wx.makePhoneCall({
        phoneNumber: this.merchantInfo.phone,
        success: () => wx.showToast({ title: "正在拨号", icon: "none" }),
        fail: () => wx.showToast({ title: "拨号失败", icon: "none" })
      });
    },
    // 复制地址（纯前端，无任何接口/后端）
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
  --text-color: #333;
  --text-light: #666;
  --text-gray: #999;
  --bg-color: #f8f8f8;
  --white: #fff;
  --border-color: #eee;
  --light-primary: #f0f5ff;
  --radius-md: 12rpx;
  --shadow: 0 4rpx 12rpx rgba(0,0,0,0.05);
  --transition: all 0.3s ease;
}
.merchant-detail {
  min-height: 100vh;
  background: var(--bg-color);
  padding-bottom: 20rpx;
}

/* 商家头部 */
.merchant-header {
  background: #fff;
  padding: 30rpx;
  display: flex;
  align-items: center;
  border-bottom: 1px solid var(--border-color);
  box-shadow: var(--shadow);
  margin-bottom: 20rpx;
}
.merchant-avatar {
  width: 120rpx;
  height: 120rpx;
  border-radius: 50%;
  margin-right: 30rpx;
  border: 3px solid var(--light-primary);
}
.merchant-name {
  font-size: 32rpx;
  font-weight: bold;
  display: block;
  margin-bottom: 10rpx;
}
.merchant-tag {
  font-size: 24rpx;
  color: var(--text-light);
  display: block;
  margin-bottom: 10rpx;
}
.merchant-rating {
  display: flex;
  align-items: center;
}
.rating-text {
  font-size: 24rpx;
  color: var(--text-light);
  margin-left: 10rpx;
}

/* 信息卡片 */
.merchant-content {
  background: #fff;
  margin: 0 20rpx 20rpx;
  border-radius: var(--radius-md);
  padding: 30rpx;
  box-shadow: var(--shadow);
}
.info-item {
  display: flex;
  align-items: center;
  padding: 25rpx 0;
  border-bottom: 1px solid #f5f5f5;
  position: relative;
}
.info-item:last-child { border-bottom: none; }
.info-item-hover { background: var(--light-primary); padding: 0 10rpx; margin: 0 -10rpx; }
.info-label {
  font-size: 28rpx;
  color: var(--text-light);
  width: 140rpx;
  margin-left: 20rpx;
}
.info-value {
  font-size: 28rpx;
  flex: 1;
  line-height: 1.4;
}

/* 操作按钮 */
.action-bar {
  display: flex;
  padding: 0 20rpx 20rpx;
  gap: 20rpx;
}
.action-btn {
  flex: 1;
  height: 88rpx;
  border-radius: var(--radius-md);
  font-size: 30rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 10rpx;
  border: none;
  box-shadow: var(--shadow);
}
.call-btn { background: #2f54eb; color: #fff; }
.nav-btn { background: #07c160; color: #fff; }

/* 评价区域 */
.comment-section {
  background: #fff;
  margin: 0 20rpx;
  border-radius: var(--radius-md);
  padding: 30rpx;
  box-shadow: var(--shadow);
}
.section-header {
  display: flex;
  justify-content: space-between;
  margin-bottom: 20rpx;
}
.section-title { font-size: 32rpx; font-weight: bold; }
.comment-count { font-size: 24rpx; color: var(--text-gray); }

.comment-list {
  display: flex;
  flex-direction: column;
  gap: 20rpx;
}
.comment-item {
  display: flex;
  padding: 20rpx 0;
  border-bottom: 1px solid #f5f5f5;
}
.comment-item:last-child { border-bottom: none; }
.comment-item-hover { background: var(--light-primary); padding: 20rpx; margin: -20rpx 0; }
.user-avatar {
  width: 60rpx;
  height: 60rpx;
  border-radius: 50%;
  margin-right: 20rpx;
}
.user-info {
  display: flex;
  justify-content: space-between;
  margin-bottom: 10rpx;
}
.user-name { font-size: 26rpx; font-weight: 500; }
.comment-text { font-size: 26rpx; color: var(--text-light); line-height: 1.6; }
.comment-time { font-size: 22rpx; color: var(--text-gray); }

/* 加载更多 */
.load-more, .no-more {
  display: flex;
  justify-content: center;
  padding: 20rpx 0;
}
.loading-icon { animation: spin 1s linear infinite; }
.load-text, .no-more-text { font-size: 24rpx; color: var(--text-gray); }
@keyframes spin { 0%{transform:rotate(0deg)} 100%{transform:rotate(360deg)} }
</style>
