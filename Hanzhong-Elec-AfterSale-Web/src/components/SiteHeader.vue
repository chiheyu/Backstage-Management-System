<script setup>
import { computed } from 'vue'
import { RouterLink, useRoute, useRouter } from 'vue-router'
import { getRoleLabel, getRoleState } from '@/lib/domain'
import { logoutSession, session } from '@/lib/session'

const router = useRouter()
const route = useRoute()

const roleState = computed(() => getRoleState(session.roleType))
const roleLabel = computed(() => getRoleLabel(session.roleType))

const navItems = computed(() => {
  const items = [
    { label: '首页', to: { name: 'home' } },
    { label: '配件商城', to: { name: 'mall' } }
  ]

  if (roleState.value.isMerchant) {
    items.push({ label: '售后工单', to: { name: 'after-sales-orders', query: { mode: 'mine' } } })
    items.push({ label: '服务门店', to: { name: 'merchants' } })
    items.push({ label: '店铺设置', to: { name: 'merchant-settings' } })
  } else if (roleState.value.isPendingMerchant) {
    items.push({ label: '服务门店', to: { name: 'merchants' } })
    items.push({ label: '店铺设置', to: { name: 'merchant-settings' } })
  } else {
    items.push({ label: '服务门店', to: { name: 'merchants' } })
    items.push({ label: '售后申请', to: { name: 'after-sales-apply' } })
    items.push({ label: '我的订单', to: { name: 'orders' } })
  }

  items.push({ label: '个人中心', to: { name: 'profile' } })
  return items
})

async function handleLogout() {
  await logoutSession()
  router.push({ name: 'home' })
}
</script>

<template>
  <header class="site-header">
    <div class="page-shell site-header__inner">
      <RouterLink class="site-brand" :to="{ name: 'home' }">
        <span class="site-brand__mark">售</span>
        <span>
          <strong>汉中电子售后服务平台</strong>
          <small>配件商城 · 售后申请 · 商家服务</small>
        </span>
      </RouterLink>

      <nav class="site-nav">
        <RouterLink
          v-for="item in navItems"
          :key="item.label"
          class="site-nav__link"
          :class="{ active: route.name === item.to.name }"
          :to="item.to"
        >
          {{ item.label }}
        </RouterLink>
      </nav>

      <div class="site-auth">
        <template v-if="session.token">
          <div class="site-auth__profile">
            <strong>{{ session.appUser?.nickName || session.appUser?.phone || '已登录' }}</strong>
            <span>{{ roleLabel }}</span>
          </div>
          <button class="btn btn--ghost btn--small" @click="handleLogout">退出</button>
        </template>
        <RouterLink v-else class="btn btn--primary btn--small" :to="{ name: 'auth' }">登录 / 注册</RouterLink>
      </div>
    </div>
  </header>
</template>
