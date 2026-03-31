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
      { label: '配件订单', to: { name: 'merchant-accessory-orders' } },
      { label: '商品管理', to: { name: 'merchant-accessories' } },
      { label: '工作台', to: { name: 'cart' } },
      {
        label: '我的店铺',
        to: merchantStoreLink.value,
        matchNames: ['merchant-detail', 'merchant-settings']
      },
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
      <div class="site-header__top">
        <RouterLink class="site-brand" :to="{ name: 'home' }">
          <span class="site-brand__mark">售</span>
          <span class="site-brand__copy">
            <strong>汉中电子售后服务平台</strong>
            <small>配件商城 / 售后申请 / 商家服务</small>
          </span>
        </RouterLink>

        <nav class="site-nav" aria-label="Primary">
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
              <strong>{{ session.appUser?.nickName || session.appUser?.phone || '已登录用户' }}</strong>
              <div class="site-auth__meta">
                <span class="site-auth__badge">{{ roleLabel }}</span>
                <span>{{ session.appUser?.phone || 'Mobile account' }}</span>
              </div>
            </div>
            <button class="btn btn--ghost btn--small" @click="handleLogout">退出</button>
          </template>
          <RouterLink v-else class="btn btn--primary btn--small" :to="{ name: 'auth' }">登录 / 注册</RouterLink>
        </div>
      </div>

    </div>
  </header>
</template>

<style scoped>
.site-header :deep(.page-shell) {
  width: min(1520px, calc(100vw - 24px));
}

.site-header__inner {
  display: block;
}

.site-header__top {
  display: grid;
  grid-template-columns: minmax(220px, auto) minmax(0, 1fr) auto;
  align-items: center;
  gap: 14px;
}

.site-brand {
  min-width: 0;
  justify-self: start;
}

.site-brand__copy strong {
  font-size: 16px;
}

.site-brand__copy small:last-child {
  font-size: 11px;
}

.site-nav {
  width: 100%;
  max-width: 100%;
  justify-self: center;
  justify-content: center;
  flex-wrap: nowrap;
  overflow-x: auto;
  overflow-y: hidden;
  gap: 6px;
  padding: 8px;
  white-space: nowrap;
}

.site-nav__link {
  flex: 0 0 auto;
  padding: 8px 12px;
  font-size: 13px;
  white-space: nowrap;
}

.site-auth {
  flex: 0 0 auto;
  gap: 10px;
  justify-self: end;
}

.site-auth__profile {
  min-width: 168px;
  padding: 10px 12px;
}

.site-auth__profile strong {
  font-size: 14px;
}

.site-auth__meta {
  gap: 6px;
  font-size: 11px;
}

.site-nav::-webkit-scrollbar {
  width: 0;
  height: 0;
}

@media (max-width: 1180px) {
  .site-header__top {
    grid-template-columns: auto minmax(0, 1fr);
  }

  .site-auth {
    display: none;
  }
}

@media (max-width: 760px) {
  .site-header :deep(.page-shell) {
    width: min(100vw - 16px, 1520px);
  }

  .site-header__inner {
    gap: 10px;
  }

  .site-brand__copy small:last-child {
    display: none;
  }

  .site-brand__copy strong {
    font-size: 14px;
  }

  .site-nav__link {
    padding: 8px 10px;
    font-size: 12px;
  }
}
</style>
