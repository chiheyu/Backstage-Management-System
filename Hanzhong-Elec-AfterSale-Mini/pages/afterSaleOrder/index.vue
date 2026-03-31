<template>
  <view class="order-page">
    <view class="loading-wrap" v-if="isLoading">
      <uni-icons type="spinner-cycle" size="32" color="#2f54eb" class="loading-icon"></uni-icons>
      <text class="loading-text">加载中...</text>
    </view>

    <view class="empty" v-else-if="filteredList.length === 0">
      <uni-icons type="empty" size="100" color="#ccc" class="empty-icon"></uni-icons>
      <text class="empty-text">{{ emptyText }}</text>
      <button
        v-if="!isMerchantMode"
        class="empty-btn"
        @tap="toApplyAfterSale"
        hover-class="empty-btn-hover"
      >
        去申请售后
      </button>
    </view>

    <view class="order-list" v-else>
      <view
        v-for="item in filteredList"
        :key="item.orderId"
        class="order-item"
        hover-class="order-item-hover"
      >
        <view class="order-header">
          <text class="order-no">订单号：{{ item.orderNo || `AS${item.orderId}` }}</text>
          <view :class="['status-tag', getStatusClass(item.status)]">
            {{ getStatusText(item.status) }}
          </view>
        </view>

        <view class="order-body">
          <view class="info-row">
            <text class="label">产品类型</text>
            <text class="value">{{ item.productType || '未填写' }}</text>
          </view>
          <view class="info-row">
            <text class="label">故障描述</text>
            <text class="value">{{ item.faultDesc || '未填写' }}</text>
          </view>
          <view class="info-row">
            <text class="label">联系人</text>
            <text class="value">{{ item.contactName || '未填写' }}</text>
          </view>
          <view class="info-row">
            <text class="label">联系电话</text>
            <text class="value">{{ item.contactPhone || '未填写' }}</text>
          </view>
          <view class="info-row">
            <text class="label">服务地址</text>
            <text class="value">{{ item.address || '未填写' }}</text>
          </view>
          <view v-if="displayCounterpart(item)" class="info-row">
            <text class="label">{{ isMerchantMode ? '用户昵称' : '接单商家' }}</text>
            <text class="value">{{ displayCounterpart(item) }}</text>
          </view>
          <view v-if="shouldShowRejectRemark(item)" class="info-row">
            <text class="label">售后结果</text>
            <text class="value">{{ formatRejectRemark(item.serviceRemark) }}</text>
          </view>
          <view v-if="item.imageList.length" class="info-row">
            <text class="label">故障图片</text>
            <view class="img-group">
              <image
                v-for="(img, index) in item.imageList"
                :key="`${img}-${index}`"
                :src="img"
                mode="aspectFill"
                class="img"
                @tap="previewImage(item.imageList, index)"
              ></image>
            </view>
          </view>
        </view>

        <view class="order-footer">
          <text class="create-time">{{ formatTime(item.createTime) }}</text>

          <view class="btn-group">
            <button
              v-if="canUserCancel(item)"
              class="btn default-btn"
              size="mini"
              :disabled="actioningOrderId === item.orderId"
              @tap="cancelOrder(item)"
            >
              {{ actioningOrderId === item.orderId ? '处理中...' : '取消申请' }}
            </button>
            <button
              v-if="canOpenReceipt(item)"
              class="btn success-btn"
              size="mini"
              @tap="openReceiptPanel(item)"
            >
              售后处理
            </button>
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
  cancelAfterSaleOrder,
  getMerchantOrders,
  getMerchantPendingOrders,
  getUserAfterSaleOrders
} from '@/api/afterSale'

const STATUS = {
  WAIT_ACCEPT: '0',
  ACCEPTED: '1',
  REPAIRING: '2',
  COMPLETED: '3',
  CANCELED: '4'
}

const DEFAULT_PAGE_SIZE = 20
const RECEIPT_ORDER_KEY = 'merchantReceiptOrderId'

