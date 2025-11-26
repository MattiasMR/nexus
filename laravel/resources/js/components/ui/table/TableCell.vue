<script setup lang="ts">
import { cn } from '@/lib/utils';
import { HTMLAttributes, computed } from 'vue';

const props = defineProps<{
  class?: HTMLAttributes['class'];
}>();

const delegatedProps = computed(() => {
  const { class: _, ...delegated } = props;
  return delegated;
});
</script>

<template>
  <td
    v-bind="delegatedProps"
    :class="cn('p-4 align-middle [&:has([role=checkbox])]:pr-0', props.class)"
  >
    <slot />
  </td>
</template>
