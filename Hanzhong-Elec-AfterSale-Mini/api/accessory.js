import config from '@/config'
import { request } from '@/utils/request'

const defaultAccessoryImage = '/static/images/accessory/default-accessory.png'
const normalizedBaseUrl = (config.baseUrl || '').replace(/\/$/, '')

function buildQuery(params = {}) {
  const query = Object.keys(params)
    .filter((key) => params[key] !== undefined && params[key] !== null && params[key] !== '')
    .map((key) => `${encodeURIComponent(key)}=${encodeURIComponent(params[key])}`)
    .join('&')

  return query ? `?${query}` : ''
}

function appendBaseUrl(path) {
  if (!path) {
    return defaultAccessoryImage
  }

  if (path.startsWith('/static/')) {
    return path
  }

  if (path.startsWith('static/')) {
    return `/${path}`
  }

  if (/^https?:\/\//i.test(path)) {
    return path
  }

  if (path.startsWith('//')) {
    const protocol = normalizedBaseUrl.startsWith('https://') ? 'https:' : 'http:'
    return `${protocol}${path}`
  }

  if (!normalizedBaseUrl) {
    return path
  }

  return path.startsWith('/') ? `${normalizedBaseUrl}${path}` : `${normalizedBaseUrl}/${path}`
}

function toNumber(value, defaultValue = 0) {
  const parsedValue = Number(value)
  return Number.isFinite(parsedValue) ? parsedValue : defaultValue
}

export function resolveAccessoryImage(image) {
  return appendBaseUrl(image)
}

export function normalizeAccessory(accessory = {}) {
  return {
    ...accessory,
    id: accessory.accessoryId,
    name: accessory.accessoryName || '未命名配件',
    spec: accessory.categoryName || '未分类',
    desc: accessory.accessoryDesc || '暂无商品详情',
    image: resolveAccessoryImage(accessory.coverImage),
    price: toNumber(accessory.price, 0),
    stock: toNumber(accessory.stock, 0),
    salesCount: toNumber(accessory.salesCount, 0),
    status: accessory.status || ''
  }
}

export function getAccessoryList(params = {}) {
  return request(`/app/common/accessory/list${buildQuery(params)}`, 'GET')
}

export function getAccessoryDetail(accessoryId) {
  return request(`/app/common/accessory/${accessoryId}`, 'GET')
}
