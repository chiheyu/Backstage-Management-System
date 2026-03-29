<template>
  <view class="login-page">
    <view class="status-bar"></view>

    <!-- 美化后的标签栏 -->
    <view class="tab-wrap">
      <view 
        class="tab-item" 
        :class="{ active: currentTab === 'login' }"
        @tap="switchTab('login')"
      >
        登录
      </view>
      <view 
        class="tab-item" 
        :class="{ active: currentTab === 'register' }"
        @tap="switchTab('register')"
      >
        注册
      </view>
    </view>

    <!-- 登录表单 -->
    <view v-if="currentTab === 'login'" class="form-wrap card-animate">
      <view class="input-item" :class="{ focused: loginFocus.phone }">
        <uni-icons type="phone" size="26" color="#666"></uni-icons>
        <input 
          v-model="loginForm.phone" 
          placeholder="请输入手机号" 
          class="input"
          @focus="loginFocus.phone = true"
          @blur="loginFocus.phone = false; checkLoginForm()"
          type="number"
          maxlength="11"
        />
      </view>
      <view class="error-tip" v-if="loginErrors.phone">{{ loginErrors.phone }}</view>

      <view class="input-item" :class="{ focused: loginFocus.password }">
        <uni-icons type="locked" size="26" color="#666"></uni-icons>
        <input 
          :key="`login-password-${loginPasswordVisible ? 'plain' : 'secret'}`"
          v-model="loginForm.password" 
          :password="loginPasswordVisible ? false : true"
          placeholder="请输入密码（6-16位，字母+数字）" 
          class="input"
          @focus="loginFocus.password = true"
          @blur="loginFocus.password = false; checkLoginForm()"
          maxlength="16"
        />
        <uni-icons
          :type="loginPasswordVisible ? 'eye-slash' : 'eye'"
          size="24"
          color="#999"
          class="toggle-password"
          @tap="toggleLoginPassword"
        ></uni-icons>
      </view>
      <view class="error-tip" v-if="loginErrors.password">{{ loginErrors.password }}</view>

      <button 
        @tap="handleLogin" 
        class="submit-btn"
        :disabled="!isLoginFormValid || isLoading"
        :class="{ disabled: !isLoginFormValid || isLoading }"
      >
        <uni-icons v-if="isLoading" type="spinner-cycle" size="20" color="#fff" class="loading-icon"></uni-icons>
        {{ isLoading ? '登录中...' : '登录' }}
      </button>
    </view>

    <!-- 注册表单 -->
    <view v-else class="form-wrap card-animate">
      <view class="input-item" :class="{ focused: registerFocus.nickName }">
        <uni-icons type="person" size="26" color="#666"></uni-icons>
        <input 
          v-model="registerForm.nickName" 
          placeholder="请输入昵称（2-16位）" 
          class="input"
          @focus="registerFocus.nickName = true"
          @blur="registerFocus.nickName = false; checkRegisterForm()"
          maxlength="16"
        />
      </view>
      <view class="error-tip" v-if="registerErrors.nickName">{{ registerErrors.nickName }}</view>

      <view class="input-item" :class="{ focused: registerFocus.password }">
        <uni-icons type="locked" size="26" color="#666"></uni-icons>
        <input 
          :key="`register-password-${registerPasswordVisible ? 'plain' : 'secret'}`"
          v-model="registerForm.password" 
          :password="registerPasswordVisible ? false : true"
          placeholder="请输入密码（6-16位，字母+数字）" 
          class="input"
          @focus="registerFocus.password = true"
          @blur="registerFocus.password = false; checkRegisterForm()"
          maxlength="16"
        />
        <uni-icons
          :type="registerPasswordVisible ? 'eye-slash' : 'eye'"
          size="24"
          color="#999"
          class="toggle-password"
          @tap="toggleRegisterPassword"
        ></uni-icons>
      </view>
      <view class="error-tip" v-if="registerErrors.password">{{ registerErrors.password }}</view>

      <view class="input-item" :class="{ focused: registerFocus.phone }">
        <uni-icons type="phone" size="26" color="#666"></uni-icons>
        <input 
          v-model="registerForm.phone" 
          placeholder="请输入手机号" 
          class="input"
          @focus="registerFocus.phone = true"
          @blur="registerFocus.phone = false; checkRegisterForm()"
          type="number"
          maxlength="11"
        />
      </view>
      <view class="error-tip" v-if="registerErrors.phone">{{ registerErrors.phone }}</view>

      <view
        class="input-item"
        :class="{ focused: registerFocus.merchantName }"
        v-if="registerForm.role === 'merchant'"
      >
        <uni-icons type="shop" size="26" color="#666"></uni-icons>
        <input
          v-model="registerForm.merchantName"
          placeholder="请输入商家名称"
          class="input"
          @focus="registerFocus.merchantName = true"
          @blur="registerFocus.merchantName = false; checkRegisterForm()"
          maxlength="30"
        />
      </view>
      <view class="error-tip" v-if="registerErrors.merchantName">{{ registerErrors.merchantName }}</view>

      <view
        class="input-item"
        :class="{ focused: registerFocus.contactName }"
        v-if="registerForm.role === 'merchant'"
      >
        <uni-icons type="person" size="26" color="#666"></uni-icons>
        <input
          v-model="registerForm.contactName"
          placeholder="请输入联系人（选填）"
          class="input"
          @focus="registerFocus.contactName = true"
          @blur="registerFocus.contactName = false"
          maxlength="20"
        />
      </view>

      <view
        class="input-item"
        :class="{ focused: registerFocus.address }"
        v-if="registerForm.role === 'merchant'"
      >
        <uni-icons type="location" size="26" color="#666"></uni-icons>
        <input
          v-model="registerForm.address"
          placeholder="请输入商家地址（选填）"
          class="input"
          @focus="registerFocus.address = true"
          @blur="registerFocus.address = false"
          maxlength="60"
        />
      </view>

      <view
        class="input-item"
        :class="{ focused: registerFocus.serviceScope }"
        v-if="registerForm.role === 'merchant'"
      >
        <uni-icons type="location" size="26" color="#666"></uni-icons>
        <input
          v-model="registerForm.serviceScope"
          placeholder="请输入服务范围（选填）"
          class="input"
          @focus="registerFocus.serviceScope = true"
          @blur="registerFocus.serviceScope = false"
          maxlength="60"
        />
      </view>

      <view class="input-item" :class="{ focused: registerFocus.code }">
        <uni-icons type="compose" size="26" color="#666"></uni-icons>
        <input
          v-model="registerForm.code"
          placeholder="请输入验证码"
          class="input"
          @focus="registerFocus.code = true"
          @blur="registerFocus.code = false; checkRegisterForm()"
          maxlength="6"
        />
        <button class="code-btn" @tap="handleSendCode" :disabled="isSendingCode">
          {{ isSendingCode ? `${countdownTime}s` : '获取验证码' }}
        </button>
      </view>
      <view class="error-tip" v-if="registerErrors.code">{{ registerErrors.code }}</view>

      <!-- 优化角色选择 -->
      <view class="role-wrap">
        <view 
          class="role-item" 
          :class="{ active: registerForm.role === 'user' }"
          @tap="changeRole('user')"
        >
          <uni-icons type="user" size="18" v-if="registerForm.role === 'user'"></uni-icons>
          普通用户
        </view>
        <view 
          class="role-item" 
          :class="{ active: registerForm.role === 'merchant' }"
          @tap="changeRole('merchant')"
        >
          <uni-icons type="shop" size="18" v-if="registerForm.role === 'merchant'"></uni-icons>
          商家用户
        </view>
      </view>

      <button 
        @tap="handleRegister" 
        class="submit-btn"
        :disabled="!isRegisterFormValid || isLoading"
        :class="{ disabled: !isRegisterFormValid || isLoading }"
      >
        <uni-icons v-if="isLoading" type="spinner-cycle" size="20" color="#fff" class="loading-icon"></uni-icons>
        {{ isLoading ? '注册中...' : '注册' }}
      </button>
    </view>
  </view>
