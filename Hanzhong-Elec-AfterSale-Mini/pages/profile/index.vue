<template>
  <view class="profile-page">
    <view class="loading" v-if="loading">
      <uni-icons type="spinner-cycle" size="36" color="#2f54eb" class="loading-icon"></uni-icons>
      <text class="loading-text">加载中...</text>
    </view>

    <view v-else-if="isLogin" class="login-content">
      <view class="profile-header" @click="editProfile">
        <image :src="avatar" mode="aspectFill" class="avatar"></image>
        <view class="info">
          <text class="nickname">{{ nickname }}</text>
          <text class="desc">{{ roleLabel }}</text>
        </view>
        <uni-icons type="arrowright" size="24" color="#fff" class="edit-icon"></uni-icons>
      </view>

      <view class="section pending-merchant-section" v-if="isPendingMerchant">
        <view class="pending-merchant-head">
          <uni-icons type="info" size="22" color="#fa8c16"></uni-icons>
          <text class="pending-merchant-title">商家入驻审核中</text>
        </view>
        <text class="pending-merchant-desc">
          {{ pendingMerchantMessage }}
        </text>
      </view>

      <view class="section order-section" v-if="role === 'user'">
        <view class="section-header">
          <text class="more" @click="goOrder('all')">全部 ></text>
        </view>
        <view class="order-grid">
          <view class="order-item" @click="goOrder('pending')" hover-class="order-item-hover">
            <view class="order-icon-wrapper">
              <uni-icons type="list" size="28" color="#2f54eb" class="order-icon"></uni-icons>
            </view>
            <text class="order-text">待处理</text>
          </view>
          <view class="order-item" @click="goOrder('finished')" hover-class="order-item-hover">
            <view class="order-icon-wrapper">
              <uni-icons type="checkmarkempty" size="28" color="#52c41a" class="order-icon"></uni-icons>
            </view>
            <text class="order-text">已完成</text>
          </view>
          <view class="order-item" @click="goAfterSaleHistory" hover-class="order-item-hover">
            <view class="order-icon-wrapper">
              <uni-icons type="refresh" size="28" color="#fa8c16" class="order-icon"></uni-icons>
            </view>
            <text class="order-text">售后历史</text>
          </view>
        </view>
      </view>

      <view class="section order-section" v-if="showMerchantModules">
        <view class="section-header">
          <text class="section-title">售后订单</text>
          <text class="more" @click="goAudit('all')">全部 ></text>
        </view>
        <view class="order-grid">
          <view class="order-item" @click="goAudit('pending')" hover-class="order-item-hover">
            <view class="order-icon-wrapper">
              <uni-icons type="flag" size="28" color="#fa8c16" class="order-icon"></uni-icons>
            </view>
            <text class="order-text">售后待处理</text>
          </view>
          <view class="order-item" @click="goAudit('finished')" hover-class="order-item-hover">
            <view class="order-icon-wrapper">
              <uni-icons type="checkmarkempty" size="28" color="#52c41a" class="order-icon"></uni-icons>
            </view>
            <text class="order-text">售后已处理</text>
          </view>
          <view class="order-item" @click="goMerchantStat" hover-class="order-item-hover">
            <view class="order-icon-wrapper">
              <uni-icons type="search" size="28" color="#2f54eb" class="order-icon"></uni-icons>
            </view>
            <text class="order-text">数据统计</text>
          </view>
        </view>
      </view>

      <view class="section order-section" v-if="showMerchantModules">
        <view class="section-header">
          <text class="section-title">配件订单</text>
          <text class="more" @click="goAccessoryOrder('all')">全部 ></text>
        </view>
        <view class="order-grid">
          <view class="order-item" @click="goAccessoryOrder('pending')" hover-class="order-item-hover">
            <view class="order-icon-wrapper">
              <uni-icons type="cart" size="28" color="#0f766e" class="order-icon"></uni-icons>
            </view>
            <text class="order-text">配件待处理</text>
          </view>
          <view class="order-item" @click="goAccessoryOrder('finished')" hover-class="order-item-hover">
            <view class="order-icon-wrapper">
              <uni-icons type="checkmarkempty" size="28" color="#18a058" class="order-icon"></uni-icons>
            </view>
            <text class="order-text">配件已处理</text>
          </view>
          <view class="order-item" @click="goAccessoryOrder('all')" hover-class="order-item-hover">
            <view class="order-icon-wrapper">
              <uni-icons type="list" size="28" color="#2f54eb" class="order-icon"></uni-icons>
            </view>
            <text class="order-text">全部配件订单</text>
          </view>
        </view>
      </view>

      <view class="section menu-section">
        <view class="menu-list">
          <view class="menu-item" @click="goAddress" v-if="role === 'user'" hover-class="menu-item-hover">
            <view class="menu-icon-wrapper">
              <uni-icons type="location" size="28" color="#666" class="menu-icon"></uni-icons>
            </view>
            <view class="menu-content">
              <text class="menu-text">收货地址</text>
              <text class="default-address" v-if="defaultAddress">{{ defaultAddress.region }} {{ defaultAddress.detail }}</text>
            </view>
            <uni-icons type="arrowright" size="24" color="#ccc" class="menu-arrow"></uni-icons>
          </view>
          <view class="menu-item" @click="goService" hover-class="menu-item-hover">
            <view class="menu-icon-wrapper">
              <uni-icons type="headphones" size="28" color="#666" class="menu-icon"></uni-icons>
            </view>
            <text class="menu-text">{{ role === 'user' ? '联系客服' : '商家客服' }}</text>
            <uni-icons type="arrowright" size="24" color="#ccc" class="menu-arrow"></uni-icons>
          </view>
          <view class="menu-item" @click="openMerchantAdmin" v-if="showMerchantModules" hover-class="menu-item-hover">
            <view class="menu-icon-wrapper">
              <uni-icons type="shop" size="28" color="#666" class="menu-icon"></uni-icons>
            </view>
            <text class="menu-text">商家后台</text>
            <uni-icons type="arrowright" size="24" color="#ccc" class="menu-arrow"></uni-icons>
          </view>
          <view class="menu-item danger" @click="logout" hover-class="menu-item-hover">
            <view class="menu-icon-wrapper">
              <uni-icons type="close" size="28" color="#ff3b30" class="menu-icon"></uni-icons>
            </view>
            <text class="menu-text">退出登录</text>
            <uni-icons type="arrowright" size="24" color="#ccc" class="menu-arrow"></uni-icons>
          </view>
        </view>
      </view>
    </view>

    <view v-else class="login-register-wrap">
      <view class="guest-card">
        <image src="/static/images/avatar.png" mode="aspectFill" class="guest-avatar"></image>
        <text class="guest-title">尚未登录</text>
        <text class="guest-desc">登录后可查看售后订单、管理收货地址和个人信息</text>
        <button class="submit-btn" @click="goLoginPage">去登录 / 注册</button>
      </view>
    </view>

    <view v-if="showMerchantModules && showStatModal" class="modal-mask" @tap="closeStatPopup">
      <view class="stat-popup" @tap.stop>
        <view class="stat-header">
          <text class="stat-title">售后数据统计</text>
          <uni-icons type="close" size="26" color="#333" class="stat-close" @click="closeStatPopup"></uni-icons>
        </view>
        <view class="stat-content">
          <view class="stat-overview">
            <view class="stat-card">
              <text class="stat-card-label">今日待处理</text>
              <text class="stat-card-value">{{ statData.todayPending }}</text>
            </view>
            <view class="stat-card">
              <text class="stat-card-label">今日已处理</text>
              <text class="stat-card-value">{{ statData.todayFinished }}</text>
            </view>
            <view class="stat-card">
              <text class="stat-card-label">本月总数</text>
              <text class="stat-card-value">{{ statData.monthTotal }}</text>
            </view>
          </view>

          <view class="stat-section">
            <text class="stat-subtitle">售后类型占比</text>
            <view class="stat-chart">
              <view class="chart-item" v-for="(item, index) in statData.typeRatio" :key="index">
                <view class="chart-item-left">
                  <view class="chart-color" :style="{ backgroundColor: item.color }"></view>
                  <text class="chart-name">{{ item.name }}</text>
                </view>
                <text class="chart-ratio">{{ item.ratio }}</text>
              </view>
            </view>
          </view>

          <view class="stat-section">
            <text class="stat-subtitle">近7天处理量</text>
            <view class="trend-list">
              <view class="trend-item" v-for="(item, index) in statData.weekTrend" :key="index">
                <text class="trend-date">{{ item.date }}</text>
                <view class="trend-bar" :style="{ height: item.value * 3 + 'rpx', backgroundColor: '#2f54eb' }"></view>
                <text class="trend-value">{{ item.value }}</text>
              </view>
            </view>
          </view>
        </view>
        <button class="stat-close-btn" @click="closeStatPopup">关闭</button>
      </view>
    </view>

    <view v-if="showMerchantModules && showMerchantAdminModal" class="modal-mask" @tap="closeMerchantAdmin">
      <view class="merchant-admin-popup" @tap.stop>
        <view class="merchant-admin-header">
          <text class="merchant-admin-title">商家管理后台</text>
          <uni-icons type="close" size="26" color="#333" class="merchant-admin-close" @click="closeMerchantAdmin"></uni-icons>
        </view>
        <view class="merchant-admin-content">
          <view class="merchant-admin-grid">
            <view class="merchant-admin-item" hover-class="merchant-admin-item-hover" @click="gotoAfterSaleManage">
              <view class="merchant-admin-icon-wrapper">
                <uni-icons type="list" size="32" color="#2f54eb"></uni-icons>
              </view>
              <text class="merchant-admin-item-text">售后订单</text>
            </view>
            <view class="merchant-admin-item" hover-class="merchant-admin-item-hover" @click="gotoAccessoryOrderManage">
              <view class="merchant-admin-icon-wrapper">
                <uni-icons type="cart" size="32" color="#0f766e"></uni-icons>
              </view>
              <text class="merchant-admin-item-text">配件订单</text>
            </view>
            <view class="merchant-admin-item" hover-class="merchant-admin-item-hover" @click="gotoGoodsManage">
              <view class="merchant-admin-icon-wrapper">
                <uni-icons type="shop" size="32" color="#fa8c16"></uni-icons>
              </view>
              <text class="merchant-admin-item-text">商品管理</text>
            </view>
            <view class="merchant-admin-item" hover-class="merchant-admin-item-hover" @click="gotoShopSetting">
              <view class="merchant-admin-icon-wrapper">
                <uni-icons type="settings" size="32" color="#722ed1"></uni-icons>
              </view>
              <text class="merchant-admin-item-text">店铺设置</text>
            </view>
          </view>
        </view>
        <button class="merchant-admin-close-btn" @click="closeMerchantAdmin">关闭</button>
      </view>
    </view>
  </view>
