<script setup lang="ts">
import { TabsRoot } from 'radix-vue';
import { cn } from '@/lib/utils';
import { computed } from 'vue';

const props = defineProps<{
    defaultValue?: string;
    modelValue?: string;
    class?: string;
}>();

const emit = defineEmits<{
    'update:modelValue': [value: string];
}>();

const delegatedProps = computed(() => {
    const { class: _, ...delegated } = props;
    return delegated;
});
</script>

<template>
    <TabsRoot v-bind="delegatedProps" :class="cn('w-full', props.class)">
        <slot />
    </TabsRoot>
</template>
