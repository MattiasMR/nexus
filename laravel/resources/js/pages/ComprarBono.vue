<script setup lang="ts">
import AppLayout from '@/layouts/AppLayout.vue';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import {
    Card,
    CardContent,
    CardDescription,
    CardFooter,
    CardHeader,
    CardTitle,
} from '@/components/ui/card';
import {
    Select,
    SelectContent,
    SelectGroup,
    SelectItem,
    SelectTrigger,
    SelectValue,
} from '@/components/ui/select';
import { Badge } from '@/components/ui/badge';
import { Head, useForm } from '@inertiajs/vue3';
import { CreditCard, Calendar, DollarSign, Clock, CheckCircle2, User, Search } from 'lucide-vue-next';
import { computed, watch, ref } from 'vue';
import {
  Popover,
  PopoverContent,
  PopoverTrigger,
} from '@/components/ui/popover';
import {
  Command,
  CommandEmpty,
  CommandGroup,
  CommandInput,
  CommandItem,
  CommandList,
} from '@/components/ui/command';

interface TipoBono {
    id: string;
    nombre: string;
    descripcion: string;
    precio: number;
    duracion_dias: number;
}

interface Paciente {
    id: string;
    nombre: string;
    email: string;
    rut: string;
    telefono: string;
    label: string;
}

interface Props {
    tiposBonos: TipoBono[];
    pacientes: Paciente[];
}

const props = defineProps<Props>();

const form = useForm({
    paciente_id: '',
    tipo_bono: '',
    nombre: '',
    email: '',
    rut: '',
    telefono: '',
});

// Estado para el popover de pacientes
const openPacientes = ref(false);
const searchPaciente = ref('');

// Paciente seleccionado para mostrar en el botón
const pacienteSeleccionado = computed(() => {
    if (!form.paciente_id) return null;
    return props.pacientes.find(p => p.id === form.paciente_id);
});

// Filtrar pacientes por búsqueda (nombre o RUT)
const pacientesFiltrados = computed(() => {
    const search = searchPaciente.value.toLowerCase().trim();
    if (!search) return props.pacientes;
    
    return props.pacientes.filter(p => {
        const nombre = (p.nombre || '').toLowerCase();
        const rut = (p.rut || '').toLowerCase();
        return nombre.includes(search) || rut.includes(search);
    });
});

// Función para seleccionar paciente
const seleccionarPaciente = (pacienteId: string) => {
    form.paciente_id = pacienteId;
    openPacientes.value = false;
    searchPaciente.value = '';
};

// Watch para autorrellenar cuando se selecciona un paciente
watch(() => form.paciente_id, (pacienteId) => {
    if (pacienteId) {
        const paciente = props.pacientes.find(p => p.id === pacienteId);
        if (paciente) {
            form.nombre = paciente.nombre;
            form.email = paciente.email;
            form.rut = paciente.rut;
            form.telefono = paciente.telefono;
        }
    } else {
        // Limpiar campos si selecciona "Ingresar datos manualmente"
        form.nombre = '';
        form.email = '';
        form.rut = '';
        form.telefono = '';
    }
});

const bonoSeleccionado = computed(() => {
    if (!form.tipo_bono) return null;
    return props.tiposBonos.find(b => b.id === form.tipo_bono) || null;
});

// Texto para mostrar en el Select
const textoBonoSeleccionado = computed(() => {
    if (!bonoSeleccionado.value) return '';
    return `${bonoSeleccionado.value.nombre} - $${bonoSeleccionado.value.precio.toLocaleString('es-CL')}`;
});

const precioFormateado = computed(() => {
    if (!bonoSeleccionado.value) return '$0';
    return '$' + bonoSeleccionado.value.precio.toLocaleString('es-CL');
});

const fechaVencimiento = computed(() => {
    if (!bonoSeleccionado.value) return '';
    const fecha = new Date();
    fecha.setDate(fecha.getDate() + bonoSeleccionado.value.duracion_dias);
    return fecha.toLocaleDateString('es-CL', { 
        year: 'numeric', 
        month: 'long', 
        day: 'numeric' 
    });
});

const submit = () => {
    if (!bonoSeleccionado.value) {
        alert('Por favor seleccione un tipo de bono');
        return;
    }
    
    // Validar campos requeridos
    if (!form.nombre || !form.rut || !form.email || !form.telefono) {
        alert('Por favor complete todos los campos requeridos');
        return;
    }
    
    // Usar Inertia post con el monto del bono
    form.transform((data) => ({
        ...data,
        monto: bonoSeleccionado.value!.precio
    })).post('/comprar-bono/iniciar');
};
</script>

