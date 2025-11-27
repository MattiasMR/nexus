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
  <tbody
    v-bind="delegatedProps"
    :class="cn('[&_tr:last-child]:border-0', props.class)"
  >
    <slot />
  </tbody>
</template>
