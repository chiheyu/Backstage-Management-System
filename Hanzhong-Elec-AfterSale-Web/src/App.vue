<script setup>
import { onMounted } from 'vue'
import { RouterView } from 'vue-router'
import SiteHeader from '@/components/SiteHeader.vue'
import { noticeStore } from '@/lib/notice'
import { bootstrapSession, session } from '@/lib/session'

onMounted(() => {
  bootstrapSession()
})
</script>

<template>
  <div class="app-root">
    <div class="app-backdrop"></div>
    <SiteHeader />

    <main class="app-main">
      <section v-if="!session.bootstrapped" class="page-shell surface-card boot-card">
        <span class="eyebrow">系统加载中</span>
        <h1>正在同步账号信息</h1>
        <p>请稍候，系统正在检查登录状态并读取当前资料。</p>
      </section>
      <RouterView v-else />
    </main>

    <TransitionGroup name="toast" tag="div" class="toast-stack">
      <div
        v-for="notice in noticeStore.items"
        :key="notice.id"
        class="toast-item"
        :class="`toast-item--${notice.tone}`"
      >
        {{ notice.message }}
      </div>
    </TransitionGroup>
  </div>
</template>
