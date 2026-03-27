<template>
  <view class="address-page">
    <view class="address-list" v-if="addressList.length > 0">
      <view 
        class="address-item" 
        v-for="(item, idx) in addressList" 
        :key="idx"
        @click="selectAddress(item)"
        hover-class="address-item-hover"
      >
        <view class="address-header">
          <view class="name-phone">
            <text class="name">{{ item.name }}</text>
            <text class="phone">{{ item.phone }}</text>
          </view>
          <text class="default-tag" v-if="item.isDefault">默认地址</text>
        </view>
        <text class="address-desc">{{ item.region }} {{ item.detail }}</text>
        <view class="address-opt">
          <text class="edit-btn" @click.stop="editAddress(item)" hover-class="opt-btn-hover">编辑</text>
          <text class="del-btn" @click.stop="deleteAddress(idx)" hover-class="opt-btn-hover">删除</text>
          <text class="default-btn" @click.stop="setDefault(idx)" v-if="!item.isDefault" hover-class="opt-btn-hover">设为默认</text>
        </view>
      </view>
    </view>
    <view class="empty-tip" v-else>
      <uni-icons type="location" size="120" color="#e5e5e5"></uni-icons>
      <text class="empty-text">暂无收货地址</text>
      <text class="empty-sub-text">点击下方按钮新增一个收货地址</text>
    </view>
    <view class="action-bar">
      <button class="add-btn" @click="addAddress" hover-class="add-btn-hover">
        新增地址
      </button>
    </view>
    <uni-popup ref="addressPopup" type="bottom" :mask-click="false" safe-area="bottom">
      <view class="popup-content">
        <view class="popup-header">
          <text class="title">{{ editMode ? '编辑地址' : '新增地址' }}</text>
          <text class="close-btn" @click="closePopup" hover-class="close-btn-hover">×</text>
        </view>
        <view class="form-item">
          <view class="label-wrap">
            <text class="label">收货人</text>
            <text class="required">*</text>
          </view>
          <input 
            v-model="form.name" 
            placeholder="请输入收货人姓名" 
            class="input"
            placeholder-class="input-placeholder"
          />
        </view>
        <view class="form-item">
          <view class="label-wrap">
            <text class="label">手机号</text>
            <text class="required">*</text>
          </view>
          <input 
            v-model="form.phone" 
            placeholder="请输入11位手机号" 
            type="number"
            class="input"
            placeholder-class="input-placeholder"
            maxlength="11"
          />
        </view>
        <view class="form-item">
          <view class="label-wrap">
            <text class="label">所在地区</text>
            <text class="required">*</text>
          </view>
          <input 
            v-model="form.region" 
            placeholder="请输入省/市/区/街道" 
            class="input"
            placeholder-class="input-placeholder"
          />
        </view>
        <view class="form-item">
          <view class="label-wrap">
            <text class="label">详细地址</text>
            <text class="required">*</text>
          </view>
          <input 
            v-model="form.detail" 
            placeholder="请输入详细地址（如街道、门牌号、小区）" 
            class="input"
            placeholder-class="input-placeholder"
          />
        </view>
        <view class="form-item default-check">
          <checkbox v-model="form.isDefault" color="#2f54eb" />
          <text class="default-text">设为默认地址</text>
        </view>
        <button class="submit-btn" @click="saveAddress" hover-class="submit-btn-hover">
          {{ editMode ? '保存修改' : '添加地址' }}
        </button>
      </view>
    </uni-popup>
  </view>
</template>

