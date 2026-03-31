<template>
  <view class="receipt-page">
    <view class="receipt-hero">
      <text class="receipt-title">售后处理</text>
    </view>

    <view class="receipt-layout">
      <view class="receipt-list-card">
        <view class="receipt-card-title">工单列表</view>
        
        <scroll-view class="order-scroll-container" scroll-y>
          <view v-if="merchantOrders.length === 0" class="receipt-empty">
            <text class="receipt-empty-text">暂无可查看工单</text>
          </view>
          <view
            v-for="item in merchantOrders"
            :key="item.orderId"
            :class="['receipt-order-item', selectedOrderId === item.orderId ? 'receipt-order-item-active' : '']"
            @tap="selectMerchantOrder(item)"
          >
            <view class="receipt-order-header">
              <text class="receipt-order-no">{{ item.orderNo || `AS${item.orderId}` }}</text>
              <text class="receipt-order-status">{{ getMerchantStatusText(item.status) }}</text>
            </view>
            <text class="receipt-order-product">{{ item.productType || '未填写产品类型' }}</text>
            <text class="receipt-order-user">{{ item.userName || '未知用户' }}</text>
          </view>
        </scroll-view>
      </view>

        <view class="receipt-form-card">
        <view class="receipt-card-title">处理意见</view>
        <view v-if="selectedMerchantOrder" class="receipt-form-body">
          <text class="receipt-line">客户诉求：{{ selectedOrderMeta.serviceType || '未填写' }}</text>
          <text class="receipt-line">产品类型：{{ selectedOrderMeta.productName || '未填写' }}</text>
          <text class="receipt-line">订单号：{{ selectedOrderMeta.orderNo || '未填写' }}</text>
          <text class="receipt-line">用户：{{ selectedMerchantOrder.userName || '未知用户' }}</text>
          <text class="receipt-line">地址：{{ selectedMerchantOrder.address || '未填写' }}</text>
          <text class="receipt-line">当前状态：{{ getMerchantStatusText(selectedMerchantOrder.status) }}</text>
          <view v-if="isReadonlyReceipt" class="receipt-readonly-box">
            <text class="receipt-readonly-text">{{ readonlyReceiptContent }}</text>
          </view>
          <view v-else class="receipt-process-body">
            <view class="receipt-action-row dual-action">
              <button
                class="receipt-primary-btn"
                :disabled="isSubmittingReceipt"
                @tap="agreeMerchantOrder"
              >
                {{ isSubmittingReceipt ? '提交中...' : '同意' }}
              </button>
              <button
                class="receipt-reject-btn"
                :disabled="isSubmittingReceipt"
                @tap="toggleRejectMode"
              >
                {{ isRejectMode ? '取消拒绝' : '拒绝' }}
              </button>
            </view>
            <view v-if="isRejectMode" class="reject-panel">
              <textarea
                v-model="merchantReceipt.remark"
                class="receipt-textarea"
                placeholder="请输入拒绝原因"
                maxlength="300"
              ></textarea>
              <view class="receipt-action-row">
                <button
                  class="receipt-primary-btn"
                  :disabled="isSubmittingReceipt || !trimmedReceiptRemark"
                  @tap="submitRejectReceipt"
                >
                  {{ isSubmittingReceipt ? '提交中...' : '提交' }}
                </button>
              </view>
            </view>
          </view>
        </view>
        <view v-else class="receipt-empty">
          <text class="receipt-empty-text">请选择上方工单后查看或处理</text>
        </view>
      </view>
    </view>
  </view>
</template>

<script>
import { getMerchantOrders, updateMerchantOrderStatus } from '@/api/afterSale'

const RECEIPT_ORDER_KEY = 'merchantReceiptOrderId'

