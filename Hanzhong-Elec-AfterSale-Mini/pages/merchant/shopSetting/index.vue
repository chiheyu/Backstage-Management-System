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
          color="#10b981"
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
.shop-setting-page {
  min-height: 100vh;
  background: #f8f9fc;
  padding: 30rpx;
  box-sizing: border-box;
}
.form-container {
  background: #ffffff;
  border-radius: 24rpx;
  box-shadow: 0 8rpx 32rpx rgba(0, 0, 0, 0.03);
  overflow: hidden;
  margin-bottom: 48rpx;
}
.form-item {
  display: flex;
  align-items: center;
  padding: 0 36rpx;
  height: 100rpx;
  border-bottom: 1rpx solid #f5f7fa;
  box-sizing: border-box;
  transition: all 0.25s cubic-bezier(0.25, 1, 0.5, 1);
}
.form-item:first-child {
  height: 180rpx;
  align-items: center;
}
.form-item:active {
  background: #fafbfc;
}
.form-item:last-child {
  border-bottom: none;
}
.label {
  font-size: 28rpx;
  color: #2c3e50;
  width: 200rpx;
  flex-shrink: 0;
  font-weight: 500;
}
.logo-upload {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 16rpx;
}
.logo-img {
  width: 140rpx;
  height: 140rpx;
  border-radius: 50%;
  background: #f5f7fa;
  border: 4rpx solid #eaf0ff;
  object-fit: cover;
  transition: all 0.25s ease;
}
.logo-upload:active .logo-img {
  transform: scale(0.96);
  border-color: #d4e0ff;
}
.upload-tips {
  font-size: 24rpx;
  color: #95a3b8;
}
.input-content {
  flex: 1;
  min-width: 0;
  font-size: 28rpx;
  color: #2c3e50;
  padding: 0;
  border: none;
  outline: none;
}
.input-content::placeholder {
  color: #95a3b8;
}
.input-content:focus {
  color: #3b82f6;
}
.textarea-item {
  align-items: flex-start;
  padding: 32rpx 36rpx;
  height: auto;
}
.textarea-content {
  flex: 1;
  min-width: 0;
  font-size: 28rpx;
  color: #2c3e50;
  min-height: 150rpx;
  line-height: 1.7;
  padding: 0;
  border: none;
  outline: none;
}
.textarea-content::placeholder {
  color: #95a3b8;
}
.time-content {
  flex: 1;
  min-width: 0;
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-size: 28rpx;
  color: #95a3b8;
}
.arrow-icon {
  font-size: 28rpx;
  color: #95a3b8;
  font-weight: 600;
}
.switch-item {
  justify-content: space-between;
}
.save-btn {
  height: 100rpx;
  line-height: 100rpx;
  background: linear-gradient(135deg, #4d8cf7, #3b82f6);
  color: #fff;
  border-radius: 50rpx;
  text-align: center;
  font-size: 32rpx;
  font-weight: 500;
  box-shadow: 0 12rpx 32rpx rgba(59, 130, 246, 0.15);
  transition: all 0.25s cubic-bezier(0.25, 1, 0.5, 1);
}
.save-btn.disabled {
  background: #e4e7ed;
  pointer-events: none;
  box-shadow: none;
}
.save-btn:active {
  transform: scale(0.95);
  box-shadow: 0 6rpx 20rpx rgba(59, 130, 246, 0.2);
}
.btn-text {
  color: #fff;
}
</style>