<script setup lang="ts">
import AppLayout from '@/layouts/AppLayout.vue';
import { Head, router } from '@inertiajs/vue3';
import { ref, computed } from 'vue';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
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
import { Badge } from '@/components/ui/badge';
import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar';
import { 
    Stethoscope, 
    Search, 
    Filter, 
    FileText, 
    AlertCircle,
    Calendar,
    User,
    Activity
} from 'lucide-vue-next';
import { type BreadcrumbItem } from '@/types';

interface Paciente {
    id: string;
    displayName: string;
    email: string;
    rut: string | null;
    telefono: string | null;
    photoURL: string | null;
    activo: boolean;
    idPaciente: string | null;
    grupoSanguineo: string | null;
    prevision: string | null;
    idFicha: string | null;
    tieneFicha: boolean;
    totalConsultas: number;
    ultimaConsulta: string | null;
    tieneAlergias: boolean;
    observacion: string | null;
}

interface Props {
    pacientes: Paciente[];
    filtros: {
        busqueda: string;
        tieneAlergias: string;
    };
    stats: {
        total: number;
        conFicha: number;
        sinFicha: number;
        conAlergias: number;
    };
}

const props = defineProps<Props>();

const breadcrumbs: BreadcrumbItem[] = [
    { title: 'Gestión Médica', href: '/gestion-medica' }
];

const busqueda = ref(props.filtros.busqueda);
const alergiasSeleccionado = ref(props.filtros.tieneAlergias);

const aplicarFiltros = () => {
    router.get('/gestion-medica', {
        busqueda: busqueda.value,
        tieneAlergias: alergiasSeleccionado.value,
    }, {
        preserveState: true,
        preserveScroll: true,
    });
};

const verFicha = (paciente: Paciente) => {
    if (paciente.idPaciente) {
        router.get(`/gestion-medica/${paciente.idPaciente}`);
    }
};

const formatearFecha = (fecha: string | null) => {
    if (!fecha) return 'Sin consultas';
    return new Date(fecha).toLocaleDateString('es-CL', {
        day: '2-digit',
        month: '2-digit',
        year: 'numeric'
    });
};

const getInitials = (name: string) => {
    return name
        .split(' ')
        .map(word => word[0])
        .join('')
        .toUpperCase()
        .substring(0, 2);
};
</script>

