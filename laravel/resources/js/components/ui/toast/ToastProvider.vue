<script setup lang="ts">
import { ToastProvider } from 'radix-vue'

defineProps<{
  swipeDirection?: 'up' | 'down' | 'left' | 'right'
  swipeThreshold?: number
  duration?: number
  label?: string
}>()
</script>

<template>
  <ToastProvider>
    <slot />
  </ToastProvider>
</template>
