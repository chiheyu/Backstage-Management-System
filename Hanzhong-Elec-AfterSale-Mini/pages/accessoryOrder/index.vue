<template>
  <view class="order-page">
    <view class="loading-wrap" v-if="isLoading">
      <uni-icons type="spinner-cycle" size="32" color="#2f54eb" class="loading-icon"></uni-icons>
      <text class="loading-text">加载中...</text>
    </view>

    <view class="empty" v-else-if="filteredList.length === 0">
      <uni-icons type="cart" size="100" color="#ccc" class="empty-icon"></uni-icons>
      <text class="empty-text">{{ emptyText }}</text>
      <button class="empty-btn" @tap="goMall">去逛逛</button>
    </view>

    <view class="order-list" v-else>
      <view v-for="item in filteredList" :key="item.accessoryOrderId" class="order-item">
        <view class="order-header">
          <text class="order-no">订单号：{{ item.orderNo }}</text>
          <view :class="['status-tag', getAccessoryOrderStatusClass(item.status)]">
            {{ getAccessoryOrderStatusText(item.status) }}
          </view>
        </view>

        <view class="order-body">
          <image :src="item.coverImage" mode="aspectFill" class="cover-image"></image>
          <view class="order-info">
            <text class="accessory-name">{{ item.accessoryName || '未命名配件' }}</text>
            <text class="order-line">数量：{{ item.quantity }}</text>
            <text class="order-line">单价：¥{{ item.price }}</text>
            <text class="order-line">合计：¥{{ item.totalAmount.toFixed(2) }}</text>
            <text class="order-line">收货人：{{ item.receiverName || '未填写' }}</text>
            <text class="order-line">联系电话：{{ item.receiverPhone || '未填写' }}</text>
            <text class="order-line">收货地址：{{ item.receiverAddress || '未填写' }}</text>
            <text class="order-line" v-if="item.orderRemark">备注：{{ item.orderRemark }}</text>
          </view>
        </view>

        <view class="order-footer">
          <text class="create-time">{{ formatTime(item.createTime) }}</text>
          <view class="footer-actions" v-if="canApplyAfterSale(item)">
            <button class="after-sale-btn" size="mini" @tap="goAfterSale(item)">售后</button>
          </view>
        </view>
      </view>

      <view
        v-if="orderList.length > 0"
        class="load-more"
        :class="{ disabled: !hasMore || isLoadingMore }"
        @tap="loadMoreOrders"
      >
        <text class="load-more-text">{{ loadMoreText }}</text>
        <text v-if="total > 0" class="load-more-total">已加载 {{ orderList.length }} / {{ total }}</text>
      </view>
    </view>
  </view>
</template>

<script>
import {
  getAccessoryOrderList,
  normalizeAccessoryOrder,
  isPendingAccessoryOrder,
  isFinishedAccessoryOrder,
  getAccessoryOrderStatusText,
  getAccessoryOrderStatusClass
} from '@/api/accessoryOrder'

const DEFAULT_PAGE_SIZE = 20
const AFTER_SALE_PREFILL_KEY = 'afterSalePrefill'
const COMPLETED_STATUS = '2'

