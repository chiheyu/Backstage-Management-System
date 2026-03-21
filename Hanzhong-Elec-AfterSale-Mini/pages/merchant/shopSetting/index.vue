<template>
  <view class="shop-setting-page">
    <view class="form-container">
      <view class="form-item">
        <text class="label">店铺Logo</text>
        <view class="logo-upload" @click="chooseShopLogo">
          <image :src="shopInfo.logo || defaultLogo" mode="aspectFill" class="logo-img"></image>
          <text class="upload-tips">点击更换</text>
        </view>
      </view>

      <view class="form-item input-item">
        <text class="label">店铺名称</text>
        <input 
          v-model="shopInfo.name" 
          placeholder="请输入店铺名称" 
          class="input-content"
          maxlength="30"
        />
      </view>

      <view class="form-item textarea-item">
        <text class="label">店铺简介</text>
        <textarea 
          v-model="shopInfo.desc" 
          placeholder="请输入店铺简介（最多100字）" 
          class="textarea-content"
          maxlength="100"
          auto-height
        ></textarea>
      </view>

      <view class="form-item input-item">
        <text class="label">联系电话</text>
        <input 
          v-model="shopInfo.phone" 
          placeholder="请输入店铺联系电话" 
          class="input-content"
          type="number"
          maxlength="11"
        />
      </view>

      <view class="form-item time-item">
        <text class="label">营业时间</text>
        <picker mode="time" :value="selectedTime" @change="onTimeChange" start="08:00" end="22:00">
          <view class="time-content">
            <text>{{ shopInfo.businessTime || "请选择营业时间" }}</text>
            <text class="arrow-icon">＞</text>
          </view>
        </picker>
      </view>

      <view class="form-item switch-item">
        <text class="label">店铺营业状态</text>
        <switch 
          :checked="shopInfo.isOpen" 
          @change="onStatusChange"
          color="#2f54eb"
        ></switch>
      </view>
    </view>

    <view class="save-btn" @click="saveShopInfo" :class="{ disabled: isSaving }">
      <text class="btn-text">{{ isSaving ? "保存中..." : "保存设置" }}</text>
    </view>
  </view>
</template>

<script>
export default {
  name: "ShopSetting",
  data() {
    return {
      shopInfo: {
        logo: "",
        name: "",
        desc: "",
        phone: "",
        businessTime: "",
        isOpen: true
      },
      defaultLogo: "/static/images/shop-default.png",
      selectedTime: "09:00",
      isSaving: false
    };
  },
  onShow() {
    this.loadShopInfo();
  },
  methods: {
    loadShopInfo() {
      try {
        const savedShopInfo = uni.getStorageSync("shopInfo");
        if (savedShopInfo) {
          this.shopInfo = { ...this.shopInfo, ...savedShopInfo };
          this.selectedTime = savedShopInfo.businessTime || "09:00";
        }
      } catch (e) {
        uni.showToast({ title: "加载配置失败", icon: "none" });
      }
    },
    chooseShopLogo() {
      uni.chooseImage({
        count: 1,
        sizeType: ["original", "compressed"],
        sourceType: ["album", "camera"],
        success: (res) => {
          this.shopInfo.logo = res.tempFilePaths[0];
        },
        fail: () => {
          uni.showToast({ title: "选择图片失败", icon: "none" });
        }
      });
    },
    onTimeChange(e) {
      this.shopInfo.businessTime = e.detail.value;
      this.selectedTime = e.detail.value;
    },
    onStatusChange(e) {
      this.shopInfo.isOpen = e.detail.value;
    },
    saveShopInfo() {
      if (!this.shopInfo.name.trim()) {
        uni.showToast({ title: "请输入店铺名称", icon: "none" });
        return;
      }
      if (this.shopInfo.phone && !/^1[3-9]\d{9}$/.test(this.shopInfo.phone)) {
        uni.showToast({ title: "请输入正确的手机号", icon: "none" });
        return;
      }
      if (this.isSaving) return;
      this.isSaving = true;
      try {
        uni.setStorageSync("shopInfo", this.shopInfo);
        uni.showToast({ title: "保存成功", icon: "success" });
      } catch (error) {
        uni.showToast({ title: "保存失败，请重试", icon: "none" });
      } finally {
        this.isSaving = false;
      }
    }
  }
};
</script>

<style scoped>
:root {
  --primary-color: #2f54eb;
  --light-primary: #f0f5ff;
  --text-color: #333;
  --text-gray: #999;
  --text-light: #666;
  --bg-color: #f8f8f8;
  --white: #fff;
  --border-color: #eee;
  --radius-sm: 8rpx;
  --radius-md: 12rpx;
  --radius-lg: 16rpx;
  --radius-full: 999rpx;
  --shadow: 0 4rpx 12rpx rgba(0, 0, 0, 0.05);
}
.shop-setting-page {
  min-height: 100vh;
  background-color: var(--bg-color);
  padding-bottom: 40rpx;
}
.form-container {
  margin: 20rpx;
  background-color: var(--white);
  border-radius: var(--radius-lg);
  box-shadow: var(--shadow);
  overflow: hidden;
}
.form-item {
  display: flex;
  align-items: center;
  padding: 0 30rpx;
  min-height: 90rpx;
  border-bottom: 1px solid var(--border-color);
}
.form-item:last-child {
  border-bottom: none;
}
.label {
  font-size: 30rpx;
  color: var(--text-color);
  width: 180rpx;
  flex-shrink: 0;
}
.logo-upload {
  display: flex;
  flex-direction: column;
  align-items: center;
  margin: 20rpx 0;
}
.logo-img {
  width: 120rpx;
  height: 120rpx;
  border-radius: var(--radius-md);
  border: 1px dashed var(--border-color);
  margin-bottom: 10rpx;
}
.upload-tips {
  font-size: 24rpx;
  color: var(--text-gray);
}
.input-content {
  flex: 1;
  font-size: 28rpx;
  color: var(--text-color);
  padding: 10rpx 0;
}
.input-content::placeholder {
  color: var(--text-gray);
}
.textarea-item {
  align-items: flex-start;
  padding: 20rpx 30rpx;
}
.textarea-content {
  flex: 1;
  font-size: 28rpx;
  color: var(--text-color);
  min-height: 120rpx;
  line-height: 1.6;
}
.textarea-content::placeholder {
  color: var(--text-gray);
}
.time-content {
  flex: 1;
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-size: 28rpx;
  color: var(--text-gray);
}
.arrow-icon {
  font-size: 24rpx;
  color: var(--text-gray);
}
.switch-item {
  justify-content: space-between;
}
.save-btn {
  margin: 30rpx 20rpx;
  height: 88rpx;
  line-height: 88rpx;
  background-color: var(--primary-color);
  color: var(--white);
  border-radius: var(--radius-full);
  text-align: center;
  font-size: 32rpx;
  box-shadow: var(--shadow);
}
.save-btn.disabled {
  background-color: #999;
  pointer-events: none;
}
.save-btn:active {
  background-color: #1e42c8;
  transform: scale(0.98);
}
.btn-text {
  color: var(--white);
  font-weight: 500;
}
</style>