<template>
  <view class="page">
    <scroll-view class="tab-scroll" scroll-x>
      <view class="tab-row">
        <view v-for="item in statusTabs" :key="item.value" class="tab-item" :class="{ active: currentStatus === item.value }" @click="changeStatus(item.value)">
          {{ item.label }}
        </view>
      </view>
    </scroll-view>

    <view v-for="item in orderList" :key="item.orderId" class="card" @click="showDetail(item)">
      <view class="card-head">
        <text>{{ item.orderNo }}</text>
        <text class="status">{{ statusLabel(item.status) }}</text>
      </view>
      <text class="desc">产品类型：{{ item.productType }}</text>
      <text class="desc">故障描述：{{ item.faultDesc }}</text>
      <text class="desc">商家：{{ item.merchantName || '待接单' }}</text>
      <button v-if="canCancel(item.status)" class="mini-btn" @click.stop="cancelOrder(item.orderId)">取消订单</button>
    </view>

    <view v-if="!orderList.length" class="empty">暂无订单数据</view>
  </view>
</template>

<script>
import { cancelAfterSalesOrder, listMyAfterSalesOrder } from '@/api/user'

export default {
  data() {
    return {
      currentStatus: '',
      orderList: [],
      statusTabs: [
        { label: '全部', value: '' },
        { label: '待接单', value: '0' },
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
    // 查询订单。
    getList() {
      listMyAfterSalesOrder({
        status: this.currentStatus || undefined
      }).then(res => {
        this.orderList = res.rows || []
      })
    },
    // 切换状态筛选。
    changeStatus(status) {
      this.currentStatus = status
      this.getList()
    },
    // 状态文案。
    statusLabel(status) {
      return (this.statusTabs.find(item => item.value === status) || {}).label || '未知'
    },
    // 是否允许取消。
    canCancel(status) {
      return status !== '3' && status !== '4'
    },
    // 显示详情。
    showDetail(item) {
      uni.showModal({
        title: '订单详情',
        content: '订单号：' + item.orderNo + '\n状态：' + this.statusLabel(item.status) + '\n故障描述：' + (item.faultDesc || '') + '\n处理备注：' + (item.serviceRemark || '暂无'),
        showCancel: false
      })
    },
    // 取消订单。
    cancelOrder(orderId) {
      cancelAfterSalesOrder(orderId).then(() => {
        uni.showToast({ title: '取消成功', icon: 'success' })
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

.tab-scroll {
  white-space: nowrap;
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
    background-color: #0f63ff;
    color: #fff;
  }
}

.card {
  margin-bottom: 20rpx;
  padding: 24rpx;
  border-radius: 20rpx;
  background-color: #fff;
}

.card-head {
  display: flex;
  justify-content: space-between;
  margin-bottom: 12rpx;
  font-weight: 600;
}

.status {
  color: #0f63ff;
}

.desc {
  display: block;
  margin-top: 8rpx;
  color: #666;
  font-size: 26rpx;
}

.mini-btn {
  margin-top: 20rpx;
  border-radius: 14rpx;
  background-color: #fff1f0;
  color: #ff4d4f;
}

.empty {
  padding: 100rpx 0;
  text-align: center;
  color: #999;
}
</style>
