import { request } from '@/utils/request'

export function getCurrentMerchantInfo() {
  return request({
    url: '/app/merchant/info',
    method: 'GET'
  })
}
