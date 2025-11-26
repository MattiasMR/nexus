<script setup lang="ts">
import { type HTMLAttributes } from 'vue'
import { AlertDialogCancel } from 'radix-vue'
import { buttonVariants } from '@/components/ui/button'
import { cn } from '@/lib/utils'

defineProps<{
  class?: HTMLAttributes['class']
}>()
</script>

<template>
  <AlertDialogCancel
    :class="cn(buttonVariants({ variant: 'outline' }), 'mt-2 sm:mt-0', $props.class)"
  >
    <slot />
  </AlertDialogCancel>
</template>
