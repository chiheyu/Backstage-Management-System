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
          <view v-if="item.serviceRemark" class="info-row">
            <text class="label">处理备注</text>
            <text class="value">{{ item.serviceRemark }}</text>
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
              v-if="canTake(item)"
              class="btn primary-btn"
              size="mini"
              :disabled="actioningOrderId === item.orderId"
              @tap="takeOrder(item)"
            >
              {{ actioningOrderId === item.orderId ? '处理中...' : '接单' }}
            </button>
            <button
              v-if="canStartRepair(item)"
              class="btn primary-btn"
              size="mini"
              :disabled="actioningOrderId === item.orderId"
              @tap="updateOrderStatus(item, STATUS.REPAIRING, '开始维修', '已更新为维修中')"
            >
              {{ actioningOrderId === item.orderId ? '处理中...' : '开始维修' }}
            </button>
            <button
              v-if="canComplete(item)"
              class="btn success-btn"
              size="mini"
              :disabled="actioningOrderId === item.orderId"
              @tap="updateOrderStatus(item, STATUS.COMPLETED, '维修完成', '订单已完成')"
            >
              {{ actioningOrderId === item.orderId ? '处理中...' : '完成订单' }}
            </button>
            <button
              v-if="canMerchantCancel(item)"
              class="btn warn-btn"
              size="mini"
              :disabled="actioningOrderId === item.orderId"
              @tap="updateOrderStatus(item, STATUS.CANCELED, merchantCancelRemark(item), '订单已取消')"
            >
              {{ actioningOrderId === item.orderId ? '处理中...' : '终止订单' }}
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
  getUserAfterSaleOrders,
  takeMerchantOrder,
  updateMerchantOrderStatus
} from '@/api/afterSale'

const STATUS = {
  WAIT_ACCEPT: '0',
  ACCEPTED: '1',
  REPAIRING: '2',
  COMPLETED: '3',
  CANCELED: '4'
}

const DEFAULT_PAGE_SIZE = 20

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
          return this.orderList.filter((item) => item.status === STATUS.WAIT_ACCEPT)
        }
        return this.orderList.filter((item) =>
          [STATUS.WAIT_ACCEPT, STATUS.ACCEPTED, STATUS.REPAIRING].includes(item.status)
        )
      }

      if (this.type === 'finished') {
        if (this.isMerchantMode) {
          return this.orderList.filter((item) =>
            [STATUS.ACCEPTED, STATUS.REPAIRING, STATUS.COMPLETED, STATUS.CANCELED].includes(item.status)
          )
        }
        return this.orderList.filter((item) =>
          [STATUS.COMPLETED, STATUS.CANCELED].includes(item.status)
        )
      }

      return this.orderList
    },
    emptyText() {
      if (this.isMerchantMode && this.type === 'pending') {
        return '暂无待接单订单'
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
            pending: '待接单订单',
            finished: '已处理订单',
            all: '售后订单管理'
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
    getStatusText(status) {
      const statusMap = {
        [STATUS.WAIT_ACCEPT]: '待接单',
        [STATUS.ACCEPTED]: '已接单',
        [STATUS.REPAIRING]: '维修中',
        [STATUS.COMPLETED]: '已完成',
        [STATUS.CANCELED]: '已取消'
      }

      return statusMap[String(status)] || '未知状态'
    },
    getStatusClass(status) {
      const classMap = {
        [STATUS.WAIT_ACCEPT]: 'status-pending',
        [STATUS.ACCEPTED]: 'status-accepted',
        [STATUS.REPAIRING]: 'status-repairing',
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
    canTake(item) {
      return this.isMerchantMode && item.status === STATUS.WAIT_ACCEPT
    },
    canStartRepair(item) {
      return this.isMerchantMode && item.status === STATUS.ACCEPTED
    },
    canComplete(item) {
      return this.isMerchantMode && item.status === STATUS.REPAIRING
    },
    canMerchantCancel(item) {
      return this.isMerchantMode && [STATUS.ACCEPTED, STATUS.REPAIRING].includes(item.status)
    },
    merchantCancelRemark(item) {
      return item.status === STATUS.REPAIRING ? '维修终止，订单取消' : '商家取消接单'
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
    takeOrder(item) {
      uni.showModal({
        title: '确认接单',
        content: '确定接下这条售后订单吗？',
        success: ({ confirm }) => {
          if (confirm) {
            this.runOrderAction(
              item.orderId,
              () => takeMerchantOrder(item.orderId),
              '接单成功',
              '接单失败'
            )
          }
        }
      })
    },
    updateOrderStatus(item, targetStatus, serviceRemark, successText) {
      const actionText = targetStatus === STATUS.CANCELED ? '取消订单' : successText
      uni.showModal({
        title: actionText,
        content: `确认执行“${actionText}”吗？`,
        success: ({ confirm }) => {
          if (confirm) {
            this.runOrderAction(
              item.orderId,
              () =>
                updateMerchantOrderStatus({
                  orderId: item.orderId,
                  status: targetStatus,
                  serviceRemark
                }),
              successText,
              '更新状态失败'
            )
          }
        }
      })
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
.order-page {
  min-height: 100vh;
  background-color: #f8f9fa;
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
  color: #ccc;
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

.empty-btn-hover {
  background: #1e42d2;
  opacity: 0.9;
}

.order-list {
  display: flex;
  flex-direction: column;
  gap: 20rpx;
  padding: 20rpx;
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

.order-item {
  background: #fff;
  padding: 30rpx;
  border-radius: 16rpx;
  box-shadow: 0 4rpx 12rpx rgba(0, 0, 0, 0.05);
}

.order-item-hover {
  background-color: #f8f8f8;
}

.order-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 20rpx;
  margin-bottom: 25rpx;
  padding-bottom: 15rpx;
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

.status-accepted {
  background-color: #e6f7ff;
  color: #1890ff;
}

.status-repairing {
  background-color: #fff7e6;
  color: #fa8c16;
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
  margin-bottom: 20rpx;
}

.info-row {
  display: flex;
  align-items: flex-start;
  margin-bottom: 20rpx;
  font-size: 28rpx;
  line-height: 1.5;
}

.label {
  width: 140rpx;
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
  gap: 15rpx;
}

.img {
  width: 120rpx;
  height: 120rpx;
  border-radius: 12rpx;
  box-shadow: 0 2rpx 8rpx rgba(0, 0, 0, 0.05);
}

.order-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 20rpx;
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
  flex-wrap: wrap;
  justify-content: flex-end;
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

.success-btn {
  background-color: #07c160;
  color: #fff;
}

.warn-btn {
  background-color: #ff7875;
  color: #fff;
}

.default-btn {
  background-color: #f5f5f5;
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