<script>
export default {
  data() {
    return {
      addressList: [],
      editMode: false,
      currentIndex: -1,
      form: {
        name: '',
        phone: '',
        region: '',
        detail: '',
        isDefault: false
      },
      regionCode: []
    }
  },
  onShow() {
    this.loadAddressList()
  },
  methods: {
    loadAddressList() {
      const list = wx.getStorageSync('addressList') || []
      this.addressList = list
    },
    addAddress() {
      this.form = {
        name: '',
        phone: '',
        region: '',
        detail: '',
        isDefault: false
      }
      this.editMode = false
      this.currentIndex = -1
      this.$refs.addressPopup.open()
    },
    editAddress(item) {
      this.form = {
        name: item.name,
        phone: item.phone,
        region: item.region,
        detail: item.detail,
        isDefault: item.isDefault
      }
      this.editMode = true
      this.currentIndex = this.addressList.findIndex(addr => addr.id === item.id)
      this.$refs.addressPopup.open()
    },
    deleteAddress(index) {
      wx.showModal({
        title: '确认删除',
        content: '是否删除该地址？',
        confirmText: '删除',
        cancelText: '取消',
        confirmColor: '#ff3b30',
        success: (res) => {
          if (res.confirm) {
            this.addressList.splice(index, 1)
            wx.setStorageSync('addressList', this.addressList)
            wx.showToast({ title: '删除成功', icon: 'success' })
          }
        }
      })
    },
    setDefault(index) {
      this.addressList.forEach(item => {
        item.isDefault = false
      })
      this.addressList[index].isDefault = true
      wx.setStorageSync('addressList', this.addressList)
      wx.showToast({ title: '已设为默认地址', icon: 'success' })
    },
    selectAddress(item) {
      const pages = getCurrentPages()
      const prevPage = pages[pages.length - 2]
      if (prevPage.route.includes('applyAfterSale')) {
        prevPage.setData({
          addressInfo: item,
          'form.name': item.name,
          'form.phone': item.phone,
          'form.region': item.region,
          'form.detail': item.detail
        })
      }
      wx.navigateBack()
    },
    saveAddress() {
      const { name, phone, region, detail } = this.form
      if (!name) return wx.showToast({ title: '请输入收货人姓名', icon: 'none' })
      if (!phone || !/^1[3-9]\d{9}$/.test(phone)) {
        return wx.showToast({ title: '请输入正确的11位手机号', icon: 'none' })
      }
      if (!region) return wx.showToast({ title: '请输入所在地区', icon: 'none' })
      if (!detail) return wx.showToast({ title: '请输入详细地址', icon: 'none' })
      const address = {
        id: Date.now(),
        name,
        phone,
        region,
        detail,
        isDefault: this.form.isDefault
      }
      if (this.editMode) {
        this.addressList[this.currentIndex] = address
        wx.showToast({ title: '修改成功', icon: 'success' })
      } else {
        if (address.isDefault) {
          this.addressList.forEach(item => {
            item.isDefault = false
          })
        }
        this.addressList.unshift(address)
        wx.showToast({ title: '添加成功', icon: 'success' })
      }
      wx.setStorageSync('addressList', this.addressList)
      this.closePopup()
    },
    closePopup() {
      this.$refs.addressPopup.close()
    }
  }
}
</script>

