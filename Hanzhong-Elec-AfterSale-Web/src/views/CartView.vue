<script setup>
import { computed, onMounted, ref, watch } from 'vue'
import { useRouter } from 'vue-router'
import EmptyState from '@/components/EmptyState.vue'
import { userApi } from '@/lib/api'
import { MERCHANT_AUDIT_STATUS, formatMoney, getRoleState, getStatusMeta } from '@/lib/domain'
import { fetchMerchantDashboardSummary, merchantFeatureSupport } from '@/lib/merchantDashboard'
import {
  addCartItem,
  clearCart,
  getDefaultAddress,
  loadCartList,
  saveCartList
} from '@/lib/localData'
import { pushNotice } from '@/lib/notice'
import { session } from '@/lib/session'

const router = useRouter()

const cartList = ref(loadCartList())
const checkoutLoading = ref(false)
const workbenchLoading = ref(false)
const merchantSummary = ref(null)

const roleState = computed(() => getRoleState(session.roleType))
const defaultAddress = computed(() => getDefaultAddress())
const totalPrice = computed(() => cartList.value.reduce((sum, item) => sum + Number(item.price || 0) * Number(item.count || 0), 0))
const merchantStoreLink = computed(() => {
  const merchantId = merchantSummary.value?.merchant?.merchantId || session.merchant?.merchantId
  if (merchantId) {
    return { name: 'merchant-detail', params: { id: merchantId } }
  }
  return { name: 'merchant-settings' }
})

const merchantCards = computed(() => {
  const counts = merchantSummary.value?.counts || {}
  return [
    { label: '待接售后', value: counts.pendingAfterSales || 0, desc: '等待当前商家接单的售后工单' },
    { label: '处理中售后', value: counts.activeAfterSales || 0, desc: '已接单或维修中的工单' },
    { label: '已完成工单', value: counts.completedAfterSales || 0, desc: '已经完工并提交回执的工单' },
    {
      label: '店铺状态',
      value: getStatusMeta(MERCHANT_AUDIT_STATUS, merchantSummary.value?.merchant?.auditStatus).label,
      desc: '当前网页端仅接入后端已开放的商家售后能力'
    }
  ]
})

function syncCart(nextList = cartList.value) {
  cartList.value = saveCartList(nextList)
}

function updateCount(item, offset) {
  const nextCount = Number(item.count || 0) + offset
  if (nextCount < 1) {
    return
  }
  if (nextCount > Number(item.stock || 0)) {
    pushNotice('已达到当前商品库存上限', 'danger')
    return
  }
  item.count = nextCount
  syncCart()
}

function removeItem(accessoryId) {
  syncCart(cartList.value.filter(item => String(item.id) !== String(accessoryId)))
  pushNotice('商品已从购物车移除', 'success')
}

async function checkout() {
  if (!session.token) {
    router.push({ name: 'auth' })
    return
  }
  if (!roleState.value.isUser) {
    pushNotice('当前账号不能使用购物车结算', 'danger')
    return
  }
  if (!cartList.value.length) {
    return
  }
  if (!defaultAddress.value) {
    pushNotice('请先添加默认收货地址', 'danger')
    router.push({ name: 'addresses' })
    return
  }
  if (checkoutLoading.value) {
    return
  }

  checkoutLoading.value = true
  const paidIds = []

  try {
    for (const item of cartList.value) {
      await userApi.createAccessoryOrder({
        accessoryId: item.accessoryId || item.id,
        quantity: Number(item.count || 0),
        receiverName: defaultAddress.value.name,
        receiverPhone: defaultAddress.value.phone,
        receiverAddress: [defaultAddress.value.region, defaultAddress.value.detail].filter(Boolean).join(' ').trim(),
        orderRemark: ''
      })
      paidIds.push(String(item.id))
    }

    clearCart()
    cartList.value = []
    pushNotice('购物车已结算完成', 'success')
    router.push({ name: 'orders' })
  } catch (error) {
    if (paidIds.length) {
      syncCart(cartList.value.filter(item => !paidIds.includes(String(item.id))))
    }
    pushNotice(error.message || '购物车结算失败', 'danger')
  } finally {
    checkoutLoading.value = false
  }
}

function duplicateItem(item) {
  addCartItem({ ...item, count: 1 })
  cartList.value = loadCartList()
  pushNotice('已增加 1 件相同商品', 'success')
}

async function loadWorkbenchData() {
  if (!roleState.value.isMerchant) {
    return
  }

  workbenchLoading.value = true
  try {
    merchantSummary.value = await fetchMerchantDashboardSummary()
    session.merchant = merchantSummary.value?.merchant || session.merchant
  } catch (error) {
    pushNotice(error.message || '商家工作台数据加载失败', 'danger')
  } finally {
    workbenchLoading.value = false
  }
}

watch(
  () => session.roleType,
  () => {
    if (roleState.value.isMerchant) {
      loadWorkbenchData()
      return
    }

    cartList.value = loadCartList()
  }
)

