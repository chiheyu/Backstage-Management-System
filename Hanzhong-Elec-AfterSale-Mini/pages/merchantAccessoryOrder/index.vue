<template>
  <view class="merchant-order-page">
    <view class="hero-card">
      <view class="hero-copy">
        <text class="hero-title">配件订单管理</text>
        <text class="hero-desc">商家可在这里查看待处理、已处理与全部配件订单。</text>
      </view>
      <view class="hero-badge">
        <text class="hero-badge-label">当前视图</text>
        <text class="hero-badge-value">{{ currentTabLabel }}</text>
      </view>
    </view>

    <view class="tab-bar">
      <view
        v-for="tab in tabs"
        :key="tab.value"
        class="tab-item"
        :class="{ active: currentTab === tab.value }"
        @tap="switchTab(tab.value)"
      >
        {{ tab.label }}
      </view>
    </view>

    <view class="summary-strip">
      <view class="summary-card">
        <text class="summary-label">已加载</text>
        <text class="summary-value">{{ filteredList.length }}</text>
      </view>
      <view class="summary-card">
        <text class="summary-label">累计订单</text>
        <text class="summary-value">{{ total }}</text>
      </view>
      <view class="summary-card">
        <text class="summary-label">分页状态</text>
        <text class="summary-value">{{ hasMore ? '可继续加载' : '已到底部' }}</text>
      </view>
    </view>

    <view v-if="errorMessage" class="notice-card">
      <view class="notice-head">
        <uni-icons type="info" size="22" color="#d97706"></uni-icons>
        <text class="notice-title">接口状态提示</text>
      </view>
      <text class="notice-desc">{{ errorMessage }}</text>
    </view>

    <view class="loading-wrap" v-if="isLoading">
      <uni-icons type="spinner-cycle" size="32" color="#2f54eb" class="loading-icon"></uni-icons>
      <text class="loading-text">正在加载配件订单...</text>
    </view>

    <view class="empty-wrap" v-else-if="showEmptyState">
      <uni-icons type="cart" size="92" color="#cbd5e1"></uni-icons>
      <text class="empty-title">{{ emptyTitle }}</text>
      <text class="empty-desc">{{ emptyDesc }}</text>
      <button class="empty-btn" @tap="reloadOrders">重新加载</button>
    </view>

    <view v-else class="order-list">
      <view v-if="filteredList.length === 0" class="tab-hint-card">
        <text class="tab-hint-title">当前页还没有命中 {{ currentTabLabel }}</text>
        <text class="tab-hint-desc">可以继续加载更多订单，或者切换到“全部订单”查看当前已加载数据。</text>
      </view>

      <view
        v-for="item in filteredList"
        :key="item.accessoryOrderId"
        class="order-card"
      >
        <view class="order-card-head">
          <view class="order-no-wrap">
            <text class="order-no-label">订单号</text>
            <text class="order-no">{{ item.orderNo || '--' }}</text>
          </view>
          <view :class="['status-tag', getAccessoryOrderStatusClass(item.status)]">
            {{ getAccessoryOrderStatusText(item.status) }}
          </view>
        </view>

        <view class="order-card-body">
          <image :src="item.coverImage" mode="aspectFill" class="cover-image"></image>
          <view class="order-info">
            <text class="accessory-name">{{ item.accessoryName || '未命名配件' }}</text>
            <text class="order-line">下单用户：{{ item.userName || '未返回' }}</text>
            <text class="order-line">数量：{{ item.quantity }}</text>
            <text class="order-line">单价：¥{{ Number(item.price || 0).toFixed(2) }}</text>
            <text class="order-line">合计：¥{{ Number(item.totalAmount || 0).toFixed(2) }}</text>
            <text class="order-line">收货人：{{ item.receiverName || '未填写' }}</text>
            <text class="order-line">联系电话：{{ item.receiverPhone || '未填写' }}</text>
            <text class="order-line">收货地址：{{ item.receiverAddress || '未填写' }}</text>
            <text class="order-line" v-if="item.orderRemark">备注：{{ item.orderRemark }}</text>
          </view>
        </view>

        <view class="order-card-foot">
          <text class="create-time">{{ formatTime(item.createTime) }}</text>
          <view class="action-group">
            <button
              v-if="canShip(item)"
              class="action-btn primary-btn"
              :disabled="actioningOrderId === item.accessoryOrderId"
              @tap="shipOrder(item)"
            >
              {{ actioningOrderId === item.accessoryOrderId ? '处理中...' : '标记已发货' }}
            </button>
            <button
              v-if="canComplete(item)"
              class="action-btn success-btn"
              :disabled="actioningOrderId === item.accessoryOrderId"
              @tap="completeOrder(item)"
            >
              {{ actioningOrderId === item.accessoryOrderId ? '处理中...' : '标记已完成' }}
            </button>
            <button
              v-if="canCancel(item)"
              class="action-btn warn-btn"
              :disabled="actioningOrderId === item.accessoryOrderId"
              @tap="cancelOrder(item)"
            >
              {{ actioningOrderId === item.accessoryOrderId ? '处理中...' : '取消订单' }}
            </button>
          </view>
        </view>
      </view>

      <view
        class="load-more"
        :class="{ disabled: !hasMore || isLoadingMore }"
        @tap="loadMoreOrders"
      >
        <text class="load-more-text">{{ loadMoreText }}</text>
        <text class="load-more-desc">当前累计 {{ orderList.length }} 条记录</text>
      </view>
    </view>
  </view>
