<script setup>
import { computed, onBeforeUnmount, onMounted, ref, watch } from 'vue'
import { RouterLink } from 'vue-router'
import EmptyState from '@/components/EmptyState.vue'
import { formatMoney, resolveImage, shortText } from '@/lib/domain'

const props = defineProps({
  eyebrow: {
    type: String,
    default: '配件推荐'
  },
  title: {
    type: String,
    default: '配件推荐'
  },
  description: {
    type: String,
    default: ''
  },
  items: {
    type: Array,
    default: () => []
  },
  emptyTitle: {
    type: String,
    default: '暂无配件'
  },
  emptyDescription: {
    type: String,
    default: '当前没有可展示的配件。'
  },
  ctaLabel: {
    type: String,
    default: '查看全部'
  },
  ctaTo: {
    type: Object,
    default: () => ({ name: 'mall' })
  },
  apiBaseUrl: {
    type: String,
    default: ''
  }
})

const currentIndex = ref(0)
let autoplayTimer = null

const slides = computed(() => Array.isArray(props.items) ? props.items : [])

function normalizeIndex(nextIndex) {
  const length = slides.value.length
  if (!length) {
    return 0
  }
  if (nextIndex < 0) {
    return length - 1
  }
  if (nextIndex >= length) {
    return 0
  }
  return nextIndex
}

function stopAutoplay() {
  if (autoplayTimer) {
    window.clearInterval(autoplayTimer)
    autoplayTimer = null
  }
}

function startAutoplay() {
  stopAutoplay()
  if (slides.value.length <= 1) {
    return
  }
  autoplayTimer = window.setInterval(() => {
    currentIndex.value = normalizeIndex(currentIndex.value + 1)
  }, 4200)
}

function goPrev() {
  currentIndex.value = normalizeIndex(currentIndex.value - 1)
  startAutoplay()
}

function goNext() {
  currentIndex.value = normalizeIndex(currentIndex.value + 1)
  startAutoplay()
}

function goTo(index) {
  currentIndex.value = normalizeIndex(index)
  startAutoplay()
}

watch(
  () => slides.value.map((item) => item.accessoryId || item.id).join(','),
  () => {
    currentIndex.value = 0
    startAutoplay()
  }
)

onMounted(() => {
  startAutoplay()
})

onBeforeUnmount(() => {
  stopAutoplay()
})
</script>

<template>
  <section class="surface-card section-card showcase-section">
    <div class="section-head">
      <div>
        <span class="eyebrow">{{ eyebrow }}</span>
        <h2>{{ title }}</h2>
        <p>{{ description }}</p>
      </div>
      <RouterLink class="btn btn--ghost btn--small" :to="ctaTo">{{ ctaLabel }}</RouterLink>
    </div>

    <div v-if="slides.length" class="showcase-shell">
      <button
        v-if="slides.length > 1"
        type="button"
        class="carousel-nav carousel-nav--prev"
        aria-label="上一张"
        @click="goPrev"
      >
        &lt;
      </button>

      <div class="showcase-track-wrap">
        <div class="showcase-track" :style="{ transform: `translateX(-${currentIndex * 100}%)` }">
          <RouterLink
            v-for="item in slides"
            :key="item.accessoryId || item.id"
            class="showcase-slide"
            :to="{ name: 'accessory-detail', params: { id: item.accessoryId || item.id } }"
          >
            <div class="showcase-slide__media">
              <img :src="resolveImage(item.coverImage, apiBaseUrl)" :alt="item.accessoryName || item.name" />
              <div class="showcase-chip">{{ item.categoryName || item.spec || '通用配件' }}</div>
              <div class="showcase-sales">销量 {{ item.salesCount || 0 }}</div>
            </div>
            <div class="showcase-slide__content">
              <h3>{{ item.accessoryName || item.name }}</h3>
              <p>{{ shortText(item.accessoryDesc || item.desc || '适用于常见电子产品维修、更换和保养场景。', 72) }}</p>
              <div class="showcase-slide__meta">
                <strong>¥{{ formatMoney(item.price) }}</strong>
                <span>库存 {{ item.stock ?? '--' }}</span>
              </div>
            </div>
          </RouterLink>
        </div>
      </div>

      <button
        v-if="slides.length > 1"
        type="button"
        class="carousel-nav carousel-nav--next"
        aria-label="下一张"
        @click="goNext"
      >
        &gt;
      </button>
    </div>

    <div v-if="slides.length > 1" class="showcase-dots">
      <button
        v-for="(item, index) in slides"
        :key="item.accessoryId || item.id || index"
        type="button"
        class="showcase-dot"
        :class="{ active: index === currentIndex }"
        @click="goTo(index)"
      ></button>
    </div>

    <EmptyState
      v-else
      :title="emptyTitle"
      :description="emptyDescription"
    />
  </section>
