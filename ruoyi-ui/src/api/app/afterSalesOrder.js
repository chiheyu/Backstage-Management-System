import request from '@/utils/request'

// 查询售后订单列表
export function listAfterSalesOrder(query) {
  return request({
    url: '/app/admin/afterSalesOrder/list',
    method: 'get',
    params: query
  })
}

// 查询售后订单详情
export function getAfterSalesOrder(orderId) {
  return request({
    url: '/app/admin/afterSalesOrder/' + orderId,
    method: 'get'
  })
}

// 修改售后订单状态
export function updateAfterSalesOrderStatus(data) {
  return request({
    url: '/app/admin/afterSalesOrder/status',
    method: 'put',
    data: data
  })
}