</template>

<script>
import { login, register, sendCode } from '@/api/login'
import { setToken } from '@/utils/auth'
import { syncRoleTabBar } from '@/utils/tabbar'

export default {
  data() {
    return {
      currentTab: 'login',
      isLoading: false,
      isSendingCode: false,
      countdownTime: 60,
      countdownTimer: null,
      loginPasswordVisible: false,
      registerPasswordVisible: false,
      loginForm: {
        phone: '',
        password: ''
      },
      loginFocus: {
        phone: false,
        password: false
      },
      loginErrors: {},
      isLoginFormValid: false,
      registerForm: {
        nickName: '',
        password: '',
        phone: '',
        merchantName: '',
        contactName: '',
        address: '',
        serviceScope: '',
        code: '',
        role: 'user'
      },
      registerFocus: {
        nickName: false,
        password: false,
        phone: false,
        merchantName: false,
        contactName: false,
        address: false,
        serviceScope: false,
        code: false
      },
      registerErrors: {},
      isRegisterFormValid: false
    }
  },
  onUnload() {
    clearInterval(this.countdownTimer)
  },
  methods: {
    switchTab(tab) {
      this.currentTab = tab;
      this.loginErrors = {};
      this.registerErrors = {};
      this.loginPasswordVisible = false;
      this.registerPasswordVisible = false;
    },
    toggleLoginPassword() {
      this.loginPasswordVisible = !this.loginPasswordVisible;
    },
    toggleRegisterPassword() {
      this.registerPasswordVisible = !this.registerPasswordVisible;
    },
    changeRole(role) {
      this.registerForm.role = role;
      if (role !== 'merchant') {
        this.registerForm.merchantName = '';
        this.registerForm.contactName = '';
        this.registerForm.address = '';
        this.registerForm.serviceScope = '';
      }
      this.checkRegisterForm();
      uni.showToast({
        title: `已选择${role === 'user' ? '普通用户' : '商家用户'}`,
        icon: 'none',
        duration: 1500
      });
    },
    startCountdown() {
      this.isSendingCode = true
      this.countdownTime = 60
      this.countdownTimer = setInterval(() => {
        this.countdownTime--
        if (this.countdownTime <= 0) {
          clearInterval(this.countdownTimer)
          this.isSendingCode = false
        }
      }, 1000)
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
    validateNickName(value) {
      if (!value) return '请输入昵称';
      if (value.length < 2 || value.length > 16) return '昵称长度需在2-16位之间';
      return '';
    },
    validatePassword(value) {
      if (!value) return '请输入密码';
      if (value.length < 6 || value.length > 16) return '密码长度需在6-16位之间';
      if (!/(?=.*[a-zA-Z])(?=.*\d)/.test(value)) return '密码需包含字母和数字';
      return '';
    },
    validatePhone(value) {
      if (!value) return '请输入手机号';
      if (!/^1[3-9]\d{9}$/.test(value)) return '请输入正确的手机号';
      return '';
    },
    validateCode(value) {
      if (!value) return '请输入验证码';
      if (!/^\d{6}$/.test(value)) return '验证码应为6位数字';
      return '';
    },
    validateMerchantName(value) {
      if (this.registerForm.role !== 'merchant') return '';
      if (!value) return '请输入商家名称';
      return '';
    },
    checkLoginForm() {
      const { phone, password } = this.loginForm;
      const phoneErr = this.validatePhone(phone);
      const passwordErr = this.validatePassword(password);

      this.loginErrors = {
        phone: phoneErr,
        password: passwordErr
      };

      this.isLoginFormValid = !phoneErr && !passwordErr;
    },
    checkRegisterForm() {
      const { nickName, password, phone, merchantName, code } = this.registerForm;
      const nickNameErr = this.validateNickName(nickName);
      const passwordErr = this.validatePassword(password);
      const phoneErr = this.validatePhone(phone);
      const merchantNameErr = this.validateMerchantName(merchantName);
      const codeErr = this.validateCode(code);

      this.registerErrors = {
        nickName: nickNameErr,
        password: passwordErr,
        phone: phoneErr,
        merchantName: merchantNameErr,
        code: codeErr
      };

      this.isRegisterFormValid = !nickNameErr && !passwordErr && !phoneErr && !merchantNameErr && !codeErr;
    },
    saveAuthState(data, fallbackPhone) {
      const appUser = data.appUser || {};
      const roleMeta = this.getRoleMeta(data.roleType || appUser.roleType || '1');
      const nickName = appUser.nickName || appUser.phone || fallbackPhone;
      const cachedUserInfo = uni.getStorageSync('userInfo') || {};

      setToken(data.token);
      uni.setStorageSync('userInfo', {
        ...cachedUserInfo,
        ...appUser,
        nickName,
        nickname: nickName,
        roleType: roleMeta.roleType,
        role: roleMeta.role,
        roleLabel: roleMeta.roleLabel,
        isPendingMerchant: roleMeta.isPendingMerchant,
        merchant: data.merchant || cachedUserInfo.merchant || null,
        avatar: cachedUserInfo.avatar || '/static/images/avatar.png'
      });
      syncRoleTabBar(uni.getStorageSync('userInfo') || {})
    },
    async handleLogin() {
      this.checkLoginForm();
      if (!this.isLoginFormValid) {
        uni.showToast({ title: '请完善表单信息', icon: 'none' });
        return;
      }

      this.isLoading = true;

      try {
        const res = await login(this.loginForm.phone, this.loginForm.password);
        const data = res.data || {};

        if (!data.token) {
          uni.showToast({ title: '登录返回缺少 token', icon: 'none' });
          return;
        }

        this.saveAuthState(data, this.loginForm.phone);

        uni.showToast({ title: '登录成功！', icon: 'success' });
        setTimeout(() => {
          uni.switchTab({ url: '/pages/profile/index' });
        }, 1500);
      } catch (err) {
        uni.showToast({
          title: (err && err.msg) || '登录失败',
          icon: 'none'
        });
      } finally {
        this.isLoading = false;
      }
    },
    async handleSendCode() {
      const phoneErr = this.validatePhone(this.registerForm.phone);
      this.registerErrors = {
        ...this.registerErrors,
        phone: phoneErr
      };
      if (phoneErr) {
        uni.showToast({ title: phoneErr, icon: 'none' });
        return;
      }

      this.startCountdown()
      try {
        const res = await sendCode(this.registerForm.phone);
        const smsCode = res.smsCode || '';
        if (smsCode) {
          this.registerForm.code = smsCode;
          this.checkRegisterForm();
          uni.showToast({
            title: `验证码：${smsCode}`,
            icon: 'none',
            duration: 2500
          });
        } else {
          uni.showToast({
            title: res.msg || '验证码已发送',
            icon: 'none'
          });
        }
      } catch (err) {
        uni.showToast({
          title: (err && err.msg) || '验证码发送失败',
          icon: 'none'
        });
        clearInterval(this.countdownTimer)
        this.isSendingCode = false
      }
    },
    async handleRegister() {
      this.checkRegisterForm();
      if (!this.isRegisterFormValid) {
        uni.showToast({ title: '请完善表单信息', icon: 'none' });
        return;
      }

      this.isLoading = true;
      try {
        const payload = {
          phone: this.registerForm.phone,
          password: this.registerForm.password,
          confirmPassword: this.registerForm.password,
          nickName: this.registerForm.nickName,
          code: this.registerForm.code,
          roleType: this.registerForm.role === 'merchant' ? '2' : '1',
          merchantName: this.registerForm.role === 'merchant' ? this.registerForm.merchantName : '',
          contactName: this.registerForm.role === 'merchant' ? this.registerForm.contactName : '',
          address: this.registerForm.role === 'merchant' ? this.registerForm.address : '',
          serviceScope: this.registerForm.role === 'merchant' ? this.registerForm.serviceScope : ''
        };

        const res = await register(payload);
        const data = res.data || {};

        if (!data.token) {
          this.loginForm.phone = this.registerForm.phone;
          this.loginForm.password = this.registerForm.password;
          this.currentTab = 'login';
          this.loginErrors = {};
          uni.showToast({ title: '注册成功，请使用新账号登录', icon: 'success' });
          return;
        }

        this.saveAuthState(data, this.registerForm.phone);
        const roleMeta = this.getRoleMeta(data.roleType || (data.appUser && data.appUser.roleType) || '1');
        uni.showToast({
          title: roleMeta.isPendingMerchant ? '入驻申请已提交，等待审核' : '注册成功！',
          icon: 'success'
        });
        setTimeout(() => {
          uni.switchTab({ url: '/pages/profile/index' });
        }, 1500);
      } catch (err) {
        const errMsg = (err && err.msg) || ''
        if (errMsg.includes('手机号或密码错误') || errMsg.includes('用户不存在')) {
          this.loginForm.phone = this.registerForm.phone;
          this.loginForm.password = this.registerForm.password;
          this.currentTab = 'login';
          this.loginErrors = {};
          uni.showToast({
            title: '注册成功，请使用新账号登录',
            icon: 'success'
          });
          return;
        }
        uni.showToast({
          title: errMsg || '注册失败',
          icon: 'none'
        });
      } finally {
        this.isLoading = false;
      }
    }
  }
}
</script>

<style scoped>
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
  -webkit-tap-highlight-color: transparent;
}

