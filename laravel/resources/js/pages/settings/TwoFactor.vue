<script setup lang="ts">
import HeadingSmall from '@/components/HeadingSmall.vue';
import { Badge } from '@/components/ui/badge';
import AppLayout from '@/layouts/AppLayout.vue';
import SettingsLayout from '@/layouts/settings/Layout.vue';
import { show } from '@/routes/two-factor';
import { BreadcrumbItem } from '@/types';
import { Head } from '@inertiajs/vue3';
import { Clock } from 'lucide-vue-next';

const breadcrumbs: BreadcrumbItem[] = [
    {
        title: 'Two-Factor Authentication',
        href: show.url(),
    },
];
</script>

<template>
    <AppLayout :breadcrumbs="breadcrumbs">
        <Head title="Two-Factor Authentication" />
        <SettingsLayout>
            <div class="space-y-6">
                <HeadingSmall
                    title="Two-Factor Authentication"
                    description="Manage your two-factor authentication settings"
                />

                <div class="flex flex-col items-center justify-center space-y-6 rounded-lg border border-border bg-muted/20 p-12 text-center">
                    <div class="rounded-full bg-primary/10 p-4">
                        <Clock class="h-12 w-12 text-primary" />
                    </div>
                    
                    <div class="space-y-2">
                        <h3 class="text-2xl font-semibold tracking-tight">Próximamente</h3>
                        <p class="text-muted-foreground max-w-md">
                            La autenticación de dos factores estará disponible próximamente. 
                            Esta característica adicional mejorará significativamente la seguridad de tu cuenta.
                        </p>
                    </div>

                    <Badge variant="secondary" class="text-sm">
                        En desarrollo
                    </Badge>
                </div>
            </div>
        </SettingsLayout>
    </AppLayout>
</template>

