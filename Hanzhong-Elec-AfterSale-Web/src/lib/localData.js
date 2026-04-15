import { loadStoredSession } from './storage'

const ADDRESS_KEY_PREFIX = 'after_sale_web_addresses_'
const CART_KEY_PREFIX = 'after_sale_web_cart_'
const AFTER_SALE_PREFILL_KEY_PREFIX = 'after_sale_web_after_sale_prefill_'

function resolveStorageScope() {
  const stored = loadStoredSession()
  const appUserId = stored?.appUser?.appUserId
  if (appUserId !== null && appUserId !== undefined && String(appUserId).trim() !== '') {
    return `user_${appUserId}`
  }
  return 'guest'
}

function buildScopedKey(prefix) {
  return `${prefix}${resolveStorageScope()}`
}

function readJson(key, fallback) {
  const raw = window.localStorage.getItem(key)
  if (!raw) {
    return fallback
  }
  try {
    return JSON.parse(raw)
  } catch {
    return fallback
  }
}

function writeJson(key, value) {
  window.localStorage.setItem(key, JSON.stringify(value))
}

function normalizeAddress(address = {}) {
  return {
    id: address.id || `${Date.now()}_${Math.random().toString(16).slice(2, 8)}`,
    name: String(address.name || '').trim(),
    phone: String(address.phone || '').trim(),
    region: String(address.region || '').trim(),
    detail: String(address.detail || '').trim(),
    isDefault: Boolean(address.isDefault)
  }
}

export function formatAddress(address = {}) {
  return [address.region, address.detail].filter(Boolean).join(' ').trim()
}

export function loadAddressList() {
  const list = readJson(buildScopedKey(ADDRESS_KEY_PREFIX), [])
  return Array.isArray(list) ? list.map(normalizeAddress) : []
}

export function saveAddressList(list = []) {
  const normalizedList = Array.isArray(list) ? list.map(normalizeAddress) : []
  const hasDefault = normalizedList.some(item => item.isDefault)
  const finalList = normalizedList.map((item, index) => ({
    ...item,
    isDefault: hasDefault ? item.isDefault : index === 0
  }))
  writeJson(buildScopedKey(ADDRESS_KEY_PREFIX), finalList)
  return finalList
}

export function getDefaultAddress() {
  const list = loadAddressList()
  return list.find(item => item.isDefault) || list[0] || null
}

export function upsertAddress(address) {
  const currentList = loadAddressList()
  const normalizedAddress = normalizeAddress(address)
  let nextList = currentList.filter(item => item.id !== normalizedAddress.id)

  if (normalizedAddress.isDefault) {
    nextList = nextList.map(item => ({ ...item, isDefault: false }))
  }

  nextList.unshift(normalizedAddress)
  return saveAddressList(nextList)
}

export function removeAddress(id) {
  const nextList = loadAddressList().filter(item => item.id !== id)
  return saveAddressList(nextList)
}

export function markAddressAsDefault(id) {
  return saveAddressList(
    loadAddressList().map(item => ({
      ...item,
      isDefault: item.id === id
    }))
  )
}

function normalizeCartItem(item = {}) {
  return {
    id: item.id || item.accessoryId || '',
    accessoryId: item.accessoryId || item.id || '',
    name: item.name || item.accessoryName || '',
    spec: item.spec || item.categoryName || '',
    desc: item.desc || item.accessoryDesc || '',
    image: item.image || item.coverImage || '',
    price: Number(item.price || 0),
    stock: Number(item.stock || 0),
    count: Math.max(1, Number(item.count || 1))
  }
}

export function loadCartList() {
  const list = readJson(buildScopedKey(CART_KEY_PREFIX), [])
  return Array.isArray(list) ? list.map(normalizeCartItem).filter(item => item.id) : []
}

export function saveCartList(list = []) {
  const normalizedList = Array.isArray(list)
    ? list.map(normalizeCartItem).filter(item => item.id)
    : []
  writeJson(buildScopedKey(CART_KEY_PREFIX), normalizedList)
  return normalizedList
}

export function addCartItem(item) {
  const normalizedItem = normalizeCartItem(item)
  const currentList = loadCartList()
  const matchedItem = currentList.find(cartItem => cartItem.id === normalizedItem.id)

  if (matchedItem) {
    matchedItem.count = Math.min(
      Math.max(1, matchedItem.count + normalizedItem.count),
      Math.max(1, normalizedItem.stock || matchedItem.stock || matchedItem.count)
    )
    matchedItem.stock = normalizedItem.stock || matchedItem.stock
    matchedItem.price = normalizedItem.price || matchedItem.price
    matchedItem.image = normalizedItem.image || matchedItem.image
    matchedItem.name = normalizedItem.name || matchedItem.name
    matchedItem.spec = normalizedItem.spec || matchedItem.spec
    matchedItem.desc = normalizedItem.desc || matchedItem.desc
    return saveCartList(currentList)
  }

  currentList.push(normalizedItem)
  return saveCartList(currentList)
}

export function clearCart() {
  writeJson(buildScopedKey(CART_KEY_PREFIX), [])
}

export function saveAfterSalePrefill(prefill = {}) {
  writeJson(buildScopedKey(AFTER_SALE_PREFILL_KEY_PREFIX), prefill)
}

export function consumeAfterSalePrefill() {
  const storageKey = buildScopedKey(AFTER_SALE_PREFILL_KEY_PREFIX)
  const payload = readJson(storageKey, null)
  window.localStorage.removeItem(storageKey)
  return payload
}
