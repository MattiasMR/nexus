<script setup lang="ts">
import { type HTMLAttributes } from 'vue'
import { ToastRoot } from 'radix-vue'
import { cn } from '@/lib/utils'
import { type ToastVariant, toastVariants } from '.'

defineProps<{
  class?: HTMLAttributes['class']
  variant?: ToastVariant
  defaultOpen?: boolean
  open?: boolean
}>()

defineEmits<{
  'update:open': [value: boolean]
}>()
</script>

<template>
  <ToastRoot
    :class="cn(toastVariants({ variant }), $props.class)"
  >
    <slot />
  </ToastRoot>
</template>
