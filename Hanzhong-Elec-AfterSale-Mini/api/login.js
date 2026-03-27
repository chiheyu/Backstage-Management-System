import { request } from '@/utils/request'

// 登录方法
export function login(phone, password) {
  return request({
    url: '/app/auth/login',
    method: 'POST',
    data: {
      phone,
      password
    },
    headers: {
      isToken: false
    }
  })
}

// 注册方法
export function register(data) {
  return request({
    url: '/app/auth/register',
    method: 'POST',
    data,
    headers: {
      isToken: false
    }
  })
}

// 获取用户详细信息
export function getInfo() {
  return request({
    url: '/app/auth/profile',
    method: 'GET'
  })
}

// 退出方法
export function logout() {
  return request({
    url: '/app/auth/logout',
    method: 'POST'
  })
}

// 获取注册验证码
export function sendCode(phone) {
  return request({
    url: `/app/auth/sendCode?phone=${encodeURIComponent(phone)}`,
    method: 'GET',
    headers: {
      isToken: false
    }
  })
}