export default {
  data() {
    return {
      type: 'all',
      orderList: [],
      pageNum: 1,
      pageSize: DEFAULT_PAGE_SIZE,
      total: 0,
      hasMore: true,
      isLoading: false,
      isLoadingMore: false,
      LOGIN_PATH: '/pages/profile/login'
    }
  },
  computed: {
    filteredList() {
      if (!Array.isArray(this.orderList)) {
        return []
      }

      if (this.type === 'pending') {
        return this.orderList.filter((item) => isPendingAccessoryOrder(item.status))
      }

      if (this.type === 'finished') {
        return this.orderList.filter((item) => isFinishedAccessoryOrder(item.status))
      }

      return this.orderList
    },
    emptyText() {
      if (this.type === 'pending') {
        return '暂无待处理配件订单'
      }
      if (this.type === 'finished') {
        return '暂无已完成配件订单'
      }
      return '暂无配件订单'
    },
    loadMoreText() {
      if (this.isLoadingMore) {
        return '加载更多中...'
      }
      if (this.hasMore) {
        return '点击加载更多'
      }
      return '没有更多订单了'
    }
  },
  onLoad(options = {}) {
    this.type = options.type || 'all'
    this.setNavigationTitle()
  },
  onShow() {
    this.reloadOrders()
  },
  onReachBottom() {
    this.loadMoreOrders()
  },
  methods: {
    setNavigationTitle() {
      const titleMap = {
        pending: '待处理配件订单',
        finished: '已完成配件订单',
        all: '配件订单'
      }

      uni.setNavigationBarTitle({
        title: titleMap[this.type] || titleMap.all
      })
    },
    ensureLogin() {
      const token = uni.getStorageSync('token')
      const userInfo = uni.getStorageSync('userInfo')

      if (token && userInfo) {
        return true
      }

      uni.showToast({
        title: '请先登录',
        icon: 'none'
      })

      setTimeout(() => {
        uni.navigateTo({
          url: this.LOGIN_PATH
        })
      }, 600)

      return false
    },
    async reloadOrders() {
      this.pageNum = 1
      this.total = 0
      this.hasMore = true
      await this.loadOrders(true)
    },
    async loadMoreOrders() {
      if (this.isLoading || this.isLoadingMore || !this.hasMore) {
        return
      }

      this.pageNum += 1
      await this.loadOrders(false)
    },
    mergeOrderList(nextRows, reset) {
      const mergedRows = reset ? nextRows : [...this.orderList, ...nextRows]

      return mergedRows.filter((item, index, array) => {
        return index === array.findIndex((current) => current.accessoryOrderId === item.accessoryOrderId)
      })
    },
    async loadOrders(reset = false) {
      if (reset ? this.isLoading : this.isLoadingMore) {
        return
      }

      if (!this.ensureLogin()) {
        return
      }

      if (reset) {
        this.isLoading = true
      } else {
        this.isLoadingMore = true
      }

      try {
        const res = await getAccessoryOrderList({
          pageNum: this.pageNum,
          pageSize: this.pageSize
        })
        const rows = Array.isArray(res.rows) ? res.rows : []
        const normalizedRows = rows.map((item) => normalizeAccessoryOrder(item))

        this.total = Number(res.total || 0)
        this.orderList = this.mergeOrderList(normalizedRows, reset)
        this.hasMore = this.total > 0 ? this.orderList.length < this.total : rows.length >= this.pageSize
      } catch (error) {
        if (!reset) {
          this.pageNum = Math.max(1, this.pageNum - 1)
        } else {
          this.orderList = []
          this.total = 0
          this.hasMore = false
        }

        if (!error || !error.msg) {
          uni.showToast({
            title: '加载配件订单失败',
            icon: 'none'
          })
        }
      } finally {
        this.isLoading = false
        this.isLoadingMore = false
      }
    },
    formatTime(value) {
      if (!value) {
        return '暂无时间'
      }

      const normalizedValue = typeof value === 'string' ? value.replace(/-/g, '/') : value
      const date = new Date(normalizedValue)

      if (Number.isNaN(date.getTime())) {
        return String(value)
      }

      const padZero = (num) => String(num).padStart(2, '0')
      return `${date.getFullYear()}-${padZero(date.getMonth() + 1)}-${padZero(date.getDate())} ${padZero(date.getHours())}:${padZero(date.getMinutes())}`
    },
    canApplyAfterSale(item) {
      return String(item.status) === COMPLETED_STATUS
    },
    buildAfterSalePrefill(order) {
      const orderNo = order.orderNo || ''
      return {
        sourceType: 'accessoryOrder',
        sourceOrderId: order.accessoryOrderId,
        orderNo,
        productName: order.accessoryName || '',
        productModel: orderNo || '',
        name: order.receiverName || '',
        phone: order.receiverPhone || '',
        receiverAddress: order.receiverAddress || ''
      }
    },
    goAfterSale(item) {
      uni.setStorageSync(AFTER_SALE_PREFILL_KEY, this.buildAfterSalePrefill(item))
      uni.switchTab({
        url: '/pages/applyAfterSale/index'
      })
    },
    getAccessoryOrderStatusText,
    getAccessoryOrderStatusClass,
    goMall() {
      uni.switchTab({
        url: '/pages/accessoryMall/index'
      })
    }
  }
}
</script>

