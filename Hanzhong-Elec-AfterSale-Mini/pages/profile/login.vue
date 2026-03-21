<template>
  <view class="login-page">
    <view class="status-bar"></view>

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

    <view v-if="currentTab === 'login'" class="form-wrap">
      <view class="input-item" :class="{ focused: loginFocus.username }">
        <uni-icons type="person" size="24" color="#666"></uni-icons>
        <input 
          v-model="loginForm.username" 
          placeholder="请输入用户名（2-16位）" 
          class="input"
          @focus="loginFocus.username = true"
          @blur="loginFocus.username = false; checkLoginForm()"
          maxlength="16"
        />
      </view>
      <view class="error-tip" v-if="loginErrors.username">{{ loginErrors.username }}</view>

      <view class="input-item" :class="{ focused: loginFocus.password }">
        <uni-icons type="locked" size="24" color="#666"></uni-icons>
        <input 
          v-model="loginForm.password" 
          type="password" 
          placeholder="请输入密码（6-16位，字母+数字）" 
          class="input"
          @focus="loginFocus.password = true"
          @blur="loginFocus.password = false; checkLoginForm()"
          maxlength="16"
        />
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

    <view v-else class="form-wrap">
      <view class="input-item" :class="{ focused: registerFocus.username }">
        <uni-icons type="person" size="24" color="#666"></uni-icons>
        <input 
          v-model="registerForm.username" 
          placeholder="请输入用户名（2-16位）" 
          class="input"
          @focus="registerFocus.username = true"
          @blur="registerFocus.username = false; checkRegisterForm()"
          maxlength="16"
        />
      </view>
      <view class="error-tip" v-if="registerErrors.username">{{ registerErrors.username }}</view>

      <view class="input-item" :class="{ focused: registerFocus.password }">
        <uni-icons type="locked" size="24" color="#666"></uni-icons>
        <input 
          v-model="registerForm.password" 
          type="password" 
          placeholder="请输入密码（6-16位，字母+数字）" 
          class="input"
          @focus="registerFocus.password = true"
          @blur="registerFocus.password = false; checkRegisterForm()"
          maxlength="16"
        />
      </view>
      <view class="error-tip" v-if="registerErrors.password">{{ registerErrors.password }}</view>

      <view class="input-item" :class="{ focused: registerFocus.phone }">
        <uni-icons type="phone" size="24" color="#666"></uni-icons>
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
export default {
  data() {
    return {
      currentTab: 'login',
      isLoading: false,
      loginForm: {
        username: '',
        password: ''
      },
      loginFocus: {
        username: false,
        password: false
      },
      loginErrors: {},
      isLoginFormValid: false,
      registerForm: {
        username: '',
        password: '',
        phone: '',
        role: 'user'
      },
      registerFocus: {
        username: false,
        password: false,
        phone: false
      },
      registerErrors: {},
      isRegisterFormValid: false
    }
  },
  methods: {
    switchTab(tab) {
      this.currentTab = tab;
      this.loginErrors = {};
      this.registerErrors = {};
    },
    changeRole(role) {
      this.registerForm.role = role;
      uni.showToast({
        title: `已选择${role === 'user' ? '普通用户' : '商家用户'}`,
        icon: 'none',
        duration: 1500
      });
    },
    validateUsername(value) {
      if (!value) return '请输入用户名';
      if (value.length < 2 || value.length > 16) return '用户名长度需在2-16位之间';
      if (!/^[a-zA-Z0-9_\u4e00-\u9fa5]+$/.test(value)) return '用户名仅支持中文、字母、数字、下划线';
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
    checkLoginForm() {
      const { username, password } = this.loginForm;
      const usernameErr = this.validateUsername(username);
      const passwordErr = this.validatePassword(password);

      this.loginErrors = {
        username: usernameErr,
        password: passwordErr
      };

      this.isLoginFormValid = !usernameErr && !passwordErr;
    },
    checkRegisterForm() {
      const { username, password, phone } = this.registerForm;
      const usernameErr = this.validateUsername(username);
      const passwordErr = this.validatePassword(password);
      const phoneErr = this.validatePhone(phone);

      this.registerErrors = {
        username: usernameErr,
        password: passwordErr,
        phone: phoneErr
      };

      this.isRegisterFormValid = !usernameErr && !passwordErr && !phoneErr;
    },
    async handleLogin() {
      this.checkLoginForm();
      if (!this.isLoginFormValid) {
        uni.showToast({ title: '请完善表单信息', icon: 'none' });
        return;
      }

      this.isLoading = true;
      setTimeout(() => {
        this.mockLogin();
        this.isLoading = false;
      }, 800);
    },
    mockLogin() {
      const { username, password } = this.loginForm;
      const userList = JSON.parse(uni.getStorageSync('userList') || '[]');
      const targetUser = userList.find(
        u => u.username === username && u.password === password
      );
      
      if (!targetUser) {
        uni.showToast({ title: '账号或密码错误', icon: 'none' });
        return;
      }

      uni.setStorageSync('token', `mock_token_${Date.now()}`);
      uni.setStorageSync('userInfo', {
        nickname: targetUser.username,
        role: targetUser.role,
        userType: targetUser.userType,
        avatar: '/static/images/avatar.png'
      });

      uni.showToast({ title: '登录成功！', icon: 'success' });
      setTimeout(() => {
        uni.switchTab({ url: '/pages/profile/index' });
      }, 1500);
    },
    async handleRegister() {
      this.checkRegisterForm();
      if (!this.isRegisterFormValid) {
        uni.showToast({ title: '请完善表单信息', icon: 'none' });
        return;
      }

      this.isLoading = true;
      setTimeout(() => {
        this.mockRegister();
        this.isLoading = false;
      }, 800);
    },
    mockRegister() {
      const { username, password, phone, role } = this.registerForm;
      const userList = JSON.parse(uni.getStorageSync('userList') || '[]');
      
      const isExist = userList.some(u => u.username === username);
      if (isExist) {
        uni.showToast({ title: '用户名已存在', icon: 'none' });
        return;
      }

      const newUser = {
        id: Date.now(),
        username,
        password,
        phone,
        role,
        userType: role === 'user' ? '01' : '02',
        createTime: new Date().toLocaleString()
      };
      userList.push(newUser);
      uni.setStorageSync('userList', JSON.stringify(userList));

      uni.showToast({ title: '注册成功！请登录', icon: 'success' });
      this.switchTab('login');
      this.registerForm = { username: '', password: '', phone: '', role: 'user' };
    }
  }
}
</script>

<style scoped>
.status-bar {
  height: var(--status-bar-height);
  background: #fff;
}

.login-page {
  padding: 40rpx;
  min-height: 100vh;
  background: #f8f9fa;
  box-sizing: border-box;
}

.tab-wrap {
  display: flex;
  margin-bottom: 60rpx;
  border-radius: 8rpx;
  background: #fff;
  box-shadow: 0 2rpx 10rpx rgba(0,0,0,0.05);
}
.tab-item {
  flex: 1;
  text-align: center;
  padding: 20rpx 0;
  font-size: 32rpx;
  color: #666;
  position: relative;
}
.tab-item.active {
  color: #2f54eb;
  font-weight: 600;
}
.tab-item.active::after {
  content: '';
  position: absolute;
  bottom: 0;
  left: 50%;
  transform: translateX(-50%);
  width: 60rpx;
  height: 4rpx;
  background: #2f54eb;
  border-radius: 2rpx;
}

.form-wrap {
  background: #fff;
  padding: 40rpx;
  border-radius: 12rpx;
  box-shadow: 0 2rpx 15rpx rgba(0,0,0,0.05);
}

.input-item {
  display: flex;
  align-items: center;
  border-bottom: 1px solid #eee;
  padding: 15rpx 0;
  margin-bottom: 10rpx;
  transition: border-color 0.3s;
}
.input-item.focused {
  border-bottom-color: #2f54eb;
}
.input {
  flex: 1;
  margin-left: 20rpx;
  font-size: 28rpx;
  color: #333;
  height: 40rpx;
  line-height: 40rpx;
}
.input::placeholder {
  color: #999;
}

.error-tip {
  font-size: 24rpx;
  color: #f56c6c;
  margin-bottom: 20rpx;
  padding-left: 44rpx;
  line-height: 1.4;
}

.role-wrap {
  display: flex;
  margin: 40rpx 0 20rpx;
}
.role-item {
  flex: 1;
  text-align: center;
  padding: 20rpx 15rpx;
  border: 1px solid #eee;
  border-radius: 8rpx;
  margin: 0 10rpx;
  font-size: 28rpx;
  color: #666;
  transition: all 0.3s;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8rpx;
}
.role-item.active {
  border-color: #2f54eb;
  color: #2f54eb;
  background: #f0f5ff;
  font-weight: 600;
}

.submit-btn {
  width: 100%;
  height: 80rpx;
  line-height: 80rpx;
  background: #2f54eb;
  color: #fff;
  border-radius: 40rpx;
  font-size: 30rpx;
  margin-top: 40rpx;
  border: none;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 10rpx;
}
.submit-btn.disabled {
  background: #ccc;
  color: #fff;
}
.loading-icon {
  animation: spin 1s linear infinite;
}
@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}
</style>