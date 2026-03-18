import request from '@/utils/request'

// 查询配件列表
export function listAccessory(query) {
  return request({
    url: '/app/admin/accessory/list',
    method: 'get',
    params: query
  })
}

// 查询配件详情
export function getAccessory(accessoryId) {
  return request({
    url: '/app/admin/accessory/' + accessoryId,
    method: 'get'
  })
}

// 新增配件
export function addAccessory(data) {
  return request({
    url: '/app/admin/accessory',
    method: 'post',
    data: data
  })
}

// 修改配件
export function updateAccessory(data) {
  return request({
    url: '/app/admin/accessory',
    method: 'put',
    data: data
  })
}

// 删除配件
export function delAccessory(accessoryId) {
  return request({
    url: '/app/admin/accessory/' + accessoryId,
    method: 'delete'
  })
}