export default {
  data() {
    return {
      STATUS,
      orderList: [],
      type: 'all',
      role: 'user',
      isMerchantMode: false,
      isLoading: false,
      isLoadingMore: false,
      actioningOrderId: null,
      pageNum: 1,
      pageSize: DEFAULT_PAGE_SIZE,
      total: 0,
      hasMore: true,
      LOGIN_PATH: '/pages/profile/login'
    }
  },
  computed: {
    filteredList() {
      if (!Array.isArray(this.orderList)) {
        return []
      }

      if (this.type === 'pending') {
        if (this.isMerchantMode) {
          return this.orderList.filter((item) => this.isUnfinishedStatus(item.status))
        }
        return this.orderList.filter((item) =>
          [STATUS.WAIT_ACCEPT, STATUS.ACCEPTED, STATUS.REPAIRING].includes(item.status)
        )
      }

      if (this.type === 'finished') {
        if (this.isMerchantMode) {
          return this.orderList.filter((item) => this.isFinishedStatus(item.status))
        }
        return this.orderList.filter((item) =>
          [STATUS.COMPLETED, STATUS.CANCELED].includes(item.status)
        )
      }

      return this.orderList
    },
    emptyText() {
      if (this.isMerchantMode && this.type === 'pending') {
        return '暂无未完成工单'
      }
      return '暂无售后订单'
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
    this.role = this.resolveRole(options)
    this.isMerchantMode = this.role === 'merchant'
    this.setNavigationTitle()
  },
  onShow() {
    this.reloadOrders()
  },
  onReachBottom() {
    this.loadMoreOrders()
  },
  methods: {
    resolveRole(options) {
      if (options.role === 'merchant' || options.role === 'user') {
        return options.role
      }

      const userInfo = uni.getStorageSync('userInfo') || {}
      return userInfo.role || (userInfo.roleType === '2' ? 'merchant' : 'user')
    },
    setNavigationTitle() {
      const titleMap = this.isMerchantMode
        ? {
            pending: '未完成工单',
            finished: '已完成工单',
            all: '售后订单'
          }
        : {
            pending: '处理中订单',
            finished: '已结束订单',
            all: '售后订单'
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
        return index === array.findIndex((current) => current.orderId === item.orderId)
      })
    },
    updatePagination(rows, reset) {
      if (typeof this.total === 'number' && this.total > 0) {
        this.hasMore = this.orderList.length < this.total
        return
      }

      this.hasMore = rows.length >= this.pageSize

      if (reset && rows.length === 0) {
        this.hasMore = false
      }
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
        const response = await this.fetchOrders({
          pageNum: this.pageNum,
          pageSize: this.pageSize
        })
        const rows = Array.isArray(response.rows) ? response.rows : []
        const normalizedRows = rows.map((item) => this.normalizeOrder(item))

        this.total = Number(response.total || 0)
        this.orderList = this.mergeOrderList(normalizedRows, reset)
        this.updatePagination(normalizedRows, reset)
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
            title: '加载订单失败',
            icon: 'none'
          })
        }
      } finally {
        this.isLoading = false
        this.isLoadingMore = false
      }
    },
    fetchOrders(params) {
      if (this.isMerchantMode) {
        if (this.type === 'pending') {
          return getMerchantPendingOrders(params)
        }
        return getMerchantOrders(params)
      }

      return getUserAfterSaleOrders(params)
    },
    normalizeOrder(order = {}) {
      return {
        ...order,
        orderId: order.orderId,
        status: String(order.status ?? ''),
        imageList: this.parseImages(order.faultImages)
      }
    },
    parseImages(value = '') {
      return String(value || '')
        .split(',')
        .map((item) => item.trim())
        .filter(Boolean)
    },
    displayCounterpart(item) {
      return this.isMerchantMode ? item.userName : item.merchantName
    },
    isUnfinishedStatus(status) {
      return [STATUS.WAIT_ACCEPT, STATUS.ACCEPTED, STATUS.REPAIRING].includes(String(status))
    },
    isFinishedStatus(status) {
      return [STATUS.COMPLETED, STATUS.CANCELED].includes(String(status))
    },
    getStatusText(status) {
      if (this.isMerchantMode) {
        return this.isFinishedStatus(status) ? '已完成' : '未完成'
      }

      const statusMap = {
        [STATUS.WAIT_ACCEPT]: '未完成',
        [STATUS.ACCEPTED]: '未完成',
        [STATUS.REPAIRING]: '未完成',
        [STATUS.COMPLETED]: '已完成',
        [STATUS.CANCELED]: '已完成'
      }
      return statusMap[String(status)] || '未知状态'
    },
    getStatusClass(status) {
      if (this.isMerchantMode) {
        return this.isFinishedStatus(status) ? 'status-completed' : 'status-pending'
      }

      const classMap = {
        [STATUS.WAIT_ACCEPT]: 'status-pending',
        [STATUS.ACCEPTED]: 'status-pending',
        [STATUS.REPAIRING]: 'status-pending',
        [STATUS.COMPLETED]: 'status-completed',
        [STATUS.CANCELED]: 'status-canceled'
      }
      return classMap[String(status)] || 'status-unknown'
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
    canUserCancel(item) {
      return (
        !this.isMerchantMode &&
        [STATUS.WAIT_ACCEPT, STATUS.ACCEPTED, STATUS.REPAIRING].includes(item.status)
      )
    },
    canOpenReceipt(item) {
      return this.isMerchantMode && this.isUnfinishedStatus(item.status)
    },
    openReceiptPanel(item) {
      uni.setStorageSync(RECEIPT_ORDER_KEY, item.orderId)
      uni.switchTab({
        url: '/pages/applyAfterSale/index'
      })
    },
    toApplyAfterSale() {
      uni.switchTab({
        url: '/pages/applyAfterSale/index'
      })
    },
    async runOrderAction(orderId, executor, successText, fallbackErrorText) {
      if (this.actioningOrderId) {
        return
      }

      this.actioningOrderId = orderId
      uni.showLoading({
        title: '处理中...',
        mask: true
      })

      try {
        await executor()
        uni.hideLoading()
        uni.showToast({
          title: successText,
          icon: 'success'
        })
        await this.reloadOrders()
      } catch (error) {
        if (!error || !error.msg) {
          uni.showToast({
            title: fallbackErrorText,
            icon: 'none'
          })
        }
      } finally {
        uni.hideLoading()
        this.actioningOrderId = null
      }
    },
    cancelOrder(item) {
      uni.showModal({
        title: '确认取消',
        content: '确定取消这条售后申请吗？',
        success: ({ confirm }) => {
          if (confirm) {
            this.runOrderAction(
              item.orderId,
              () => cancelAfterSaleOrder(item.orderId),
              '已取消',
              '取消失败'
            )
          }
        }
      })
    },
    shouldShowRejectRemark(item) {
      return !this.isMerchantMode && String(item.serviceRemark || '').trim().startsWith('已拒绝')
    },
    formatRejectRemark(serviceRemark) {
      return serviceRemark || ''
    },
    previewImage(images, currentIndex) {
      if (!Array.isArray(images) || !images.length) {
        return
      }

      uni.previewImage({
        current: images[currentIndex],
        urls: images
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
  background-color: #f8f9fa;
  padding: 0;
}

.loading-wrap,
.empty {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 180rpx 40rpx;
  color: #ccc;
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

.empty-btn-hover {
  transform: scale(0.96);
  opacity: 0.9;
}

.order-list {
  display: flex;
  flex-direction: column;
  gap: 24rpx;
  padding: 24rpx;
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

.order-item {
  background: #fff;
  padding: 32rpx;
  border-radius: 24rpx;
  box-shadow: 0 8rpx 24rpx rgba(0, 0, 0, 0.05);
  transition: all 0.25s ease;
}

.order-item-hover {
  transform: translateY(-4rpx);
  box-shadow: 0 12rpx 32rpx rgba(0, 0, 0, 0.08);
}

.order-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 20rpx;
  margin-bottom: 32rpx;
  padding-bottom: 20rpx;
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

.status-accepted {
  background-color: #e8f4ff;
  color: #1677ff;
}

.status-repairing {
  background-color: #fff4e8;
  color: #fa8c16;
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
  margin-bottom: 28rpx;
}

.info-row {
  display: flex;
  align-items: flex-start;
  margin-bottom: 24rpx;
  font-size: 28rpx;
  line-height: 1.6;
}

.label {
  width: 150rpx;
  flex-shrink: 0;
  color: #666;
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
  gap: 16rpx;
}

.img {
  width: 120rpx;
  height: 120rpx;
  border-radius: 16rpx;
  box-shadow: 0 4rpx 12rpx rgba(0, 0, 0, 0.06);
  transition: all 0.2s ease;
}

.img:active {
  transform: scale(0.96);
}

.order-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 20rpx;
  padding-top: 24rpx;
  border-top: 1rpx solid #f5f5f5;
}

.create-time {
  font-size: 24rpx;
  color: #999;
}

.btn-group {
  display: flex;
  gap: 16rpx;
  flex-wrap: wrap;
  justify-content: flex-end;
}

.btn {
  height: 70rpx;
  padding: 0 28rpx;
  font-size: 26rpx;
  border-radius: 35rpx;
  border: none;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.2s ease;
}

.btn:active:not([disabled]) {
  transform: scale(0.95);
}

.primary-btn {
  background-color: #2f54eb;
  color: #fff;
}

.success-btn {
  background-color: #00b46a;
  color: #fff;
}

.warn-btn {
  background-color: #ff6b6b;
  color: #fff;
}

.default-btn {
  background-color: #f5f7fa;
  color: #666;
}

.btn[disabled] {
  opacity: 0.6;
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
