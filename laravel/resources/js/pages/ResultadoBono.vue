<script setup lang="ts">
import AppLayout from '@/layouts/AppLayout.vue';
import { Button } from '@/components/ui/button';
import {
    Card,
    CardContent,
    CardDescription,
    CardFooter,
    CardHeader,
    CardTitle,
} from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Alert, AlertDescription, AlertTitle } from '@/components/ui/alert';
import { Separator } from '@/components/ui/separator';
import { Head, Link } from '@inertiajs/vue3';
import { 
    CheckCircle2, 
    XCircle, 
    Download, 
    Calendar, 
    CreditCard,
    User,
    Mail,
    Phone,
    FileText,
    ArrowLeft
} from 'lucide-vue-next';
import { computed } from 'vue';

interface DatosPaciente {
    nombre: string;
    email: string;
    rut: string;
    telefono: string;
    monto: number;
    buy_order: string;
}

interface Resultado {
    approved: boolean;
    buy_order: string;
    session_id: string;
    card_number: string;
    accounting_date: string;
    transaction_date: string;
    authorization_code: string;
    payment_type_code: string;
    response_code: number;
    amount: number;
    installments_number: number;
    installments_amount?: number;
    status: string;
    vci: string;
    balance?: number;
}

interface Props {
    resultado: Resultado;
    datosPaciente: DatosPaciente;
}

const props = defineProps<Props>();

const esAprobada = computed(() => props.resultado.approved);

const montoFormateado = computed(() => {
    return '$' + props.resultado.amount.toLocaleString('es-CL');
});

const tipoPago = computed(() => {
    const tipos: Record<string, string> = {
        'VD': 'Venta Débito',
        'VN': 'Venta Normal',
        'VC': 'Venta en cuotas',
        'SI': '3 cuotas sin interés',
        'S2': '2 cuotas sin interés',
        'NC': 'N cuotas sin interés',
    };
    return tipos[props.resultado.payment_type_code] || props.resultado.payment_type_code;
});

const fechaTransaccion = computed(() => {
    const fecha = props.resultado.transaction_date;
    if (!fecha) return 'N/A';
    
    // Formato: 2024-11-23T18:30:45.123
    const date = new Date(fecha);
    return date.toLocaleString('es-CL', {
        year: 'numeric',
        month: 'long',
        day: 'numeric',
        hour: '2-digit',
        minute: '2-digit',
    });
});
</script>

