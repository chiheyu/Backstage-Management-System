<template>
  <view class="receipt-page">
    <view class="receipt-hero">
      <text class="receipt-title">售后回执</text>
    </view>

    <view class="receipt-layout">
      <view class="receipt-list-card">
        <view class="receipt-card-title">订单列表</view>
        
        <scroll-view class="order-scroll-container" scroll-y>
          <view v-if="merchantOrders.length === 0" class="receipt-empty">
            <text class="receipt-empty-text">暂无可处理订单</text>
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
        <view class="receipt-card-title">回执内容</view>
        <view v-if="selectedMerchantOrder" class="receipt-form-body">
          <text class="receipt-line">产品：{{ selectedMerchantOrder.productType || '未填写' }}</text>
          <text class="receipt-line">用户：{{ selectedMerchantOrder.userName || '未知用户' }}</text>
          <text class="receipt-line">地址：{{ selectedMerchantOrder.address || '未填写' }}</text>
          <text class="receipt-line">当前状态：{{ getMerchantStatusText(selectedMerchantOrder.status) }}</text>
          <textarea
            v-model="merchantReceipt.remark"
            class="receipt-textarea"
            placeholder="请输入本次回执，例如检测结果、维修进展、完工说明"
            maxlength="300"
          ></textarea>
          <view class="receipt-action-row">
            <button
              v-if="selectedMerchantOrder.status === '1'"
              class="receipt-primary-btn"
              :disabled="isSubmittingReceipt"
              @tap="submitMerchantReceipt('2')"
            >
              {{ isSubmittingReceipt ? '提交中...' : '提交回执并开始维修' }}
            </button>
            <button
              v-else-if="selectedMerchantOrder.status === '2'"
              class="receipt-primary-btn"
              :disabled="isSubmittingReceipt"
              @tap="submitMerchantReceipt('3')"
            >
              {{ isSubmittingReceipt ? '提交中...' : '提交回执并完成订单' }}
            </button>
            <button
              v-else
              class="receipt-secondary-btn"
              disabled
            >
              当前状态无需提交回执
            </button>
          </view>
        </view>
        <view v-else class="receipt-empty">
          <text class="receipt-empty-text">请选择上方订单后填写回执</text>
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
      isSubmittingReceipt: false
    }
  },
  computed: {
    selectedMerchantOrder() {
      return this.merchantOrders.find((item) => item.orderId === this.selectedOrderId) || null
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
    getMerchantStatusText(status) {
      const statusMap = {
        '0': '待接单',
        '1': '已接单',
        '2': '维修中',
        '3': '已完成',
        '4': '已取消'
      }
      return statusMap[String(status)] || '未知状态'
    },
    async loadMerchantOrders() {
      try {
        const res = await getMerchantOrders({
          pageNum: 1,
          pageSize: 50
        })
        const rows = Array.isArray(res.rows) ? res.rows : []
        this.merchantOrders = rows.filter((item) => ['1', '2'].includes(String(item.status)))
        if (this.merchantOrders.length) {
          const preferredOrderId = Number(uni.getStorageSync(RECEIPT_ORDER_KEY) || 0) || null
          if (preferredOrderId) {
            uni.removeStorageSync(RECEIPT_ORDER_KEY)
          }
          const selected = this.merchantOrders.find((item) => item.orderId === preferredOrderId)
            || this.merchantOrders.find((item) => item.orderId === this.selectedOrderId)
            || this.merchantOrders[0]
          this.selectedOrderId = selected.orderId
          this.merchantReceipt.remark = this.getDefaultRemark(selected)
        } else {
          this.selectedOrderId = null
          this.merchantReceipt.remark = ''
          uni.navigateTo({
            url: '/pages/afterSaleOrder/index'
          })
        }
      } catch (error) {
        this.merchantOrders = []
        this.selectedOrderId = null
        this.merchantReceipt.remark = ''
      }
    },
    getDefaultRemark(order) {
      if (!order) {
        return ''
      }
      if (String(order.status) === '2') {
        return ''
      }
      return order.serviceRemark || ''
    },
    selectMerchantOrder(order) {
      this.selectedOrderId = order.orderId
      this.merchantReceipt.remark = this.getDefaultRemark(order)
    },
    async submitMerchantReceipt(targetStatus) {
      const selectedMerchantOrder = this.merchantOrders.find((item) => item.orderId === this.selectedOrderId)
      if (!selectedMerchantOrder || this.isSubmittingReceipt) {
        return
      }

      const remark = (this.merchantReceipt.remark || '').trim()
      if (!remark) {
        uni.showToast({
          title: '请先填写回执内容',
          icon: 'none'
        })
        return
      }

      if (targetStatus === '3' && remark === (selectedMerchantOrder.serviceRemark || '').trim()) {
        uni.showToast({
          title: '请填写本次完工回执后再完成订单',
          icon: 'none'
        })
        return
      }

      this.isSubmittingReceipt = true
      try {
        await updateMerchantOrderStatus({
          orderId: selectedMerchantOrder.orderId,
          status: targetStatus,
          serviceRemark: remark
        })
        uni.showToast({
          title: '回执提交成功',
          icon: 'success'
        })
        await this.loadMerchantOrders()
        
        if (targetStatus === '3') {
          if (this.merchantOrders.length) {
            this.selectedOrderId = this.merchantOrders[0].orderId
            this.merchantReceipt.remark = this.getDefaultRemark(this.merchantOrders[0])
          } else {
            this.selectedOrderId = null
            this.merchantReceipt.remark = ''
          }
        }
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

.receipt-action-row {
  margin-top: 32rpx;
}

.receipt-primary-btn,
.receipt-secondary-btn {
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

.receipt-primary-btn:disabled,
.receipt-secondary-btn:disabled {
  opacity: 0.6;
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