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
            <view class="stat-row" v-for="(row, rowIndex) in merchantStatRows" :key="rowIndex">
              <view class="stat-card" v-for="(item, itemIndex) in row" :key="`${rowIndex}-${itemIndex}`">
                <text class="stat-card-label">{{ item.label }}：</text>
                <text class="stat-card-value">{{ item.value }}</text>
              </view>
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
            <text class="stat-subtitle">近7天发货+售后量</text>
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
import { getCurrentMerchantInfo, getMerchantStats } from '@/api/merchant'
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
        todayPendingShipment: 0,
        todayShipped: 0,
        todayPendingAfterSale: 0,
        todayCompletedAfterSale: 0,
        monthTotal: 0,
        typeRatio: [],
        weekTrend: []
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
      return this.isLogin && this.role === 'merchant'
    },
    merchantStatCards() {
      return [
        { label: '今日待发货', value: this.statData.todayPendingShipment },
        { label: '今日已发货', value: this.statData.todayShipped },
        { label: '今日待售后', value: this.statData.todayPendingAfterSale },
        { label: '今日已售后', value: this.statData.todayCompletedAfterSale },
        { label: '本月总数', value: this.statData.monthTotal }
      ]
    },
    merchantStatRows() {
      const rows = []
      for (let i = 0; i < this.merchantStatCards.length; i += 2) {
        rows.push(this.merchantStatCards.slice(i, i + 2))
      }
      return rows
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
      const isMerchant = normalizedRoleType === '2' || normalizedRoleType === '0';
      return {
        roleType: isMerchant ? '2' : '1',
        role: isMerchant ? 'merchant' : 'user',
        roleLabel: isMerchant ? '商家用户' : '普通用户',
        isPendingMerchant: false
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
      this.fetchMerchantStatData();
    },
    async fetchMerchantStatData() {
      uni.showLoading({
        title: '加载中...',
        mask: true
      })

      try {
        const res = await getMerchantStats()
        const data = res.data || {}
        this.statData = {
          ...this.statData,
          todayPendingShipment: Number(data.todayPendingShipment || 0),
          todayShipped: Number(data.todayShipped || 0),
          todayPendingAfterSale: Number(data.todayPendingAfterSale || 0),
          todayCompletedAfterSale: Number(data.todayCompletedAfterSale || 0),
          monthTotal: Number(data.monthTotal || 0),
          typeRatio: Array.isArray(data.typeRatio) ? data.typeRatio : [],
          weekTrend: Array.isArray(data.weekTrend) ? data.weekTrend : []
        }
        this.showStatModal = true
      } catch (error) {
        uni.showToast({
          title: (error && error.msg) || '加载统计数据失败',
          icon: 'none'
        })
      } finally {
        uni.hideLoading()
      }
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
  --deep-light-primary: #e6f7ff;
  --text-primary: #1d2129;
  --text-secondary: #4e5969;
  --text-tertiary: #86909c;
  --bg-page: #f7f8fa;
  --bg-card: #ffffff;
  --border-color: #e5e6eb;
  --radius-sm: 12rpx;
  --radius-md: 16rpx;
  --radius-lg: 20rpx;
  --radius-full: 999rpx;
  --shadow-light: 0 2rpx 12rpx rgba(0, 0, 0, 0.06);
  --shadow-medium: 0 4rpx 16rpx rgba(0, 0, 0, 0.08);
  --transition: all 0.25s cubic-bezier(0.4, 0, 0.2, 1);
}

.profile-page {
  min-height: 100vh;
  background-color: var(--bg-page);
  box-sizing: border-box;
  position: relative;
  padding-bottom: 40rpx;
}

.loading {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 200rpx 0;
}

.loading-icon {
  animation: spin 1s linear infinite;
  margin-bottom: 24rpx;
}

.loading-text {
  font-size: 28rpx;
  color: var(--text-tertiary);
  font-weight: 500;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.profile-header {
  background: linear-gradient(135deg, #2f54eb 0%, #5b7bff 100%);
  padding: 80rpx 32rpx 60rpx;
  border-radius: 0 0 var(--radius-lg) var(--radius-lg);
  margin-bottom: 24rpx;
  display: flex;
  align-items: center;
  color: #fff;
  position: relative;
  box-shadow: var(--shadow-medium);
  transition: var(--transition);
}

.profile-header:active {
  opacity: 0.96;
}

.avatar {
  width: 130rpx;
  height: 130rpx;
  border-radius: 50%;
  border: 4rpx solid rgba(255, 255, 255, 0.6);
  margin-right: 32rpx;
  object-fit: cover;
}

.info {
  flex: 1;
}

.nickname {
  font-size: 40rpx;
  font-weight: 700;
  display: block;
  margin-bottom: 12rpx;
  letter-spacing: 1rpx;
}

.desc {
  font-size: 28rpx;
  opacity: 0.9;
  font-weight: 400;
}

.edit-icon {
  position: absolute;
  right: 32rpx;
  top: 50%;
  transform: translateY(-50%);
  transition: var(--transition);
}

.section {
  background: var(--bg-card);
  border-radius: var(--radius-lg);
  margin: 0 24rpx 24rpx;
  box-shadow: var(--shadow-light);
  overflow: hidden;
  transition: var(--transition);
}

.section:hover {
  box-shadow: var(--shadow-medium);
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 32rpx;
  border-bottom: 1rpx solid var(--border-color);
}

.section-title {
  font-size: 32rpx;
  font-weight: 600;
  color: var(--text-primary);
}

.pending-merchant-section {
  padding: 32rpx;
  background: linear-gradient(135deg, #fffbe6 0%, #fff1f0 100%);
  border: 1rpx solid #ffeeba;
}

.pending-merchant-head {
  display: flex;
  align-items: center;
  margin-bottom: 16rpx;
}

.pending-merchant-title {
  margin-left: 12rpx;
  font-size: 30rpx;
  font-weight: 600;
  color: #d46b00;
}

.pending-merchant-desc {
  font-size: 26rpx;
  line-height: 1.8;
  color: #946a00;
}

.more {
  font-size: 26rpx;
  color: var(--text-tertiary);
  transition: var(--transition);
  font-weight: 500;
}

.more:active {
  color: var(--primary-color);
  transform: translateX(4rpx);
}

.order-grid {
  display: flex;
  padding: 48rpx 32rpx;
  justify-content: space-around;
  gap: 24rpx;
}

.order-item {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 20rpx;
  border-radius: var(--radius-lg);
  transition: var(--transition);
  min-width: 120rpx;
}

.order-item-hover {
  background-color: var(--deep-light-primary);
  transform: translateY(-4rpx);
}

.order-icon-wrapper {
  width: 80rpx;
  height: 80rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 20rpx;
  background-color: var(--light-primary);
  border-radius: var(--radius-full);
  transition: var(--transition);
}

.order-item-hover .order-icon-wrapper {
  transform: scale(1.08);
}

.order-text {
  font-size: 28rpx;
  color: var(--text-secondary);
  font-weight: 500;
  text-align: center;
  white-space: nowrap;
}

.menu-list {
  padding: 0;
}

.menu-item {
  display: flex;
  align-items: center;
  padding: 32rpx;
  border-bottom: 1rpx solid var(--border-color);
  transition: var(--transition);
}

.menu-item:last-child {
  border-bottom: none;
}

.menu-item-hover {
  background-color: var(--light-primary);
  padding-left: 40rpx;
}

.menu-item.danger {
  color: #f53f3f;
}

.menu-icon-wrapper {
  width: 60rpx;
  height: 60rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-right: 24rpx;
  background-color: var(--light-primary);
  border-radius: var(--radius-full);
  transition: var(--transition);
}

.menu-item.danger .menu-icon-wrapper {
  background-color: #fff1f0;
}

.menu-content {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 8rpx;
}

.default-address {
  font-size: 24rpx;
  color: var(--text-tertiary);
  max-width: 420rpx;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.menu-text {
  flex: 1;
  font-size: 30rpx;
  color: var(--text-primary);
  font-weight: 500;
}

.menu-arrow {
  color: var(--text-tertiary);
  transition: var(--transition);
}

.menu-item-hover .menu-arrow {
  color: var(--primary-color);
  transform: translateX(4rpx);
}

.login-register-wrap {
  padding: 60rpx 32rpx;
}

.guest-card {
  background: var(--bg-card);
  border-radius: var(--radius-lg);
  box-shadow: var(--shadow-medium);
  margin: 40rpx 24rpx;
  padding: 100rpx 48rpx;
  display: flex;
  flex-direction: column;
  align-items: center;
  text-align: center;
  transition: var(--transition);
}

.guest-avatar {
  width: 160rpx;
  height: 160rpx;
  border-radius: 50%;
  margin-bottom: 40rpx;
  border: 4rpx solid var(--light-primary);
}

.guest-title {
  font-size: 40rpx;
  font-weight: 700;
  color: var(--text-primary);
  margin-bottom: 20rpx;
}

.guest-desc {
  font-size: 28rpx;
  color: var(--text-secondary);
  line-height: 1.7;
  margin-bottom: 60rpx;
  padding: 0 20rpx;
}

.submit-btn {
  width: 100%;
  height: 88rpx;
  line-height: 88rpx;
  background: var(--primary-color);
  color: #fff;
  border-radius: var(--radius-full);
  font-size: 32rpx;
  font-weight: 600;
  border: none;
  transition: var(--transition);
  box-shadow: var(--shadow-light);
}

.submit-btn:active {
  background: #274bdb;
  transform: scale(0.98);
  box-shadow: none;
}

.modal-mask {
  position: fixed;
  inset: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 40rpx;
  z-index: 999;
  box-sizing: border-box;
  animation: fadeIn 0.3s ease;
}

@keyframes fadeIn {
  from { opacity: 0; }
  to { opacity: 1; }
}

.stat-popup,
.merchant-admin-popup {
  width: 720rpx;
  background: var(--bg-card);
  border-radius: var(--radius-lg);
  overflow: hidden;
  box-shadow: 0 8rpx 40rpx rgba(0, 0, 0, 0.15);
  animation: scaleIn 0.3s ease;
}

@keyframes scaleIn {
  from { transform: scale(0.9); opacity: 0; }
  to { transform: scale(1); opacity: 1; }
}

.stat-header,
.merchant-admin-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 36rpx;
  border-bottom: 1rpx solid var(--border-color);
  background: #fafbfc;
}

.stat-title,
.merchant-admin-title {
  font-size: 36rpx;
  font-weight: 700;
  color: var(--text-primary);
}

.stat-close,
.merchant-admin-close {
  width: 60rpx;
  height: 60rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 50%;
  background: var(--light-primary);
  transition: var(--transition);
}

.stat-close:active,
.merchant-admin-close:active {
  transform: scale(0.9);
}

.stat-content,
.merchant-admin-content {
  padding: 48rpx 36rpx;
}

.stat-overview {
  display: flex;
  flex-direction: column;
  gap: 16rpx;
  margin-bottom: 40rpx;
}

.stat-row {
  display: flex;
  gap: 16rpx;
}

.stat-card {
  flex: 1;
  min-height: 88rpx;
  padding: 20rpx 24rpx;
  background: linear-gradient(135deg, var(--light-primary) 0%, var(--deep-light-primary) 100%);
  border-radius: var(--radius-md);
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.stat-card-label {
  font-size: 26rpx;
  color: var(--text-secondary);
  flex: 1;
  padding-right: 12rpx;
}

.stat-card-value {
  font-size: 34rpx;
  font-weight: 700;
  color: var(--primary-color);
}

.stat-section {
  margin-bottom: 48rpx;
}

.stat-subtitle {
  font-size: 32rpx;
  font-weight: 600;
  color: var(--text-primary);
  margin-bottom: 24rpx;
  display: block;
}

.stat-chart {
  display: flex;
  flex-direction: column;
  gap: 24rpx;
}

.chart-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16rpx 0;
}

.chart-item-left {
  display: flex;
  align-items: center;
  gap: 20rpx;
}

.chart-color {
  width: 32rpx;
  height: 32rpx;
  border-radius: var(--radius-sm);
}

.chart-name {
  font-size: 30rpx;
  color: var(--text-secondary);
  font-weight: 500;
}

.chart-ratio {
  font-size: 30rpx;
  font-weight: 600;
  color: var(--text-primary);
}

.trend-list {
  display: flex;
  justify-content: space-between;
  align-items: flex-end;
  height: 260rpx;
  padding: 24rpx 0;
  border-top: 1rpx solid var(--border-color);
}

.trend-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  width: 84rpx;
}

.trend-date {
  font-size: 26rpx;
  color: var(--text-tertiary);
  margin-bottom: 12rpx;
  font-weight: 500;
}

.trend-bar {
  width: 36rpx;
  border-radius: var(--radius-sm) var(--radius-sm) 0 0;
  margin-bottom: 12rpx;
  transition: var(--transition);
}

.trend-value {
  font-size: 26rpx;
  color: var(--text-primary);
  font-weight: 600;
}

.stat-close-btn,
.merchant-admin-close-btn {
  width: 100%;
  height: 90rpx;
  line-height: 90rpx;
  background: var(--primary-color);
  color: #fff;
  border: none;
  font-size: 34rpx;
  font-weight: 600;
  border-radius: 0 0 var(--radius-lg) var(--radius-lg);
  transition: var(--transition);
}

.stat-close-btn:active,
.merchant-admin-close-btn:active {
  background: #274bdb;
}

.merchant-admin-grid {
  display: flex;
  flex-wrap: wrap;
  gap: 24rpx;
  justify-content: space-between;
}

.merchant-admin-item {
  width: 30%;
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 32rpx 16rpx;
  border-radius: var(--radius-md);
  background: #f7f8fa;
  transition: var(--transition);
  margin-bottom: 16rpx;
}

.merchant-admin-item-hover {
  background: var(--light-primary);
  transform: translateY(-6rpx);
  box-shadow: var(--shadow-light);
}

.merchant-admin-icon-wrapper {
  width: 88rpx;
  height: 88rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  background: var(--bg-card);
  border-radius: 50%;
  box-shadow: var(--shadow-light);
  margin-bottom: 20rpx;
  transition: var(--transition);
}

.merchant-admin-item-hover .merchant-admin-icon-wrapper {
  transform: scale(1.08);
}

.merchant-admin-item-text {
  font-size: 28rpx;
  color: var(--text-primary);
  font-weight: 500;
  text-align: center;
  line-height: 1.4;
}
</style>
