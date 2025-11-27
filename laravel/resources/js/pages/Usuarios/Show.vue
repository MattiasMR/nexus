<script setup lang="ts">
import { ref, computed } from 'vue'
import { router, useForm } from '@inertiajs/vue3'
import { Head } from '@inertiajs/vue3'
import AppLayout from '@/layouts/AppLayout.vue'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Tabs, TabsList, TabsTrigger, TabsContent } from '@/components/ui/tabs'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Badge } from '@/components/ui/badge'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select'
import { Switch } from '@/components/ui/switch'
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
  AlertDialogTrigger,
} from '@/components/ui/alert-dialog'
import { 
  ArrowLeft, 
  Save, 
  User, 
  Mail, 
  Phone, 
  Image, 
  Shield, 
  Lock, 
  Key,
  UserX,
  Trash2,
  AlertTriangle,
  CheckCircle,
  XCircle,
} from 'lucide-vue-next'

interface Usuario {
  id: string
  displayName: string
  email: string
  rol: 'admin' | 'profesional' | 'paciente'
  activo: boolean
  photoURL: string | null
  telefono?: string
  rut?: string
  ultimoAcceso: any
  createdAt: any
  emailVerified?: boolean
}

interface Permiso {
  nombre: string
  activo: boolean
  fechaModificacion?: any
}

const props = defineProps<{
  usuario: Usuario
  permisos: Permiso[]
}>()

// Formulario de información básica
const formBasico = useForm({
  displayName: props.usuario.displayName || '',
  email: props.usuario.email || '',
  photoURL: props.usuario.photoURL || '',
  telefono: props.usuario.telefono || '',
})

// Formulario de rol
const formRol = useForm({
  rol: props.usuario.rol || 'paciente',
})

// Formulario de contraseña
const formPassword = useForm({
  password: '',
  password_confirmation: '',
})

// Formulario de permisos
const permisosDisponibles = [
  { nombre: 'gestionar_usuarios', label: 'Gestionar Usuarios' },
  { nombre: 'gestionar_bonos', label: 'Gestionar Bonos' },
  { nombre: 'ver_reportes', label: 'Ver Reportes' },
  { nombre: 'gestionar_citas', label: 'Gestionar Citas' },
  { nombre: 'gestionar_pagos', label: 'Gestionar Pagos' },
]

const permisosActuales = ref<Record<string, boolean>>(
  props.permisos.reduce((acc, p) => {
    acc[p.nombre] = p.activo
    return acc
  }, {} as Record<string, boolean>)
)

// Funciones de guardado
const guardarBasico = () => {
  formBasico.put(`/usuarios/${props.usuario.id}`, {
    preserveScroll: true,
  })
}

const guardarRol = () => {
  formRol.put(`/usuarios/${props.usuario.id}`, {
    preserveScroll: true,
  })
}

const cambiarPassword = () => {
  formPassword.put(`/usuarios/${props.usuario.id}/password`, {
    preserveScroll: true,
    onSuccess: () => {
      formPassword.reset()
    },
  })
}

const enviarResetPassword = () => {
  router.post(`/usuarios/${props.usuario.id}/password-reset`, {}, {
    preserveScroll: true,
  })
}

const verificarEmail = () => {
  router.post(`/usuarios/${props.usuario.id}/verify-email`, {}, {
    preserveScroll: true,
  })
}

const guardarPermisos = () => {
  const permisosArray = Object.entries(permisosActuales.value).map(([nombre, activo]) => ({
    nombre,
    activo,
  }))

  router.put(`/usuarios/${props.usuario.id}/permissions`, {
    permisos: permisosArray,
  }, {
    preserveScroll: true,
  })
}

const toggleEstado = () => {
  router.post(`/usuarios/${props.usuario.id}/toggle-status`, {}, {
    preserveScroll: true,
  })
}

const eliminarUsuario = () => {
  router.delete(`/usuarios/${props.usuario.id}`)
}

const volver = () => {
  router.get('/usuarios')
}

const getBadgeRol = (rol: string) => {
  switch (rol) {
    case 'admin':
      return { label: 'Administrador', class: 'bg-gradient-to-r from-red-500 to-red-600 text-white border-0 hover:from-red-600 hover:to-red-700' }
    case 'profesional':
      return { label: 'Profesional', class: 'bg-gradient-to-r from-blue-500 to-blue-600 text-white border-0 hover:from-blue-600 hover:to-blue-700' }
    case 'paciente':
      return { label: 'Paciente', class: 'bg-gradient-to-r from-green-500 to-green-600 text-white border-0 hover:from-green-600 hover:to-green-700' }
    default:
      return { label: 'Sin Rol', class: 'bg-gray-500 text-white' }
  }
}

