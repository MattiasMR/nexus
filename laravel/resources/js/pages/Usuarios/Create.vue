<script setup lang="ts">
import AppLayout from '@/layouts/AppLayout.vue';
import { Head, router, useForm } from '@inertiajs/vue3';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import {
    Card,
    CardContent,
    CardDescription,
    CardHeader,
    CardTitle,
} from '@/components/ui/card';
import {
    Select,
    SelectContent,
    SelectItem,
    SelectTrigger,
    SelectValue,
} from '@/components/ui/select';
import { Alert, AlertDescription } from '@/components/ui/alert';
import { UserPlus, ArrowLeft, AlertCircle, Eye, EyeOff } from 'lucide-vue-next';
import { ref } from 'vue';
import { type BreadcrumbItem } from '@/types';

const breadcrumbs: BreadcrumbItem[] = [
    { title: 'Usuarios', href: '/usuarios' },
    { title: 'Crear Usuario', href: '/usuarios/crear' }
];

const mostrarPassword = ref(false);

const form = useForm({
    displayName: '',
    email: '',
    rut: '',
    telefono: '',
    rol: '',
    password: '',
    password_confirmation: '',
    activo: true,
});

const submit = () => {
    form.post('/usuarios', {
        preserveScroll: true,
        onSuccess: () => {
            // Redirigir a la lista de usuarios después de crear
        },
    });
};

const cancelar = () => {
    router.get('/usuarios');
};

const togglePassword = () => {
    mostrarPassword.value = !mostrarPassword.value;
};
</script>

