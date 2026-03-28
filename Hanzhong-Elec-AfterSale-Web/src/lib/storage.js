const TOKEN_KEY = 'after_sale_web_token'
const USER_KEY = 'after_sale_web_user'
const MERCHANT_KEY = 'after_sale_web_merchant'
const ROLE_KEY = 'after_sale_web_role'
const MERCHANT_SHOP_META_PREFIX = 'after_sale_web_merchant_shop_meta_'

function readJson(key) {
  const raw = window.localStorage.getItem(key)
  if (!raw) {
    return null
  }
  try {
    return JSON.parse(raw)
  } catch {
    return null
  }
}

function writeJson(key, value) {
  if (value === null || value === undefined) {
    window.localStorage.removeItem(key)
    return
  }
  window.localStorage.setItem(key, JSON.stringify(value))
}

function buildMerchantShopMetaKey(merchantId) {
  return `${MERCHANT_SHOP_META_PREFIX}${merchantId || 'default'}`
}

function normalizeMerchantShopMeta(payload = {}) {
  return {
    logo: String(payload.logo || '').trim(),
    businessTime: String(payload.businessTime || '').trim(),
    isOpen: payload.isOpen !== false
  }
}

export function getStoredToken() {
  return window.localStorage.getItem(TOKEN_KEY) || ''
}

export function saveStoredSession(payload = {}) {
  if (payload.token) {
    window.localStorage.setItem(TOKEN_KEY, payload.token)
  } else {
    window.localStorage.removeItem(TOKEN_KEY)
  }
  writeJson(USER_KEY, payload.appUser || null)
  writeJson(MERCHANT_KEY, payload.merchant || null)
  if (payload.roleType) {
    window.localStorage.setItem(ROLE_KEY, payload.roleType)
  } else {
    window.localStorage.removeItem(ROLE_KEY)
  }
}

export function loadStoredSession() {
  return {
    token: getStoredToken(),
    appUser: readJson(USER_KEY),
    merchant: readJson(MERCHANT_KEY),
    roleType: window.localStorage.getItem(ROLE_KEY) || ''
  }
}

export function clearStoredSession() {
  window.localStorage.removeItem(TOKEN_KEY)
  window.localStorage.removeItem(ROLE_KEY)
  window.localStorage.removeItem(USER_KEY)
  window.localStorage.removeItem(MERCHANT_KEY)
}

export function loadMerchantShopMeta(merchantId) {
  return normalizeMerchantShopMeta(readJson(buildMerchantShopMetaKey(merchantId)) || {})
}

export function saveMerchantShopMeta(merchantId, payload = {}) {
  const normalizedPayload = normalizeMerchantShopMeta(payload)
  writeJson(buildMerchantShopMetaKey(merchantId), normalizedPayload)
  return normalizedPayload
}
