import request from '@/utils/request'

// 查询商家管理列表
export function listMerchant(query) {
  return request({
    url: '/app/admin/merchant/list',
    method: 'get',
    params: query
  })
}

// 查询商家详情
export function getMerchant(merchantId) {
  return request({
    url: '/app/admin/merchant/' + merchantId,
    method: 'get'
  })
}

// 审核商家
export function auditMerchant(data) {
  return request({
    url: '/app/admin/merchant/audit',
    method: 'put',
    data: data
  })
}

// 修改商家
export function updateMerchant(data) {
  return request({
    url: '/app/admin/merchant',
    method: 'put',
    data: data
  })
}
