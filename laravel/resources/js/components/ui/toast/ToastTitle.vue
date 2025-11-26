<script setup lang="ts">
import { type HTMLAttributes } from 'vue'
import { ToastTitle } from 'radix-vue'
import { cn } from '@/lib/utils'

defineProps<{
  class?: HTMLAttributes['class']
}>()
</script>

<template>
  <ToastTitle :class="cn('text-sm font-semibold', $props.class)">
    <slot />
  </ToastTitle>
</template>
