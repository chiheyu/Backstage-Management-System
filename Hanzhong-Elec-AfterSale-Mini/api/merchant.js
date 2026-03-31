import { request } from '@/utils/request'

export function getCurrentMerchantInfo() {
  return request({
    url: '/app/merchant/info',
    method: 'GET'
  })
}

export function getMerchantList(params = {}) {
  return request({
    url: '/app/common/merchant/list',
    method: 'GET',
    params
  })
}

export function getMerchantDetail(merchantId) {
  return request({
    url: `/app/common/merchant/${merchantId}`,
    method: 'GET'
  })
}

export function getMerchantReviewList(merchantId) {
  return request({
    url: `/app/common/merchant/${merchantId}/review/list`,
    method: 'GET'
  })
}

export function getMerchantStats() {
  return request({
    url: '/app/merchant/stats',
    method: 'GET'
  })
}
