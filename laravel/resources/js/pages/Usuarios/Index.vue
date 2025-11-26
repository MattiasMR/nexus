<script setup lang="ts">
import AppLayout from '@/layouts/AppLayout.vue';
import { Head, router } from '@inertiajs/vue3';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Badge } from '@/components/ui/badge';
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
import {
    Table,
    TableBody,
    TableCell,
    TableHead,
    TableHeader,
    TableRow,
} from '@/components/ui/table';
import { Users, Search, Filter, UserCheck, UserX, Shield, Stethoscope, User } from 'lucide-vue-next';
import { ref, computed, watch } from 'vue';
import { type BreadcrumbItem } from '@/types';

interface Usuario {
    id: string;
    displayName: string;
    email: string;
    rol: string;
    activo: boolean;
    photoURL?: string;
    ultimoAcceso?: any;
    createdAt?: any;
    idPaciente?: string;
    idProfesional?: string;
}

interface Stats {
    total: number;
    admins: number;
    profesionales: number;
    pacientes: number;
    activos: number;
}

interface Filtros {
    rol: string;
    estado: string;
    busqueda: string;
}

const props = defineProps<{
    usuarios: Usuario[];
    filtros: Filtros;
    stats: Stats;
    error?: string;
}>();

const breadcrumbs: BreadcrumbItem[] = [
    { title: 'Usuarios', href: '/usuarios' }
];

// Estado local de filtros
const rolSeleccionado = ref(props.filtros.rol);
const estadoSeleccionado = ref(props.filtros.estado);
const busqueda = ref(props.filtros.busqueda);

// Aplicar filtros automáticamente cuando cambian
const aplicarFiltros = () => {
    router.get('/usuarios', {
        rol: rolSeleccionado.value,
        estado: estadoSeleccionado.value,
        busqueda: busqueda.value,
    }, {
        preserveState: true,
        preserveScroll: true,
    });
};

// Watchers para aplicar filtros automáticamente
watch([rolSeleccionado, estadoSeleccionado, busqueda], () => {
    aplicarFiltros();
});

// Ver detalle de usuario
const verUsuario = (id: string) => {
    router.get(`/usuarios/${id}`);
};

// Formatear fecha
const formatearFecha = (fecha: any) => {
    if (!fecha) return 'Nunca';
    
    try {
        let date: Date;
        
        if (fecha._seconds) {
            date = new Date(fecha._seconds * 1000);
        } else if (fecha.seconds) {
            date = new Date(fecha.seconds * 1000);
        } else if (typeof fecha === 'string') {
            date = new Date(fecha);
        } else {
            return 'Fecha inválida';
        }
        
        const now = new Date();
        const diffMs = now.getTime() - date.getTime();
        const diffMins = Math.floor(diffMs / 60000);
        const diffHours = Math.floor(diffMs / 3600000);
        const diffDays = Math.floor(diffMs / 86400000);
        
        if (diffMins < 1) return 'Hace un momento';
        if (diffMins < 60) return `Hace ${diffMins} min`;
        if (diffHours < 24) return `Hace ${diffHours}h`;
        if (diffDays < 7) return `Hace ${diffDays}d`;
        
        return date.toLocaleDateString('es-CL', {
            day: '2-digit',
            month: 'short',
            year: 'numeric'
        });
    } catch (error) {
        return 'Fecha inválida';
    }
};

// Badge de rol con colores
const getBadgeRol = (rol: string) => {
    const roles: Record<string, { label: string; class: string }> = {
        'admin': { 
            label: 'Admin', 
            class: 'bg-gradient-to-r from-red-500 to-red-600 text-white border-0 hover:from-red-600 hover:to-red-700'
        },
        'profesional': { 
            label: 'Profesional', 
            class: 'bg-gradient-to-r from-blue-500 to-blue-600 text-white border-0 hover:from-blue-600 hover:to-blue-700'
        },
        'paciente': { 
            label: 'Paciente', 
            class: 'bg-gradient-to-br opacity-90 from-purple-500 to-purple-600 text-white border-0 hover:from-red-600 hover:to-red-700'
        },
    };
    return roles[rol] || { label: rol, class: 'bg-muted text-muted-foreground' };
};

