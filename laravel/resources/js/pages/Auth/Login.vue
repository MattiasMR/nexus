<script setup lang="ts">
import { login } from '@/routes';
import { Head, useForm } from '@inertiajs/vue3';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Checkbox } from '@/components/ui/checkbox';
import { LogIn, AlertTriangle } from 'lucide-vue-next';

const form = useForm({
    email: '',
    password: '',
    remember: false,
});

const submit = () => {
    form.post(login.url(), {
        onFinish: () => {
            form.reset('password');
        },
    });
};
</script>

<template>
    <Head title="Iniciar Sesión" />
    
    <div class="min-h-screen flex items-center justify-center bg-background p-4">
        <Card class="w-full max-w-md">
            <CardHeader class="space-y-1">
                <CardTitle class="text-2xl font-bold text-center">
                    Iniciar Sesión
                </CardTitle>
                <CardDescription class="text-center">
                    Panel de Administración
                </CardDescription>
            </CardHeader>

            <CardContent class="space-y-4">
                <!-- Advertencia solo para administradores -->
                <div class="flex items-start gap-3 rounded-lg border border-yellow-500/50 bg-yellow-50 dark:bg-yellow-950/50 p-3">
                    <AlertTriangle class="h-5 w-5 text-yellow-600 dark:text-yellow-500 mt-0.5 flex-shrink-0" />
                    <p class="text-sm text-yellow-800 dark:text-yellow-200">
                        Solo administradores pueden acceder a este panel
                    </p>
                </div>

                <form @submit.prevent="submit" class="space-y-4">
                    <!-- Email -->
                    <div class="space-y-2">
                        <Label for="email">Correo Electrónico</Label>
                        <Input
                            id="email"
                            v-model="form.email"
                            type="email"
                            placeholder="admin@nexus.cl"
                            autocomplete="email"
                            required
                            :disabled="form.processing"
                        />
                    </div>

                    <!-- Password -->
                    <div class="space-y-2">
                        <Label for="password">Contraseña</Label>
                        <Input
                            id="password"
                            v-model="form.password"
                            type="password"
                            placeholder="••••••••"
                            autocomplete="current-password"
                            required
                            :disabled="form.processing"
                        />
                    </div>

                    <!-- Remember me -->
                    <div class="flex items-center space-x-2">
                        <Checkbox 
                            id="remember"
                            :checked="form.remember"
                            @update:checked="form.remember = $event"
                            :disabled="form.processing"
                        />
                        <Label
                            for="remember"
                            class="text-sm font-normal cursor-pointer"
                        >
                            Recordarme
                        </Label>
                    </div>

                    <!-- Error message -->
                    <div v-if="form.errors.email" class="rounded-lg border border-destructive/50 bg-destructive/10 p-3">
                        <p class="text-sm text-destructive">{{ form.errors.email }}</p>
                    </div>

                    <!-- Submit button -->
                    <Button
                        type="submit"
                        class="w-full"
                        :disabled="form.processing"
                    >
                        <LogIn class="mr-2 h-4 w-4" />
                        {{ form.processing ? 'Iniciando sesión...' : 'Iniciar Sesión' }}
                    </Button>
                </form>
            </CardContent>
        </Card>
    </div>
</template>
