<template>
  <view class="page">
    <view class="search-bar">
      <input v-model="queryParams.accessoryName" placeholder="搜索配件名称" @confirm="getList" />
      <button class="search-btn" @click="getList">搜索</button>
    </view>

    <view v-for="item in accessoryList" :key="item.accessoryId" class="card">
      <image class="cover" :src="baseUrl + item.coverImage" mode="aspectFill"></image>
      <view class="content">
        <text class="title">{{ item.accessoryName }}</text>
        <text class="desc">{{ item.accessoryDesc }}</text>
        <text class="price">￥{{ item.price }}</text>
        <view class="action-row">
          <button class="plain-btn" @click="handleCollect(item)">收藏</button>
          <button class="primary-btn small" @click="openOrder(item)">下单</button>
        </view>
      </view>
    </view>

    <view v-if="orderOpen" class="mask">
      <view class="popup">
        <text class="popup-title">购买 {{ orderForm.accessoryName }}</text>
        <input v-model="orderForm.receiverName" placeholder="收货人" />
        <input v-model="orderForm.receiverPhone" type="number" maxlength="11" placeholder="联系电话" />
        <input v-model="orderForm.receiverAddress" placeholder="收货地址" />
        <input v-model="orderForm.quantity" type="number" placeholder="购买数量" />
        <view class="popup-actions">
          <button @click="orderOpen = false">取消</button>
          <button class="primary-btn small" @click="submitOrder">提交</button>
        </view>
      </view>
    </view>
  </view>
</template>

<script>
import config from '@/config'
import { getAccessory, listAccessory } from '@/api/common'
import { collectAccessory, createAccessoryOrder } from '@/api/user'

export default {
  data() {
    return {
      baseUrl: config.baseUrl,
      accessoryList: [],
      queryParams: {
        accessoryName: '',
        status: '0'
      },
      orderOpen: false,
      orderForm: {
        accessoryId: undefined,
        accessoryName: '',
        receiverName: '',
        receiverPhone: '',
        receiverAddress: '',
        quantity: 1
      }
    }
  },
  onShow() {
    this.getList()
  },
  methods: {
    // 查询配件商城。
    getList() {
      listAccessory(this.queryParams).then(res => {
        this.accessoryList = res.rows || []
      })
    },
    // 收藏配件。
    handleCollect(item) {
      collectAccessory(item.accessoryId).then(() => {
        uni.showToast({ title: '收藏成功', icon: 'success' })
      })
    },
    // 打开下单弹窗。
    openOrder(item) {
      getAccessory(item.accessoryId).then(() => {
        this.orderForm = {
          accessoryId: item.accessoryId,
          accessoryName: item.accessoryName,
          receiverName: '',
          receiverPhone: '',
          receiverAddress: '',
          quantity: 1
        }
        this.orderOpen = true
      })
    },
    // 提交配件订单。
    submitOrder() {
      createAccessoryOrder({
        accessoryId: this.orderForm.accessoryId,
        quantity: Number(this.orderForm.quantity || 1),
        receiverName: this.orderForm.receiverName,
        receiverPhone: this.orderForm.receiverPhone,
        receiverAddress: this.orderForm.receiverAddress,
        orderRemark: 'uni-app 用户端下单'
      }).then(() => {
        uni.showToast({ title: '下单成功', icon: 'success' })
        this.orderOpen = false
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

.search-bar {
  display: flex;
  gap: 16rpx;
  margin-bottom: 20rpx;

  input {
    flex: 1;
    height: 76rpx;
    padding: 0 24rpx;
    border-radius: 16rpx;
    background-color: #fff;
  }
}

.search-btn,
.primary-btn,
.plain-btn {
  border-radius: 14rpx;
}

.card {
  display: flex;
  margin-bottom: 20rpx;
  padding: 20rpx;
  border-radius: 20rpx;
  background-color: #fff;
}

.cover {
  width: 180rpx;
  height: 180rpx;
  border-radius: 16rpx;
  background-color: #f6f8fb;
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

.desc {
  display: block;
  margin-top: 12rpx;
  color: #666;
  font-size: 24rpx;
  line-height: 1.6;
}

.price {
  display: block;
  margin-top: 16rpx;
  color: #ff4d4f;
  font-weight: 600;
}

.action-row {
  display: flex;
  gap: 16rpx;
  margin-top: 16rpx;
}

.small {
  font-size: 24rpx;
}

.plain-btn {
  background-color: #eef4ff;
  color: #0f63ff;
}

.primary-btn {
  background-color: #0f63ff;
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

  input {
    height: 80rpx;
    margin-top: 16rpx;
    padding: 0 20rpx;
    border-radius: 14rpx;
    background-color: #f6f8fb;
  }
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