</template>

<script>
import {
  getMerchantAccessoryOrderList,
  shipMerchantAccessoryOrder,
  completeMerchantAccessoryOrder,
  cancelMerchantAccessoryOrder,
  normalizeAccessoryOrder,
  isPendingAccessoryOrder,
  isFinishedAccessoryOrder,
  getAccessoryOrderStatusText,
  getAccessoryOrderStatusClass
} from '@/api/merchantAccessoryOrder'

const DEFAULT_PAGE_SIZE = 20

export default {
  data() {
    return {
      currentTab: 'pending',
      tabs: [
        { value: 'pending', label: '待处理' },
        { value: 'finished', label: '已处理' },
        { value: 'all', label: '全部订单' }
      ],
      orderList: [],
      pageNum: 1,
      pageSize: DEFAULT_PAGE_SIZE,
      total: 0,
      hasMore: true,
      isLoading: false,
      isLoadingMore: false,
      actioningOrderId: null,
      errorMessage: '',
      LOGIN_PATH: '/pages/profile/login'
    }
  },
  computed: {
    currentTabLabel() {
      const matchedTab = this.tabs.find((item) => item.value === this.currentTab)
      return matchedTab ? matchedTab.label : '待处理'
    },
    filteredList() {
      if (!Array.isArray(this.orderList)) {
        return []
      }

      if (this.currentTab === 'pending') {
        return this.orderList.filter((item) => isPendingAccessoryOrder(item.status))
      }

      if (this.currentTab === 'finished') {
        return this.orderList.filter((item) => isFinishedAccessoryOrder(item.status))
      }

      return this.orderList
    },
    emptyTitle() {
      if (this.currentTab === 'pending') {
        return '暂无待处理配件订单'
      }

      if (this.currentTab === 'finished') {
        return '暂无已处理配件订单'
      }

      return '暂无配件订单'
    },
    emptyDesc() {
      if (this.errorMessage) {
        return '当前页面已接入商家配件订单接口，如果仍加载失败，请检查后端权限、订单归属和状态流转接口。'
      }

      if (this.currentTab === 'pending') {
        return '新下的配件订单会在这里显示。'
      }

      if (this.currentTab === 'finished') {
        return '已发货、已完成、已取消的订单会在这里归档展示。'
      }

      return '当前商家还没有可见的配件订单。'
    },
    loadMoreText() {
      if (this.isLoadingMore) {
        return '加载更多中...'
      }

      if (this.hasMore) {
        return '点击加载更多'
      }

      return '没有更多订单了'
    },
    showEmptyState() {
      return this.filteredList.length === 0 && (this.orderList.length === 0 || !this.hasMore)
    }
  },
  onLoad(options = {}) {
    if (['pending', 'finished', 'all'].includes(options.type)) {
      this.currentTab = options.type
    }
    this.syncNavigationTitle()
  },
  onShow() {
    this.reloadOrders()
  },
  onReachBottom() {
    this.loadMoreOrders()
  },
  methods: {
    ensureLogin() {
      const token = uni.getStorageSync('token')
      const userInfo = uni.getStorageSync('userInfo')

      if (token && userInfo) {
        return true
      }

      uni.showToast({
        title: '请先登录商家账号',
        icon: 'none'
      })

      setTimeout(() => {
        uni.navigateTo({
          url: this.LOGIN_PATH
        })
      }, 600)

      return false
    },
    syncNavigationTitle() {
      const titleMap = {
        pending: '待处理配件订单',
        finished: '已处理配件订单',
        all: '配件订单管理'
      }

      uni.setNavigationBarTitle({
        title: titleMap[this.currentTab] || titleMap.all
      })
    },
    switchTab(tab) {
      if (tab === this.currentTab) {
        return
      }

      this.currentTab = tab
      this.syncNavigationTitle()
      this.reloadOrders()
    },
    mergeOrderList(nextRows, reset) {
      const mergedRows = reset ? nextRows : [...this.orderList, ...nextRows]

      return mergedRows.filter((item, index, array) => {
        return index === array.findIndex((current) => current.accessoryOrderId === item.accessoryOrderId)
      })
    },
    resolveListRequest() {
      return getMerchantAccessoryOrderList
    },
    formatApiError(error) {
      const message = (error && error.msg) || ''
      return message || '加载商家配件订单失败'
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
    async loadOrders(reset = false) {
      if (reset ? this.isLoading : this.isLoadingMore) {
        return
      }

      if (!this.ensureLogin()) {
        return
      }

      if (reset) {
        this.isLoading = true
        this.errorMessage = ''
      } else {
        this.isLoadingMore = true
      }

      try {
        const requestFn = this.resolveListRequest()
        const res = await requestFn({
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

        this.errorMessage = this.formatApiError(error)
        uni.showToast({
          title: this.errorMessage,
          icon: 'none'
        })
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
    canShip(item) {
      return String(item.status) === '0'
    },
    canComplete(item) {
      return String(item.status) === '1'
    },
    canCancel(item) {
      return ['0', '1'].includes(String(item.status))
    },
    async runOrderAction(order, executor, successText, fallbackErrorText) {
      if (!order || this.actioningOrderId) {
        return
      }

      this.actioningOrderId = order.accessoryOrderId
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
        uni.hideLoading()
        uni.showToast({
          title: (error && error.msg) || fallbackErrorText,
          icon: 'none'
        })
      } finally {
        this.actioningOrderId = null
      }
    },
    shipOrder(item) {
      uni.showModal({
        title: '确认发货',
        content: '确认将这笔配件订单更新为“已发货”吗？',
        success: ({ confirm }) => {
          if (confirm) {
            this.runOrderAction(
              item,
              () => shipMerchantAccessoryOrder(item.accessoryOrderId),
              '已更新为已发货',
              '发货失败'
            )
          }
        }
      })
    },
    completeOrder(item) {
      uni.showModal({
        title: '确认完成',
        content: '确认将这笔配件订单更新为“已完成”吗？',
        success: ({ confirm }) => {
          if (confirm) {
            this.runOrderAction(
              item,
              () => completeMerchantAccessoryOrder(item.accessoryOrderId),
              '订单已完成',
              '更新失败'
            )
          }
        }
      })
    },
    cancelOrder(item) {
      uni.showModal({
        title: '确认取消',
        content: '确认取消这笔配件订单吗？',
        success: ({ confirm }) => {
          if (confirm) {
            this.runOrderAction(
              item,
              () => cancelMerchantAccessoryOrder(item.accessoryOrderId),
              '订单已取消',
              '取消失败'
            )
          }
        }
      })
    },
    getAccessoryOrderStatusText,
    getAccessoryOrderStatusClass
  }
}
</script>

<style scoped>
.merchant-order-page {
  min-height: 100vh;
  background: linear-gradient(180deg, #f4f8ff 0%, #f8fafc 26%, #f6f7fb 100%);
  padding: 24rpx;
  box-sizing: border-box;
}

.hero-card {
  display: flex;
  justify-content: space-between;
  gap: 24rpx;
  padding: 30rpx;
  border-radius: 24rpx;
  background: linear-gradient(135deg, #1d4ed8 0%, #2563eb 48%, #60a5fa 100%);
  color: #fff;
  box-shadow: 0 16rpx 36rpx rgba(37, 99, 235, 0.2);
}

.hero-copy {
  flex: 1;
}

.hero-title {
  display: block;
  font-size: 38rpx;
  font-weight: 700;
}

.hero-desc {
  display: block;
  margin-top: 12rpx;
  font-size: 24rpx;
  line-height: 1.7;
  color: rgba(255, 255, 255, 0.88);
}

.hero-badge {
  min-width: 160rpx;
  padding: 18rpx 20rpx;
  border-radius: 20rpx;
  background: rgba(255, 255, 255, 0.14);
  text-align: center;
  align-self: center;
}

.hero-badge-label {
  display: block;
  font-size: 22rpx;
  color: rgba(255, 255, 255, 0.78);
}

.hero-badge-value {
  display: block;
  margin-top: 8rpx;
  font-size: 28rpx;
  font-weight: 600;
}

.tab-bar {
  display: flex;
  margin-top: 24rpx;
  padding: 10rpx;
  border-radius: 999rpx;
  background: #fff;
  box-shadow: 0 10rpx 28rpx rgba(15, 23, 42, 0.06);
}

.tab-item {
  flex: 1;
  text-align: center;
  padding: 18rpx 0;
  border-radius: 999rpx;
  font-size: 28rpx;
  color: #64748b;
}

.tab-item.active {
  background: linear-gradient(135deg, #2563eb 0%, #1d4ed8 100%);
  color: #fff;
  font-weight: 600;
}

.summary-strip {
  display: flex;
  gap: 18rpx;
  margin-top: 24rpx;
}

.summary-card {
  flex: 1;
  padding: 22rpx 18rpx;
  border-radius: 20rpx;
  background: #fff;
  box-shadow: 0 12rpx 24rpx rgba(15, 23, 42, 0.06);
  text-align: center;
}

.summary-label {
  display: block;
  font-size: 22rpx;
  color: #64748b;
}

.summary-value {
  display: block;
  margin-top: 10rpx;
  font-size: 28rpx;
  color: #0f172a;
  font-weight: 600;
}

.notice-card {
  margin-top: 24rpx;
  padding: 24rpx 26rpx;
  border-radius: 22rpx;
  background: linear-gradient(135deg, #fff7e6 0%, #fff1d6 100%);
  box-shadow: 0 12rpx 24rpx rgba(217, 119, 6, 0.08);
}

.notice-head {
  display: flex;
  align-items: center;
}

.notice-title {
  margin-left: 12rpx;
  font-size: 28rpx;
  font-weight: 600;
  color: #c2410c;
}

.notice-desc {
  display: block;
  margin-top: 12rpx;
  font-size: 24rpx;
  line-height: 1.7;
  color: #7c5a11;
}

.loading-wrap,
.empty-wrap {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 140rpx 40rpx;
}

.loading-icon {
  animation: spin 1s linear infinite;
  margin-bottom: 20rpx;
}

.loading-text,
.empty-desc {
  font-size: 26rpx;
  color: #64748b;
}

.empty-title {
  margin-top: 26rpx;
  font-size: 34rpx;
  font-weight: 600;
  color: #0f172a;
}

.empty-desc {
  margin-top: 16rpx;
  line-height: 1.7;
  text-align: center;
}

.empty-btn {
  width: 58%;
  height: 84rpx;
  line-height: 84rpx;
  margin-top: 36rpx;
  border: none;
  border-radius: 999rpx;
  background: linear-gradient(135deg, #2563eb 0%, #1d4ed8 100%);
  color: #fff;
  font-size: 28rpx;
  font-weight: 600;
}

.order-list {
  display: flex;
  flex-direction: column;
  gap: 20rpx;
  margin-top: 24rpx;
}

.tab-hint-card {
  padding: 26rpx 28rpx;
  border-radius: 22rpx;
  background: rgba(255, 255, 255, 0.9);
  box-shadow: 0 12rpx 24rpx rgba(15, 23, 42, 0.05);
}

.tab-hint-title {
  display: block;
  font-size: 28rpx;
  font-weight: 600;
  color: #0f172a;
}

.tab-hint-desc {
  display: block;
  margin-top: 10rpx;
  font-size: 24rpx;
  line-height: 1.7;
  color: #64748b;
}

.order-card {
  background: rgba(255, 255, 255, 0.96);
  border-radius: 24rpx;
  box-shadow: 0 14rpx 28rpx rgba(15, 23, 42, 0.08);
  overflow: hidden;
}

.order-card-head {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 20rpx;
  padding: 24rpx 28rpx 18rpx;
  border-bottom: 1px solid #eef2f7;
}

.order-no-wrap {
  flex: 1;
  min-width: 0;
}

.order-no-label {
  display: block;
  font-size: 22rpx;
  color: #64748b;
}

.order-no {
  display: block;
  margin-top: 8rpx;
  font-size: 26rpx;
  color: #0f172a;
  word-break: break-all;
}

.status-tag {
  flex-shrink: 0;
  padding: 8rpx 18rpx;
  border-radius: 999rpx;
  font-size: 24rpx;
  font-weight: 600;
}

.status-pending {
  background: #fff3e0;
  color: #ea580c;
}

.status-shipped {
  background: #e0f2fe;
  color: #0284c7;
}

.status-completed {
  background: #dcfce7;
  color: #15803d;
}

.status-canceled,
.status-unknown {
  background: #f1f5f9;
  color: #64748b;
}

.order-card-body {
  display: flex;
  gap: 20rpx;
  padding: 24rpx 28rpx;
}

.cover-image {
  width: 180rpx;
  height: 180rpx;
  border-radius: 16rpx;
  background: #f1f5f9;
  flex-shrink: 0;
}

.order-info {
  flex: 1;
  min-width: 0;
}

.accessory-name {
  display: block;
  font-size: 30rpx;
  font-weight: 700;
  color: #0f172a;
  margin-bottom: 14rpx;
  word-break: break-all;
}

.order-line {
  display: block;
  font-size: 24rpx;
  line-height: 1.75;
  color: #475569;
  word-break: break-all;
}

.order-card-foot {
  padding: 18rpx 28rpx 24rpx;
  border-top: 1px solid #eef2f7;
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 20rpx;
  flex-wrap: wrap;
}

.create-time {
  font-size: 22rpx;
  color: #94a3b8;
}

.action-group {
  display: flex;
  gap: 16rpx;
  flex-wrap: wrap;
  justify-content: flex-end;
}

.action-btn {
  min-width: 160rpx;
  height: 66rpx;
  line-height: 66rpx;
  padding: 0 24rpx;
  border: none;
  border-radius: 999rpx;
  font-size: 24rpx;
}

.primary-btn {
  background: linear-gradient(135deg, #2563eb 0%, #1d4ed8 100%);
  color: #fff;
}

.success-btn {
  background: linear-gradient(135deg, #22c55e 0%, #16a34a 100%);
  color: #fff;
}

.warn-btn {
  background: #fff1f2;
  color: #e11d48;
  border: 1px solid #fecdd3;
}

.load-more {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8rpx;
  padding: 24rpx 0 40rpx;
}

.load-more.disabled {
  opacity: 0.72;
}

.load-more-text {
  font-size: 26rpx;
  color: #334155;
}

.load-more-desc {
  font-size: 22rpx;
  color: #94a3b8;
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