</template>

<script>
import { getInfo, logout as appLogout } from '@/api/login'
import { getCurrentMerchantInfo } from '@/api/merchant'
import { getToken, removeToken } from '@/utils/auth'
import { resetDefaultTabBar, syncRoleTabBar } from '@/utils/tabbar'

export default {
  data() {
    return {
      loading: true,
      isLoading: false,
      isLogin: false,
      avatar: '/static/images/avatar.png',
      nickname: '游客用户',
      role: 'user',
      roleLabel: '普通用户',
      isPendingMerchant: false,
      merchantInfo: null,
      showStatModal: false,
      showMerchantAdminModal: false,
      pendingCount: 0,
      auditCount: 0,
      statData: {
        todayPending: 8,
        todayFinished: 24,
        monthTotal: 326,
        typeRatio: [
          { name: '退货', ratio: '45%', color: '#2f54eb' },
          { name: '换货', ratio: '30%', color: '#fa8c16' },
          { name: '退款', ratio: '25%', color: '#52c41a' }
        ],
        weekTrend: [
          { date: '周一', value: 12 },
          { date: '周二', value: 18 },
          { date: '周三', value: 15 },
          { date: '周四', value: 22 },
          { date: '周五', value: 19 },
          { date: '周六', value: 8 },
          { date: '周日', value: 10 }
        ]
      },
      PAGE_PATH: {
        INDEX: '/pages/index/index',
        ACCESSORY_ORDER: '/pages/accessoryOrder/index',
        MERCHANT_ACCESSORY_ORDER: '/pages/merchantAccessoryOrder/index',
        AFTER_SALE_ORDER: '/pages/afterSaleOrder/index',
        AFTER_SALE_APPLY: '/pages/applyAfterSale/index',
        PROFILE: '/pages/profile/index',
        LOGIN: '/pages/profile/login',
        ADDRESS: '/pages/address/index',
        MERCHANT_PENDING_ORDER: '/pages/afterSaleOrder/index?type=pending&audit=1&role=merchant',
        MERCHANT_AFTER_SALE_ORDER: '/pages/afterSaleOrder/index?type=all&audit=1&role=merchant',
        ACCESSORY_MALL: '/pages/accessoryMall/index',
        SHOP_SETTING: '/pages/merchant/shopSetting/index'
      },
      defaultAddress: null
    }
  },
  computed: {
    showMerchantModules() {
      return this.isLogin && this.role === 'merchant' && !this.isPendingMerchant
    },
    pendingMerchantMessage() {
      const merchantName = this.merchantInfo && this.merchantInfo.merchantName
      if (merchantName) {
        return `已提交 ${merchantName} 的入驻资料，审核通过前可继续按普通用户模式使用小程序。`
      }
      return '已提交商家入驻资料，审核通过前可继续按普通用户模式使用小程序。'
    }
  },
  async onShow() {
    this.loading = true;
    await this.syncUserState();
    this.loadDefaultAddress();
    this.loading = false;
  },
  methods: {
    navigateToPage(url) {
      wx.navigateTo({
        url,
        fail: () => {
          wx.showToast({
            title: '页面跳转失败',
            icon: 'none'
          })
        }
      })
    },
    async syncUserState() {
      const token = getToken();
      const localUserInfo = wx.getStorageSync('userInfo');
      if (!token || !localUserInfo) {
        this.resetGuestState();
        return;
      }

      try {
        const res = await getInfo();
        const remoteUser = res.data || {};
        const latestRoleType = String(remoteUser.roleType || localUserInfo.roleType || '1');
        let merchantInfo = localUserInfo.merchant || null;
        if (latestRoleType === '2') {
          try {
            const merchantRes = await getCurrentMerchantInfo();
            merchantInfo = merchantRes.data || merchantInfo;
          } catch (merchantErr) {
            merchantInfo = localUserInfo.merchant || null;
          }
        }
        const mergedUserInfo = this.mergeUserInfo(localUserInfo, remoteUser, merchantInfo);
        wx.setStorageSync('userInfo', mergedUserInfo);
        syncRoleTabBar(mergedUserInfo)
        this.applyUserState(mergedUserInfo);
      } catch (err) {
        if (!wx.getStorageSync('token')) {
          this.resetGuestState();
          return;
        }
        this.applyUserState(localUserInfo);
      }
    },
    getRoleMeta(roleType) {
      const normalizedRoleType = String(roleType || '1');
      return {
        roleType: normalizedRoleType,
        role: normalizedRoleType === '2' ? 'merchant' : 'user',
        roleLabel: normalizedRoleType === '2'
          ? '商家用户'
          : (normalizedRoleType === '0' ? '待审核商家' : '普通用户'),
        isPendingMerchant: normalizedRoleType === '0'
      };
    },
    mergeUserInfo(localUserInfo, remoteUser, merchantInfo) {
      const roleMeta = this.getRoleMeta(remoteUser.roleType || localUserInfo.roleType || '1');
      const nickname = remoteUser.nickName || remoteUser.nickname || localUserInfo.nickname || localUserInfo.nickName || remoteUser.phone || localUserInfo.phone || '未知用户';

      return {
        ...localUserInfo,
        ...remoteUser,
        roleType: roleMeta.roleType,
        role: roleMeta.role,
        roleLabel: roleMeta.roleLabel,
        isPendingMerchant: roleMeta.isPendingMerchant,
        merchant: typeof merchantInfo === 'undefined' ? (localUserInfo.merchant || null) : merchantInfo,
        nickName: nickname,
        nickname,
        avatar: localUserInfo.avatar || '/static/images/avatar.png'
      };
    },
    applyUserState(userInfo) {
      if (!getToken() || !userInfo) {
        this.resetGuestState();
        return;
      }
      const roleMeta = this.getRoleMeta(userInfo.roleType || '1');
      this.isLogin = true;
      this.nickname = userInfo.nickname || userInfo.nickName || userInfo.phone || '未知用户';
      this.role = roleMeta.role;
      this.roleLabel = userInfo.roleLabel || roleMeta.roleLabel;
      this.isPendingMerchant = typeof userInfo.isPendingMerchant === 'boolean' ? userInfo.isPendingMerchant : roleMeta.isPendingMerchant;
      this.merchantInfo = userInfo.merchant || null;
      this.avatar = userInfo.avatar || '/static/images/avatar.png';
      syncRoleTabBar(userInfo)
    },
    updateUserInfo(patch) {
      const userInfo = wx.getStorageSync('userInfo') || {};
      const nextUserInfo = {
        ...userInfo,
        ...patch
      };

      if (patch.nickname || patch.nickName) {
        const nickname = patch.nickname || patch.nickName;
        nextUserInfo.nickname = nickname;
        nextUserInfo.nickName = nickname;
      }

      wx.setStorageSync('userInfo', nextUserInfo);
      this.applyUserState(nextUserInfo);
    },
    resetGuestState() {
      this.isLogin = false;
      this.avatar = '/static/images/avatar.png';
      this.nickname = '游客用户';
      this.role = 'user';
      this.roleLabel = '普通用户';
      this.isPendingMerchant = false;
      this.merchantInfo = null;
      this.showStatModal = false;
      this.showMerchantAdminModal = false;
      resetDefaultTabBar()
    },
    loadDefaultAddress() {
      const addressList = wx.getStorageSync('addressList') || [];
      this.defaultAddress = addressList.find(item => item.isDefault) || null;
    },
    goLoginPage() {
      this.navigateToPage(this.PAGE_PATH.LOGIN)
    },
    logout() {
      wx.showModal({
        title: '确认退出',
        content: '是否退出当前账号？',
        success: async (res) => {
          if (res.confirm) {
            try {
              await appLogout();
            } catch (err) {
              // Even if server logout fails, we still clear the local session.
            } finally {
              removeToken();
              wx.removeStorageSync('userInfo');
              this.resetGuestState();
              wx.showToast({ title: '退出成功', icon: 'success' });
              setTimeout(() => {
                wx.switchTab({
                  url: this.PAGE_PATH.INDEX
                });
              }, 500);
            }
          }
        }
      });
    },
    editProfile() {
      wx.showActionSheet({
        itemList: ['更换头像', '修改昵称', '修改资料'],
        success: (res) => {
          switch (res.tapIndex) {
            case 0:
              this.chooseAvatar();
              break;
            case 1:
              wx.showModal({
                title: '修改昵称',
                content: '',
                editable: true,
                placeholderText: '请输入新昵称',
                success: (modalRes) => {
                  if (modalRes.confirm) {
                    const newNickname = modalRes.content?.trim();
                    if (!newNickname) {
                      wx.showToast({ title: '昵称不能为空', icon: 'none' });
                      return;
                    }
                    this.updateUserInfo({
                      nickname: newNickname
                    });
                    wx.showToast({ title: '昵称修改成功', icon: 'success' });
                  }
                }
              });
              break;
            case 2:
              wx.showToast({ title: '修改资料功能开发中', icon: 'none' });
              break;
          }
        }
      });
    },
    chooseAvatar() {
      wx.chooseImage({
        count: 1,
        sizeType: ['original', 'compressed'],
        sourceType: ['album', 'camera'],
        success: (res) => {
          this.updateUserInfo({
            avatar: res.tempFilePaths[0]
          });
          wx.showToast({ title: '头像更换成功', icon: 'success' });
        },
        fail: () => {
          wx.showToast({ title: '头像选择取消', icon: 'none' });
        }
      });
    },
    goOrder(type) {
      const url = `${this.PAGE_PATH.ACCESSORY_ORDER}?type=${type}`;
      this.navigateToPage(url)
    },
    goAudit(type) {
      const url = `${this.PAGE_PATH.AFTER_SALE_ORDER}?type=${type}&audit=1&role=merchant`;
      this.navigateToPage(url)
    },
    goAccessoryOrder(type) {
      const url = `${this.PAGE_PATH.MERCHANT_ACCESSORY_ORDER}?type=${type}`
      this.navigateToPage(url)
    },
    goAfterSaleHistory() {
      this.navigateToPage(`${this.PAGE_PATH.AFTER_SALE_ORDER}?type=all&role=user`)
    },
    goMerchantStat() {
      if (!this.showMerchantModules) {
        return;
      }
      this.showStatModal = true;
    },
    closeStatPopup() {
      this.showStatModal = false;
    },
    openMerchantAdmin() {
      if (!this.showMerchantModules) {
        return;
      }
      this.showMerchantAdminModal = true;
    },
    closeMerchantAdmin() {
      this.showMerchantAdminModal = false;
    },
    gotoAfterSaleManage() {
      this.closeMerchantAdmin();
      this.navigateToPage(this.PAGE_PATH.MERCHANT_AFTER_SALE_ORDER)
    },
    gotoAccessoryOrderManage() {
      this.closeMerchantAdmin();
      this.navigateToPage(`${this.PAGE_PATH.MERCHANT_ACCESSORY_ORDER}?type=pending`)
    },
    gotoGoodsManage() {
      this.closeMerchantAdmin();
      setTimeout(() => {
        wx.switchTab({ url: this.PAGE_PATH.ACCESSORY_MALL });
      }, 100);
    },
    gotoShopSetting() {
      this.closeMerchantAdmin();
      this.navigateToPage(this.PAGE_PATH.SHOP_SETTING)
    },
    goAddress() {
      this.navigateToPage(this.PAGE_PATH.ADDRESS)
    },
    goService() {
      wx.showModal({
        title: '客服中心',
        content: '客服电话：400-123-4567\n工作时间：9:00-18:00',
        showCancel: false
      });
    }
  }
}
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
  --red: #ff3b30;
  --green: #52c41a;
  --orange: #fa8c16;
  --border-color: #eee;
  --radius-sm: 8rpx;
  --radius-md: 12rpx;
  --radius-lg: 16rpx;
  --radius-full: 999rpx;
  --shadow: 0 4rpx 12rpx rgba(0, 0, 0, 0.05);
  --transition: all 0.3s ease;
}

