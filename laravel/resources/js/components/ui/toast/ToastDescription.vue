<script setup lang="ts">
import { type HTMLAttributes } from 'vue'
import { ToastDescription } from 'radix-vue'
import { cn } from '@/lib/utils'

defineProps<{
  class?: HTMLAttributes['class']
}>()
</script>

<template>
  <ToastDescription :class="cn('text-sm opacity-90', $props.class)">
    <slot />
  </ToastDescription>
</template>
