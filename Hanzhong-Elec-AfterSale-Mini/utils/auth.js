const TokenKey = 'token'
const LegacyTokenKey = 'App-Token'

export function getToken() {
  return uni.getStorageSync(TokenKey) || uni.getStorageSync(LegacyTokenKey)
}

export function setToken(token) {
  uni.setStorageSync(TokenKey, token)
  uni.removeStorageSync(LegacyTokenKey)
  return token
}

export function removeToken() {
  uni.removeStorageSync(TokenKey)
  return uni.removeStorageSync(LegacyTokenKey)
}