.profile-page {
  min-height: 100vh;
  background-color: var(--bg-color);
  padding: 0;
  box-sizing: border-box;
  position: relative;
}

.loading {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 150rpx 0;
}

.loading-icon {
  animation: spin 1s linear infinite;
  margin-bottom: 20rpx;
}

.loading-text {
  font-size: 28rpx;
  color: var(--text-gray);
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.login-content {
  padding: 0;
}

.profile-header {
  background: linear-gradient(135deg, var(--primary-color) 0%, #409eff 100%);
  padding: 60rpx 30rpx 40rpx;
  border-radius: 0 0 var(--radius-lg) var(--radius-lg);
  margin-bottom: 20rpx;
  display: flex;
  align-items: center;
  color: var(--white);
  position: relative;
  box-shadow: var(--shadow);
}

.avatar {
  width: 120rpx;
  height: 120rpx;
  border-radius: 50%;
  border: 3px solid rgba(255, 255, 255, 0.5);
  margin-right: 30rpx;
}

.info {
  flex: 1;
}

.nickname {
  font-size: 36rpx;
  font-weight: bold;
  display: block;
  margin-bottom: 10rpx;
}

.desc {
  font-size: 28rpx;
  opacity: 0.8;
}

.edit-icon {
  position: absolute;
  right: 30rpx;
  top: 50%;
  transform: translateY(-50%);
}

.section {
  background: var(--white);
  border-radius: var(--radius-lg);
  margin: 0 20rpx 20rpx;
  box-shadow: var(--shadow);
  overflow: hidden;
}

.section-header {
  display: flex;
  gap: 16rpx;
  justify-content: flex-end;
  align-items: center;
  padding: 30rpx;
  border-bottom: 1px solid var(--border-color);
}

.section-title {
  margin-right: auto;
  font-size: 30rpx;
  font-weight: 600;
  color: var(--text-color);
}

.pending-merchant-section {
  padding: 28rpx 30rpx;
  background: linear-gradient(135deg, #fff7e6 0%, #fff1d6 100%);
}

.pending-merchant-head {
  display: flex;
  align-items: center;
  margin-bottom: 12rpx;
}

.pending-merchant-title {
  margin-left: 12rpx;
  font-size: 30rpx;
  font-weight: 600;
  color: #d97706;
}

.pending-merchant-desc {
  font-size: 26rpx;
  line-height: 1.7;
  color: #7c5a11;
}

.more {
  font-size: 26rpx;
  color: var(--text-gray);
  transition: var(--transition);
}

.more:active {
  color: var(--primary-color);
}

.order-grid {
  display: flex;
  padding: 40rpx 30rpx;
  justify-content: space-around;
}

.order-item {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  position: relative;
	padding: 15rpx 10rpx;
  border-radius: var(--radius-lg);
  margin: 0 10rpx;
  min-width: 100rpx;
  min-height: 120rpx;
  transition: var(--transition);
}

.order-item-hover {
  background-color: var(--light-primary);
  border-radius: var(--radius-lg);
}

.order-icon-wrapper {
  width: 72rpx;
  height: 72rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 15rpx;
  background-color: var(--light-primary);
  border-radius: var(--radius-full);
  z-index: 1;
}

.order-icon {
  display: inline-block !important;
}

.order-text {
  font-size: 28rpx;
  color: var(--text-light);
  margin-top: 10rpx;
  font-weight: 500;
  text-align: center;
}

.menu-list {
  padding: 10rpx 0;
}

.menu-item {
  display: flex;
  align-items: center;
  padding: 30rpx;
  border-bottom: 1px solid var(--border-color);
  transition: var(--transition);
}

.menu-item:last-child {
  border-bottom: none;
}

.menu-item-hover {
  background-color: var(--light-primary);
}

.menu-item.danger {
  color: var(--red);
}

.menu-icon-wrapper {
  width: 56rpx;
  height: 56rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-right: 20rpx;
  background-color: var(--light-primary);
  border-radius: var(--radius-full);
  z-index: 1;
}

.menu-item.danger .menu-icon-wrapper {
  background-color: var(--light-primary);
}

.menu-item.danger .menu-icon {
  color: var(--red) !important;
  display: inline-block !important;
}

.menu-icon {
  display: inline-block !important;
}

.menu-content {
  flex: 1;
  display: flex;
  flex-direction: column;
}

.default-address {
  font-size: 24rpx;
  color: #999;
  margin-top: 5rpx;
  max-width: 400rpx;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.menu-text {
  flex: 1;
  font-size: 30rpx;
  color: var(--text-color);
}

.menu-arrow {
  color: var(--text-gray);
}

.login-register-wrap {
  padding: 40rpx 30rpx;
}

.tab-wrap {
  display: flex;
  margin-bottom: 40rpx;
  border-radius: var(--radius-md);
  background: var(--white);
  box-shadow: var(--shadow);
}

.tab-item {
  flex: 1;
  text-align: center;
  padding: 20rpx 0;
  font-size: 32rpx;
  color: var(--text-light);
  position: relative;
  transition: var(--transition);
}

.tab-item-hover {
  background-color: var(--light-primary);
}

.tab-item.active {
  color: var(--primary-color);
  font-weight: 600;
}

.tab-item.active::after {
  content: '';
  position: absolute;
  bottom: 0;
  left: 50%;
  transform: translateX(-50%);
  width: 80rpx;
  height: 4rpx;
  background: var(--primary-color);
  border-radius: 2rpx;
}

.form-wrap {
  background: var(--white);
  padding: 40rpx;
  border-radius: var(--radius-lg);
  box-shadow: var(--shadow);
}

.input-item {
  display: flex;
  align-items: center;
  border-bottom: 1px solid var(--border-color);
  padding: 20rpx 0;
  margin-bottom: 10rpx;
  transition: border-color 0.3s;
}

.input-item.focused {
  border-bottom-color: var(--primary-color);
}

.input-icon-wrapper {
  width: 48rpx;
  height: 48rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-right: 20rpx;
}

.input {
  flex: 1;
  font-size: 28rpx;
  color: var(--text-color);
  height: 40rpx;
  line-height: 40rpx;
}

.input::placeholder {
  color: var(--text-gray);
}

.error-tip {
  font-size: 24rpx;
  color: #f56c6c;
  margin-bottom: 20rpx;
  padding-left: 60rpx;
  line-height: 1.4;
}

.role-wrap {
  display: flex;
  margin: 30rpx 0;
}

.role-item {
  flex: 1;
  text-align: center;
  padding: 20rpx 15rpx;
  border: 1px solid var(--border-color);
  border-radius: var(--radius-md);
  margin: 0 10rpx;
  font-size: 28rpx;
  color: var(--text-light);
  transition: var(--transition);
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8rpx;
}

.role-item-hover {
  background-color: var(--light-primary);
}

.role-item.active {
  border-color: var(--primary-color);
  color: var(--primary-color);
  background: var(--light-primary);
  font-weight: 600;
}

.role-icon-wrapper {
  display: flex;
  align-items: center;
  justify-content: center;
}

.submit-btn {
  width: 100%;
  height: 88rpx;
  line-height: 88rpx;
  background: var(--primary-color);
  color: var(--white);
  border-radius: var(--radius-full);
  font-size: 32rpx;
  margin-top: 20rpx;
  border: none;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 10rpx;
  transition: var(--transition);
  box-shadow: var(--shadow);
}

.submit-btn.disabled {
  background: var(--text-gray);
  color: var(--white);
}

.submit-btn:active:not(.disabled) {
  background: #1e42c8;
  transform: scale(0.98);
}

.stat-popup {
  width: 700rpx;
  background: #fff;
  border-radius: 20rpx;
  overflow: hidden;
  box-shadow: 0 10rpx 40rpx rgba(0, 0, 0, 0.15);
}

.modal-mask {
  position: fixed;
  inset: 0;
  background: rgba(0, 0, 0, 0.45);
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 32rpx;
  z-index: 999;
  box-sizing: border-box;
}

.stat-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 30rpx;
  border-bottom: 1px solid #f0f0f0;
  background: #f8f9fa;
}

.stat-title {
  font-size: 36rpx;
  font-weight: 700;
  color: #333;
}

.stat-close {
  width: 56rpx;
  height: 56rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 50%;
  background: #e9ecef;
}

.stat-content {
  padding: 40rpx 30rpx;
}

.stat-overview {
  display: flex;
  gap: 20rpx;
  margin-bottom: 40rpx;
}

.stat-card {
  flex: 1;
  padding: 30rpx 15rpx;
  background: linear-gradient(135deg, #f0f5ff 0%, #e6f0ff 100%);
  border-radius: 16rpx;
  text-align: center;
}

.stat-card-label {
  font-size: 28rpx;
  color: #666;
  display: block;
  margin-bottom: 10rpx;
}

.stat-card-value {
  font-size: 42rpx;
  font-weight: 700;
  color: #2f54eb;
}

.stat-section {
  margin-bottom: 40rpx;
}

.stat-subtitle {
  font-size: 32rpx;
  font-weight: 600;
  color: #333;
  margin-bottom: 20rpx;
  display: block;
}

.stat-chart {
  display: flex;
  flex-direction: column;
  gap: 20rpx;
}

.chart-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 15rpx 0;
}

.chart-item-left {
  display: flex;
  align-items: center;
  gap: 20rpx;
}

.chart-color {
  width: 32rpx;
  height: 32rpx;
  border-radius: 8rpx;
}

.chart-name {
  font-size: 30rpx;
  color: #555;
}

.chart-ratio {
  font-size: 30rpx;
  font-weight: 600;
  color: #333;
}

.trend-list {
  display: flex;
  justify-content: space-between;
  align-items: flex-end;
  height: 240rpx;
  padding: 20rpx 0;
  border-top: 1px solid #f0f0f0;
}

.trend-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  width: 80rpx;
}

.trend-date {
  font-size: 26rpx;
  color: #888;
  margin-bottom: 10rpx;
}

.trend-bar {
  width: 36rpx;
  border-radius: 6rpx 6rpx 0 0;
  margin-bottom: 10rpx;
}

.trend-value {
  font-size: 26rpx;
  color: #333;
  font-weight: 500;
}

.stat-close-btn {
  width: 100%;
  height: 90rpx;
  line-height: 90rpx;
  background: #2f54eb;
  color: #fff;
  border: none;
  font-size: 34rpx;
  font-weight: 600;
  border-radius: 0 0 20rpx 20rpx;
}

.merchant-admin-popup {
  width: 700rpx;
  background: #fff;
  border-radius: 20rpx;
  overflow: hidden;
  box-shadow: 0 10rpx 40rpx rgba(0, 0, 0, 0.15);
}

.merchant-admin-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 30rpx;
  border-bottom: 1px solid #f0f0f0;
  background: #f8f9fa;
}

.merchant-admin-title {
  font-size: 36rpx;
  font-weight: 700;
  color: #333;
}

.merchant-admin-close {
  width: 56rpx;
  height: 56rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 50%;
  background: #e9ecef;
}

.merchant-admin-content {
  padding: 40rpx 30rpx;
}

.merchant-admin-grid {
  display: flex;
  flex-wrap: wrap;
  gap: 20rpx;
  justify-content: space-around;
}

.merchant-admin-item {
  width: 31%;
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 20rpx 10rpx;
  border-radius: 16rpx;
  background: #f8f9fa;
  transition: var(--transition);
}

.merchant-admin-item-hover {
  background: var(--light-primary);
  transform: scale(1.05);
}

.merchant-admin-icon-wrapper {
  width: 80rpx;
  height: 80rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #fff;
  border-radius: 50%;
  box-shadow: var(--shadow);
  margin-bottom: 15rpx;
}

.merchant-admin-item-text {
  font-size: 28rpx;
  color: #333;
  font-weight: 500;
  text-align: center;
}

.merchant-admin-close-btn {
  width: 100%;
  height: 90rpx;
  line-height: 90rpx;
  background: #2f54eb;
  color: #fff;
  border: none;
  font-size: 34rpx;
  font-weight: 600;
  border-radius: 0 0 20rpx 20rpx;
}

.guest-card {
  background: #fff;
  border-radius: 24rpx;
  box-shadow: 0 8rpx 24rpx rgba(0, 0, 0, 0.08);
  margin: 40rpx;
  padding: 80rpx 40rpx;
  display: flex;
  flex-direction: column;
  align-items: center;
  text-align: center;
}

.guest-avatar {
  width: 140rpx;
  height: 140rpx;
  border-radius: 50%;
  margin-bottom: 30rpx;
}

.guest-title {
  font-size: 36rpx;
  font-weight: 600;
  color: #333;
  margin-bottom: 16rpx;
}

.guest-desc {
  font-size: 28rpx;
  color: #999;
  line-height: 1.6;
  margin-bottom: 40rpx;
}
</style>
