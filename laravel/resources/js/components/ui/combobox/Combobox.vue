<script setup lang="ts">
import { computed, ref } from 'vue'
import { Check, ChevronsUpDown } from 'lucide-vue-next'
import { cn } from '@/lib/utils'
import { Button } from '@/components/ui/button'
import {
  Command,
  CommandEmpty,
  CommandGroup,
  CommandInput,
  CommandItem,
  CommandList,
} from '@/components/ui/command'
import {
  Popover,
  PopoverContent,
  PopoverTrigger,
} from '@/components/ui/popover'

interface Option {
  value: string
  label: string
}

interface Props {
  options: Option[]
  modelValue?: string
  placeholder?: string
  emptyText?: string
  searchPlaceholder?: string
}

const props = withDefaults(defineProps<Props>(), {
  placeholder: 'Seleccione una opción...',
  emptyText: 'No se encontraron resultados',
  searchPlaceholder: 'Buscar...',
})

const emit = defineEmits<{
  'update:modelValue': [value: string]
}>()

const open = ref(false)

const selectedOption = computed(() => {
  return props.options.find((option) => option.value === props.modelValue)
})

const selectOption = (value: string) => {
  emit('update:modelValue', value)
  open.value = false
}
</script>

<template>
  <Popover v-model:open="open">
    <PopoverTrigger as-child>
      <Button
        variant="outline"
        role="combobox"
        :aria-expanded="open"
        class="w-full justify-between"
      >
        {{ selectedOption ? selectedOption.label : placeholder }}
        <ChevronsUpDown class="ml-2 h-4 w-4 shrink-0 opacity-50" />
      </Button>
    </PopoverTrigger>
    <PopoverContent class="w-full p-0" align="start">
      <Command>
        <CommandInput :placeholder="searchPlaceholder" />
        <CommandList>
          <CommandEmpty>{{ emptyText }}</CommandEmpty>
          <CommandGroup>
            <CommandItem
              v-for="option in options"
              :key="option.value"
              :value="option.value"
              @select="selectOption(option.value)"
            >
              <Check
                :class="cn(
                  'mr-2 h-4 w-4',
                  modelValue === option.value ? 'opacity-100' : 'opacity-0'
                )"
              />
              {{ option.label }}
            </CommandItem>
          </CommandGroup>
        </CommandList>
      </Command>
    </PopoverContent>
  </Popover>
</template>