page {
  background: #f6f7f9;
  height: 100%;
}

.status-bar {
  height: var(--status-bar-height);
  background: #ffffff;
}

.login-page {
  padding: 60rpx 40rpx;
  min-height: 100vh;
  background: #f6f7f9;
}

/* -------------- 核心美化：登录/注册切换Tab -------------- */
.tab-wrap {
  display: flex;
  margin: 0 auto 60rpx;
  width: 400rpx;
  background: #ffffff;
  border-radius: 999rpx;
  box-shadow: 0 8rpx 24rpx rgba(0, 0, 0, 0.06);
  overflow: hidden;
}

.tab-item {
  flex: 1;
  text-align: center;
  padding: 26rpx 0;
  font-size: 32rpx;
  color: #666666;
  font-weight: 500;
  transition: all 0.3s ease;
  border-radius: 999rpx;
  background: transparent;
}

.tab-item.active {
  background: #2f54eb;
  color: #ffffff;
  font-weight: 600;
}
/* ------------------------------------------------------ */

.form-wrap {
  background: #ffffff;
  padding: 48rpx;
  border-radius: 32rpx;
  box-shadow: 0 12rpx 32rpx rgba(0, 0, 0, 0.08);
  margin-bottom: 30rpx;
}

.card-animate {
  animation: formFade 0.4s ease forwards;
}

