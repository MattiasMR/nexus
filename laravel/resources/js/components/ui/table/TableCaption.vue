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
  <caption
    v-bind="delegatedProps"
    :class="cn('mt-4 text-sm text-muted-foreground', props.class)"
  >
    <slot />
  </caption>
</template>
