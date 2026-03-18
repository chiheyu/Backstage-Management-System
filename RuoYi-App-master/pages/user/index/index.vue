<template>
  <view class="page">
    <view class="banner">
      <text class="title">用户服务中心</text>
      <text class="sub-title">一站式提交售后、查看订单、购买配件</text>
    </view>
    <view class="card-list">
      <view class="card" @click="go('/pages/user/apply-after-sales/apply-after-sales')">
        <text class="card-title">申请售后</text>
        <text class="card-desc">提交产品类型、故障描述和图片</text>
      </view>
      <view class="card" @click="go('/pages/user/my-order/my-order')">
        <text class="card-title">我的订单</text>
        <text class="card-desc">按状态查看待接单、维修中和完成订单</text>
      </view>
      <view class="card" @click="go('/pages/user/accessory-mall/accessory-mall')">
        <text class="card-title">配件商城</text>
        <text class="card-desc">搜索电池、屏幕等常见配件</text>
      </view>
      <view class="card" @click="go('/pages/user/my-collection/my-collection')">
        <text class="card-title">我的收藏</text>
        <text class="card-desc">管理已收藏配件并快速下单</text>
      </view>
      <view class="card" @click="go('/pages/user/merchant-intro/merchant-intro')">
        <text class="card-title">商家简介</text>
        <text class="card-desc">查看汉中市商家地址、电话和服务范围</text>
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
  background: linear-gradient(135deg, #0f63ff, #4e8cff);
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
  grid-template-columns: repeat(2, 1fr);
  gap: 20rpx;
  margin-top: 24rpx;
}

.card {
  padding: 28rpx;
  border-radius: 20rpx;
  background-color: #fff;
  box-shadow: 0 10rpx 30rpx rgba(15, 99, 255, 0.06);

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
