<template>
  <view class="page">
    <scroll-view class="tab-scroll" scroll-x>
      <view class="tab-row">
        <view v-for="item in statusTabs" :key="item.value" class="tab-item" :class="{ active: currentStatus === item.value }" @click="changeStatus(item.value)">
          {{ item.label }}
        </view>
      </view>
    </scroll-view>

    <view v-for="item in orderList" :key="item.orderId" class="card">
      <text class="title">{{ item.orderNo }}</text>
      <text class="desc">产品类型：{{ item.productType }}</text>
      <text class="desc">客户：{{ item.contactName }} / {{ item.contactPhone }}</text>
      <text class="desc">当前状态：{{ statusLabel(item.status) }}</text>
      <button class="primary-btn" @click="openStatus(item)">更新状态</button>
    </view>

    <view v-if="statusOpen" class="mask">
      <view class="popup">
        <text class="popup-title">更新订单状态</text>
        <picker :range="statusTabs.slice(1)" range-key="label" @change="changePicker">
          <view class="picker-box">{{ statusLabel(statusForm.status) || '请选择目标状态' }}</view>
        </picker>
        <textarea v-model="statusForm.serviceRemark" placeholder="请输入维修备注"></textarea>
        <view class="popup-actions">
          <button @click="statusOpen = false">取消</button>
          <button class="primary-btn" @click="submitStatus">提交</button>
        </view>
      </view>
    </view>
  </view>
</template>

<script>
import { listMerchantOrder, updateMerchantOrderStatus } from '@/api/merchant'

export default {
  data() {
    return {
      currentStatus: '',
      orderList: [],
      statusOpen: false,
      statusForm: {
        orderId: undefined,
        status: '2',
        serviceRemark: ''
      },
      statusTabs: [
        { label: '全部', value: '' },
        { label: '已接单', value: '1' },
        { label: '维修中', value: '2' },
        { label: '已完成', value: '3' },
        { label: '已取消', value: '4' }
      ]
    }
  },
  onShow() {
    this.getList()
  },
  methods: {
    // 查询商家订单。
    getList() {
      listMerchantOrder({
        status: this.currentStatus || undefined
      }).then(res => {
        this.orderList = res.rows || []
      })
    },
    // 切换状态。
    changeStatus(status) {
      this.currentStatus = status
      this.getList()
    },
    // 状态文案。
    statusLabel(status) {
      return (this.statusTabs.find(item => item.value === status) || {}).label || '未知'
    },
    // 打开弹窗。
    openStatus(item) {
      this.statusForm = {
        orderId: item.orderId,
        status: item.status,
        serviceRemark: item.serviceRemark || ''
      }
      this.statusOpen = true
    },
    // Picker 选择状态。
    changePicker(event) {
      this.statusForm.status = this.statusTabs.slice(1)[event.detail.value].value
    },
    // 提交状态更新。
    submitStatus() {
      updateMerchantOrderStatus(this.statusForm).then(() => {
        uni.showToast({ title: '更新成功', icon: 'success' })
        this.statusOpen = false
        this.getList()
      })
    }
  }
}
</script>

<style lang="scss" scoped>
.page {
  min-height: 100vh;
  padding: 24rpx;
  background-color: #f5f7fb;
}

.tab-row {
  display: flex;
  gap: 16rpx;
  margin-bottom: 20rpx;
}

.tab-item {
  padding: 14rpx 26rpx;
  border-radius: 999rpx;
  background-color: #fff;
  color: #666;

  &.active {
    background-color: #15a36d;
    color: #fff;
  }
}

.card {
  margin-bottom: 20rpx;
  padding: 24rpx;
  border-radius: 20rpx;
  background-color: #fff;
}

.title {
  display: block;
  font-size: 30rpx;
  font-weight: 600;
}

.desc {
  display: block;
  margin-top: 10rpx;
  color: #666;
  font-size: 26rpx;
}

.primary-btn {
  margin-top: 20rpx;
  border-radius: 14rpx;
  background-color: #15a36d;
  color: #fff;
}

.mask {
  position: fixed;
  inset: 0;
  display: flex;
  align-items: center;
  justify-content: center;
  background: rgba(0, 0, 0, 0.45);
}

.popup {
  width: 640rpx;
  padding: 28rpx;
  border-radius: 24rpx;
  background-color: #fff;

  textarea {
    width: 100%;
    min-height: 160rpx;
    margin-top: 20rpx;
    padding: 20rpx;
    border-radius: 16rpx;
    background-color: #f6f8fb;
  }
}

.picker-box {
  margin-top: 20rpx;
  padding: 24rpx;
  border-radius: 16rpx;
  background-color: #f6f8fb;
}

.popup-title {
  font-size: 30rpx;
  font-weight: 600;
}

.popup-actions {
  display: flex;
  gap: 16rpx;
  margin-top: 24rpx;
}
</style>