onMounted(() => {
  if (roleState.value.isMerchant) {
    loadWorkbenchData()
  }
})
</script>

<template>
  <section class="page-shell cart-page">
    <template v-if="roleState.isMerchant">
      <section class="glass-card workbench-hero">
        <div>
          <span class="eyebrow">商家工作台</span>
          <h1>{{ merchantSummary?.merchant?.merchantName || '商家工作台' }}</h1>
          <p>工作台现在只保留后端真实存在的商家售后能力，配件订单和商品管理入口已隐藏，避免进入页面后连续请求失败。</p>
        </div>
        <div class="surface-card workbench-hero__side">
          <strong>{{ merchantSummary?.merchant?.contactPhone || '--' }}</strong>
          <span>{{ merchantSummary?.merchant?.address || '请先完善店铺地址' }}</span>
          <span>{{ workbenchLoading ? '正在同步商家工作台数据...' : '网页端与小程序共享同一套商家售后和店铺资料数据。' }}</span>
        </div>
      </section>

      <section class="summary-grid">
        <article v-for="item in merchantCards" :key="item.label" class="surface-card summary-card">
          <span>{{ item.label }}</span>
          <strong>{{ item.value }}</strong>
          <p>{{ item.desc }}</p>
        </article>
      </section>

      <section class="workbench-grid">
        <button class="surface-card workbench-card" @click="router.push({ name: 'after-sales-orders', query: { mode: 'pending' } })">
          <strong>待接售后</strong>
          <span>查看等待当前商家接单的工单</span>
        </button>
        <button class="surface-card workbench-card" @click="router.push({ name: 'after-sales-orders', query: { mode: 'mine' } })">
          <strong>我的工单</strong>
          <span>查看已接单和处理中工单</span>
        </button>
        <button class="surface-card workbench-card" @click="router.push({ name: 'after-sales-apply' })">
          <strong>售后回执</strong>
          <span>填写检测结果、维修进度和完工说明</span>
        </button>
        <button class="surface-card workbench-card" @click="router.push({ name: 'merchant-settings' })">
          <strong>店铺设置</strong>
          <span>维护联系人、地址和服务范围</span>
        </button>
        <button class="surface-card workbench-card" @click="router.push(merchantStoreLink)">
          <strong>我的店铺</strong>
          <span>查看门店对外展示信息</span>
        </button>
        <button class="surface-card workbench-card" @click="router.push({ name: 'profile' })">
          <strong>个人中心</strong>
          <span>查看账号概览和商家快捷入口</span>
        </button>
      </section>

      <section class="surface-card section-card">
        <div class="section-head">
          <div>
            <span class="eyebrow">接口适配</span>
            <h2>当前工作台已静默降级</h2>
            <p>只展示后端已经开放的商家售后能力，未开放的页面入口不再主动请求。</p>
          </div>
        </div>

        <div class="workbench-grid">
          <article class="workbench-card">
            <strong>已接入</strong>
            <span>商家信息、待接售后、我的工单、售后回执、店铺资料维护。</span>
          </article>
          <article class="workbench-card">
            <strong>已隐藏</strong>
            <span v-if="!merchantFeatureSupport.accessoryOrders">商家配件订单接口未开放，相关入口已移除。</span>
            <span v-if="!merchantFeatureSupport.accessoryCatalog">商家商品管理接口未开放，网页端保留公共配件浏览，不再进入管理模式。</span>
          </article>
        </div>
      </section>
    </template>

    <template v-else>
      <section class="glass-card cart-hero">
        <div>
          <span class="eyebrow">购物车</span>
          <h1>我的购物车</h1>
          <p>和小程序一致，购物车暂存在当前网页端本地，结算时会写入后端配件订单。</p>
        </div>
        <div class="surface-card cart-hero__side">
          <strong>￥{{ formatMoney(totalPrice) }}</strong>
          <span>{{ cartList.length }} 件商品</span>
          <span>{{ defaultAddress ? `${defaultAddress.name} / ${defaultAddress.phone}` : '尚未设置默认地址' }}</span>
        </div>
      </section>

      <section v-if="cartList.length" class="cart-grid">
        <section class="surface-card section-card">
          <div class="section-head">
            <div>
              <span class="eyebrow">商品列表</span>
              <h2>待结算商品</h2>
              <p>可直接修改数量或删除商品，结算后会逐条提交到后端。</p>
            </div>
          </div>

          <div class="cart-list">
            <article v-for="item in cartList" :key="item.id" class="cart-item">
              <img :src="item.image" :alt="item.name" />
              <div class="cart-item__content">
                <strong>{{ item.name }}</strong>
                <span>{{ item.spec || '通用配件' }}</span>
                <p>{{ item.desc || '暂无商品说明' }}</p>
                <div class="between-row cart-item__footer">
                  <div>
                    <strong>￥{{ formatMoney(item.price) }}</strong>
                    <span>库存 {{ item.stock }}</span>
                  </div>
                  <div class="action-row">
                    <button class="btn btn--ghost btn--small" @click="updateCount(item, -1)">-1</button>
                    <span class="cart-item__count">{{ item.count }}</span>
                    <button class="btn btn--ghost btn--small" @click="updateCount(item, 1)">+1</button>
                    <button class="btn btn--ghost btn--small" @click="duplicateItem(item)">再加一件</button>
                    <button class="btn btn--ghost btn--small" @click="removeItem(item.id)">删除</button>
                  </div>
                </div>
              </div>
            </article>
          </div>
        </section>

        <section class="surface-card section-card cart-side">
          <div class="section-head">
            <div>
              <span class="eyebrow">结算信息</span>
              <h2>结算准备</h2>
              <p>当前默认地址会用于购物车中全部商品的统一下单。</p>
            </div>
          </div>

          <article class="cart-summary-card">
            <strong>默认收货地址</strong>
            <p v-if="defaultAddress">
              {{ defaultAddress.name }} / {{ defaultAddress.phone }}<br />
              {{ defaultAddress.region }} {{ defaultAddress.detail }}
            </p>
            <p v-else>尚未设置默认地址，请先补充地址信息。</p>
            <button class="btn btn--ghost btn--small" @click="router.push({ name: 'addresses' })">管理地址</button>
          </article>

          <article class="cart-summary-card">
            <strong>订单总额</strong>
            <p>￥{{ formatMoney(totalPrice) }}</p>
            <button class="btn btn--primary" :disabled="checkoutLoading" @click="checkout">
              {{ checkoutLoading ? '结算中...' : '立即结算' }}
            </button>
          </article>
        </section>
      </section>

      <EmptyState
        v-else
        title="购物车还是空的"
        description="先去配件商城把想要的商品加入购物车，再回来统一结算。"
        action-label="去逛配件商城"
        @action="router.push({ name: 'mall' })"
      />
    </template>
  </section>
