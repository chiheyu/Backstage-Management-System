import request from '@/utils/request'

// 查询配件订单列表
export function listAccessoryOrder(query) {
  return request({
    url: '/app/admin/accessoryOrder/list',
    method: 'get',
    params: query
  })
}

// 查询配件订单详情
export function getAccessoryOrder(accessoryOrderId) {
  return request({
    url: '/app/admin/accessoryOrder/' + accessoryOrderId,
    method: 'get'
  })
}
