<template>
  <view class="order-page">
    <view class="empty" v-if="filteredList.length === 0">
      <uni-icons type="empty" size="100" color="#ccc" class="empty-icon"></uni-icons>
      <text class="empty-text">{{ isAuditMode ? '暂无待审核订单' : '暂无售后订单' }}</text>
      <button class="empty-btn" @click="toApplyAfterSale" v-if="!isAuditMode" hover-class="empty-btn-hover">去申请售后</button>
    </view>
    
    <view class="order-list" v-else>
      <view class="order-item" v-for="item in filteredList" :key="item.id" hover-class="order-item-hover">
        <view class="order-header">
          <text class="order-no">订单号：{{ item.orderNo || 'SH' + item.id }}</text>
          <view :class="['status-tag', getStatusClass(item.status)]">
            {{ getStatusText(item.status) }}
          </view>
        </view>
        
        <view class="order-body">
          <view class="info-row">
            <text class="label">产品名称：</text>
            <text class="value">{{ item.productName || '未填写' }}</text>
          </view>
          <view class="info-row">
            <text class="label">产品型号：</text>
            <text class="value">{{ item.productModel || '未填写' }}</text>
          </view>
          <view class="info-row">
            <text class="label">故障描述：</text>
            <text class="value">{{ item.faultDesc || '未填写' }}</text>
          </view>
          
          <view class="info-row" v-if="item.faultImage && item.faultImage.trim() && item.faultImage.split(',').filter(i => i.trim()).length > 0">
            <text class="label">故障图片：</text>
            <view class="img-group">
              <image 
                :src="img.trim() === '/static/images/avatar.png' ? '/static/images/default-img.png' : img" 
                mode="aspectFill" 
                class="img" 
                v-for="(img, idx) in item.faultImage.split(',').filter(i => i.trim())" 
                :key="idx"
                @tap="previewImage(img, item.faultImage)"
                lazy-load="true"
                @error="imgError(idx)"
              ></image>
            </view>
          </view>
        </view>
        
        <view class="order-footer">
          <text class="create-time">{{ formatTime(item.createTime) || '暂无时间' }}</text>
          
          <view class="btn-group" v-if="item.status === 0">
            <template v-if="isAuditMode">
              <button class="btn primary-btn" size="mini" @click="auditOrder(item.id, 1)">接单</button>
              <button class="btn warn-btn" size="mini" @click="auditOrder(item.id, -1)">拒绝</button>
            </template>
            <button class="btn default-btn" size="mini" @click="cancelOrder(item.id)" v-else>取消申请</button>
          </view>
          
          <view class="btn-group" v-if="isAuditMode && item.status === 1">
            <button class="btn primary-btn" size="mini" @click="completeOrder(item.id)">完成</button>
          </view>
        </view>
      </view>
    </view>
  </view>
</template>

