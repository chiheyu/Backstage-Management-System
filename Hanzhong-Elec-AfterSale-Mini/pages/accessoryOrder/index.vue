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
.order-page {
  min-height: 100vh;
  background: #f8f9fa;
  padding: 0;
  box-sizing: border-box;
}

.loading-wrap,
.empty {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 150rpx 40rpx;
}

.loading-icon {
  animation: spin 1s linear infinite;
  margin-bottom: 20rpx;
}

.loading-text,
.empty-text {
  font-size: 28rpx;
  color: #999;
}

.empty-icon {
  margin-bottom: 30rpx;
}

.empty-text {
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

.order-list {
  display: flex;
  flex-direction: column;
  gap: 20rpx;
  padding: 20rpx;
}

.order-item {
  background: #fff;
  border-radius: 16rpx;
  box-shadow: 0 4rpx 12rpx rgba(0, 0, 0, 0.05);
  overflow: hidden;
}

.order-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 20rpx;
  padding: 24rpx 30rpx 18rpx;
  border-bottom: 1px solid #f5f5f5;
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
  padding: 6rpx 16rpx;
  border-radius: 20rpx;
  white-space: nowrap;
}

.status-pending {
  background-color: #fff3e0;
  color: #ff7300;
}

.status-shipped {
  background-color: #e6f7ff;
  color: #1890ff;
}

.status-completed {
  background-color: #f0fff4;
  color: #07c160;
}

.status-canceled,
.status-unknown {
  background-color: #f5f5f5;
  color: #999;
}

.order-body {
  display: flex;
  gap: 20rpx;
  padding: 24rpx 30rpx;
}

.cover-image {
  width: 180rpx;
  height: 180rpx;
  border-radius: 12rpx;
  background: #f5f5f5;
  flex-shrink: 0;
}

.order-info {
  flex: 1;
  min-width: 0;
}

.accessory-name {
  display: block;
  font-size: 30rpx;
  color: #333;
  font-weight: 600;
  margin-bottom: 12rpx;
  word-break: break-all;
}

.order-line {
  display: block;
  font-size: 25rpx;
  color: #666;
  line-height: 1.7;
  word-break: break-all;
}

.order-footer {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 20rpx;
  padding: 18rpx 30rpx 24rpx;
  border-top: 1px solid #f5f5f5;
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
  border: 1px solid #b7ccff;
  border-radius: 28rpx;
  font-size: 24rpx;
}

.load-more {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 8rpx;
  padding: 24rpx 0 40rpx;
  color: #666;
}

.load-more.disabled {
  color: #999;
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
