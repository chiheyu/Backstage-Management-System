<template>
  <view class="page">
    <view v-for="item in collectionList" :key="item.collectionId" class="card">
      <image class="cover" :src="baseUrl + item.coverImage" mode="aspectFill"></image>
      <view class="content">
        <text class="title">{{ item.accessoryName }}</text>
        <text class="price">￥{{ item.price }}</text>
        <button class="danger-btn" @click="removeCollection(item.accessoryId)">取消收藏</button>
      </view>
    </view>
    <view v-if="!collectionList.length" class="empty">暂无收藏配件</view>
  </view>
</template>

<script>
import config from '@/config'
import { cancelCollection, listMyCollection } from '@/api/user'

export default {
  data() {
    return {
      baseUrl: config.baseUrl,
      collectionList: []
    }
  },
  onShow() {
    this.getList()
  },
  methods: {
    // 查询我的收藏。
    getList() {
      listMyCollection().then(res => {
        this.collectionList = res.rows || []
      })
    },
    // 取消收藏。
    removeCollection(accessoryId) {
      cancelCollection(accessoryId).then(() => {
        uni.showToast({ title: '已取消收藏', icon: 'success' })
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
  display: flex;
  margin-bottom: 20rpx;
  padding: 20rpx;
  border-radius: 20rpx;
  background-color: #fff;
}

.cover {
  width: 160rpx;
  height: 160rpx;
  border-radius: 16rpx;
}

.content {
  flex: 1;
  margin-left: 20rpx;
}

.title {
  display: block;
  font-size: 30rpx;
  font-weight: 600;
}

.price {
  display: block;
  margin-top: 12rpx;
  color: #ff4d4f;
}

.danger-btn {
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
