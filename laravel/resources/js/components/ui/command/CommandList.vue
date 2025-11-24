<script setup lang="ts">
import type { HTMLAttributes } from 'vue'
import { ComboboxContent } from 'radix-vue'
import { cn } from '@/lib/utils'

defineProps<{ class?: HTMLAttributes['class'] }>()
</script>

<template>
  <ComboboxContent
    :class="cn('max-h-[300px] overflow-y-auto overflow-x-hidden', $props.class)"
  >
    <slot />
  </ComboboxContent>
</template>
