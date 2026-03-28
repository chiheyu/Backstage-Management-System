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
    <div class="app-backdrop" aria-hidden="true">
      <span class="app-backdrop__orb app-backdrop__orb--mint"></span>
      <span class="app-backdrop__orb app-backdrop__orb--amber"></span>
      <span class="app-backdrop__grid"></span>
    </div>
    <SiteHeader />

    <main class="app-main">
      <section v-if="!session.bootstrapped" class="page-shell surface-card boot-card">
        <span class="eyebrow">系统加载中</span>
        <h1>正在同步账号信息</h1>
        <p>请稍候，系统正在检查登录状态并读取当前资料。</p>
      </section>
      <RouterView v-else v-slot="{ Component, route }">
        <Transition name="page-fade" mode="out-in">
          <component :is="Component" :key="route.fullPath" />
        </Transition>
      </RouterView>
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
