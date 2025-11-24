<script setup lang="ts">
import AppLayout from '@/layouts/AppLayout.vue';
import { dashboard } from '@/routes';
import { type BreadcrumbItem } from '@/types';
import { Head } from '@inertiajs/vue3';
import { 
    Users, 
    FileText, 
    CalendarCheck, 
    Bed, 
    FlaskConical, 
    AlertTriangle,
    TrendingUp,
    Activity,
    Clock
} from 'lucide-vue-next';
import { computed } from 'vue';

interface Stat {
    value: string;
    title: string;
    subtitle: string;
    icon: string;
    color: string;
    trend?: 'up' | 'down' | 'stable' | 'attention' | null;
}

interface Alerta {
    paciente: string;
    rut: string;
    descripcion: string;
    severidad: string;
    fecha: string;
}

interface ActividadItem {
    id: string;
    paciente: string;
    tipo: string;
    motivo: string;
    fecha: string;
    fechaRelativa: string;
}

const props = defineProps<{
    stats: Stat[];
    alertas: Alerta[];
    actividadReciente: ActividadItem[];
    isLoading: boolean;
    error?: string;
    resumen?: {
        totalPacientes: number;
        totalFichas: number;
        atencionesMes: number;
        hospitalizacionesActivas: number;
    };
}>();

const breadcrumbs: BreadcrumbItem[] = [{ title: 'Dashboard', href: dashboard().url }];

// Mapear iconos
const iconComponents: Record<string, any> = {
    'users': Users,
    'file-text': FileText,
    'calendar-check': CalendarCheck,
    'bed': Bed,
    'flask-conical': FlaskConical,
    'alert-triangle': AlertTriangle,
};

// Colores de las tarjetas KPI
const colorClasses: Record<string, string> = {
    'blue': 'from-blue-500 to-blue-600',
    'green': 'from-green-500 to-green-600',
    'purple': 'from-purple-500 to-purple-600',
    'orange': 'from-orange-500 to-orange-600',
    'yellow': 'from-yellow-500 to-yellow-600',
    'red': 'from-red-500 to-red-600',
};

// Colores de severidad
const severidadClasses: Record<string, string> = {
    'critica': 'border-red-500 bg-red-50 dark:bg-red-900/20',
    'alta': 'border-orange-500 bg-orange-50 dark:bg-orange-900/20',
    'media': 'border-yellow-500 bg-yellow-50 dark:bg-yellow-900/20',
    'baja': 'border-blue-500 bg-blue-50 dark:bg-blue-900/20',
};

const severidadTextClasses: Record<string, string> = {
    'critica': 'text-red-700 dark:text-red-400',
    'alta': 'text-orange-700 dark:text-orange-400',
    'media': 'text-yellow-700 dark:text-yellow-400',
    'baja': 'text-blue-700 dark:text-blue-400',
};
</script>