.input-item {
  display: flex;
  align-items: center;
  background: #f6f7f9;
  border-radius: 20rpx;
  padding: 28rpx 32rpx;
  margin-bottom: 24rpx;
  transition: all 0.3s ease;
  border: 2rpx solid transparent;
}

.input-item.focused {
  background: #ffffff;
  border-color: #2f54eb;
  box-shadow: 0 0 0 6rpx rgba(47, 84, 235, 0.1);
}

.input {
  flex: 1;
  margin-left: 24rpx;
  font-size: 30rpx;
  color: #1d2129;
  height: 44rpx;
  line-height: 44rpx;
  border: none;
  background: transparent;
}

.input::placeholder {
  color: #86909c;
}

.toggle-password {
  flex-shrink: 0;
  padding-left: 16rpx;
  transition: transform 0.2s ease;
}

.toggle-password:active {
  transform: scale(0.9);
}

.code-btn {
  flex-shrink: 0;
  margin-left: 20rpx;
  padding: 0 28rpx;
  height: 64rpx;
  line-height: 64rpx;
  border: none;
  border-radius: 32rpx;
  background: #2f54eb;
  color: #ffffff;
  font-size: 26rpx;
  font-weight: 500;
  transition: all 0.2s ease;
  box-shadow: 0 4rpx 12rpx rgba(47, 84, 235, 0.2);
}