<template>
    <Head title="Comprar Bono" />
    <AppLayout>
        <div class="container mx-auto p-6 max-w-5xl">
            <!-- Header -->
            <div class="mb-8">
                <h1 class="text-3xl font-bold text-gray-900 dark:text-white mb-2">
                    Comprar Bono Médico
                </h1>
                <p class="text-gray-600 dark:text-gray-400">
                    Complete el formulario para proceder con el pago del bono médico a través de WebPay
                </p>
            </div>

            <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
                <!-- Formulario -->
                <div class="lg:col-span-2">
                    <Card>
                        <CardHeader>
                            <CardTitle class="flex items-center gap-2">
                                <CreditCard class="h-5 w-5" />
                                Información del Paciente
                            </CardTitle>
                            <CardDescription>
                                Seleccione un paciente existente o ingrese los datos manualmente
                            </CardDescription>
                        </CardHeader>
                        <CardContent>
                            <form @submit.prevent="submit" class="space-y-6">
                                <!-- Selección de Paciente -->
                                <div class="space-y-2">
                                    <Label for="paciente" class="flex items-center gap-2">
                                        <User class="h-4 w-4" />
                                        Seleccionar Paciente
                                    </Label>
                                    <Popover v-model:open="openPacientes">
                                        <PopoverTrigger as-child>
                                            <Button
                                                variant="outline"
                                                role="combobox"
                                                :aria-expanded="openPacientes"
                                                class="w-full justify-between"
                                            >
                                                <span class="truncate">
                                                    {{ pacienteSeleccionado ? pacienteSeleccionado.label : 'Seleccione un paciente o ingrese datos manualmente...' }}
                                                </span>
                                                <Search class="ml-2 h-4 w-4 shrink-0 opacity-50" />
                                            </Button>
                                        </PopoverTrigger>
                                        <PopoverContent class="w-full p-0" align="start">
                                            <Command>
                                                <CommandInput 
                                                    v-model="searchPaciente"
                                                    placeholder="Buscar por nombre o RUT..." 
                                                />
                                                <CommandList>
                                                    <CommandEmpty>No se encontraron pacientes</CommandEmpty>
                                                    <CommandGroup>
                                                        <CommandItem
                                                            value="__manual__"
                                                            @select="seleccionarPaciente('')"
                                                        >
                                                            <User class="mr-2 h-4 w-4" />
                                                            Ingresar datos manualmente
                                                        </CommandItem>
                                                        <CommandItem
                                                            v-for="paciente in pacientesFiltrados"
                                                            :key="paciente.id"
                                                            :value="paciente.id"
                                                            @select="seleccionarPaciente(paciente.id)"
                                                        >
                                                            {{ paciente.label }}
                                                        </CommandItem>
                                                    </CommandGroup>
                                                </CommandList>
                                            </Command>
                                        </PopoverContent>
                                    </Popover>
                                    <p class="text-sm text-muted-foreground">
                                        Haga clic y escriba para buscar. Si selecciona un paciente, sus datos se rellenarán automáticamente
                                    </p>
                                </div>

                                <!-- Selección de Tipo de Bono -->
                                <div class="space-y-2">
                                    <Label for="tipo_bono">Tipo de Bono *</Label>
                                    <Select v-model:model-value="form.tipo_bono">
                                        <SelectTrigger>
                                            <SelectValue placeholder="Seleccione un tipo de bono">
                                                <template v-if="form.tipo_bono">
                                                    {{ textoBonoSeleccionado }}
                                                </template>
                                            </SelectValue>
                                        </SelectTrigger>
                                        <SelectContent>
                                            <SelectGroup>
                                                <SelectItem 
                                                    v-for="bono in tiposBonos" 
                                                    :key="bono.id" 
                                                    :value="bono.id"
                                                >
                                                    {{ bono.nombre }} - {{ '$' + bono.precio.toLocaleString('es-CL') }}
                                                </SelectItem>
                                            </SelectGroup>
                                        </SelectContent>
                                    </Select>
                                    <p v-if="form.errors.tipo_bono" class="text-sm text-red-600">
                                        {{ form.errors.tipo_bono }}
                                    </p>
                                </div>

                                <!-- Nombre -->
                                <div class="space-y-2">
                                    <Label for="nombre">Nombre Completo *</Label>
                                    <Input
                                        id="nombre"
                                        v-model="form.nombre"
                                        type="text"
                                        placeholder="Juan Pérez González"
                                        required
                                    />
                                    <p v-if="form.errors.nombre" class="text-sm text-red-600">
                                        {{ form.errors.nombre }}
                                    </p>
                                </div>

                                <!-- RUT -->
                                <div class="space-y-2">
                                    <Label for="rut">RUT *</Label>
                                    <Input
                                        id="rut"
                                        v-model="form.rut"
                                        type="text"
                                        placeholder="12.345.678-9"
                                        required
                                    />
                                    <p v-if="form.errors.rut" class="text-sm text-red-600">
                                        {{ form.errors.rut }}
                                    </p>
                                </div>

                                <!-- Email -->
                                <div class="space-y-2">
                                    <Label for="email">Email *</Label>
                                    <Input
                                        id="email"
                                        v-model="form.email"
                                        type="email"
                                        placeholder="correo@ejemplo.com"
                                        required
                                    />
                                    <p v-if="form.errors.email" class="text-sm text-red-600">
                                        {{ form.errors.email }}
                                    </p>
                                </div>

                                <!-- Teléfono -->
                                <div class="space-y-2">
                                    <Label for="telefono">Teléfono *</Label>
                                    <Input
                                        id="telefono"
                                        v-model="form.telefono"
                                        type="tel"
                                        placeholder="+56 9 1234 5678"
                                        required
                                    />
                                    <p v-if="form.errors.telefono" class="text-sm text-red-600">
                                        {{ form.errors.telefono }}
                                    </p>
                                </div>

                                <!-- Botón Submit -->
                                <Button 
                                    type="submit" 
                                    class="w-full"
                                    :disabled="form.processing || !bonoSeleccionado"
                                >
                                    <CreditCard class="w-4 h-4 mr-2" />
                                    {{ form.processing ? 'Procesando...' : 'Proceder al Pago' }}
                                </Button>
                            </form>
                        </CardContent>
                    </Card>
                </div>

                <!-- Resumen del Bono -->
                <div class="lg:col-span-1">
                    <Card v-if="bonoSeleccionado" class="sticky top-6">
                        <CardHeader>
                            <CardTitle class="text-lg">Resumen del Bono</CardTitle>
                        </CardHeader>
                        <CardContent class="space-y-4">
                            <div>
                                <h3 class="font-semibold text-gray-900 dark:text-white mb-1">
                                    {{ bonoSeleccionado.nombre }}
                                </h3>
                                <p class="text-sm text-gray-600 dark:text-gray-400">
                                    {{ bonoSeleccionado.descripcion }}
                                </p>
                            </div>

                            <div class="space-y-3 pt-4 border-t">
                                <!-- Precio -->
                                <div class="flex items-center justify-between">
                                    <div class="flex items-center gap-2 text-sm text-gray-600 dark:text-gray-400">
                                        <DollarSign class="w-4 h-4" />
                                        <span>Precio</span>
                                    </div>
                                    <span class="font-semibold text-lg text-gray-900 dark:text-white">
                                        {{ precioFormateado }}
                                    </span>
                                </div>

                                <!-- Validez -->
                                <div class="flex items-center justify-between">
                                    <div class="flex items-center gap-2 text-sm text-gray-600 dark:text-gray-400">
                                        <Clock class="w-4 h-4" />
                                        <span>Validez</span>
                                    </div>
                                    <span class="text-sm font-medium">
                                        {{ bonoSeleccionado.duracion_dias }} días
                                    </span>
                                </div>

                                <!-- Vencimiento -->
                                <div class="flex items-center justify-between">
                                    <div class="flex items-center gap-2 text-sm text-gray-600 dark:text-gray-400">
                                        <Calendar class="w-4 h-4" />
                                        <span>Válido hasta</span>
                                    </div>
                                    <span class="text-sm font-medium">
                                        {{ fechaVencimiento }}
                                    </span>
                                </div>
                            </div>

                            <!-- Beneficios -->
                            <div class="pt-4 border-t">
                                <h4 class="text-sm font-semibold mb-2 text-gray-900 dark:text-white">
                                    Beneficios incluidos:
                                </h4>
                                <div class="space-y-2">
                                    <div class="flex items-center gap-2 text-sm">
                                        <CheckCircle2 class="w-4 h-4 text-green-600" />
                                        <span class="text-gray-600 dark:text-gray-400">Pago seguro con WebPay</span>
                                    </div>
                                    <div class="flex items-center gap-2 text-sm">
                                        <CheckCircle2 class="w-4 h-4 text-green-600" />
                                        <span class="text-gray-600 dark:text-gray-400">Comprobante descargable</span>
                                    </div>
                                    <div class="flex items-center gap-2 text-sm">
                                        <CheckCircle2 class="w-4 h-4 text-green-600" />
                                        <span class="text-gray-600 dark:text-gray-400">Sin costos adicionales</span>
                                    </div>
                                </div>
                            </div>
                        </CardContent>
                        <CardFooter>
                            <Badge variant="secondary" class="w-full justify-center">
                                Ambiente de Pruebas
                            </Badge>
                        </CardFooter>
                    </Card>

                    <!-- Placeholder cuando no hay bono seleccionado -->
                    <Card v-else>
                        <CardContent class="pt-6">
                            <div class="text-center py-8 text-gray-400">
                                <CreditCard class="w-12 h-12 mx-auto mb-3 opacity-30" />
                                <p class="text-sm">
                                    Seleccione un tipo de bono para ver el resumen
                                </p>
                            </div>
                        </CardContent>
                    </Card>
                </div>
            </div>
        </div>
    </AppLayout>
</template>
