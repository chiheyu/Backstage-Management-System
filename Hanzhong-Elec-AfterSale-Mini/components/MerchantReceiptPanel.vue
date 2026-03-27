<template>
  <view class="receipt-page">
    <view class="receipt-hero">
      <text class="receipt-title">售后回执</text>
    </view>

    <view class="receipt-layout">
      <view class="receipt-list-card">
        <view class="receipt-card-title">订单列表</view>
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
        this.merchantOrders = rows.filter((item) => ['1', '2', '3'].includes(String(item.status)))
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
.receipt-page {
  min-height: 100vh;
  background: #f8f8f8;
  padding: 20rpx;
  box-sizing: border-box;
}

.receipt-hero {
  padding: 32rpx 30rpx;
  border-radius: 16rpx;
  background: linear-gradient(135deg, #1236b6 0%, #2f54eb 60%, #5d7cff 100%);
  color: #fff;
  box-shadow: 0 4rpx 12rpx rgba(0, 0, 0, 0.05);
  margin-bottom: 20rpx;
}

.receipt-title {
  display: block;
  font-size: 38rpx;
  font-weight: 700;
  margin-bottom: 10rpx;
}

.receipt-desc {
  display: block;
  font-size: 25rpx;
  line-height: 1.7;
  opacity: 0.92;
}

.receipt-layout {
  display: flex;
  flex-direction: column;
  gap: 20rpx;
}

.receipt-list-card,
.receipt-form-card {
  background: #fff;
  padding: 30rpx;
  border-radius: 16rpx;
  box-shadow: 0 4rpx 12rpx rgba(0, 0, 0, 0.05);
}

.receipt-card-title {
  font-size: 32rpx;
  font-weight: 700;
  color: #333;
  margin-bottom: 20rpx;
}

.receipt-order-item {
  padding: 22rpx 20rpx;
  border-radius: 12rpx;
  background: #f8f9fc;
  margin-bottom: 16rpx;
  border: 1px solid transparent;
}

.receipt-order-item-active {
  border-color: #2f54eb;
  background: #f0f5ff;
}

.receipt-order-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 20rpx;
  margin-bottom: 10rpx;
}

.receipt-order-no {
  font-size: 25rpx;
  color: #666;
}

.receipt-order-status {
  font-size: 23rpx;
  color: #2f54eb;
}

.receipt-order-product {
  display: block;
  font-size: 30rpx;
  font-weight: 600;
  color: #333;
  margin-bottom: 8rpx;
}

.receipt-order-user,
.receipt-line {
  display: block;
  font-size: 25rpx;
  color: #666;
  line-height: 1.7;
}

.receipt-textarea {
  width: 100%;
  min-height: 220rpx;
  margin-top: 20rpx;
  padding: 20rpx;
  border: 1px solid #eee;
  border-radius: 12rpx;
  box-sizing: border-box;
  background: #fafafa;
  font-size: 28rpx;
  color: #333;
}

.receipt-action-row {
  margin-top: 24rpx;
}

.receipt-primary-btn,
.receipt-secondary-btn {
  width: 100%;
  height: 88rpx;
  line-height: 88rpx;
  border: none;
  border-radius: 999rpx;
  font-size: 30rpx;
}

.receipt-primary-btn {
  background: #2f54eb;
  color: #fff;
}

.receipt-secondary-btn {
  background: #eef2ff;
  color: #2f54eb;
}

.receipt-empty {
  padding: 60rpx 20rpx;
  text-align: center;
}

.receipt-empty-text {
  font-size: 28rpx;
  color: #999;
}
</style>
