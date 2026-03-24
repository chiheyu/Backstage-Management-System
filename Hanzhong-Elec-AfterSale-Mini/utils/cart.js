function resolveCartOwner() {
  const userInfo = uni.getStorageSync('userInfo') || {}
  const appUserId = userInfo.appUserId || userInfo.userId
  const phone = userInfo.phone

  if (appUserId) {
    return `user_${appUserId}`
  }

  if (phone) {
    return `phone_${phone}`
  }

  return 'guest'
}

export function getCartStorageKey() {
  return `cartList_${resolveCartOwner()}`
}

export function getCartList() {
  return uni.getStorageSync(getCartStorageKey()) || []
}

export function setCartList(cartList) {
  uni.setStorageSync(getCartStorageKey(), Array.isArray(cartList) ? cartList : [])
}

export function clearCartList() {
  uni.removeStorageSync(getCartStorageKey())
}
