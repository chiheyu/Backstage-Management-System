<script setup>
import { computed } from 'vue'
import { RouterLink, useRoute, useRouter } from 'vue-router'
import { getRoleLabel, getRoleState } from '@/lib/domain'
import { logoutSession, session } from '@/lib/session'

const router = useRouter()
const route = useRoute()

const roleState = computed(() => getRoleState(session.roleType))
const roleLabel = computed(() => getRoleLabel(session.roleType))
const merchantStoreLink = computed(() => {
  const merchantId = session.merchant?.merchantId
  if (merchantId) {
    return { name: 'merchant-detail', params: { id: merchantId } }
  }
  return { name: 'merchant-settings' }
})

const navItems = computed(() => {
  if (roleState.value.isMerchant) {
    return [
      { label: '首页', to: { name: 'home' } },
      { label: '售后工单', to: { name: 'after-sales-orders', query: { mode: 'pending' } } },
      { label: '售后回执', to: { name: 'after-sales-apply' } },
      { label: '工作台', to: { name: 'cart' } },
      {
        label: '我的店铺',
        to: merchantStoreLink.value,
        matchNames: ['merchant-detail', 'merchant-settings']
      },
      { label: '配件商城', to: { name: 'mall' } },
      { label: '个人中心', to: { name: 'profile' } }
    ]
  }

  if (roleState.value.isPendingMerchant) {
    return [
      { label: '首页', to: { name: 'home' } },
      { label: '配件商城', to: { name: 'mall' } },
      { label: '购物车', to: { name: 'cart' } },
      { label: '服务商家', to: { name: 'merchants' } },
      { label: '地址簿', to: { name: 'addresses' } },
      { label: '店铺设置', to: { name: 'merchant-settings' } },
      { label: '个人中心', to: { name: 'profile' } }
    ]
  }

  return [
    { label: '首页', to: { name: 'home' } },
    { label: '配件商城', to: { name: 'mall' } },
    { label: '购物车', to: { name: 'cart' } },
    { label: '服务商家', to: { name: 'merchants' } },
    { label: '售后申请', to: { name: 'after-sales-apply' } },
    { label: '我的订单', to: { name: 'orders' } },
    { label: '地址簿', to: { name: 'addresses' } },
    { label: '个人中心', to: { name: 'profile' } }
  ]
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
          <small>配件商城 / 售后申请 / 商家服务</small>
        </span>
      </RouterLink>

      <nav class="site-nav">
        <RouterLink
          v-for="item in navItems"
          :key="item.label"
          class="site-nav__link"
          :class="{ active: (item.matchNames || [item.to.name]).includes(route.name) }"
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