.code-btn:active {
  transform: scale(0.96);
}

.code-btn[disabled] {
  background: #c9cdd4;
  box-shadow: none;
  transform: none;
}

.error-tip {
  font-size: 24rpx;
  color: #ff4d4f;
  margin: 0 0 20rpx 16rpx;
  line-height: 1.4;
}

.role-wrap {
  display: flex;
  margin: 48rpx 0 32rpx;
  gap: 24rpx;
}

.role-item {
  flex: 1;
  text-align: center;
  padding: 24rpx 20rpx;
  border: 2rpx solid #e5e6eb;
  border-radius: 20rpx;
  font-size: 30rpx;
  color: #666666;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8rpx;
  font-weight: 500;
}

.role-item.active {
  border-color: #2f54eb;
  color: #2f54eb;
  background: #f0f5ff;
  font-weight: 600;
  transform: translateY(-4rpx);
  box-shadow: 0 6rpx 16rpx rgba(47, 84, 235, 0.15);
}

.role-item:active {
  transform: scale(0.96);
}

.submit-btn {
  width: 100%;
  height: 88rpx;
  line-height: 88rpx;
  background: #2f54eb;
  color: #ffffff;
  border-radius: 44rpx;
  font-size: 34rpx;
  font-weight: 600;
  margin-top: 40rpx;
  border: none;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 12rpx;
  transition: all 0.3s ease;
  box-shadow: 0 8rpx 24rpx rgba(47, 84, 235, 0.3);
}

.submit-btn:active {
  transform: translateY(4rpx);
  box-shadow: 0 4rpx 12rpx rgba(47, 84, 235, 0.2);
}

.submit-btn.disabled {
  background: #c9cdd4;
  color: #ffffff;
  box-shadow: none;
  transform: none;
}

.loading-icon {
  animation: spin 1s linear infinite;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

@keyframes formFade {
  0% { opacity: 0; transform: translateY(20rpx); }
  100% { opacity: 1; transform: translateY(0); }
}
</style>