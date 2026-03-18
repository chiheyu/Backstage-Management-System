import request from '@/api/request'

// 提交售后申请
export function createAfterSalesOrder(data) {
  return request({
    url: '/app/user/afterSalesOrder',
    method: 'post',
    data
  })
}

// 查询我的售后订单
export function listMyAfterSalesOrder(query) {
  return request({
    url: '/app/user/afterSalesOrder/list',
    method: 'get',
    params: query
  })
}

// 查询售后订单详情
export function getMyAfterSalesOrder(orderId) {
  return request({
    url: '/app/user/afterSalesOrder/' + orderId,
    method: 'get'
  })
}

// 取消售后订单
export function cancelAfterSalesOrder(orderId) {
  return request({
    url: '/app/user/afterSalesOrder/cancel/' + orderId,
    method: 'put'
  })
}

// 查询我的收藏
export function listMyCollection() {
  return request({
    url: '/app/user/accessoryCollection/list',
    method: 'get'
  })
}

// 收藏配件
export function collectAccessory(accessoryId) {
  return request({
    url: '/app/user/accessoryCollection/' + accessoryId,
    method: 'post'
  })
}

// 取消收藏
export function cancelCollection(accessoryId) {
  return request({
    url: '/app/user/accessoryCollection/' + accessoryId,
    method: 'delete'
  })
}

// 创建配件订单
export function createAccessoryOrder(data) {
  return request({
    url: '/app/user/accessoryOrder',
    method: 'post',
    data
  })
}

// 查询我的配件订单
export function listMyAccessoryOrder(query) {
  return request({
    url: '/app/user/accessoryOrder/list',
    method: 'get',
    params: query
  })
}
