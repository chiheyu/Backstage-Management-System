<template>
  <view class="page">
    <view class="section">
      <text class="section-title">{{ role === '2' ? '商家工作台' : '用户工作台' }}</text>
      <view class="work-list">
        <view v-for="item in workList" :key="item.url" class="work-item" @click="go(item.url)">
          <text class="work-title">{{ item.title }}</text>
          <text class="work-desc">{{ item.desc }}</text>
        </view>
      </view>
    </view>
  </view>
</template>

<script>
export default {
  data() {
    return {
      role: '1'
    }
  },
  computed: {
    workList() {
      if (this.role === '2') {
        return [
          { title: '待接单订单', desc: '快速处理全市待接单售后工单', url: '/pages/merchant/pending-order/pending-order' },
          { title: '我的维修订单', desc: '跟踪接单、维修中和已完成订单', url: '/pages/merchant/my-order/my-order' },
          { title: '编辑商家信息', desc: '维护门店电话、地址与服务范围', url: '/pages/merchant/edit-info/edit-info' }
        ]
      }
      return [
        { title: '配件商城', desc: '搜索并购买常见维修配件', url: '/pages/user/accessory-mall/accessory-mall' },
        { title: '我的收藏', desc: '查看已收藏配件并继续下单', url: '/pages/user/my-collection/my-collection' },
        { title: '商家简介', desc: '筛选汉中本地商家和服务范围', url: '/pages/user/merchant-intro/merchant-intro' }
      ]
    }
  },
  onShow() {
    this.role = uni.getStorageSync('role') || '1'
  },
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
  padding: 24rpx;
  background-color: #f5f7fb;
}

.section {
  padding: 24rpx;
  border-radius: 24rpx;
  background-color: #fff;
}

.section-title {
  display: block;
  font-size: 34rpx;
  font-weight: 600;
  color: #1f2d3d;
}

.work-list {
  display: flex;
  flex-direction: column;
  gap: 18rpx;
  margin-top: 24rpx;
}

.work-item {
  padding: 24rpx;
  border-radius: 18rpx;
  background-color: #f6f8fb;
}

.work-title {
  display: block;
  font-size: 28rpx;
  font-weight: 600;
}

.work-desc {
  display: block;
  margin-top: 10rpx;
  color: #666;
  font-size: 24rpx;
}
</style>
