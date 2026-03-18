<template>
  <view class="page">
    <view v-for="item in merchantList" :key="item.merchantId" class="card" @click="showDetail(item)">
      <text class="title">{{ item.merchantName }}</text>
      <text class="desc">联系电话：{{ item.contactPhone }}</text>
      <text class="desc">服务范围：{{ item.serviceScope }}</text>
      <text class="desc">地址：{{ item.address }}</text>
    </view>
  </view>
</template>

<script>
import { listMerchant } from '@/api/common'

export default {
  data() {
    return {
      merchantList: []
    }
  },
  onShow() {
    this.getList()
  },
  methods: {
    // 查询商家简介列表。
    getList() {
      listMerchant({ auditStatus: '1' }).then(res => {
        this.merchantList = res.rows || []
      })
    },
    // 查看商家详情。
    showDetail(item) {
      uni.showModal({
        title: item.merchantName,
        content: '联系人：' + item.contactName + '\n电话：' + item.contactPhone + '\n服务范围：' + item.serviceScope + '\n地址：' + item.address,
        showCancel: false
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
  color: #1f2d3d;
}

.desc {
  display: block;
  margin-top: 10rpx;
  color: #666;
  font-size: 26rpx;
  line-height: 1.6;
}
</style>