<template>
    <Head title="Resultado de la Transacción" />
    <AppLayout>
        <div class="container mx-auto p-6 max-w-4xl">
            <!-- Header con estado -->
            <div class="mb-8 text-center">
                <div v-if="esAprobada" class="mb-4">
                    <div class="inline-flex items-center justify-center w-20 h-20 bg-green-100 dark:bg-green-900/20 rounded-full mb-4">
                        <CheckCircle2 class="w-10 h-10 text-green-600 dark:text-green-400" />
                    </div>
                    <h1 class="text-3xl font-bold text-gray-900 dark:text-white mb-2">
                        ¡Pago Exitoso!
                    </h1>
                    <p class="text-gray-600 dark:text-gray-400">
                        Tu bono médico ha sido pagado correctamente
                    </p>
                </div>
                <div v-else class="mb-4">
                    <div class="inline-flex items-center justify-center w-20 h-20 bg-red-100 dark:bg-red-900/20 rounded-full mb-4">
                        <XCircle class="w-10 h-10 text-red-600 dark:text-red-400" />
                    </div>
                    <h1 class="text-3xl font-bold text-gray-900 dark:text-white mb-2">
                        Pago Rechazado
                    </h1>
                    <p class="text-gray-600 dark:text-gray-400">
                        La transacción no pudo ser completada
                    </p>
                </div>
            </div>

            <!-- Alerta de estado -->
            <Alert :variant="esAprobada ? 'default' : 'destructive'" class="mb-6">
                <AlertTitle class="flex items-center gap-2">
                    <component :is="esAprobada ? CheckCircle2 : XCircle" class="w-4 h-4" />
                    {{ esAprobada ? 'Transacción Aprobada' : 'Transacción Rechazada' }}
                </AlertTitle>
                <AlertDescription>
                    {{ esAprobada 
                        ? 'El pago se ha procesado correctamente. Puedes descargar tu comprobante más abajo.' 
                        : 'El pago no pudo ser procesado. Por favor, intenta nuevamente o contacta a tu banco.' 
                    }}
                </AlertDescription>
            </Alert>

            <div class="grid grid-cols-1 md:grid-cols-2 gap-6 mb-6">
                <!-- Datos del Paciente -->
                <Card>
                    <CardHeader>
                        <CardTitle class="text-lg flex items-center gap-2">
                            <User class="w-5 h-5" />
                            Datos del Paciente
                        </CardTitle>
                    </CardHeader>
                    <CardContent class="space-y-3">
                        <div class="flex items-start gap-3">
                            <User class="w-4 h-4 mt-1 text-gray-400" />
                            <div class="flex-1">
                                <p class="text-sm text-gray-600 dark:text-gray-400">Nombre</p>
                                <p class="font-medium">{{ datosPaciente.nombre }}</p>
                            </div>
                        </div>
                        <Separator />
                        <div class="flex items-start gap-3">
                            <FileText class="w-4 h-4 mt-1 text-gray-400" />
                            <div class="flex-1">
                                <p class="text-sm text-gray-600 dark:text-gray-400">RUT</p>
                                <p class="font-medium">{{ datosPaciente.rut }}</p>
                            </div>
                        </div>
                        <Separator />
                        <div class="flex items-start gap-3">
                            <Mail class="w-4 h-4 mt-1 text-gray-400" />
                            <div class="flex-1">
                                <p class="text-sm text-gray-600 dark:text-gray-400">Email</p>
                                <p class="font-medium">{{ datosPaciente.email }}</p>
                            </div>
                        </div>
                        <Separator />
                        <div class="flex items-start gap-3">
                            <Phone class="w-4 h-4 mt-1 text-gray-400" />
                            <div class="flex-1">
                                <p class="text-sm text-gray-600 dark:text-gray-400">Teléfono</p>
                                <p class="font-medium">{{ datosPaciente.telefono }}</p>
                            </div>
                        </div>
                    </CardContent>
                </Card>

                <!-- Datos de la Transacción -->
                <Card>
                    <CardHeader>
                        <CardTitle class="text-lg flex items-center gap-2">
                            <CreditCard class="w-5 h-5" />
                            Detalles de la Transacción
                        </CardTitle>
                    </CardHeader>
                    <CardContent class="space-y-3">
                        <div>
                            <p class="text-sm text-gray-600 dark:text-gray-400">Monto Total</p>
                            <p class="text-2xl font-bold text-gray-900 dark:text-white">{{ montoFormateado }}</p>
                        </div>
                        <Separator />
                        <div>
                            <p class="text-sm text-gray-600 dark:text-gray-400">Número de Orden</p>
                            <p class="font-medium">{{ resultado.buy_order }}</p>
                        </div>
                        <Separator />
                        <div v-if="esAprobada">
                            <p class="text-sm text-gray-600 dark:text-gray-400">Código de Autorización</p>
                            <p class="font-medium">{{ resultado.authorization_code }}</p>
                        </div>
                        <div v-else>
                            <p class="text-sm text-gray-600 dark:text-gray-400">Código de Respuesta</p>
                            <p class="font-medium">{{ resultado.response_code }}</p>
                        </div>
                        <Separator />
                        <div>
                            <p class="text-sm text-gray-600 dark:text-gray-400">Tipo de Pago</p>
                            <p class="font-medium">{{ tipoPago }}</p>
                        </div>
                        <Separator />
                        <div>
                            <p class="text-sm text-gray-600 dark:text-gray-400">Tarjeta</p>
                            <p class="font-medium">**** {{ resultado.card_number }}</p>
                        </div>
                        <Separator v-if="resultado.installments_number > 0" />
                        <div v-if="resultado.installments_number > 0">
                            <p class="text-sm text-gray-600 dark:text-gray-400">Cuotas</p>
                            <p class="font-medium">{{ resultado.installments_number }} cuotas</p>
                        </div>
                    </CardContent>
                </Card>
            </div>

            <!-- Información adicional -->
            <Card class="mb-6">
                <CardHeader>
                    <CardTitle class="text-lg flex items-center gap-2">
                        <Calendar class="w-5 h-5" />
                        Información Adicional
                    </CardTitle>
                </CardHeader>
                <CardContent class="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div>
                        <p class="text-sm text-gray-600 dark:text-gray-400">Fecha de Transacción</p>
                        <p class="font-medium">{{ fechaTransaccion }}</p>
                    </div>
                    <div>
                        <p class="text-sm text-gray-600 dark:text-gray-400">ID de Sesión</p>
                        <p class="font-medium font-mono text-xs">{{ resultado.session_id }}</p>
                    </div>
                    <div>
                        <p class="text-sm text-gray-600 dark:text-gray-400">Estado</p>
                        <Badge :variant="esAprobada ? 'default' : 'destructive'">
                            {{ resultado.status }}
                        </Badge>
                    </div>
                    <div>
                        <p class="text-sm text-gray-600 dark:text-gray-400">Ambiente</p>
                        <Badge variant="secondary">Pruebas</Badge>
                    </div>
                </CardContent>
            </Card>

            <!-- Acciones -->
            <Card>
                <CardFooter class="flex flex-col sm:flex-row gap-3 pt-6">
                    <Button 
                        v-if="esAprobada"
                        as="a"
                        :href="'/comprar-bono/descargar-comprobante'"
                        variant="default"
                        class="flex-1"
                    >
                        <Download class="w-4 h-4 mr-2" />
                        Descargar Comprobante (JSON)
                    </Button>
                    <Button 
                        v-if="esAprobada"
                        as="a"
                        :href="'/comprar-bono/descargar-comprobante-html'"
                        variant="outline"
                        class="flex-1"
                    >
                        <Download class="w-4 h-4 mr-2" />
                        Descargar Comprobante (HTML)
                    </Button>
                    <Button 
                        as="a"
                        :href="'/comprar-bono'"
                        variant="ghost"
                        class="flex-1"
                    >
                        <ArrowLeft class="w-4 h-4 mr-2" />
                        Volver al Inicio
                    </Button>
                </CardFooter>
            </Card>
        </div>
    </AppLayout>
</template>