<script>
export default {
  data() {
    return {
      orderList: [],
      type: '', 
      isAuditMode: false,
      isLoading: false
    }
  },
  onLoad(options) {
    this.type = options.type || 'all';
    this.isAuditMode = options.audit === '1';
    this.loadOrders();
  },
  onShow() {
    if (this.orderList.length === 0 && !this.isLoading) {
      this.loadOrders();
    }
  },
  computed: {
    filteredList() {
      if (!Array.isArray(this.orderList)) return [];
      if (this.type === 'all') return this.orderList;
      if (this.type === 'pending') return this.orderList.filter(item => item.status === 0);
      if (this.type === 'finished') return this.orderList.filter(item => 
        item.status === 2 || item.status === -1 || item.status === -2
      );
      if (this.type === 'refund') return this.orderList.filter(item => 
        item.status !== 0 || item.status !== 1
      );
      return this.orderList;
    }
  },
  methods: {
   getStatusText(status) {
     const statusStr = String(status); 
     const statusMap = {
       "0": '待处理',
       "1": '已接单',
       "2": '已完成',
       "-1": '已拒绝',
       "-2": '已取消'
     };
     return statusMap[statusStr] || '未知状态';
   },
   
   getStatusClass(status) {
     const statusStr = String(status); 
     const classMap = {
       "0": 'status-pending',
       "1": 'status-accepted',
       "2": 'status-finished',
       "-1": 'status-rejected',
       "-2": 'status-canceled'
     };
     return classMap[statusStr] || 'status-unknown';
   },

    loadOrders() {
      if (this.isLoading) return;
      this.isLoading = true;
      
      const localOrders = uni.getStorageSync('afterSaleOrders');
      if (localOrders && Array.isArray(localOrders) && localOrders.length > 0) {
        this.orderList = localOrders;
        this.isLoading = false;
        return;
      }
      
      uni.showLoading({ title: '加载中...', mask: true });
      setTimeout(() => {
        const mockData = [
          {
            id: Date.now() + 1001,
            orderNo: 'SH' + Date.now().toString().slice(-6),
            productName: '无线蓝牙耳机',
            productModel: 'Pro-Max',
            faultDesc: '左耳无声，充电仓无法充电，偶尔断连',
            faultImage: '/static/images/default-img.png',
            status: 0,
            createTime: Date.now() - 3600000 * 2
          },
          {
            id: Date.now() + 1002,
            orderNo: 'SH' + Date.now().toString().slice(-6) + 1,
            productName: '智能手表',
            productModel: 'Watch S1',
            faultDesc: '心率监测不准，屏幕偶尔闪屏',
            faultImage: '',
            status: 2,
            createTime: Date.now() - 86400000
          },
          {
            id: Date.now() + 1003,
            orderNo: 'SH' + Date.now().toString().slice(-6) + 2,
            productName: '便携充电宝',
            productModel: '20000mAh',
            faultDesc: '充电发烫，输出功率不足',
            faultImage: '/static/images/default-img.png',
            status: -1,
            createTime: Date.now() - 172800000
          }
        ];
        this.orderList = mockData;
        uni.setStorageSync('afterSaleOrders', mockData);
        uni.hideLoading();
        this.isLoading = false;
      }, 500);
    },

    formatTime(timeStr) {
      if (!timeStr) return '暂无时间';
      let date;
      try {
        if (typeof timeStr === 'number') {
          date = new Date(timeStr);
        } else {
          date = new Date(timeStr);
        }
        if (isNaN(date.getTime())) {
          return '暂无时间';
        }
        const padZero = (num) => num.toString().padStart(2, '0');
        return `${date.getFullYear()}-${padZero(date.getMonth()+1)}-${padZero(date.getDate())} ${padZero(date.getHours())}:${padZero(date.getMinutes())}`;
      } catch (e) {
        return '暂无时间';
      }
    },

    toApplyAfterSale() {
      uni.navigateTo({ 
        url: '/pages/applyAfterSale/index',
        fail: () => {
          uni.switchTab({
            url: '/pages/applyAfterSale/index',
            fail: () => {
              uni.showModal({ 
                title: '跳转失败',
                content: '请检查applyAfterSale页面路径是否正确，或是否在pages.json中注册',
                showCancel: false
              });
            }
          });
        }
      });
    },

    cancelOrder(id) {
      uni.showModal({
        title: '确认取消',
        content: '是否取消该售后申请？',
        success: (res) => {
          if (res.confirm) {
            uni.showLoading({ title: '处理中...', mask: true });
            setTimeout(() => {
              const index = this.orderList.findIndex(item => item.id === id);
              if (index !== -1) {
                this.orderList[index].status = -2;
                uni.setStorageSync('afterSaleOrders', this.orderList);
              }
              uni.hideLoading();
              uni.showToast({ title: '已取消', icon: 'success' });
            }, 600);
          }
        }
      });
    },

    auditOrder(id, status) {
      const tip = status === 1 ? '接单' : '拒绝';
      uni.showModal({
        title: '确认审核',
        content: `是否${tip}该售后申请？`,
        success: (res) => {
          if (res.confirm) {
            uni.showLoading({ title: '处理中...', mask: true });
            setTimeout(() => {
              const index = this.orderList.findIndex(item => item.id === id);
              if (index !== -1) {
                this.orderList[index].status = status;
                uni.setStorageSync('afterSaleOrders', this.orderList);
              }
              uni.hideLoading();
              uni.showToast({ title: `已${tip}`, icon: 'success' });
            }, 600);
          }
        }
      });
    },

    completeOrder(id) {
      uni.showModal({
        title: '确认完成',
        content: '是否确认完成该售后订单？',
        success: (res) => {
          if (res.confirm) {
            uni.showLoading({ title: '处理中...', mask: true });
            setTimeout(() => {
              const index = this.orderList.findIndex(item => item.id === id);
              if (index !== -1) {
                this.orderList[index].status = 2;
                uni.setStorageSync('afterSaleOrders', this.orderList);
              }
              uni.hideLoading();
              uni.showToast({ title: '已完成', icon: 'success' });
            }, 600);
          }
        }
      });
    },

    previewImage(imgUrl, faultImageStr) {
      if (!imgUrl || imgUrl === '/static/images/avatar.png') {
        imgUrl = '/static/images/default-img.png';
      }
      let imgList = [];
      try {
        imgList = faultImageStr ? faultImageStr.split(',').filter(i => i.trim()) : [imgUrl];
        imgList = imgList.map(img => img.trim() === '/static/images/avatar.png' ? '/static/images/default-img.png' : img);
      } catch (e) {
        imgList = [imgUrl];
      }
      uni.previewImage({
        current: imgUrl,
        urls: imgList,
        fail: () => {
          uni.showToast({ title: '图片预览失败，请检查图片路径', icon: 'none' });
        }
      });
    },

    imgError(idx) {
      console.log(`图片加载失败，索引：${idx}`);
    }
  }
}
</script>

