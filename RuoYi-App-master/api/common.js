import request from '@/api/request'

// 发送模拟验证码
export function sendRegisterCode(phone) {
  return request({
    url: '/app/auth/sendCode',
    method: 'get',
    params: { phone }
  })
}

// App 登录
export function appLogin(data) {
  return request({
    url: '/app/auth/login',
    method: 'post',
    headers: { isToken: false },
    data
  })
}

// App 注册
export function appRegister(data) {
  return request({
    url: '/app/auth/register',
    method: 'post',
    headers: { isToken: false },
    data
  })
}

// 获取当前登录用户扩展信息
export function getAppProfile() {
  return request({
    url: '/app/auth/profile',
    method: 'get'
  })
}

// 查询商家列表
export function listMerchant(query) {
  return request({
    url: '/app/common/merchant/list',
    method: 'get',
    params: query
  })
}

// 查询商家详情
export function getMerchant(merchantId) {
  return request({
    url: '/app/common/merchant/' + merchantId,
    method: 'get'
  })
}

// 查询配件列表
export function listAccessory(query) {
  return request({
    url: '/app/common/accessory/list',
    method: 'get',
    params: query
  })
}

// 查询配件详情
export function getAccessory(accessoryId) {
  return request({
    url: '/app/common/accessory/' + accessoryId,
    method: 'get'
  })
}
