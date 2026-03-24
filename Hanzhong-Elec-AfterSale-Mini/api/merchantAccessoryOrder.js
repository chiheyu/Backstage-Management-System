import { request } from '@/utils/request'
import {
  normalizeAccessoryOrder,
  isPendingAccessoryOrder,
  isFinishedAccessoryOrder,
  getAccessoryOrderStatusText,
  getAccessoryOrderStatusClass
} from '@/api/accessoryOrder'

export function getMerchantAccessoryOrderPendingList(params = {}) {
  return request({
    url: '/app/merchant/accessoryOrder/pendingList',
    method: 'GET',
    params
  })
}

export function getMerchantAccessoryOrderList(params = {}) {
  return request({
    url: '/app/merchant/accessoryOrder/list',
    method: 'GET',
    params
  })
}

export function shipMerchantAccessoryOrder(accessoryOrderId) {
  return request({
    url: `/app/merchant/accessoryOrder/ship/${accessoryOrderId}`,
    method: 'PUT'
  })
}

export function completeMerchantAccessoryOrder(accessoryOrderId) {
  return request({
    url: `/app/merchant/accessoryOrder/complete/${accessoryOrderId}`,
    method: 'PUT'
  })
}

export function cancelMerchantAccessoryOrder(accessoryOrderId) {
  return request({
    url: `/app/merchant/accessoryOrder/cancel/${accessoryOrderId}`,
    method: 'PUT'
  })
}

export {
  normalizeAccessoryOrder,
  isPendingAccessoryOrder,
  isFinishedAccessoryOrder,
  getAccessoryOrderStatusText,
  getAccessoryOrderStatusClass
}