<style scoped>
:root {
  --primary-color: #2f54eb;
  --primary-light: #f0f5ff;
  --danger-color: #ff3b30;
  --warning-color: #fa8c16;
  --text-color: #1a1a1a;
  --text-gray: #999;
  --text-light: #666;
  --border-color: #f0f0f0;
  --bg-color: #f5f7fa;
  --white: #fff;
  --shadow-sm: 0 2rpx 10rpx rgba(0, 0, 0, 0.04);
  --shadow-md: 0 6rpx 20rpx rgba(0, 0, 0, 0.08);
  --radius-sm: 8rpx;
  --radius-md: 12rpx;
  --radius-lg: 16rpx;
  --radius-xl: 28rpx;
  --radius-full: 999rpx;
  --transition: all 0.25s cubic-bezier(0.25, 0.46, 0.45, 0.94);
}
.address-page {
  min-height: 100vh;
  background-color: var(--bg-color);
  padding: 0 0 160rpx;
}
.address-list {
  padding: 24rpx;
}
.address-item {
  background: var(--white);
  border-radius: var(--radius-lg);
  padding: 32rpx;
  margin-bottom: 20rpx;
  box-shadow: var(--shadow-sm);
  transition: var(--transition);
}
.address-item-hover {
  box-shadow: var(--shadow-md);
  transform: translateY(-3rpx);
}
.address-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 20rpx;
}
.name-phone {
  display: flex;
  align-items: center;
  gap: 24rpx;
}
.name {
  font-size: 32rpx;
  font-weight: 600;
  color: var(--text-color);
}
.phone {
  font-size: 28rpx;
  color: var(--text-light);
}
.default-tag {
  font-size: 24rpx;
  color: var(--primary-color);
  background: var(--primary-light);
  padding: 8rpx 18rpx;
  border-radius: var(--radius-full);
  font-weight: 500;
}
.address-desc {
  font-size: 28rpx;
  color: var(--text-light);
  line-height: 1.7;
  margin-bottom: 24rpx;
}
.address-opt {
  display: flex;
  gap: 40rpx;
  font-size: 26rpx;
}
.edit-btn {
  color: var(--primary-color);
  transition: var(--transition);
}
.del-btn {
  color: var(--danger-color);
  transition: var(--transition);
}
.default-btn {
  color: var(--warning-color);
  transition: var(--transition);
}
.opt-btn-hover {
  opacity: 0.7;
  transform: scale(1.06);
}
.empty-tip {
  text-align: center;
  padding: 160rpx 0;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 16rpx;
}
.empty-text {
  font-size: 32rpx;
  color: var(--text-gray);
  font-weight: 500;
}
.empty-sub-text {
  font-size: 26rpx;
  color: #b5b5b5;
}
.action-bar {
  position: fixed;
  left: 0;
  right: 0;
  bottom: 0;
  padding: 20rpx 24rpx calc(20rpx + env(safe-area-inset-bottom));
  background: linear-gradient(180deg, rgba(245, 247, 250, 0) 0%, rgba(245, 247, 250, 0.92) 24%, rgba(245, 247, 250, 1) 100%);
  z-index: 10;
}
.add-btn {
  width: 100%;
  height: 88rpx;
  line-height: 88rpx;
  border: none;
  border-radius: var(--radius-full);
  background: var(--primary-color);
  color: var(--white);
  font-size: 30rpx;
  font-weight: 500;
  box-shadow: var(--shadow-md);
}
.add-btn-hover {
  background: #2546d1;
  transform: scale(0.98);
}
.popup-content {
  background: var(--white);
  border-radius: var(--radius-xl) var(--radius-xl) 0 0;
  padding: 44rpx 36rpx;
  max-height: 82vh;
  overflow-y: auto;
}
.popup-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 44rpx;
}
.title {
  font-size: 36rpx;
  font-weight: 600;
  color: var(--text-color);
}
.close-btn {
  font-size: 48rpx;
  color: var(--text-gray);
  width: 68rpx;
  height: 68rpx;
  line-height: 68rpx;
  text-align: center;
  border-radius: 50%;
  transition: var(--transition);
}
.close-btn-hover {
  background: #f5f5f5;
  color: var(--danger-color);
}
.form-item {
  margin-bottom: 40rpx;
}
.label-wrap {
  display: flex;
  align-items: center;
  margin-bottom: 14rpx;
}
.label {
  font-size: 30rpx;
  color: var(--text-color);
  font-weight: 500;
}
.required {
  color: var(--danger-color);
  margin-left: 8rpx;
  font-size: 30rpx;
}
.input {
  font-size: 28rpx;
  color: var(--text-color);
  padding: 26rpx 20rpx;
  border: 1px solid var(--border-color);
  border-radius: var(--radius-md);
  background: #fafafa;
  transition: var(--transition);
  height: 92rpx;
}
.input:focus {
  border-color: var(--primary-color);
  background: var(--white);
  box-shadow: 0 0 0 6rpx rgba(47, 84, 235, 0.08);
  outline: none;
}
.input-placeholder {
  color: var(--text-gray);
  font-size: 28rpx;
}
.default-check {
  display: flex;
  align-items: center;
  font-size: 28rpx;
  color: var(--text-color);
  margin-top: 12rpx;
}
.default-check checkbox {
  margin-right: 14rpx;
  transform: scale(1.25);
}
.default-text {
  font-weight: 400;
}
.submit-btn {
  width: 100%;
  height: 96rpx;
  background: var(--primary-color);
  color: var(--white);
  border-radius: var(--radius-full);
  font-size: 32rpx;
  border: none;
  margin-top: 24rpx;
  font-weight: 500;
  box-shadow: var(--shadow-sm);
  transition: var(--transition);
}
.submit-btn-hover {
  background: #2546d1;
  transform: scale(0.97);
}
</style>
