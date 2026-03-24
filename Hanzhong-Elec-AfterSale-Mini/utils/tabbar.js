function isMerchantUser(userInfo = {}) {
  return userInfo.role === 'merchant' || String(userInfo.roleType || '') === '2'
}

export function syncRoleTabBar(userInfo = uni.getStorageSync('userInfo') || {}) {
  const merchantMode = isMerchantUser(userInfo)

  const tabBarConfigs = [
    { index: 1, text: merchantMode ? '售后回执' : '申请售后' },
    { index: 3, text: merchantMode ? '工作台' : '购物车' }
  ]

  tabBarConfigs.forEach((item) => {
    uni.setTabBarItem({
      index: item.index,
      text: item.text
    })
  })
}

export function resetDefaultTabBar() {
  syncRoleTabBar({})
}