export default {
  data() {
    return {
      merchantOrders: [],
      selectedOrderId: null,
      merchantReceipt: {
        remark: ''
      },
      isSubmittingReceipt: false,
      isLoadingOrders: false,
      isRejectMode: false
    }
  },
  computed: {
    selectedMerchantOrder() {
      return this.merchantOrders.find((item) => item.orderId === this.selectedOrderId) || null
    },
    selectedOrderMeta() {
      return this.parseOrderMeta(this.selectedMerchantOrder?.productType)
    },
    isReadonlyReceipt() {
      return ['3', '4'].includes(String(this.selectedMerchantOrder?.status || ''))
    },
    readonlyReceiptContent() {
      return (this.selectedMerchantOrder?.serviceRemark || '').trim() || '暂无处理意见'
    },
    trimmedReceiptRemark() {
      return (this.merchantReceipt.remark || '').trim()
    }
  },
  mounted() {
    this.loadMerchantOrders()
  },
  pageLifetimes: {
    show() {
      this.loadMerchantOrders()
    }
  },
  methods: {
    parseOrderMeta(productType) {
      const parts = String(productType || '')
        .split('/')
        .map((item) => item.trim())
        .filter(Boolean)

      return {
        serviceType: parts[0] || '',
        productName: parts[1] || '',
        orderNo: parts[2] || ''
      }
    },
    getMerchantStatusText(status) {
      return ['3', '4'].includes(String(status)) ? '已完成' : '未完成'
    },
    async loadMerchantOrders() {
      if (this.isLoadingOrders) {
        return
      }

      this.isLoadingOrders = true
      try {
        const res = await getMerchantOrders({
          pageNum: 1,
          pageSize: 50
        })
        const rows = Array.isArray(res.rows) ? res.rows : []
        this.merchantOrders = rows.filter((item) => ['0', '1', '2', '3', '4'].includes(String(item.status)))
        if (this.merchantOrders.length) {
          const preferredOrderId = Number(uni.getStorageSync(RECEIPT_ORDER_KEY) || 0) || null
          if (preferredOrderId) {
            uni.removeStorageSync(RECEIPT_ORDER_KEY)
          }
          const activeOrders = this.merchantOrders.filter((item) => !['3', '4'].includes(String(item.status)))
          const selected = this.merchantOrders.find((item) => item.orderId === preferredOrderId)
            || this.merchantOrders.find((item) => item.orderId === this.selectedOrderId)
            || activeOrders[0]
            || this.merchantOrders[0]
          this.selectedOrderId = selected.orderId
          this.merchantReceipt.remark = ''
          this.isRejectMode = false
        } else {
          this.selectedOrderId = null
          this.merchantReceipt.remark = ''
          this.isRejectMode = false
        }
      } catch (error) {
        this.merchantOrders = []
        this.selectedOrderId = null
        this.merchantReceipt.remark = ''
        if (!error || !error.msg) {
          uni.showToast({
            title: '加载回执订单失败',
            icon: 'none'
          })
        }
      } finally {
        this.isLoadingOrders = false
      }
    },
    selectMerchantOrder(order) {
      this.selectedOrderId = order.orderId
      this.merchantReceipt.remark = ''
      this.isRejectMode = false
    },
    async submitMerchantReceipt(remark) {
      const selectedMerchantOrder = this.merchantOrders.find((item) => item.orderId === this.selectedOrderId)
      if (!selectedMerchantOrder || this.isSubmittingReceipt) {
        return
      }

      if (!remark) {
        uni.showToast({
          title: '请先填写处理意见',
          icon: 'none'
        })
        return
      }

      this.isSubmittingReceipt = true
      try {
        await updateMerchantOrderStatus({
          orderId: selectedMerchantOrder.orderId,
          status: '3',
          serviceRemark: remark
        })
        uni.showToast({
          title: '处理成功',
          icon: 'success'
        })
        await this.loadMerchantOrders()
      } catch (error) {
        if (!error || !error.msg) {
          uni.showToast({
            title: '提交失败，请稍后重试',
            icon: 'none'
          })
        }
      } finally {
        this.isSubmittingReceipt = false
      }
    },
    agreeMerchantOrder() {
      this.isRejectMode = false
      this.submitMerchantReceipt('已同意售后申请')
    },
    toggleRejectMode() {
      this.isRejectMode = !this.isRejectMode
      if (!this.isRejectMode) {
        this.merchantReceipt.remark = ''
      }
    },
    submitRejectReceipt() {
      this.submitMerchantReceipt(`已拒绝 拒绝原因：${this.trimmedReceiptRemark}`)
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
  background: #f8f8f8;
}

.receipt-page {
  min-height: 100vh;
  background: #f8f8f8;
  padding: 24rpx;
}

.receipt-hero {
  padding: 40rpx 32rpx;
  border-radius: 24rpx;
  background: linear-gradient(135deg, #1236b6 0%, #2f54eb 60%, #5d7cff 100%);
  color: #fff;
  box-shadow: 0 8rpx 24rpx rgba(47, 84, 235, 0.15);
  margin-bottom: 24rpx;
}

.receipt-title {
  display: block;
  font-size: 42rpx;
  font-weight: 700;
}

.receipt-layout {
  display: flex;
  flex-direction: column;
  gap: 24rpx;
}

.receipt-list-card,
.receipt-form-card {
  background: #fff;
  padding: 32rpx;
  border-radius: 24rpx;
  box-shadow: 0 8rpx 24rpx rgba(0, 0, 0, 0.06);
}

.receipt-card-title {
  font-size: 34rpx;
  font-weight: 700;
  color: #333;
  margin-bottom: 24rpx;
}

.order-scroll-container {
  height: 480rpx;
  overflow-y: auto;
}

.order-scroll-container::-webkit-scrollbar {
  width: 0;
}

.receipt-order-item {
  padding: 28rpx 24rpx;
  border-radius: 16rpx;
  background: #f8f9fc;
  margin-bottom: 20rpx;
  border: 1rpx solid transparent;
  transition: all 0.25s ease;
}

.receipt-order-item:active {
  transform: scale(0.98);
}

.receipt-order-item-active {
  border-color: #2f54eb;
  background: #f0f5ff;
  box-shadow: 0 4rpx 12rpx rgba(47, 84, 235, 0.1);
}

.receipt-order-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 20rpx;
  margin-bottom: 12rpx;
}

.receipt-order-no {
  font-size: 26rpx;
  color: #666;
}

.receipt-order-status {
  font-size: 24rpx;
  color: #2f54eb;
  font-weight: 500;
}

.receipt-order-product {
  display: block;
  font-size: 32rpx;
  font-weight: 600;
  color: #333;
  margin-bottom: 10rpx;
}

.receipt-order-user,
.receipt-line {
  display: block;
  font-size: 26rpx;
  color: #666;
  line-height: 1.7;
}

.receipt-textarea {
  width: 100%;
  min-height: 220rpx;
  margin-top: 24rpx;
  padding: 24rpx;
  border: 1rpx solid #f0f0f0;
  border-radius: 16rpx;
  background: #fafafa;
  font-size: 28rpx;
  color: #333;
  transition: all 0.2s ease;
}

.receipt-textarea:focus {
  border-color: #2f54eb;
  background: #fff;
  box-shadow: 0 0 0 6rpx rgba(47, 84, 235, 0.1);
}

.receipt-readonly-box {
  width: 100%;
  min-height: 220rpx;
  margin-top: 24rpx;
  padding: 24rpx;
  border: 1rpx solid #f0f0f0;
  border-radius: 16rpx;
  background: #f8f9fc;
}

.receipt-readonly-text {
  font-size: 28rpx;
  color: #333;
  line-height: 1.8;
  white-space: pre-wrap;
  word-break: break-all;
}

.receipt-process-body {
  margin-top: 24rpx;
}

.receipt-action-row {
  margin-top: 32rpx;
}

.dual-action {
  display: flex;
  gap: 20rpx;
}

.receipt-primary-btn,
.receipt-secondary-btn,
.receipt-reject-btn {
  width: 100%;
  height: 88rpx;
  line-height: 88rpx;
  border: none;
  border-radius: 44rpx;
  font-size: 30rpx;
  font-weight: 500;
  transition: all 0.2s ease;
}

.receipt-primary-btn {
  background: #2f54eb;
  color: #fff;
}

.receipt-primary-btn:active:not(:disabled) {
  transform: scale(0.96);
  opacity: 0.9;
}

.receipt-secondary-btn {
  background: #eef2ff;
  color: #2f54eb;
}

.receipt-reject-btn {
  background: #fff1f0;
  color: #ff4d4f;
}

.receipt-primary-btn:disabled,
.receipt-secondary-btn:disabled,
.receipt-reject-btn:disabled {
  opacity: 0.6;
}

.reject-panel {
  margin-top: 24rpx;
}

.receipt-empty {
  padding: 80rpx 20rpx;
  text-align: center;
}

.receipt-empty-text {
  font-size: 28rpx;
  color: #999;
}
</style>