// Badge de estado con colores
const getBadgeEstado = (activo: boolean) => {
    if (activo) {
        return {
            label: 'Activo',
            class: 'bg-gradient-to-br from-green-500 to-green-600 text-white border-0"'
        };
    }
    return {
        label: 'Inactivo',
        class: 'bg-gradient-to-r from-gray-400 to-gray-500 text-white border-0'
    };
};
</script>

<template>
    <Head title="Gestión de Usuarios" />
    <AppLayout :breadcrumbs="breadcrumbs">
        <div class="p-6 lg:p-8 space-y-6">
            <!-- Header con stats -->
            <div>
                <div class="flex items-center gap-3 mb-6">
                    <div class="flex h-12 w-12 items-center justify-center rounded-lg bg-primary/10">
                        <Users class="h-6 w-6 text-primary" />
                    </div>
                    <div>
                        <h1 class="text-3xl font-bold">Gestión de Usuarios</h1>
                        <p class="text-muted-foreground">Administra los usuarios del sistema</p>
                    </div>
                </div>

                <!-- Stats Cards -->
                <div class="grid gap-4 md:grid-cols-2 lg:grid-cols-5">
                    <Card class="bg-gradient-to-br opacity-90 from-orange-500 to-orange-600">
                        <CardHeader class="flex flex-row items-center justify-between space-y-0 pb-2">
                            <CardTitle class="text-sm font-medium">Total Usuarios</CardTitle>
                            <Users class="h-4 w-4 text-white/80" />
                        </CardHeader>
                        <CardContent>
                            <div class="text-2xl font-bold text-white">{{ stats.total }}</div>
                        </CardContent>
                    </Card>

                    <Card class="bg-gradient-to-br from-red-500 to-red-600 text-white border-0">
                        <CardHeader class="flex flex-row items-center justify-between space-y-0 pb-2">
                            <CardTitle class="text-sm font-medium text-white">Administradores</CardTitle>
                            <Shield class="h-4 w-4 text-white/80" />
                        </CardHeader>
                        <CardContent>
                            <div class="text-2xl font-bold text-white">{{ stats.admins }}</div>
                        </CardContent>
                    </Card>

                    <Card class="bg-gradient-to-br from-blue-500 to-blue-600 text-white border-0">
                        <CardHeader class="flex flex-row items-center justify-between space-y-0 pb-2">
                            <CardTitle class="text-sm font-medium text-white">Profesionales</CardTitle>
                            <Stethoscope class="h-4 w-4 text-white/80" />
                        </CardHeader>
                        <CardContent>
                            <div class="text-2xl font-bold text-white">{{ stats.profesionales }}</div>
                        </CardContent>
                    </Card>

                    <Card class="bg-gradient-to-br from-green-500 to-green-600 text-white border-0">
                        <CardHeader class="flex flex-row items-center justify-between space-y-0 pb-2">
                            <CardTitle class="text-sm font-medium text-white">Pacientes</CardTitle>
                            <User class="h-4 w-4 text-white/80" />
                        </CardHeader>
                        <CardContent>
                            <div class="text-2xl font-bold text-white">{{ stats.pacientes }}</div>
                        </CardContent>
                    </Card>

                    <Card class="bg-gradient-to-br from-purple-500 to-purple-600 text-white border-0">
                        <CardHeader class="flex flex-row items-center justify-between space-y-0 pb-2">
                            <CardTitle class="text-sm font-medium text-white">Activos</CardTitle>
                            <UserCheck class="h-4 w-4 text-white/80" />
                        </CardHeader>
                        <CardContent>
                            <div class="text-2xl font-bold text-white">{{ stats.activos }}</div>
                        </CardContent>
                    </Card>
                </div>
            </div>

            <!-- Filtros -->
            <Card>
                <CardHeader>
                    <CardTitle class="flex items-center gap-2">
                        <Filter class="h-5 w-5" />
                        Filtros
                    </CardTitle>
                </CardHeader>
                <CardContent>
                    <div class="grid gap-4 md:grid-cols-4">
                        <!-- Búsqueda -->
                        <div class="md:col-span-2">
                            <div class="relative">
                                <Search class="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
                                <Input
                                    v-model="busqueda"
                                    placeholder="Buscar por nombre o email..."
                                    class="pl-9"
                                />
                            </div>
                        </div>

                        <!-- Filtro por rol -->
                        <div>
                            <Select v-model="rolSeleccionado">
                                <SelectTrigger>
                                    <SelectValue>
                                        <template v-if="rolSeleccionado === 'todos'">Todos los roles</template>
                                        <template v-else-if="rolSeleccionado === 'admin'">Administradores</template>
                                        <template v-else-if="rolSeleccionado === 'profesional'">Profesionales</template>
                                        <template v-else-if="rolSeleccionado === 'paciente'">Pacientes</template>
                                    </SelectValue>
                                </SelectTrigger>
                                <SelectContent>
                                    <SelectItem value="todos">Todos los roles</SelectItem>
                                    <SelectItem value="admin">Administradores</SelectItem>
                                    <SelectItem value="profesional">Profesionales</SelectItem>
                                    <SelectItem value="paciente">Pacientes</SelectItem>
                                </SelectContent>
                            </Select>
                        </div>

                        <!-- Filtro por estado -->
                        <div>
                            <Select v-model="estadoSeleccionado">
                                <SelectTrigger>
                                    <SelectValue>
                                        <template v-if="estadoSeleccionado === 'todos'">Todos los estados</template>
                                        <template v-else-if="estadoSeleccionado === 'activo'">Activos</template>
                                        <template v-else-if="estadoSeleccionado === 'inactivo'">Inactivos</template>
                                    </SelectValue>
                                </SelectTrigger>
                                <SelectContent>
                                    <SelectItem value="todos">Todos los estados</SelectItem>
                                    <SelectItem value="activo">Activos</SelectItem>
                                    <SelectItem value="inactivo">Inactivos</SelectItem>
                                </SelectContent>
                            </Select>
                        </div>
                    </div>
                </CardContent>
            </Card>

            <!-- Tabla de usuarios -->
            <Card>
                <CardHeader>
                    <CardTitle>Listado de Usuarios</CardTitle>
                    <CardDescription>Click en un usuario para ver más detalles</CardDescription>
                </CardHeader>
                <CardContent>
                    <div v-if="error" class="rounded-lg border border-destructive/50 bg-destructive/10 p-4 mb-4">
                        <p class="text-sm text-destructive">{{ error }}</p>
                    </div>

                    <div v-if="usuarios.length === 0" class="text-center py-12">
                        <UserX class="h-12 w-12 text-muted-foreground mx-auto mb-4" />
                        <p class="text-muted-foreground">No se encontraron usuarios con los filtros aplicados</p>
                    </div>

                    <div v-else class="rounded-md border">
                        <Table>
                            <TableHeader>
                                <TableRow class="bg-muted/50">
                                    <TableHead>Usuario</TableHead>
                                    <TableHead>Email</TableHead>
                                    <TableHead>Rol</TableHead>
                                    <TableHead>Estado</TableHead>
                                    <TableHead>Último Acceso</TableHead>
                                </TableRow>
                            </TableHeader>
                            <TableBody>
                                <TableRow
                                    v-for="(usuario, index) in usuarios"
                                    :key="usuario.id"
                                    :class="[
                                        'cursor-pointer hover:bg-muted/70 transition-colors',
                                        index % 2 === 0 ? 'bg-background' : 'bg-muted/60'
                                    ]"
                                    @click="verUsuario(usuario.id)"
                                >
                                    <TableCell class="font-medium py-4">
                                        <div class="flex items-center gap-3">
                                            <div class="h-10 w-10 rounded-full bg-primary/10 flex items-center justify-center flex-shrink-0">
                                                <span class="text-sm font-semibold text-primary">
                                                    {{ usuario.displayName.charAt(0).toUpperCase() }}
                                                </span>
                                            </div>
                                            <span>{{ usuario.displayName }}</span>
                                        </div>
                                    </TableCell>
                                    <TableCell class="py-4">{{ usuario.email }}</TableCell>
                                    <TableCell class="py-4">
                                        <Badge :class="getBadgeRol(usuario.rol).class">
                                            {{ getBadgeRol(usuario.rol).label }}
                                        </Badge>
                                    </TableCell>
                                    <TableCell class="py-4">
                                        <Badge :class="getBadgeEstado(usuario.activo).class">
                                            {{ getBadgeEstado(usuario.activo).label }}
                                        </Badge>
                                    </TableCell>
                                    <TableCell class="text-muted-foreground py-4">
                                        {{ formatearFecha(usuario.ultimoAcceso) }}
                                    </TableCell>
                                </TableRow>
                            </TableBody>
                        </Table>
                    </div>
                </CardContent>
            </Card>
        </div>
    </AppLayout>
</template>
