import { ref } from 'vue'
import { usePage } from '@inertiajs/vue3'
import { watch } from 'vue'

export interface ToastMessage {
  id: string
  title: string
  description?: string
  variant: 'default' | 'success' | 'destructive' | 'warning'
  duration?: number
}

const toasts = ref<ToastMessage[]>([])

export function useToast() {
  const page = usePage()

  // Escuchar cambios en los flash messages de Laravel
  watch(
    () => page.props,
    (props: any) => {
      if (props.flash) {
        if (props.flash.success) {
          toast({
            title: '✓ Éxito',
            description: props.flash.success,
            variant: 'success',
          })
        }
        if (props.flash.error) {
          toast({
            title: '✕ Error',
            description: props.flash.error,
            variant: 'destructive',
          })
        }
        if (props.flash.warning) {
          toast({
            title: '⚠ Advertencia',
            description: props.flash.warning,
            variant: 'warning',
          })
        }
        if (props.flash.info) {
          toast({
            title: 'ℹ Información',
            description: props.flash.info,
            variant: 'default',
          })
        }
      }
    },
    { deep: true, immediate: true }
  )

  function toast({ title, description, variant = 'default', duration = 5000 }: Omit<ToastMessage, 'id'>) {
    const id = Math.random().toString(36).substring(2, 9)
    const newToast: ToastMessage = {
      id,
      title,
      description,
      variant,
      duration,
    }
    
    toasts.value.push(newToast)

    if (duration > 0) {
      setTimeout(() => {
        dismiss(id)
      }, duration)
    }

    return {
      id,
      dismiss: () => dismiss(id),
    }
  }

  function dismiss(id: string) {
    const index = toasts.value.findIndex((t) => t.id === id)
    if (index > -1) {
      toasts.value.splice(index, 1)
    }
  }

  return {
    toasts,
    toast,
    dismiss,
  }
}
