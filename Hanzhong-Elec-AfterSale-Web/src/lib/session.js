import { reactive } from 'vue'
import { authApi, merchantApi } from './api'
import { ROLE_TYPES } from './domain'
import { pushNotice } from './notice'
import { clearStoredSession, loadStoredSession, saveStoredSession } from './storage'

const stored = loadStoredSession()

export const session = reactive({
  token: stored.token,
  appUser: stored.appUser,
  merchant: stored.merchant,
  roleType: stored.roleType,
  bootstrapped: false
})

function syncStorage() {
  saveStoredSession({
    token: session.token,
    appUser: session.appUser,
    merchant: session.merchant,
    roleType: session.roleType
  })
}

export function clearSession() {
  session.token = ''
  session.appUser = null
  session.merchant = null
  session.roleType = ''
  clearStoredSession()
}

window.addEventListener('after-sale-auth-cleared', () => {
  clearSession()
})

export function hasSession() {
  return !!session.token
}

export async function applyLogin(payload) {
  session.token = payload?.token || ''
  session.appUser = payload?.appUser || null
  session.merchant = payload?.merchant || null
  session.roleType = payload?.roleType || payload?.appUser?.roleType || ''
  syncStorage()
}

export async function refreshSessionData() {
  if (!session.token) {
    return
  }
  const profile = await authApi.profile()
  session.appUser = profile || null
  session.roleType = session.appUser?.roleType || session.roleType
  if (String(session.roleType) === ROLE_TYPES.merchant) {
    try {
      session.merchant = await merchantApi.currentInfo()
    } catch {
      session.merchant = null
    }
  }
  syncStorage()
}

export async function bootstrapSession() {
  if (session.bootstrapped) {
    return
  }
  if (!session.token) {
    session.bootstrapped = true
    return
  }
  try {
    await refreshSessionData()
  } catch {
    clearSession()
  } finally {
    session.bootstrapped = true
  }
}

export async function logoutSession() {
  try {
    if (session.token) {
      await authApi.logout()
    }
  } catch {
    // Ignore logout errors and clear local session anyway.
  } finally {
    clearSession()
    pushNotice('已退出登录', 'success')
  }
}
