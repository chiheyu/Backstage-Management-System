<template>
  <view class="page">
    <view v-for="item in orderList" :key="item.orderId" class="card">
      <text class="title">{{ item.orderNo }}</text>
      <text class="desc">产品类型：{{ item.productType }}</text>
      <text class="desc">故障描述：{{ item.faultDesc }}</text>
      <text class="desc">联系人：{{ item.contactName }} / {{ item.contactPhone }}</text>
      <button class="primary-btn" @click="acceptOrder(item.orderId)">接单</button>
    </view>
    <view v-if="!orderList.length" class="empty">暂无待接单订单</view>
  </view>
</template>

<script>
import { listPendingOrder, takeOrder } from '@/api/merchant'

export default {
  data() {
    return {
      orderList: []
    }
  },
  onShow() {
    this.getList()
  },
  methods: {
    // 查询待接单订单。
    getList() {
      listPendingOrder().then(res => {
        this.orderList = res.rows || []
      })
    },
    // 商家接单。
    acceptOrder(orderId) {
      takeOrder(orderId).then(() => {
        uni.showToast({ title: '接单成功', icon: 'success' })
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

.empty {
  padding: 100rpx 0;
  text-align: center;
  color: #999;
}
</style>
