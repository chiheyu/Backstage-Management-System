import { createRouter, createWebHistory } from 'vue-router'
import HomeView from '@/views/HomeView.vue'
import AuthView from '@/views/AuthView.vue'
import MallView from '@/views/MallView.vue'
import AccessoryDetailView from '@/views/AccessoryDetailView.vue'
import MerchantListView from '@/views/MerchantListView.vue'
import MerchantDetailView from '@/views/MerchantDetailView.vue'
import AfterSaleApplyView from '@/views/AfterSaleApplyView.vue'
import AfterSaleOrdersView from '@/views/AfterSaleOrdersView.vue'
import OrdersView from '@/views/OrdersView.vue'
import ProfileView from '@/views/ProfileView.vue'
import MerchantSettingsView from '@/views/MerchantSettingsView.vue'
import { bootstrapSession } from '@/lib/session'

const router = createRouter({
  history: createWebHistory(),
  routes: [
    { path: '/', name: 'home', component: HomeView },
    { path: '/auth', name: 'auth', component: AuthView },
    { path: '/mall', name: 'mall', component: MallView },
    { path: '/accessories/:id', name: 'accessory-detail', component: AccessoryDetailView, props: true },
    { path: '/merchants', name: 'merchants', component: MerchantListView },
    { path: '/merchants/:id', name: 'merchant-detail', component: MerchantDetailView, props: true },
    { path: '/after-sales/apply', name: 'after-sales-apply', component: AfterSaleApplyView },
    { path: '/after-sales/orders', name: 'after-sales-orders', component: AfterSaleOrdersView },
    { path: '/orders', name: 'orders', component: OrdersView },
    { path: '/profile', name: 'profile', component: ProfileView },
    { path: '/merchant/settings', name: 'merchant-settings', component: MerchantSettingsView }
  ],
  scrollBehavior() {
    return { top: 0 }
  }
})

let bootstrapped = false

router.beforeEach(async () => {
  if (!bootstrapped) {
    await bootstrapSession()
    bootstrapped = true
  }
  return true
})

export default router