<template>
    <Head title="Crear Usuario" />
    <AppLayout :breadcrumbs="breadcrumbs">
        <div class="p-6 lg:p-8 max-w-4xl mx-auto">
            <!-- Header -->
            <div class="mb-6">
                <Button
                    variant="ghost"
                    @click="cancelar"
                    class="mb-4 -ml-2"
                >
                    <ArrowLeft class="mr-2 h-4 w-4" />
                    Volver a Usuarios
                </Button>

                <div class="flex items-center gap-3">
                    <div class="flex h-12 w-12 items-center justify-center rounded-lg bg-primary/10">
                        <UserPlus class="h-6 w-6 text-primary" />
                    </div>
                    <div>
                        <h1 class="text-3xl font-bold">Crear Nuevo Usuario</h1>
                        <p class="text-muted-foreground">Completa los datos para crear un usuario en el sistema</p>
                    </div>
                </div>
            </div>

            <!-- Formulario -->
            <form @submit.prevent="submit">
                <div class="space-y-6">
                    <!-- Información Personal -->
                    <Card>
                        <CardHeader>
                            <CardTitle>Información Personal</CardTitle>
                            <CardDescription>Datos básicos del usuario</CardDescription>
                        </CardHeader>
                        <CardContent class="space-y-4">
                            <!-- Nombre Completo -->
                            <div class="space-y-2">
                                <Label for="displayName">
                                    Nombre Completo <span class="text-destructive">*</span>
                                </Label>
                                <Input
                                    id="displayName"
                                    v-model="form.displayName"
                                    placeholder="Ej: Juan Pérez González"
                                    :class="{ 'border-destructive': form.errors.displayName }"
                                    required
                                />
                                <p v-if="form.errors.displayName" class="text-sm text-destructive">
                                    {{ form.errors.displayName }}
                                </p>
                            </div>

                            <!-- Email -->
                            <div class="space-y-2">
                                <Label for="email">
                                    Email <span class="text-destructive">*</span>
                                </Label>
                                <Input
                                    id="email"
                                    v-model="form.email"
                                    type="email"
                                    placeholder="usuario@ejemplo.com"
                                    :class="{ 'border-destructive': form.errors.email }"
                                    required
                                />
                                <p v-if="form.errors.email" class="text-sm text-destructive">
                                    {{ form.errors.email }}
                                </p>
                            </div>

                            <!-- RUT y Teléfono en grid -->
                            <div class="grid gap-4 md:grid-cols-2">
                                <!-- RUT -->
                                <div class="space-y-2">
                                    <Label for="rut">
                                        RUT <span class="text-destructive">*</span>
                                    </Label>
                                    <Input
                                        id="rut"
                                        v-model="form.rut"
                                        placeholder="12345678-9"
                                        :class="{ 'border-destructive': form.errors.rut }"
                                        required
                                    />
                                    <p v-if="form.errors.rut" class="text-sm text-destructive">
                                        {{ form.errors.rut }}
                                    </p>
                                </div>

                                <!-- Teléfono -->
                                <div class="space-y-2">
                                    <Label for="telefono">Teléfono</Label>
                                    <Input
                                        id="telefono"
                                        v-model="form.telefono"
                                        type="tel"
                                        placeholder="+56 9 1234 5678"
                                        :class="{ 'border-destructive': form.errors.telefono }"
                                    />
                                    <p v-if="form.errors.telefono" class="text-sm text-destructive">
                                        {{ form.errors.telefono }}
                                    </p>
                                </div>
                            </div>
                        </CardContent>
                    </Card>

                    <!-- Información del Sistema -->
                    <Card>
                        <CardHeader>
                            <CardTitle>Información del Sistema</CardTitle>
                            <CardDescription>Rol y permisos de acceso</CardDescription>
                        </CardHeader>
                        <CardContent class="space-y-4">
                            <!-- Rol -->
                            <div class="space-y-2">
                                <Label for="rol">
                                    Rol <span class="text-destructive">*</span>
                                </Label>
                                <Select v-model="form.rol">
                                    <SelectTrigger :class="{ 'border-destructive': form.errors.rol }">
                                        <SelectValue>
                                            <template v-if="form.rol === 'admin'">
                                                <div class="flex items-center gap-2">
                                                    <div class="h-2 w-2 rounded-full bg-red-500"></div>
                                                    <span>Administrador</span>
                                                </div>
                                            </template>
                                            <template v-else-if="form.rol === 'profesional'">
                                                <div class="flex items-center gap-2">
                                                    <div class="h-2 w-2 rounded-full bg-blue-500"></div>
                                                    <span>Profesional</span>
                                                </div>
                                            </template>
                                            <template v-else-if="form.rol === 'paciente'">
                                                <div class="flex items-center gap-2">
                                                    <div class="h-2 w-2 rounded-full bg-purple-500"></div>
                                                    <span>Paciente</span>
                                                </div>
                                            </template>
                                            <template v-else>
                                                <span class="text-muted-foreground">Selecciona un rol</span>
                                            </template>
                                        </SelectValue>
                                    </SelectTrigger>
                                    <SelectContent>
                                        <SelectItem value="admin">
                                            <div class="flex items-center gap-2">
                                                <div class="h-2 w-2 rounded-full bg-red-500"></div>
                                                <span>Administrador</span>
                                            </div>
                                        </SelectItem>
                                        <SelectItem value="profesional">
                                            <div class="flex items-center gap-2">
                                                <div class="h-2 w-2 rounded-full bg-blue-500"></div>
                                                <span>Profesional</span>
                                            </div>
                                        </SelectItem>
                                        <SelectItem value="paciente">
                                            <div class="flex items-center gap-2">
                                                <div class="h-2 w-2 rounded-full bg-purple-500"></div>
                                                <span>Paciente</span>
                                            </div>
                                        </SelectItem>
                                    </SelectContent>
                                </Select>
                                <p v-if="form.errors.rol" class="text-sm text-destructive">
                                    {{ form.errors.rol }}
                                </p>
                                <p class="text-xs text-muted-foreground">
                                    El rol determina los permisos y funcionalidades disponibles para el usuario
                                </p>
                            </div>

                            <!-- Contraseña y Confirmación en grid -->
                            <div class="grid gap-4 md:grid-cols-2">
                                <!-- Contraseña -->
                                <div class="space-y-2">
                                    <Label for="password">
                                        Contraseña <span class="text-destructive">*</span>
                                    </Label>
                                    <div class="relative">
                                        <Input
                                            id="password"
                                            v-model="form.password"
                                            :type="mostrarPassword ? 'text' : 'password'"
                                            placeholder="Mínimo 6 caracteres"
                                            :class="{ 'border-destructive': form.errors.password }"
                                            required
                                        />
                                        <Button
                                            type="button"
                                            variant="ghost"
                                            size="sm"
                                            class="absolute right-0 top-0 h-full px-3 py-2 hover:bg-transparent"
                                            @click="togglePassword"
                                        >
                                            <Eye v-if="!mostrarPassword" class="h-4 w-4 text-muted-foreground" />
                                            <EyeOff v-else class="h-4 w-4 text-muted-foreground" />
                                        </Button>
                                    </div>
                                    <p v-if="form.errors.password" class="text-sm text-destructive">
                                        {{ form.errors.password }}
                                    </p>
                                </div>

                                <!-- Confirmar Contraseña -->
                                <div class="space-y-2">
                                    <Label for="password_confirmation">
                                        Confirmar Contraseña <span class="text-destructive">*</span>
                                    </Label>
                                    <Input
                                        id="password_confirmation"
                                        v-model="form.password_confirmation"
                                        :type="mostrarPassword ? 'text' : 'password'"
                                        placeholder="Repite la contraseña"
                                        :class="{ 'border-destructive': form.errors.password_confirmation }"
                                        required
                                    />
                                    <p v-if="form.errors.password_confirmation" class="text-sm text-destructive">
                                        {{ form.errors.password_confirmation }}
                                    </p>
                                </div>
                            </div>

                            <!-- Info sobre contraseña -->
                            <Alert>
                                <AlertCircle class="h-4 w-4" />
                                <AlertDescription>
                                    La contraseña debe tener al menos 6 caracteres. El usuario podrá cambiarla después de su primer inicio de sesión.
                                </AlertDescription>
                            </Alert>
                        </CardContent>
                    </Card>

                    <!-- Botones de acción -->
                    <div class="flex items-center justify-end gap-3">
                        <Button
                            type="button"
                            variant="outline"
                            @click="cancelar"
                            :disabled="form.processing"
                        >
                            Cancelar
                        </Button>
                        <Button
                            type="submit"
                            :disabled="form.processing"
                            class="min-w-[140px]"
                        >
                            <UserPlus v-if="!form.processing" class="mr-2 h-4 w-4" />
                            <span v-if="form.processing">Creando...</span>
                            <span v-else>Crear Usuario</span>
                        </Button>
                    </div>
                </div>
            </form>
        </div>
    </AppLayout>
</template>
