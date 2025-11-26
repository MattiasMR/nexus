<script setup lang="ts">
import { AlertDialogRoot } from 'radix-vue'

defineProps<{
  open?: boolean
  defaultOpen?: boolean
}>()

defineEmits<{
  'update:open': [value: boolean]
}>()
</script>

<template>
  <AlertDialogRoot>
    <slot />
  </AlertDialogRoot>
</template>
