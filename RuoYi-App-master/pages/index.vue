<template>
  <view class="page">
    <view class="banner" :class="{ merchant: isMerchant }">
      <text class="title">{{ isMerchant ? '商家首页' : '用户首页' }}</text>
      <text class="sub-title">{{ welcomeText }}</text>
    </view>
    <view class="grid">
      <view v-for="item in menuList" :key="item.url" class="card" @click="go(item.url)">
        <text class="card-title">{{ item.title }}</text>
        <text class="card-desc">{{ item.desc }}</text>
      </view>
    </view>
    <view v-if="role === '0'" class="notice">
      <text>当前商家账号仍处于待审核状态，暂时仅可体验用户侧基础功能。</text>
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
    isMerchant() {
      return this.role === '2'
    },
    welcomeText() {
      if (this.role === '2') {
        return '快速进入待接单、我的订单和商家资料维护。'
      }
      if (this.role === '0') {
        return '商家注册待审核中，先体验用户侧售后与配件功能。'
      }
      return '快速进入售后申请、订单跟踪和配件商城。'
    },
    menuList() {
      if (this.isMerchant) {
        return [
          { title: '待接单订单', desc: '查看全市待接单售后工单', url: '/pages/merchant/pending-order/pending-order' },
          { title: '我的订单', desc: '更新维修状态和备注', url: '/pages/merchant/my-order/my-order' },
          { title: '编辑商家信息', desc: '维护商家名称、地址和服务范围', url: '/pages/merchant/edit-info/edit-info' }
        ]
      }
      return [
        { title: '申请售后', desc: '提交产品故障和现场图片', url: '/pages/user/apply-after-sales/apply-after-sales' },
        { title: '我的订单', desc: '跟踪待接单、维修中和完成订单', url: '/pages/user/my-order/my-order' },
        { title: '配件商城', desc: '浏览电池、屏幕等热门配件', url: '/pages/user/accessory-mall/accessory-mall' },
        { title: '商家简介', desc: '查看汉中市本地服务商家', url: '/pages/user/merchant-intro/merchant-intro' }
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

.banner {
  padding: 40rpx 32rpx;
  border-radius: 24rpx;
  background: linear-gradient(135deg, #0f63ff, #4e8cff);
  color: #fff;

  &.merchant {
    background: linear-gradient(135deg, #15a36d, #31c48d);
  }
}

.title {
  display: block;
  font-size: 40rpx;
  font-weight: 600;
}

.sub-title {
  display: block;
  margin-top: 12rpx;
  font-size: 26rpx;
  opacity: 0.92;
}

.grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 20rpx;
  margin-top: 24rpx;
}

.card {
  padding: 28rpx;
  border-radius: 20rpx;
  background-color: #fff;
}

.card-title {
  display: block;
  font-size: 30rpx;
  font-weight: 600;
}

.card-desc {
  display: block;
  margin-top: 12rpx;
  color: #666;
  font-size: 24rpx;
  line-height: 1.6;
}

.notice {
  margin-top: 24rpx;
  padding: 20rpx 24rpx;
  border-radius: 16rpx;
  background-color: #fff7e6;
  color: #ad6800;
  font-size: 24rpx;
  line-height: 1.6;
}
</style>
