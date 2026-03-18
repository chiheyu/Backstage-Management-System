import request from '@/api/request'

// 查询当前商家信息
export function getMerchantProfile() {
  return request({
    url: '/app/merchant/info',
    method: 'get'
  })
}

// 更新商家信息
export function updateMerchantProfile(data) {
  return request({
    url: '/app/merchant/info',
    method: 'put',
    data
  })
}

// 待接单订单
export function listPendingOrder(query) {
  return request({
    url: '/app/merchant/order/pendingList',
    method: 'get',
    params: query
  })
}

// 商家订单列表
export function listMerchantOrder(query) {
  return request({
    url: '/app/merchant/order/list',
    method: 'get',
    params: query
  })
}

// 商家接单
export function takeOrder(orderId) {
  return request({
    url: '/app/merchant/order/take/' + orderId,
    method: 'put'
  })
}

// 商家修改订单状态
export function updateMerchantOrderStatus(data) {
  return request({
    url: '/app/merchant/order/status',
    method: 'put',
    data
  })
}
