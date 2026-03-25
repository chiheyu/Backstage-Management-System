import { API_FALLBACK_BASE_URL } from './domain'
import { clearStoredSession, getStoredToken } from './storage'

export const apiBaseUrl = import.meta.env.VITE_API_BASE_URL || API_FALLBACK_BASE_URL

function buildUrl(path, params) {
  const url = new URL(path, apiBaseUrl)
  if (params && typeof params === 'object') {
    Object.entries(params).forEach(([key, value]) => {
      if (value === null || value === undefined || value === '') {
        return
      }
      if (typeof value === 'object' && !Array.isArray(value)) {
        Object.entries(value).forEach(([childKey, childValue]) => {
          if (childValue === null || childValue === undefined || childValue === '') {
            return
          }
          url.searchParams.set(`${key}[${childKey}]`, childValue)
        })
        return
      }
      url.searchParams.set(key, value)
    })
  }
  return url.toString()
}

function normalizeCode(code) {
  if (typeof code === 'string' && /^\d+$/.test(code)) {
    return Number(code)
  }
  return code
}

export async function apiRequest(path, options = {}) {
  const {
    method = 'GET',
    params,
    body,
    auth = true,
    raw = false
  } = options

  const headers = {
    'Content-Type': 'application/json'
  }

  if (auth && getStoredToken()) {
    headers.Authorization = `Bearer ${getStoredToken()}`
  }

  const response = await fetch(buildUrl(path, params), {
    method,
    headers,
    body: body ? JSON.stringify(body) : undefined
  })

  let payload = null
  try {
    payload = await response.json()
  } catch {
    payload = null
  }

  if (!response.ok) {
    throw new Error(payload?.msg || `请求失败：HTTP ${response.status}`)
  }

  if (raw) {
    return payload
  }

  if (!payload || typeof payload !== 'object') {
    throw new Error('后端返回格式异常')
  }

  const code = normalizeCode(payload.code)

  if (code === 200) {
    return payload.data !== undefined ? payload.data : payload
  }

  if (path === '/app/auth/sendCode' && /^\d{6}$/.test(String(payload.code))) {
    return payload
  }

  if (code === 401) {
    clearStoredSession()
    window.dispatchEvent(new Event('after-sale-auth-cleared'))
  }

  throw new Error(payload.msg || '接口调用失败')
}

export const authApi = {
  sendCode(phone) {
    return apiRequest('/app/auth/sendCode', {
      method: 'GET',
      params: { phone },
      auth: false,
      raw: true
    })
  },
  login(payload) {
    return apiRequest('/app/auth/login', {
      method: 'POST',
      body: payload,
      auth: false
    })
  },
  register(payload) {
    return apiRequest('/app/auth/register', {
      method: 'POST',
      body: payload,
      auth: false
    })
  },
  profile() {
    return apiRequest('/app/auth/profile')
  },
  logout() {
    return apiRequest('/logout', {
      method: 'POST'
    })
  }
}

export const commonApi = {
  listAccessories(params = {}) {
    return apiRequest('/app/common/accessory/list', {
      method: 'GET',
      params,
      raw: true
    })
  },
  getAccessory(id) {
    return apiRequest(`/app/common/accessory/${id}`, {
      method: 'GET'
    })
  },
  listMerchants(params = {}) {
    return apiRequest('/app/common/merchant/list', {
      method: 'GET',
      params,
      raw: true
    })
  },
  getMerchant(id) {
    return apiRequest(`/app/common/merchant/${id}`, {
      method: 'GET'
    })
  }
}

export const userApi = {
  createAfterSalesOrder(payload) {
    return apiRequest('/app/user/afterSalesOrder', {
      method: 'POST',
      body: payload
    })
  },
  listAfterSalesOrders(params = {}) {
    return apiRequest('/app/user/afterSalesOrder/list', {
      method: 'GET',
      params,
      raw: true
    })
  },
  cancelAfterSalesOrder(orderId) {
    return apiRequest(`/app/user/afterSalesOrder/cancel/${orderId}`, {
      method: 'PUT'
    })
  },
  listAccessoryCollections(params = {}) {
    return apiRequest('/app/user/accessoryCollection/list', {
      method: 'GET',
      params,
      raw: true
    })
  },
  collectAccessory(accessoryId) {
    return apiRequest(`/app/user/accessoryCollection/${accessoryId}`, {
      method: 'POST'
    })
  },
  cancelAccessoryCollection(accessoryId) {
    return apiRequest(`/app/user/accessoryCollection/${accessoryId}`, {
      method: 'DELETE'
    })
  },
  createAccessoryOrder(payload) {
    return apiRequest('/app/user/accessoryOrder', {
      method: 'POST',
      body: payload
    })
  },
  listAccessoryOrders(params = {}) {
    return apiRequest('/app/user/accessoryOrder/list', {
      method: 'GET',
      params,
      raw: true
    })
  }
}

export const merchantApi = {
  currentInfo() {
    return apiRequest('/app/merchant/info')
  },
  updateInfo(payload) {
    return apiRequest('/app/merchant/info', {
      method: 'PUT',
      body: payload
    })
  },
  listPendingOrders(params = {}) {
    return apiRequest('/app/merchant/order/pendingList', {
      method: 'GET',
      params,
      raw: true
    })
  },
  takeOrder(orderId) {
    return apiRequest(`/app/merchant/order/take/${orderId}`, {
      method: 'PUT'
    })
  },
  listOrders(params = {}) {
    return apiRequest('/app/merchant/order/list', {
      method: 'GET',
      params,
      raw: true
    })
  },
  updateOrderStatus(payload) {
    return apiRequest('/app/merchant/order/status', {
      method: 'PUT',
      body: payload
    })
  }
}