<style scoped>
.order-page {
  min-height: 100vh;
  background-color: #f8f9fa;
  padding: 0;
  box-sizing: border-box;
}

.empty {
  text-align: center;
  padding: 150rpx 0;
  color: #ccc;
}
.empty-icon {
  margin-bottom: 30rpx;
}
.empty-text {
  font-size: 28rpx;
  color: #999;
  margin-bottom: 40rpx;
}
.empty-btn {
  width: 60%;
  height: 88rpx;
  line-height: 88rpx;
  background: #2f54eb;
  color: #fff;
  border-radius: 44rpx;
  font-size: 30rpx;
  border: none;
}
.empty-btn-hover {
  background: #1e42d2;
  opacity: 0.9;
}

.order-list {
  gap: 20rpx;
  display: flex;
  flex-direction: column;
  padding: 20rpx;
}
.order-item {
  background: #fff;
  padding: 30rpx;
  border-radius: 16rpx;
  box-shadow: 0 4rpx 12rpx rgba(0,0,0,0.05);
}
.order-item-hover {
  background-color: #f8f8f8;
}

.order-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 25rpx;
  padding-bottom: 15rpx;
  border-bottom: 1px solid #f5f5f5;
}
.order-no {
  font-size: 26rpx;
  color: #666;
}
.status-tag {
  font-size: 24rpx;
  font-weight: 500;
  padding: 6rpx 16rpx;
  border-radius: 20rpx;
}
.status-pending {
  background-color: #fff3e0;
  color: #ff7300;
}
.status-accepted {
  background-color: #e6f7ff;
  color: #1890ff;
}
.status-finished {
  background-color: #f0fff4;
  color: #07c160;
}
.status-rejected {
  background-color: #fff2f0;
  color: #f53f3f;
}
.status-canceled {
  background-color: #f5f5f5;
  color: #999;
}
.status-unknown {
  background-color: #f5f5f5;
  color: #999;
}

.order-body {
  margin-bottom: 20rpx;
}
.info-row {
  display: flex;
  margin-bottom: 20rpx;
  font-size: 28rpx;
  align-items: flex-start;
  line-height: 1.5;
}
.label {
  color: #666;
  width: 120rpx;
  flex-shrink: 0;
  font-weight: 500;
}
.value {
  flex: 1;
  color: #333;
  word-break: break-all;
}

.img-group {
  flex: 1;
  display: flex;
  flex-wrap: wrap;
  gap: 15rpx;
}
.img {
  width: 120rpx;
  height: 120rpx;
  border-radius: 12rpx;
  box-shadow: 0 2rpx 8rpx rgba(0,0,0,0.05);
}

.order-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding-top: 20rpx;
  border-top: 1px solid #f5f5f5;
}
.create-time {
  font-size: 24rpx;
  color: #999;
}
.btn-group {
  display: flex;
  gap: 15rpx;
}
.btn {
  height: 70rpx;
  padding: 0 24rpx;
  font-size: 26rpx;
  border-radius: 35rpx;
  border: none;
  display: flex;
  align-items: center;
  justify-content: center;
}
.primary-btn {
  background-color: #2f54eb;
  color: #fff;
}
.warn-btn {
  background-color: #ff3b30;
  color: #fff;
}
.default-btn {
  background-color: #f5f5f5;
  color: #666;
}
.btn:active {
  opacity: 0.8;
}
</style>