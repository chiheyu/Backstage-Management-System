<script setup>
defineProps({
  title: {
    type: String,
    required: true
  },
  description: {
    type: String,
    required: true
  },
  actionLabel: {
    type: String,
    default: ''
  }
})

defineEmits(['action'])
</script>

<template>
  <section class="surface-card empty-state">
    <div class="empty-state__mark" aria-hidden="true">空</div>
    <div class="empty-state__content">
      <h3>{{ title }}</h3>
      <p>{{ description }}</p>
    </div>
    <button v-if="actionLabel" class="btn btn--primary" @click="$emit('action')">
      {{ actionLabel }}
    </button>
  </section>
</template>
