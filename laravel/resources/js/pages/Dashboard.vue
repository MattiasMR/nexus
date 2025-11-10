<script setup lang="ts">
import AppLayout from '@/layouts/AppLayout.vue';
import { dashboard } from '@/routes';
import { type BreadcrumbItem } from '@/types';
import { Head } from '@inertiajs/vue3';

defineProps<{
    stats: any[];
    alertas: any[];
    isLoading: boolean;
}>();

const breadcrumbs: BreadcrumbItem[] = [{ title: 'Dashboard', href: dashboard().url }];
</script>

<template>
    <Head title="Dashboard" />
    <AppLayout :breadcrumbs="breadcrumbs">
        <div class="p-8">
            <h1 class="text-3xl font-bold mb-2">Sistema Médico Ascle</h1>
            <p class="text-gray-600 mb-8">Gestión integral de fichas médicas</p>
            
            <div v-if="isLoading" class="text-center py-12">
                <p>Cargando datos...</p>
            </div>

            <div v-else>
                <div class="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8">
                    <div v-for="stat in stats" :key="stat.title" class="bg-white dark:bg-gray-800 rounded-lg shadow p-6">
                        <h3 class="text-2xl font-bold">{{ stat.value }}</h3>
                        <p class="text-sm text-gray-600 dark:text-gray-400">{{ stat.title }}</p>
                        <small class="text-xs text-gray-500">{{ stat.sub }}</small>
                    </div>
                </div>

                <div class="bg-white dark:bg-gray-800 rounded-lg shadow">
                    <div class="bg-purple-600 p-6">
                        <h2 class="text-xl font-semibold text-white">Alertas del Sistema</h2>
                    </div>
                    
                    <div v-if="alertas.length === 0" class="p-12 text-center text-gray-500">
                        <p>No hay alertas en este momento</p>
                    </div>

                    <div v-else class="p-6">
                        <div v-for="alerta in alertas" :key="alerta.id" class="mb-4 p-4 border-l-4 rounded bg-gray-50 dark:bg-gray-700">
                            <h4 class="font-semibold">{{ alerta.pacienteNombre }}</h4>
                            <p class="text-sm text-gray-600 dark:text-gray-400 mt-1">{{ alerta.descripcion }}</p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </AppLayout>
</template>