</template>

<style scoped>
.showcase-section {
  display: grid;
  gap: 18px;
}

.showcase-shell {
  position: relative;
  padding: 0 52px;
}

.showcase-track-wrap {
  overflow: hidden;
  border-radius: 28px;
}

.showcase-track {
  display: flex;
  transition: transform 0.45s cubic-bezier(0.2, 0.8, 0.2, 1);
}

.showcase-slide {
  min-width: 100%;
  display: grid;
  grid-template-columns: minmax(138px, 0.48fr) minmax(0, 1fr);
  gap: 14px;
  padding: 16px 18px;
  border-radius: 28px;
  background: linear-gradient(135deg, rgba(255, 255, 255, 0.96), rgba(247, 242, 232, 0.96));
  border: 1px solid rgba(17, 61, 77, 0.08);
}

.showcase-slide__media {
  position: relative;
  min-height: 148px;
  border-radius: 24px;
  overflow: hidden;
  background: linear-gradient(135deg, rgba(14, 116, 144, 0.12), rgba(245, 158, 11, 0.16));
}

.showcase-slide__media img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.showcase-chip,
.showcase-sales {
  position: absolute;
  top: 16px;
  display: inline-flex;
  align-items: center;
  min-height: 34px;
  padding: 0 14px;
  border-radius: 999px;
  font-size: 12px;
  font-weight: 800;
  box-shadow: 0 10px 22px rgba(19, 46, 40, 0.12);
}

.showcase-chip {
  left: 16px;
  background: rgba(255, 255, 255, 0.9);
  color: var(--primary-deep);
}

.showcase-sales {
  right: 16px;
  background: linear-gradient(135deg, var(--accent), var(--accent-deep));
  color: #fff;
}

.showcase-slide__content {
  display: grid;
  align-content: center;
  gap: 14px;
}

.showcase-slide__content h3 {
  margin: 0;
  font-size: clamp(20px, 2.2vw, 28px);
  line-height: 1.08;
  color: var(--primary-deep);
}

.showcase-slide__content p {
  margin: 0;
  color: var(--muted);
  line-height: 1.64;
}

.showcase-slide__meta {
  display: flex;
  flex-wrap: wrap;
  align-items: baseline;
  gap: 16px;
}

.showcase-slide__meta strong {
  font-size: 22px;
  color: var(--accent-deep);
}

.showcase-slide__meta span {
  color: var(--muted);
  font-size: 14px;
  font-weight: 700;
}

.carousel-nav {
  position: absolute;
  top: 50%;
  z-index: 2;
  width: 40px;
  height: 40px;
  margin-top: -20px;
  border-radius: 999px;
  border: 1px solid rgba(17, 61, 77, 0.12);
  background: rgba(255, 255, 255, 0.88);
  color: var(--primary-deep);
  font-size: 18px;
  font-weight: 700;
  line-height: 1;
  box-shadow: 0 12px 28px rgba(19, 46, 40, 0.08);
}

.carousel-nav--prev {
  left: 6px;
}

.carousel-nav--next {
  right: 6px;
}

.showcase-dots {
  display: flex;
  justify-content: center;
  gap: 10px;
}

.showcase-dot {
  width: 10px;
  height: 10px;
  border-radius: 999px;
  border: none;
  background: rgba(17, 61, 77, 0.18);
}

.showcase-dot.active {
  width: 28px;
  background: linear-gradient(135deg, var(--primary), var(--accent));
}

@media (max-width: 860px) {
  .showcase-slide {
    grid-template-columns: 1fr;
  }

  .showcase-slide__media {
    min-height: 152px;
  }
}

@media (max-width: 640px) {
  .showcase-shell {
    padding: 0 40px;
  }

  .carousel-nav {
    width: 34px;
    height: 34px;
    margin-top: -17px;
    font-size: 16px;
  }

  .carousel-nav--prev {
    left: 0;
  }

  .carousel-nav--next {
    right: 0;
  }

  .showcase-slide {
    padding: 14px 16px;
  }
}
</style>