<template>
    <Head title="Gestión Médica" />
    <AppLayout :breadcrumbs="breadcrumbs">
        <div class="p-6 lg:p-8">
            <!-- Header -->
            <div class="mb-6">
                <div class="flex items-center gap-3 mb-2">
                    <div class="flex h-12 w-12 items-center justify-center rounded-lg bg-primary/10">
                        <Stethoscope class="h-6 w-6 text-primary" />
                    </div>
                    <div>
                        <h1 class="text-3xl font-bold">Gestión Médica</h1>
                        <p class="text-muted-foreground">Administra las fichas médicas de los pacientes</p>
                    </div>
                </div>
            </div>

            <!-- Stats Cards -->
            <div class="grid gap-4 md:grid-cols-2 lg:grid-cols-4 mb-6">
                <Card class="border-l-4 border-l-blue-500 **bg-gradient-to-br from-blue-500/90 to-blue-600/90** **text-white**">
                    <CardHeader class="flex flex-row items-center justify-between space-y-0 pb-2">
                        <CardTitle class="text-sm font-medium">Total Pacientes</CardTitle>
                        <div class="flex h-10 w-10 items-center justify-center rounded-full bg-blue-100">
                            <User class="h-5 w-5 text-blue-600" />
                        </div>
                    </CardHeader>
                    <CardContent>
                        <div class="text-2xl font-bold text-blue-600">{{ stats.total }}</div>
                        <p class="text-xs text-muted-foreground">Pacientes registrados</p>
                    </CardContent>
                </Card>

                <Card class="border-l-4 border-l-green-500 **bg-gradient-to-br from-green-500/90 to-green-600/90** **text-white**">
                    <CardHeader class="flex flex-row items-center justify-between space-y-0 pb-2">
                        <CardTitle class="text-sm font-medium">Con Ficha Médica</CardTitle>
                        <div class="flex h-10 w-10 items-center justify-center rounded-full bg-green-100">
                            <FileText class="h-5 w-5 text-green-600" />
                        </div>
                    </CardHeader>
                    <CardContent>
                        <div class="text-2xl font-bold text-green-600">{{ stats.conFicha }}</div>
                        <p class="text-xs text-muted-foreground">
                            {{ stats.total > 0 ? Math.round((stats.conFicha / stats.total) * 100) : 0 }}% del total
                        </p>
                    </CardContent>
                </Card>

                <Card class="border-l-4 border-l-amber-500 **bg-gradient-to-br from-amber-500/90 to-amber-600/90** **text-white**">
                    <CardHeader class="flex flex-row items-center justify-between space-y-0 pb-2">
                        <CardTitle class="text-sm font-medium">Sin Ficha Médica</CardTitle>
                        <div class="flex h-10 w-10 items-center justify-center rounded-full bg-amber-100">
                            <AlertCircle class="h-5 w-5 text-amber-600" />
                        </div>
                    </CardHeader>
                    <CardContent>
                        <div class="text-2xl font-bold text-amber-600">{{ stats.sinFicha }}</div>
                        <p class="text-xs text-muted-foreground">Requieren atención</p>
                    </CardContent>
                </Card>

                <Card class="border-l-4 border-l-red-500 **bg-gradient-to-br from-red-500/90 to-red-600/90** **text-white**">
                    <CardHeader class="flex flex-row items-center justify-between space-y-0 pb-2">
                        <CardTitle class="text-sm font-medium">Con Alergias</CardTitle>
                        <div class="flex h-10 w-10 items-center justify-center rounded-full bg-red-100">
                            <Activity class="h-5 w-5 text-red-600" />
                        </div>
                    </CardHeader>
                    <CardContent>
                        <div class="text-2xl font-bold text-red-600">{{ stats.conAlergias }}</div>
                        <p class="text-xs text-muted-foreground">Requieren precaución</p>
                    </CardContent>
                </Card>
            </div>

            <!-- Filtros -->
            <Card class="mb-6">
                <CardHeader>
                    <div class="flex items-center gap-2">
                        <Filter class="h-5 w-5" />
                        <CardTitle>Filtros</CardTitle>
                    </div>
                </CardHeader>
                <CardContent>
                    <div class="flex flex-col md:flex-row gap-4">
                        <!-- Búsqueda -->
                        <div class="flex-1">
                            <div class="relative">
                                <Search class="absolute left-2.5 top-2.5 h-4 w-4 text-muted-foreground" />
                                <Input
                                    v-model="busqueda"
                                    @input="aplicarFiltros"
                                    placeholder="Buscar por nombre, RUT o email..."
                                    class="pl-9"
                                />
                            </div>
                        </div>

                        <!-- Filtro por alergias -->
                        <div class="w-full md:w-48">
                            <Select v-model="alergiasSeleccionado" @update:model-value="aplicarFiltros">
                                <SelectTrigger>
                                    <SelectValue>
                                        <template v-if="alergiasSeleccionado === 'todos'">Todas las alergias</template>
                                        <template v-else-if="alergiasSeleccionado === 'si'">Con alergias</template>
                                        <template v-else-if="alergiasSeleccionado === 'no'">Sin alergias</template>
                                    </SelectValue>
                                </SelectTrigger>
                                <SelectContent>
                                    <SelectItem value="todos">Todas las alergias</SelectItem>
                                    <SelectItem value="si">Con alergias</SelectItem>
                                    <SelectItem value="no">Sin alergias</SelectItem>
                                </SelectContent>
                            </Select>
                        </div>
                    </div>
                </CardContent>
            </Card>

            <!-- Tabla de pacientes -->
            <Card>
                <CardHeader>
                    <CardTitle>Pacientes</CardTitle>
                    <CardDescription>Lista de pacientes con sus fichas médicas</CardDescription>
                </CardHeader>
                <CardContent>
                    <Table>
                        <TableHeader>
                            <TableRow>
                                <TableHead>Paciente</TableHead>
                                <TableHead>RUT</TableHead>
                                <TableHead>Grupo Sanguíneo</TableHead>
                                <TableHead>Previsión</TableHead>
                                <TableHead>Alergias</TableHead>
                                <TableHead>Consultas</TableHead>
                                <TableHead>Última Consulta</TableHead>
                                <TableHead>Estado</TableHead>
                            </TableRow>
                        </TableHeader>
                        <TableBody>
                            <TableRow
                                v-for="(paciente, index) in pacientes"
                                :key="paciente.id"
                                :class="[
                                    'cursor-pointer transition-colors',
                                    index % 2 === 0 ? 'bg-background hover:bg-muted/50' : 'bg-muted/30 hover:bg-muted/60'
                                ]"
                                @click="verFicha(paciente)"
                            >
                                <!-- Paciente -->
                                <TableCell>
                                    <div class="flex items-center gap-3">
                                        <Avatar>
                                            <AvatarImage v-if="paciente.photoURL" :src="paciente.photoURL" />
                                            <AvatarFallback>{{ getInitials(paciente.displayName) }}</AvatarFallback>
                                        </Avatar>
                                        <div>
                                            <div class="font-medium">{{ paciente.displayName }}</div>
                                            <div class="text-sm text-muted-foreground">{{ paciente.email }}</div>
                                        </div>
                                    </div>
                                </TableCell>

                                <!-- RUT -->
                                <TableCell>
                                    <span class="font-mono text-sm">{{ paciente.rut || 'Sin RUT' }}</span>
                                </TableCell>

                                <!-- Grupo Sanguíneo -->
                                <TableCell>
                                    <Badge v-if="paciente.grupoSanguineo" variant="outline">
                                        {{ paciente.grupoSanguineo }}
                                    </Badge>
                                    <span v-else class="text-sm text-muted-foreground">Sin datos</span>
                                </TableCell>

                                <!-- Previsión -->
                                <TableCell>
                                    <span class="text-sm">{{ paciente.prevision || 'Sin datos' }}</span>
                                </TableCell>

                                <!-- Alergias -->
                                <TableCell>
                                    <Badge v-if="paciente.tieneAlergias" variant="destructive">
                                        Con alergias
                                    </Badge>
                                    <Badge v-else variant="outline">
                                        Sin alergias
                                    </Badge>
                                </TableCell>

                                <!-- Total Consultas -->
                                <TableCell>
                                    <div class="flex items-center gap-2">
                                        <Calendar class="h-4 w-4 text-muted-foreground" />
                                        <span class="font-medium">{{ paciente.totalConsultas }}</span>
                                    </div>
                                </TableCell>

                                <!-- Última Consulta -->
                                <TableCell>
                                    <span class="text-sm">{{ formatearFecha(paciente.ultimaConsulta) }}</span>
                                </TableCell>

                                <!-- Estado -->
                                <TableCell>
                                    <Badge v-if="paciente.tieneFicha" variant="default">
                                        Con ficha
                                    </Badge>
                                    <Badge v-else variant="secondary">
                                        Sin ficha
                                    </Badge>
                                </TableCell>
                            </TableRow>

                            <!-- Estado vacío -->
                            <TableRow v-if="pacientes.length === 0">
                                <TableCell :colspan="8" class="text-center py-8">
                                    <div class="flex flex-col items-center gap-2">
                                        <Search class="h-8 w-8 text-muted-foreground" />
                                        <p class="text-muted-foreground">No se encontraron pacientes</p>
                                    </div>
                                </TableCell>
                            </TableRow>
                        </TableBody>
                    </Table>
                </CardContent>
            </Card>
        </div>
    </AppLayout>
</template>