<style scoped>
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
  -webkit-tap-highlight-color: transparent;
}

page {
  background: #f8f9fa;
}

.order-page {
  min-height: 100vh;
  background: #f8f9fa;
  padding: 0;
}

.loading-wrap,
.empty {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 180rpx 40rpx;
}

.loading-icon {
  animation: spin 1s linear infinite;
  margin-bottom: 24rpx;
}

.loading-text,
.empty-text {
  font-size: 28rpx;
  color: #999;
}

.empty-icon {
  margin-bottom: 32rpx;
  opacity: 0.6;
}

.empty-text {
  margin-bottom: 48rpx;
}

.empty-btn {
  width: 320rpx;
  height: 88rpx;
  line-height: 88rpx;
  background: #2f54eb;
  color: #fff;
  border-radius: 44rpx;
  font-size: 30rpx;
  border: none;
  transition: all 0.2s ease;
}

.empty-btn:active {
  transform: scale(0.96);
  opacity: 0.9;
}

.order-list {
  display: flex;
  flex-direction: column;
  gap: 24rpx;
  padding: 24rpx;
}

.order-item {
  background: #fff;
  border-radius: 24rpx;
  box-shadow: 0 8rpx 24rpx rgba(0, 0, 0, 0.05);
  overflow: hidden;
  transition: all 0.25s ease;
}

.order-item:active {
  transform: translateY(-4rpx);
  box-shadow: 0 12rpx 32rpx rgba(0, 0, 0, 0.08);
}

.order-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 20rpx;
  padding: 32rpx 32rpx 20rpx;
  border-bottom: 1rpx solid #f5f5f5;
}

.order-no {
  font-size: 26rpx;
  color: #666;
  flex: 1;
  word-break: break-all;
}

.status-tag {
  font-size: 24rpx;
  font-weight: 500;
  padding: 8rpx 20rpx;
  border-radius: 24rpx;
  white-space: nowrap;
}

.status-pending {
  background-color: #fff7e8;
  color: #ff7d00;
}

.status-shipped {
  background-color: #e8f4ff;
  color: #1677ff;
}

.status-completed {
  background-color: #e8fff4;
  color: #00b46a;
}

.status-canceled,
.status-unknown {
  background-color: #f7f8fa;
  color: #8c8c8c;
}

.order-body {
  display: flex;
  gap: 24rpx;
  padding: 32rpx;
}

.cover-image {
  width: 180rpx;
  height: 180rpx;
  border-radius: 16rpx;
  background: #f5f5f5;
  flex-shrink: 0;
  object-fit: cover;
}

.order-info {
  flex: 1;
  min-width: 0;
}

.accessory-name {
  display: block;
  font-size: 32rpx;
  color: #333;
  font-weight: 600;
  margin-bottom: 16rpx;
  word-break: break-all;
}

.order-line {
  display: block;
  font-size: 26rpx;
  color: #666;
  line-height: 1.8;
  word-break: break-all;
}

.order-footer {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 20rpx;
  padding: 20rpx 32rpx 32rpx;
  border-top: 1rpx solid #f5f5f5;
}

.create-time {
  font-size: 24rpx;
  color: #999;
}

.footer-actions {
  display: flex;
  justify-content: flex-end;
}

.after-sale-btn {
  min-width: 120rpx;
  height: 56rpx;
  line-height: 56rpx;
  padding: 0 24rpx;
  background: #f0f5ff;
  color: #2f54eb;
  border: 1rpx solid #d0e0ff;
  border-radius: 28rpx;
  font-size: 24rpx;
  transition: all 0.2s ease;
}

.after-sale-btn:active {
  transform: scale(0.95);
  background: #e0ebff;
}

.load-more {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 8rpx;
  padding: 32rpx 0 60rpx;
  color: #666;
  transition: all 0.2s ease;
}

.load-more:active:not(.disabled) {
  transform: scale(0.98);
}

.load-more.disabled {
  color: #999;
  pointer-events: none;
}

.load-more-text {
  font-size: 26rpx;
}

.load-more-total {
  font-size: 22rpx;
  color: #999;
}

@keyframes spin {
  0% {
    transform: rotate(0deg);
  }
  100% {
    transform: rotate(360deg);
  }
}
</style>