import upload from '@/utils/upload'
import { request } from '@/utils/request'

export function getMerchantAccessoryList(params = {}) {
  return request({
    url: '/app/merchant/accessory/list',
    method: 'GET',
    params
  })
}

export function getMerchantAccessoryDetail(accessoryId) {
  return request({
    url: `/app/merchant/accessory/${accessoryId}`,
    method: 'GET'
  })
}

export function createMerchantAccessory(data) {
  return request({
    url: '/app/merchant/accessory',
    method: 'POST',
    data
  })
}

export function updateMerchantAccessory(data) {
  return request({
    url: '/app/merchant/accessory',
    method: 'PUT',
    data
  })
}

export function deleteMerchantAccessory(accessoryId) {
  return request({
    url: `/app/merchant/accessory/${accessoryId}`,
    method: 'DELETE'
  })
}

export function uploadMerchantAccessoryImage(filePath) {
  return upload({
    url: '/common/upload',
    filePath,
    name: 'file'
  })
}