const getBadgeEstado = (activo: boolean) => {
  return activo
    ? { label: 'Activo', class: 'bg-gradient-to-r from-purple-500 to-purple-600 text-white border-0 hover:from-purple-600 hover:to-purple-700' }
    : { label: 'Inactivo', class: 'bg-gradient-to-r from-gray-400 to-gray-500 text-white border-0 hover:from-gray-500 hover:to-gray-600' }
}

const getRolLabel = (rol: string) => {
  switch (rol) {
    case 'admin':
      return 'Administrador'
    case 'profesional':
      return 'Profesional'
    case 'paciente':
      return 'Paciente'
    default:
      return 'Sin Rol'
  }
}
</script>

<template>
  <AppLayout>
    <Head :title="`Usuario: ${usuario.displayName}`" />

    <div class="container mx-auto p-6 max-w-6xl">
      <!-- Header -->
      <div class="flex items-center justify-between mb-6">
        <div class="flex items-center gap-4">
          <Button variant="outline" size="icon" @click="volver">
            <ArrowLeft class="h-4 w-4" />
          </Button>
          <div>
            <h1 class="text-3xl font-bold">Gestión de Usuario</h1>
            <p class="text-muted-foreground">Edita toda la información del usuario</p>
          </div>
        </div>
        <div class="flex gap-2">
          <Badge :class="getBadgeRol(usuario.rol).class">
            {{ getBadgeRol(usuario.rol).label }}
          </Badge>
          <Badge :class="getBadgeEstado(usuario.activo).class">
            {{ getBadgeEstado(usuario.activo).label }}
          </Badge>
        </div>
      </div>

      <!-- User Info Card -->
      <Card class="mb-6">
        <CardHeader>
          <div class="flex items-center gap-4">
            <div class="h-16 w-16 rounded-full bg-gradient-to-br from-purple-500 to-pink-500 flex items-center justify-center text-white text-2xl font-bold">
              {{ usuario.displayName?.charAt(0).toUpperCase() || 'U' }}
            </div>
            <div>
              <CardTitle class="text-2xl">{{ usuario.displayName }}</CardTitle>
              <CardDescription>{{ usuario.email }}</CardDescription>
            </div>
          </div>
        </CardHeader>
      </Card>

      <!-- Tabs -->
      <Tabs default-value="basico" class="w-full">
        <TabsList class="grid w-full grid-cols-4">
          <TabsTrigger value="basico">
            <User class="h-4 w-4 mr-2" />
            Información Básica
          </TabsTrigger>
          <TabsTrigger value="seguridad">
            <Shield class="h-4 w-4 mr-2" />
            Seguridad
          </TabsTrigger>
          <TabsTrigger value="permisos">
            <Key class="h-4 w-4 mr-2" />
            Permisos
          </TabsTrigger>
          <TabsTrigger value="acciones">
            <AlertTriangle class="h-4 w-4 mr-2" />
            Acciones
          </TabsTrigger>
        </TabsList>

        <!-- Tab 1: Información Básica -->
        <TabsContent value="basico">
          <Card>
            <CardHeader>
              <CardTitle>Información Personal</CardTitle>
              <CardDescription>
                Actualiza el nombre, email, foto de perfil y teléfono del usuario
              </CardDescription>
            </CardHeader>
            <CardContent class="space-y-4">
              <div class="grid grid-cols-2 gap-4">
                <div class="space-y-2">
                  <Label for="displayName">
                    <User class="h-4 w-4 inline mr-2" />
                    Nombre Completo
                  </Label>
                  <Input
                    id="displayName"
                    v-model="formBasico.displayName"
                    placeholder="Nombre del usuario"
                    :disabled="formBasico.processing"
                  />
                  <span v-if="formBasico.errors.displayName" class="text-sm text-red-500">
                    {{ formBasico.errors.displayName }}
                  </span>
                </div>

                <div class="space-y-2">
                  <Label for="email">
                    <Mail class="h-4 w-4 inline mr-2" />
                    Email
                  </Label>
                  <Input
                    id="email"
                    v-model="formBasico.email"
                    type="email"
                    placeholder="email@ejemplo.com"
                    :disabled="formBasico.processing"
                  />
                  <span v-if="formBasico.errors.email" class="text-sm text-red-500">
                    {{ formBasico.errors.email }}
                  </span>
                </div>

                <div class="space-y-2">
                  <Label for="telefono">
                    <Phone class="h-4 w-4 inline mr-2" />
                    Teléfono
                  </Label>
                  <Input
                    id="telefono"
                    v-model="formBasico.telefono"
                    placeholder="+56 9 1234 5678"
                    :disabled="formBasico.processing"
                  />
                  <span v-if="formBasico.errors.telefono" class="text-sm text-red-500">
                    {{ formBasico.errors.telefono }}
                  </span>
                </div>

                <div class="space-y-2">
                  <Label for="photoURL">
                    <Image class="h-4 w-4 inline mr-2" />
                    URL de Foto de Perfil
                  </Label>
                  <Input
                    id="photoURL"
                    v-model="formBasico.photoURL"
                    placeholder="https://ejemplo.com/foto.jpg"
                    :disabled="formBasico.processing"
                  />
                  <span v-if="formBasico.errors.photoURL" class="text-sm text-red-500">
                    {{ formBasico.errors.photoURL }}
                  </span>
                </div>

                <!-- Campo RUT (solo lectura) -->
                <div class="space-y-2">
                  <Label for="rut" class="flex items-center gap-2">
                    <Shield class="h-4 w-4" />
                    RUT
                  </Label>
                  <Input
                    id="rut"
                    :value="usuario.rut || 'No registrado'"
                    disabled
                    class="cursor-not-allowed opacity-60"
                  />
                  <p class="text-sm text-muted-foreground">
                    El RUT no se puede modificar. Se establece al crear el usuario.
                  </p>
                </div>
              </div>

              <div class="space-y-2">
                <Label for="rol">
                  <Shield class="h-4 w-4 inline mr-2" />
                  Rol del Usuario
                </Label>
                <Select v-model="formRol.rol">
                  <SelectTrigger id="rol">
                    <SelectValue :placeholder="formRol.rol ? getRolLabel(formRol.rol) : 'Selecciona un rol'" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="admin">Administrador</SelectItem>
                    <SelectItem value="profesional">Profesional</SelectItem>
                    <SelectItem value="paciente">Paciente</SelectItem>
                  </SelectContent>
                </Select>
                <span v-if="formRol.errors.rol" class="text-sm text-red-500">
                  {{ formRol.errors.rol }}
                </span>
              </div>

              <div class="flex gap-2 pt-4">
                <Button @click="guardarBasico" :disabled="formBasico.processing">
                  <Save class="h-4 w-4 mr-2" />
                  {{ formBasico.processing ? 'Guardando...' : 'Guardar Cambios' }}
                </Button>
                <Button 
                  v-if="formRol.rol !== usuario.rol" 
                  @click="guardarRol" 
                  :disabled="formRol.processing"
                  variant="outline"
                >
                  <Save class="h-4 w-4 mr-2" />
                  Actualizar Rol
                </Button>
              </div>
            </CardContent>
          </Card>
        </TabsContent>

        <!-- Tab 2: Seguridad -->
        <TabsContent value="seguridad">
          <div class="space-y-4">
            <!-- Cambiar Contraseña -->
            <Card>
              <CardHeader>
                <CardTitle>Cambiar Contraseña</CardTitle>
                <CardDescription>
                  Establece una nueva contraseña para este usuario
                </CardDescription>
              </CardHeader>
              <CardContent class="space-y-4">
                <div class="space-y-2">
                  <Label for="password">
                    <Lock class="h-4 w-4 inline mr-2" />
                    Nueva Contraseña
                  </Label>
                  <Input
                    id="password"
                    v-model="formPassword.password"
                    type="password"
                    placeholder="Mínimo 6 caracteres"
                    :disabled="formPassword.processing"
                  />
                  <span v-if="formPassword.errors.password" class="text-sm text-red-500">
                    {{ formPassword.errors.password }}
                  </span>
                </div>

                <div class="space-y-2">
                  <Label for="password_confirmation">
                    <Lock class="h-4 w-4 inline mr-2" />
                    Confirmar Contraseña
                  </Label>
                  <Input
                    id="password_confirmation"
                    v-model="formPassword.password_confirmation"
                    type="password"
                    placeholder="Repite la contraseña"
                    :disabled="formPassword.processing"
                  />
                </div>

                <AlertDialog>
                  <AlertDialogTrigger as-child>
                    <Button variant="default" :disabled="!formPassword.password || formPassword.processing">
                      <Lock class="h-4 w-4 mr-2" />
                      Cambiar Contraseña
                    </Button>
                  </AlertDialogTrigger>
                  <AlertDialogContent>
                    <AlertDialogHeader>
                      <AlertDialogTitle>¿Cambiar contraseña?</AlertDialogTitle>
                      <AlertDialogDescription>
                        Estás a punto de cambiar la contraseña de <strong>{{ usuario.displayName }}</strong>. 
                        El usuario deberá usar la nueva contraseña para iniciar sesión.
                      </AlertDialogDescription>
                    </AlertDialogHeader>
                    <AlertDialogFooter>
                      <AlertDialogCancel>Cancelar</AlertDialogCancel>
                      <AlertDialogAction @click="cambiarPassword">
                        Confirmar Cambio
                      </AlertDialogAction>
                    </AlertDialogFooter>
                  </AlertDialogContent>
                </AlertDialog>
              </CardContent>
            </Card>

            <!-- Restablecer Contraseña por Email -->
            <Card>
              <CardHeader>
                <CardTitle>Enviar Email de Restablecimiento</CardTitle>
                <CardDescription>
                  Envía un enlace al usuario para que restablezca su contraseña
                </CardDescription>
              </CardHeader>
              <CardContent>
                <AlertDialog>
                  <AlertDialogTrigger as-child>
                    <Button variant="outline">
                      <Mail class="h-4 w-4 mr-2" />
                      Enviar Email de Restablecimiento
                    </Button>
                  </AlertDialogTrigger>
                  <AlertDialogContent>
                    <AlertDialogHeader>
                      <AlertDialogTitle>¿Enviar email de restablecimiento?</AlertDialogTitle>
                      <AlertDialogDescription>
                        Se enviará un email a <strong>{{ usuario.email }}</strong> con instrucciones 
                        para restablecer su contraseña.
                      </AlertDialogDescription>
                    </AlertDialogHeader>
                    <AlertDialogFooter>
                      <AlertDialogCancel>Cancelar</AlertDialogCancel>
                      <AlertDialogAction @click="enviarResetPassword">
                        Enviar Email
                      </AlertDialogAction>
                    </AlertDialogFooter>
                  </AlertDialogContent>
                </AlertDialog>
              </CardContent>
            </Card>

            <!-- Estado de Verificación de Email -->
            <Card>
              <CardHeader>
                <CardTitle>Verificación de Email</CardTitle>
                <CardDescription>
                  Estado de verificación del correo electrónico
                </CardDescription>
              </CardHeader>
              <CardContent class="space-y-4">
                <div class="flex items-center gap-2">
                  <Badge :class="usuario.emailVerified ? 'bg-green-500' : 'bg-yellow-500'">
                    {{ usuario.emailVerified ? 'Email Verificado' : 'Email No Verificado' }}
                  </Badge>
                  {{ usuario.emailVerified ? '' : '' }}
                  <CheckCircle v-if="usuario.emailVerified" class="h-5 w-5 text-green-500" />
                  <XCircle v-else class="h-5 w-5 text-yellow-500" />
                </div>

                <Button 
                  v-if="!usuario.emailVerified" 
                  variant="outline"
                  @click="verificarEmail"
                >
                  <CheckCircle class="h-4 w-4 mr-2" />
                  Verificar Email Manualmente
                </Button>
              </CardContent>
            </Card>
          </div>
        </TabsContent>

        <!-- Tab 3: Permisos -->
        <TabsContent value="permisos">
          <Card>
            <CardHeader>
              <CardTitle>Permisos del Usuario</CardTitle>
              <CardDescription>
                Gestiona los permisos específicos para este usuario
              </CardDescription>
            </CardHeader>
            <CardContent class="space-y-4">
              <div class="space-y-4">
                <div 
                  v-for="permiso in permisosDisponibles" 
                  :key="permiso.nombre"
                  class="flex items-center justify-between p-4 border rounded-lg"
                >
                  <div class="space-y-0.5">
                    <Label :for="permiso.nombre" class="text-base font-medium">
                      {{ permiso.label }}
                    </Label>
                    <p class="text-sm text-muted-foreground">
                      Permiso para {{ permiso.label.toLowerCase() }}
                    </p>
                  </div>
                  <Switch
                    :id="permiso.nombre"
                    v-model:checked="permisosActuales[permiso.nombre]"
                  />
                </div>
              </div>

              <Button @click="guardarPermisos" class="mt-4">
                <Save class="h-4 w-4 mr-2" />
                Guardar Permisos
              </Button>
            </CardContent>
          </Card>
        </TabsContent>

        <!-- Tab 4: Acciones Peligrosas -->
        <TabsContent value="acciones">
          <div class="space-y-4">
            <!-- Suspender/Activar Usuario -->
            <Card class="border-l-4 border-l-orange-500">
              <CardHeader>
                <CardTitle class="flex items-center gap-2">
                  <div class="flex h-10 w-10 items-center justify-center rounded-lg bg-orange-100">
                    <UserX class="h-5 w-5 text-orange-600" />
                  </div>
                  <div>
                    {{ usuario.activo ? 'Suspender Usuario' : 'Activar Usuario' }}
                  </div>
                </CardTitle>
                <CardDescription class="ml-12">
                  {{ usuario.activo 
                    ? 'El usuario no podrá iniciar sesión mientras esté suspendido. Esta acción es reversible.' 
                    : 'Reactiva la cuenta del usuario para que pueda volver a acceder al sistema.' 
                  }}
                </CardDescription>
              </CardHeader>
              <CardContent class="ml-12">
                <AlertDialog>
                  <AlertDialogTrigger as-child>
                    <Button :variant="usuario.activo ? 'outline' : 'default'" class="border-orange-500 text-orange-600 hover:bg-orange-50">
                      <UserX class="h-4 w-4 mr-2" />
                      {{ usuario.activo ? 'Suspender Cuenta' : 'Activar Cuenta' }}
                    </Button>
                  </AlertDialogTrigger>
                  <AlertDialogContent>
                    <AlertDialogHeader>
                      <AlertDialogTitle>
                        ¿{{ usuario.activo ? 'Suspender' : 'Activar' }} cuenta?
                      </AlertDialogTitle>
                      <AlertDialogDescription>
                        {{ usuario.activo
                          ? `El usuario ${usuario.displayName} no podrá iniciar sesión en el sistema. Esta acción es reversible.`
                          : `El usuario ${usuario.displayName} podrá volver a iniciar sesión en el sistema.`
                        }}
                      </AlertDialogDescription>
                    </AlertDialogHeader>
                    <AlertDialogFooter>
                      <AlertDialogCancel>Cancelar</AlertDialogCancel>
                      <AlertDialogAction @click="toggleEstado">
                        {{ usuario.activo ? 'Suspender' : 'Activar' }}
                      </AlertDialogAction>
                    </AlertDialogFooter>
                  </AlertDialogContent>
                </AlertDialog>
              </CardContent>
            </Card>

            <!-- Eliminar Usuario -->
            <Card class="border-l-4 border-l-red-500">
              <CardHeader>
                <CardTitle class="flex items-center gap-2">
                  <div class="flex h-10 w-10 items-center justify-center rounded-lg bg-red-100">
                    <Trash2 class="h-5 w-5 text-red-600" />
                  </div>
                  <div>
                    Eliminar Usuario Permanentemente
                  </div>
                </CardTitle>
                <CardDescription class="ml-12 text-red-600 font-medium">
                  ⚠️ Esta acción NO se puede deshacer. Se eliminarán todos los datos del usuario.
                </CardDescription>
              </CardHeader>
              <CardContent class="ml-12">
                <AlertDialog>
                  <AlertDialogTrigger as-child>
                    <Button variant="destructive">
                      <Trash2 class="h-4 w-4 mr-2" />
                      Eliminar Usuario
                    </Button>
                  </AlertDialogTrigger>
                  <AlertDialogContent>
                    <AlertDialogHeader>
                      <AlertDialogTitle class="text-red-600">
                        ⚠️ ¿Eliminar usuario permanentemente?
                      </AlertDialogTitle>
                      <AlertDialogDescription>
                        Esta acción es <strong>IRREVERSIBLE</strong>. Se eliminará:
                        <ul class="list-disc list-inside mt-2 space-y-1">
                          <li>La cuenta de <strong>{{ usuario.displayName }}</strong></li>
                          <li>Todos sus datos en Firebase Auth</li>
                          <li>Todos sus datos en Firestore</li>
                          <li>Todos sus permisos asociados</li>
                        </ul>
                        <p class="mt-3 font-semibold text-red-600">
                          ¿Estás completamente seguro?
                        </p>
                      </AlertDialogDescription>
                    </AlertDialogHeader>
                    <AlertDialogFooter>
                      <AlertDialogCancel>Cancelar</AlertDialogCancel>
                      <AlertDialogAction 
                        @click="eliminarUsuario"
                        class="bg-red-600 hover:bg-red-700"
                      >
                        Sí, Eliminar Permanentemente
                      </AlertDialogAction>
                    </AlertDialogFooter>
                  </AlertDialogContent>
                </AlertDialog>
              </CardContent>
            </Card>
          </div>
        </TabsContent>
      </Tabs>
    </div>
  </AppLayout>
</template>
