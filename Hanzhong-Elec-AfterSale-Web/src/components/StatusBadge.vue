<script setup>
const props = defineProps({
  label: {
    type: String,
    required: true
  },
  tone: {
    type: String,
    default: 'muted'
  }
})
</script>

<template>
  <span class="status-badge" :class="`status-badge--${props.tone}`">{{ props.label }}</span>
</template>
