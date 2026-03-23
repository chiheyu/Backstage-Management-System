import upload from '@/utils/upload'
import { request } from '@/utils/request'

function appendQueryEntries(entries, value, path = []) {
  if (value === undefined || value === null || value === '') {
    return
  }

  if (Array.isArray(value)) {
    value.forEach((item, index) => {
      appendQueryEntries(entries, item, [...path, index])
    })
    return
  }

  if (Object.prototype.toString.call(value) === '[object Object]') {
    Object.keys(value).forEach((key) => {
      appendQueryEntries(entries, value[key], [...path, key])
    })
    return
  }

  const [firstKey, ...restKeys] = path
  const queryKey = [firstKey, ...restKeys.map((key) => `[${key}]`)].join('')
  entries.push(`${encodeURIComponent(queryKey)}=${encodeURIComponent(value)}`)
}

function buildQuery(params = {}) {
  const entries = []

  Object.keys(params).forEach((key) => {
    appendQueryEntries(entries, params[key], [key])
  })

  return entries.length ? `?${entries.join('&')}` : ''
}

export function uploadAfterSaleImage(filePath) {
  return upload({
    url: '/common/upload',
    filePath,
    name: 'file'
  })
}

export function createAfterSaleOrder(data) {
  return request('/app/user/afterSalesOrder', 'POST', data)
}

export function getUserAfterSaleOrders(params = {}) {
  return request(`/app/user/afterSalesOrder/list${buildQuery(params)}`, 'GET')
}

export function cancelAfterSaleOrder(orderId) {
  return request(`/app/user/afterSalesOrder/cancel/${orderId}`, 'PUT')
}

export function getMerchantPendingOrders(params = {}) {
  return request(`/app/merchant/order/pendingList${buildQuery(params)}`, 'GET')
}

export function getMerchantOrders(params = {}) {
  return request(`/app/merchant/order/list${buildQuery(params)}`, 'GET')
}

export function takeMerchantOrder(orderId) {
  return request(`/app/merchant/order/take/${orderId}`, 'PUT')
}

export function updateMerchantOrderStatus(data) {
  return request('/app/merchant/order/status', 'PUT', data)
}
