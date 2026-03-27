export const API_FALLBACK_BASE_URL = 'http://127.0.0.1:8080'

export const ROLE_TYPES = {
  pendingMerchant: '0',
  user: '1',
  merchant: '2'
}

export const ROLE_OPTIONS = [
  {
    label: '普通用户',
    value: ROLE_TYPES.user,
    desc: '提交售后、购买配件、查看订单'
  },
  {
    label: '商家入驻',
    value: ROLE_TYPES.merchant,
    desc: '注册后进入待审核状态，通过后可接单'
  }
]

export const MERCHANT_AUDIT_STATUS = {
  '0': { label: '待审核', tone: 'warm' },
  '1': { label: '已通过', tone: 'success' },
  '2': { label: '已停用', tone: 'danger' }
}

export const AFTER_SALES_STATUS = {
  '0': { label: '待接单', tone: 'warm' },
  '1': { label: '已接单', tone: 'brand' },
  '2': { label: '维修中', tone: 'brand' },
  '3': { label: '已完成', tone: 'success' },
  '4': { label: '已取消', tone: 'danger' }
}

export const ACCESSORY_ORDER_STATUS = {
  '0': { label: '待处理', tone: 'warm' },
  '1': { label: '已发货', tone: 'brand' },
  '2': { label: '已完成', tone: 'success' },
  '3': { label: '已取消', tone: 'danger' }
}

export const ROLE_LABEL_MAP = {
  [ROLE_TYPES.pendingMerchant]: '待审核商家',
  [ROLE_TYPES.user]: '普通用户',
  [ROLE_TYPES.merchant]: '商家'
}

export function getRoleState(roleType) {
  const normalizedRoleType = String(roleType)
  return {
    isPendingMerchant: normalizedRoleType === ROLE_TYPES.pendingMerchant,
    isUser: normalizedRoleType === ROLE_TYPES.user || normalizedRoleType === ROLE_TYPES.pendingMerchant,
    isMerchant: normalizedRoleType === ROLE_TYPES.merchant
  }
}

export function getRoleLabel(roleType) {
  return ROLE_LABEL_MAP[String(roleType)] || '游客'
}

export function getStatusMeta(dict, value) {
  return dict[String(value)] || { label: '未知状态', tone: 'muted' }
}

export function formatMoney(value) {
  const numeric = Number(value || 0)
  if (Number.isNaN(numeric)) {
    return '0.00'
  }
  return numeric.toFixed(2)
}

export function formatDateTime(value) {
  if (!value) {
    return '--'
  }
  const date = new Date(value)
  if (Number.isNaN(date.getTime())) {
    return String(value).replace('T', ' ').slice(0, 16)
  }
  const year = date.getFullYear()
  const month = `${date.getMonth() + 1}`.padStart(2, '0')
  const day = `${date.getDate()}`.padStart(2, '0')
  const hour = `${date.getHours()}`.padStart(2, '0')
  const minute = `${date.getMinutes()}`.padStart(2, '0')
  return `${year}-${month}-${day} ${hour}:${minute}`
}

export function shortText(value, size = 46) {
  const text = String(value || '')
  if (text.length <= size) {
    return text
  }
  return `${text.slice(0, size)}...`
}

export function safeRows(payload) {
  return Array.isArray(payload?.rows) ? payload.rows : []
}

export function resolveImage(url, apiBaseUrl) {
  if (!url) {
    return ''
  }
  if (/^https?:\/\//i.test(url)) {
    return url
  }
  if (!apiBaseUrl) {
    return url
  }
  return `${apiBaseUrl}${url.startsWith('/') ? url : `/${url}`}`
}
