<script setup>
import { computed } from 'vue'
import { useRouter } from 'vue-router'
import EmptyState from '@/components/EmptyState.vue'
import { getRoleState } from '@/lib/domain'
import { merchantFeatureSupport } from '@/lib/merchantDashboard'
import { session } from '@/lib/session'

const router = useRouter()
const roleState = computed(() => getRoleState(session.roleType))
</script>

<template>
  <section class="page-shell merchant-accessory-orders-page">
    <EmptyState
      v-if="!session.token"
      title="请先登录商家账号"
      description="商家配件订单页只对已登录商家开放。"
      action-label="前往登录"
      @action="router.push({ name: 'auth' })"
    />

    <EmptyState
      v-else-if="!roleState.isMerchant"
      title="当前账号不是已审核商家"
      description="普通用户和待审核商家无法进入商家配件订单页。"
      action-label="返回个人中心"
      @action="router.push({ name: 'profile' })"
    />

    <section v-else class="surface-card section-card unsupported-card">
      <span class="eyebrow">接口适配</span>
      <h1>商家配件订单页已停用</h1>
      <p>当前后端没有开放商家配件订单相关接口，网页端已停止请求这些地址，因此这里改为静态说明页，不再弹出“请求失败”。</p>

      <div class="unsupported-grid">
        <article class="unsupported-item">
          <strong>当前状态</strong>
          <p>{{ merchantFeatureSupport.accessoryOrders ? '已开放' : '未开放' }}</p>
        </article>
        <article class="unsupported-item">
          <strong>已处理</strong>
          <p>导航入口已移除，首页、工作台和个人中心也不再调用对应接口。</p>
        </article>
        <article class="unsupported-item">
          <strong>建议入口</strong>
          <p>请改用售后工单、售后回执和店铺设置页面继续处理商家业务。</p>
        </article>
      </div>

      <div class="action-row">
        <button class="btn btn--primary" @click="router.push({ name: 'cart' })">返回工作台</button>
        <button class="btn btn--ghost" @click="router.push({ name: 'after-sales-orders', query: { mode: 'pending' } })">查看售后工单</button>
      </div>
    </section>
  </section>
</template>

<style scoped>
.merchant-accessory-orders-page {
  display: grid;
  gap: 22px;
}

.unsupported-card {
  padding: 28px;
}

.unsupported-card h1 {
  margin: 14px 0 8px;
  font-size: clamp(32px, 4vw, 48px);
  line-height: 1.08;
}

.unsupported-grid {
  display: grid;
  grid-template-columns: repeat(3, minmax(0, 1fr));
  gap: 16px;
  margin: 24px 0;
}

.unsupported-item {
  padding: 18px;
  border-radius: 24px;
  background: linear-gradient(180deg, rgba(255, 255, 255, 0.94), rgba(248, 244, 236, 0.94));
  border: 1px solid rgba(17, 61, 77, 0.08);
}

.unsupported-item strong {
  display: block;
  margin-bottom: 8px;
  color: var(--primary-deep);
}

.unsupported-item p {
  margin: 0;
  color: var(--muted);
}

@media (max-width: 980px) {
  .unsupported-grid {
    grid-template-columns: 1fr;
  }
}
</style>