<template>
    <Head title="Dashboard" />
    <AppLayout :breadcrumbs="breadcrumbs">
        <div class="p-6 lg:p-8">
            <!-- Header -->
            <div class="mb-8">
                <h1 class="text-3xl font-bold text-gray-900 dark:text-white mb-2">
                    Nexus
                </h1>
                <p class="text-gray-600 dark:text-gray-400">
                    Panel de administración - Gestión integral de fichas médicas
                </p>
            </div>

            <!-- Error Message -->
            <div v-if="error" class="mb-6 p-4 bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800 rounded-lg">
                <div class="flex items-center">
                    <AlertTriangle class="w-5 h-5 text-red-600 dark:text-red-400 mr-3" />
                    <p class="text-red-800 dark:text-red-200">{{ error }}</p>
                </div>
            </div>

            <!-- Loading State -->
            <div v-if="isLoading" class="text-center py-12">
                <div class="inline-block animate-spin rounded-full h-12 w-12 border-b-2 border-purple-600"></div>
                <p class="mt-4 text-gray-600 dark:text-gray-400">Cargando datos...</p>
            </div>

            <!-- KPIs Grid -->
            <div v-else class="space-y-8">
                <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                    <div 
                        v-for="stat in stats" 
                        :key="stat.title"
                        class="relative overflow-hidden rounded-xl shadow-lg transition-all duration-300 hover:shadow-xl hover:-translate-y-1"
                    >
                        <!-- Gradient Background -->
                        <div 
                            class="absolute inset-0 bg-gradient-to-br opacity-90"
                            :class="colorClasses[stat.color]"
                        ></div>
                        
                        <!-- Content -->
                        <div class="relative p-6 text-white">
                            <div class="flex items-start justify-between">
                                <div class="flex-1">
                                    <p class="text-sm font-medium text-white/80 mb-1">
                                        {{ stat.title }}
                                    </p>
                                    <h3 class="text-4xl font-bold mb-2">
                                        {{ stat.value }}
                                    </h3>
                                    <p class="text-sm text-white/70">
                                        {{ stat.subtitle }}
                                    </p>
                                </div>
                                <div class="ml-4">
                                    <component 
                                        :is="iconComponents[stat.icon]" 
                                        class="w-12 h-12 text-white/30"
                                    />
                                </div>
                            </div>
                            
                            <!-- Trend Indicator -->
                            <div v-if="stat.trend" class="mt-4 flex items-center text-sm">
                                <TrendingUp 
                                    v-if="stat.trend === 'up'" 
                                    class="w-4 h-4 mr-1"
                                />
                                <Activity 
                                    v-else-if="stat.trend === 'attention'" 
                                    class="w-4 h-4 mr-1"
                                />
                                <span class="text-white/80">
                                    {{ stat.trend === 'up' ? 'En aumento' : stat.trend === 'attention' ? 'Requiere atención' : 'Estable' }}
                                </span>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Two Column Layout -->
                <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
                    <!-- Alertas Críticas -->
                    <div class="bg-white dark:bg-gray-800 rounded-xl shadow-lg overflow-hidden">
                        <div class="bg-gradient-to-r from-red-500 to-red-600 p-6">
                            <div class="flex items-center justify-between">
                                <h2 class="text-xl font-semibold text-white flex items-center">
                                    <AlertTriangle class="w-5 h-5 mr-2" />
                                    Alertas Críticas
                                </h2>
                                <span class="bg-white/20 text-white px-3 py-1 rounded-full text-sm font-medium">
                                    {{ alertas.length }}
                                </span>
                            </div>
                        </div>
                        
                        <div class="p-6 max-h-96 overflow-y-auto">
                            <div v-if="alertas.length === 0" class="text-center py-8 text-gray-500 dark:text-gray-400">
                                <AlertTriangle class="w-12 h-12 mx-auto mb-3 opacity-30" />
                                <p>No hay alertas críticas en este momento</p>
                            </div>

                            <div v-else class="space-y-3">
                                <div 
                                    v-for="(alerta, index) in alertas" 
                                    :key="index"
                                    class="p-4 border-l-4 rounded-lg transition-all duration-200 hover:shadow-md"
                                    :class="severidadClasses[alerta.severidad]"
                                >
                                    <div class="flex items-start justify-between mb-2">
                                        <h4 class="font-semibold text-gray-900 dark:text-white">
                                            {{ alerta.paciente }}
                                        </h4>
                                        <span 
                                            class="text-xs font-medium px-2 py-1 rounded-full"
                                            :class="severidadTextClasses[alerta.severidad]"
                                        >
                                            {{ alerta.severidad.toUpperCase() }}
                                        </span>
                                    </div>
                                    <p class="text-sm text-gray-600 dark:text-gray-300 mb-2">
                                        {{ alerta.descripcion }}
                                    </p>
                                    <div class="flex items-center justify-between text-xs text-gray-500 dark:text-gray-400">
                                        <span>RUT: {{ alerta.rut }}</span>
                                        <span class="flex items-center">
                                            <Clock class="w-3 h-3 mr-1" />
                                            {{ alerta.fecha }}
                                        </span>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Actividad Reciente -->
                    <div class="bg-white dark:bg-gray-800 rounded-xl shadow-lg overflow-hidden">
                        <div class="bg-gradient-to-r from-purple-500 to-purple-600 p-6">
                            <div class="flex items-center justify-between">
                                <h2 class="text-xl font-semibold text-white flex items-center">
                                    <Activity class="w-5 h-5 mr-2" />
                                    Actividad Reciente
                                </h2>
                                <span class="bg-white/20 text-white px-3 py-1 rounded-full text-sm font-medium">
                                    {{ actividadReciente.length }}
                                </span>
                            </div>
                        </div>
                        
                        <div class="p-6 max-h-96 overflow-y-auto">
                            <div v-if="actividadReciente.length === 0" class="text-center py-8 text-gray-500 dark:text-gray-400">
                                <Activity class="w-12 h-12 mx-auto mb-3 opacity-30" />
                                <p>No hay actividad reciente</p>
                            </div>

                            <div v-else class="space-y-4">
                                <div 
                                    v-for="actividad in actividadReciente" 
                                    :key="actividad.id"
                                    class="p-4 bg-gray-50 dark:bg-gray-700/50 rounded-lg hover:bg-gray-100 dark:hover:bg-gray-700 transition-colors duration-200"
                                >
                                    <div class="flex items-start justify-between mb-2">
                                        <div class="flex-1">
                                            <h4 class="font-semibold text-gray-900 dark:text-white">
                                                {{ actividad.paciente }}
                                            </h4>
                                            <span class="text-xs text-purple-600 dark:text-purple-400 font-medium">
                                                {{ actividad.tipo }}
                                            </span>
                                        </div>
                                        <span class="text-xs text-gray-500 dark:text-gray-400 ml-2">
                                            {{ actividad.fechaRelativa }}
                                        </span>
                                    </div>
                                    <p class="text-sm text-gray-600 dark:text-gray-300 mb-2">
                                        {{ actividad.motivo }}
                                    </p>
                                    <div class="flex items-center text-xs text-gray-500 dark:text-gray-400">
                                        <Clock class="w-3 h-3 mr-1" />
                                        {{ actividad.fecha }}
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </AppLayout>
</template>