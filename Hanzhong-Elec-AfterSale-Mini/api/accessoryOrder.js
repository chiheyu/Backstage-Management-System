import { request } from '@/utils/request'
import { resolveAccessoryImage } from '@/api/accessory'

const STATUS = {
  PENDING: '0',
  SHIPPED: '1',
  COMPLETED: '2',
  CANCELED: '3'
}

export function createAccessoryOrder(data) {
  return request({
    url: '/app/user/accessoryOrder',
    method: 'POST',
    data
  })
}

export function getAccessoryOrderList(params = {}) {
  return request({
    url: '/app/user/accessoryOrder/list',
    method: 'GET',
    params
  })
}

export function normalizeAccessoryOrder(order = {}) {
  return {
    ...order,
    accessoryOrderId: order.accessoryOrderId,
    status: String(order.status ?? ''),
    coverImage: resolveAccessoryImage(order.coverImage),
    quantity: Number(order.quantity || 0),
    price: Number(order.price || 0),
    totalAmount: Number(order.totalAmount || 0)
  }
}

export function isPendingAccessoryOrder(status) {
  return [STATUS.PENDING, STATUS.SHIPPED].includes(String(status))
}

export function isFinishedAccessoryOrder(status) {
  return [STATUS.COMPLETED, STATUS.CANCELED].includes(String(status))
}

export function getAccessoryOrderStatusText(status) {
  const statusMap = {
    [STATUS.PENDING]: '待处理',
    [STATUS.SHIPPED]: '已发货',
    [STATUS.COMPLETED]: '已完成',
    [STATUS.CANCELED]: '已取消'
  }

  return statusMap[String(status)] || '未知状态'
}

export function getAccessoryOrderStatusClass(status) {
  const statusMap = {
    [STATUS.PENDING]: 'status-pending',
    [STATUS.SHIPPED]: 'status-shipped',
    [STATUS.COMPLETED]: 'status-completed',
    [STATUS.CANCELED]: 'status-canceled'
  }

  return statusMap[String(status)] || 'status-unknown'
}
