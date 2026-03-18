<template>
  <view class="page">
    <view class="banner">
      <text class="title">商家工作台</text>
      <text class="sub-title">查看待接单工单、跟踪维修进度、维护商家资料</text>
    </view>
    <view class="card-list">
      <view class="card" @click="go('/pages/merchant/pending-order/pending-order')">
        <text class="card-title">待接单订单</text>
        <text class="card-desc">查看汉中市所有待接单的售后工单</text>
      </view>
      <view class="card" @click="go('/pages/merchant/my-order/my-order')">
        <text class="card-title">我的订单</text>
        <text class="card-desc">更新订单状态并补充维修备注</text>
      </view>
      <view class="card" @click="go('/pages/merchant/edit-info/edit-info')">
        <text class="card-title">编辑商家信息</text>
        <text class="card-desc">维护门店名称、地址、电话与服务范围</text>
      </view>
    </view>
  </view>
</template>

<script>
export default {
  methods: {
    // 页面跳转。
    go(url) {
      this.$tab.navigateTo(url)
    }
  }
}
</script>

<style lang="scss" scoped>
.page {
  min-height: 100vh;
  padding: 32rpx;
  background-color: #f5f7fb;
}

.banner {
  padding: 40rpx 32rpx;
  border-radius: 24rpx;
  background: linear-gradient(135deg, #15a36d, #31c48d);
  color: #fff;

  .title {
    display: block;
    font-size: 40rpx;
    font-weight: 600;
  }

  .sub-title {
    display: block;
    margin-top: 16rpx;
    font-size: 26rpx;
    opacity: 0.92;
  }
}

.card-list {
  display: grid;
  grid-template-columns: repeat(1, 1fr);
  gap: 20rpx;
  margin-top: 24rpx;
}

.card {
  padding: 28rpx;
  border-radius: 20rpx;
  background-color: #fff;
  box-shadow: 0 10rpx 30rpx rgba(21, 163, 109, 0.08);

  .card-title {
    display: block;
    color: #1f2d3d;
    font-size: 30rpx;
    font-weight: 600;
  }

  .card-desc {
    display: block;
    margin-top: 12rpx;
    color: #6b7785;
    font-size: 24rpx;
    line-height: 1.6;
  }
}
</style>