</template>

<style scoped>
.cart-page {
  display: grid;
  gap: 22px;
}

.cart-hero,
.workbench-hero {
  display: grid;
  grid-template-columns: minmax(0, 1fr) 320px;
  gap: 22px;
  padding: 28px;
}

.cart-hero h1,
.workbench-hero h1 {
  margin: 14px 0 8px;
  font-size: clamp(32px, 4vw, 48px);
  line-height: 1.08;
}

.cart-hero__side,
.workbench-hero__side {
  display: grid;
  gap: 10px;
  align-content: start;
  padding: 22px;
}

.cart-hero__side strong,
.workbench-hero__side strong {
  font-size: 30px;
  color: var(--primary-deep);
}

.summary-grid {
  display: grid;
  grid-template-columns: repeat(4, minmax(0, 1fr));
  gap: 16px;
}

.summary-card {
  padding: 20px;
}

.summary-card span {
  color: var(--muted);
}

.summary-card strong {
  display: block;
  margin-top: 10px;
  font-size: 28px;
  color: var(--primary-deep);
}

.summary-card p {
  margin-top: 10px;
}

.cart-grid {
  display: grid;
  grid-template-columns: minmax(0, 1.14fr) minmax(320px, 0.86fr);
  gap: 24px;
}

.cart-list,
.workbench-grid {
  display: grid;
  gap: 16px;
}

.cart-item,
.workbench-grid {
  align-items: stretch;
}

.cart-item {
  display: grid;
  grid-template-columns: 132px minmax(0, 1fr);
  gap: 16px;
  padding: 18px;
  border-radius: 24px;
  background: linear-gradient(180deg, rgba(255, 255, 255, 0.94), rgba(248, 244, 236, 0.94));
  border: 1px solid rgba(17, 61, 77, 0.08);
}

.cart-item img {
  width: 132px;
  height: 132px;
  object-fit: cover;
  border-radius: 20px;
}

.cart-item__content {
  display: grid;
  gap: 8px;
}

.cart-item__content strong,
.cart-summary-card strong,
.workbench-card strong {
  display: block;
}

.cart-item__content span,
.cart-item__content p,
.cart-summary-card p,
.workbench-card span {
  color: var(--muted);
}

.cart-item__count {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  min-width: 28px;
  font-weight: 700;
}

.cart-summary-card,
.workbench-card {
  padding: 18px;
  border-radius: 24px;
  background: linear-gradient(180deg, rgba(255, 255, 255, 0.94), rgba(248, 244, 236, 0.94));
  border: 1px solid rgba(17, 61, 77, 0.08);
}

.cart-side {
  display: grid;
  gap: 16px;
  align-content: start;
}

.workbench-grid {
  grid-template-columns: repeat(3, minmax(0, 1fr));
}

.workbench-card {
  text-align: left;
}

@media (max-width: 980px) {
  .cart-hero,
  .workbench-hero,
  .summary-grid,
  .cart-grid {
    grid-template-columns: 1fr;
  }
}

@media (max-width: 720px) {
  .cart-hero,
  .workbench-hero,
  .cart-item,
  .cart-item__footer,
  .workbench-grid {
    display: grid;
  }

  .cart-hero,
  .workbench-hero {
    padding: 18px;
  }
}
</style>
