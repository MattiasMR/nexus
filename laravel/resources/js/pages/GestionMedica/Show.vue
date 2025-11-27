<script setup lang="ts">
import AppLayout from '@/layouts/AppLayout.vue';
import { Head, router, useForm } from '@inertiajs/vue3';
import { ref } from 'vue';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import Textarea from '@/components/ui/textarea.vue';
import {
    Card,
    CardContent,
    CardDescription,
    CardHeader,
    CardTitle,
} from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar';
import { Separator } from '@/components/ui/separator';
import {
    Dialog,
    DialogContent,
    DialogDescription,
    DialogFooter,
    DialogHeader,
    DialogTitle,
    DialogTrigger,
} from '@/components/ui/dialog';
import { 
    ArrowLeft, 
    Save, 
    FileText, 
    Download,
    Trash2,
    Calendar,
    Phone,
    Mail,
    User,
    Activity,
    AlertCircle,
    Plus,
    X
} from 'lucide-vue-next';
import { type BreadcrumbItem } from '@/types';

interface Usuario {
    id: string;
    displayName: string;
    email: string;
    rut: string | null;
    telefono: string | null;
    photoURL: string | null;
}

interface Paciente {
    id: string;
    grupoSanguineo: string | null;
    prevision: string | null;
    fechaNacimiento: string | null;
    contactoEmergencia: {
        nombre: string;
        telefono: string;
        relacion: string;
    } | null;
}

interface FichaMedica {
    id: string;
    idPaciente: string;
    antecedentes: {
        alergias: string[];
        familiares: string;
        hospitalizaciones: string;
        personales: string;
        quirurgicos: string;
    };
    observacion: string;
    totalConsultas: number;
    ultimaConsulta: string | null;
    fechaMedica: string;
    createdAt: string;
    updatedAt: string;
}

interface Props {
    usuario: Usuario;
    paciente: Paciente;
    ficha: FichaMedica;
}

const props = defineProps<Props>();

const breadcrumbs: BreadcrumbItem[] = [
    { title: 'Gestión Médica', href: '/gestion-medica' },
    { title: props.usuario.displayName, href: `/gestion-medica/${props.paciente.id}` }
];

const mostrarDialogoEliminar = ref(false);
const nuevaAlergia = ref('');

const form = useForm({
    antecedentes: {
        alergias: props.ficha.antecedentes?.alergias || [],
        familiares: props.ficha.antecedentes?.familiares || '',
        hospitalizaciones: props.ficha.antecedentes?.hospitalizaciones || '',
        personales: props.ficha.antecedentes?.personales || '',
        quirurgicos: props.ficha.antecedentes?.quirurgicos || '',
    },
    observacion: props.ficha.observacion || '',
});

const agregarAlergia = () => {
    if (nuevaAlergia.value.trim()) {
        form.antecedentes.alergias.push(nuevaAlergia.value.trim());
        nuevaAlergia.value = '';
    }
};

const eliminarAlergia = (index: number) => {
    form.antecedentes.alergias.splice(index, 1);
};

const guardar = () => {
    form.put(`/gestion-medica/${props.ficha.id}`, {
        preserveScroll: true,
        onSuccess: () => {
            // Mensaje de éxito
        },
    });
};

const volver = () => {
    router.get('/gestion-medica');
};

const descargarPDF = () => {
    window.location.href = `/gestion-medica/${props.paciente.id}/pdf`;
};

const eliminarFicha = () => {
    router.delete(`/gestion-medica/${props.ficha.id}`, {
        onSuccess: () => {
            router.get('/gestion-medica');
        },
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

const calcularEdad = (fechaNacimiento: string | null) => {
    if (!fechaNacimiento) return 'No especificada';
    
    const hoy = new Date();
    const nacimiento = new Date(fechaNacimiento);
    let edad = hoy.getFullYear() - nacimiento.getFullYear();
    const mes = hoy.getMonth() - nacimiento.getMonth();
    
    if (mes < 0 || (mes === 0 && hoy.getDate() < nacimiento.getDate())) {
        edad--;
    }
    
    return `${edad} años`;
};

const formatearFecha = (fecha: string | null) => {
    if (!fecha) return 'Sin fecha';
    return new Date(fecha).toLocaleDateString('es-CL', {
        day: '2-digit',
        month: 'long',
        year: 'numeric'
    });
};
</script>

<template>
    <Head :title="`Ficha Médica - ${usuario.displayName}`" />
    <AppLayout :breadcrumbs="breadcrumbs">
        <div class="p-6 lg:p-8">
            <!-- Header -->
            <div class="mb-6">
                <Button
                    variant="ghost"
                    @click="volver"
                    class="mb-4 -ml-2"
                >
                    <ArrowLeft class="mr-2 h-4 w-4" />
                    Volver a Gestión Médica
                </Button>

                <div class="flex items-start justify-between">
                    <div class="flex items-center gap-4">
                        <Avatar class="h-16 w-16">
                            <AvatarImage v-if="usuario.photoURL" :src="usuario.photoURL" />
                            <AvatarFallback>{{ getInitials(usuario.displayName) }}</AvatarFallback>
                        </Avatar>
                        <div>
                            <h1 class="text-3xl font-bold">{{ usuario.displayName }}</h1>
                            <p class="text-muted-foreground">Ficha Médica del Paciente</p>
                        </div>
                    </div>

                    <div class="flex gap-2">
                        <Button
                            variant="outline"
                            @click="descargarPDF"
                        >
                            <Download class="mr-2 h-4 w-4" />
                            Descargar PDF
                        </Button>

                        <Dialog v-model:open="mostrarDialogoEliminar">
                            <DialogTrigger as-child>
                                <Button variant="destructive">
                                    <Trash2 class="mr-2 h-4 w-4" />
                                    Eliminar Ficha
                                </Button>
                            </DialogTrigger>
                            <DialogContent>
                                <DialogHeader>
                                    <DialogTitle>¿Eliminar ficha médica?</DialogTitle>
                                    <DialogDescription>
                                        Esta acción no se puede deshacer. Se eliminará permanentemente la ficha médica de {{ usuario.displayName }}.
                                    </DialogDescription>
                                </DialogHeader>
                                <DialogFooter>
                                    <Button variant="outline" @click="mostrarDialogoEliminar = false">
                                        Cancelar
                                    </Button>
                                    <Button variant="destructive" @click="eliminarFicha">
                                        Eliminar
                                    </Button>
                                </DialogFooter>
                            </DialogContent>
                        </Dialog>
                    </div>
                </div>
            </div>

            <div class="grid gap-6 md:grid-cols-3">
                <!-- Columna izquierda: Información del paciente -->
                <div class="space-y-6">
                    <!-- Datos Personales -->
                    <Card>
                        <CardHeader>
                            <CardTitle class="text-lg">Datos Personales</CardTitle>
                        </CardHeader>
                        <CardContent class="space-y-4">
                            <div>
                                <div class="flex items-center gap-2 text-sm text-muted-foreground mb-1">
                                    <User class="h-4 w-4" />
                                    <span>RUT</span>
                                </div>
                                <p class="font-mono">{{ usuario.rut || 'Sin RUT' }}</p>
                            </div>

                            <Separator />

                            <div>
                                <div class="flex items-center gap-2 text-sm text-muted-foreground mb-1">
                                    <Mail class="h-4 w-4" />
                                    <span>Email</span>
                                </div>
                                <p>{{ usuario.email }}</p>
                            </div>

                            <Separator />

                            <div>
                                <div class="flex items-center gap-2 text-sm text-muted-foreground mb-1">
                                    <Phone class="h-4 w-4" />
                                    <span>Teléfono</span>
                                </div>
                                <p>{{ usuario.telefono || 'Sin teléfono' }}</p>
                            </div>

                            <Separator />

                            <div>
                                <div class="flex items-center gap-2 text-sm text-muted-foreground mb-1">
                                    <Calendar class="h-4 w-4" />
                                    <span>Edad</span>
                                </div>
                                <p>{{ calcularEdad(paciente.fechaNacimiento) }}</p>
                            </div>
                        </CardContent>
                    </Card>

                    <!-- Datos Médicos -->
                    <Card>
                        <CardHeader>
                            <CardTitle class="text-lg">Datos Médicos</CardTitle>
                        </CardHeader>
                        <CardContent class="space-y-4">
                            <div>
                                <div class="text-sm text-muted-foreground mb-1">Grupo Sanguíneo</div>
                                <Badge v-if="paciente.grupoSanguineo" variant="outline" class="font-mono">
                                    {{ paciente.grupoSanguineo }}
                                </Badge>
                                <p v-else class="text-sm text-muted-foreground">Sin datos</p>
                            </div>

                            <Separator />

                            <div>
                                <div class="text-sm text-muted-foreground mb-1">Previsión</div>
                                <p>{{ paciente.prevision || 'Sin datos' }}</p>
                            </div>

                            <Separator />

                            <div>
                                <div class="flex items-center gap-2 text-sm text-muted-foreground mb-1">
                                    <Activity class="h-4 w-4" />
                                    <span>Total Consultas</span>
                                </div>
                                <p class="text-2xl font-bold">{{ ficha.totalConsultas }}</p>
                            </div>

                            <Separator />

                            <div>
                                <div class="text-sm text-muted-foreground mb-1">Última Consulta</div>
                                <p class="text-sm">{{ formatearFecha(ficha.ultimaConsulta) }}</p>
                            </div>
                        </CardContent>
                    </Card>

                    <!-- Contacto de Emergencia -->
                    <Card v-if="paciente.contactoEmergencia">
                        <CardHeader>
                            <CardTitle class="text-lg">Contacto de Emergencia</CardTitle>
                        </CardHeader>
                        <CardContent class="space-y-4">
                            <div>
                                <div class="text-sm text-muted-foreground mb-1">Nombre</div>
                                <p>{{ paciente.contactoEmergencia.nombre }}</p>
                            </div>

                            <Separator />

                            <div>
                                <div class="text-sm text-muted-foreground mb-1">Teléfono</div>
                                <p class="font-mono">{{ paciente.contactoEmergencia.telefono }}</p>
                            </div>

                            <Separator />

                            <div>
                                <div class="text-sm text-muted-foreground mb-1">Relación</div>
                                <p>{{ paciente.contactoEmergencia.relacion }}</p>
                            </div>
                        </CardContent>
                    </Card>
                </div>

                <!-- Columna derecha: Ficha médica -->
                <div class="md:col-span-2 space-y-6">
                    <form @submit.prevent="guardar">
                        <!-- Alergias -->
                        <Card class="mb-6">
                            <CardHeader>
                                <div class="flex items-center gap-2">
                                    <AlertCircle class="h-5 w-5 text-destructive" />
                                    <CardTitle>Alergias</CardTitle>
                                </div>
                                <CardDescription>Alergias conocidas del paciente</CardDescription>
                            </CardHeader>
                            <CardContent class="space-y-4">
                                <!-- Lista de alergias -->
                                <div class="flex flex-wrap gap-2">
                                    <Badge
                                        v-for="(alergia, index) in form.antecedentes.alergias"
                                        :key="index"
                                        variant="destructive"
                                        class="flex items-center gap-1"
                                    >
                                        {{ alergia }}
                                        <button
                                            type="button"
                                            @click="eliminarAlergia(index)"
                                            class="ml-1 hover:bg-destructive-foreground/20 rounded-full p-0.5"
                                        >
                                            <X class="h-3 w-3" />
                                        </button>
                                    </Badge>
                                    <Badge
                                        v-if="form.antecedentes.alergias.length === 0"
                                        variant="outline"
                                    >
                                        Sin alergias registradas
                                    </Badge>
                                </div>

                                <!-- Agregar alergia -->
                                <div class="flex gap-2">
                                    <Input
                                        v-model="nuevaAlergia"
                                        placeholder="Nueva alergia..."
                                        @keydown.enter.prevent="agregarAlergia"
                                    />
                                    <Button
                                        type="button"
                                        @click="agregarAlergia"
                                        variant="outline"
                                        size="icon"
                                    >
                                        <Plus class="h-4 w-4" />
                                    </Button>
                                </div>
                            </CardContent>
                        </Card>

                        <!-- Antecedentes -->
                        <Card class="mb-6">
                            <CardHeader>
                                <CardTitle>Antecedentes Médicos</CardTitle>
                                <CardDescription>Historial médico del paciente</CardDescription>
                            </CardHeader>
                            <CardContent class="space-y-6">
                                <!-- Antecedentes Personales -->
                                <div class="space-y-2">
                                    <Label for="personales">Antecedentes Personales</Label>
                                    <Textarea
                                        id="personales"
                                        v-model="form.antecedentes.personales"
                                        placeholder="Ej: Hipertensión arterial desde 2015"
                                        rows="3"
                                    />
                                </div>

                                <!-- Antecedentes Familiares -->
                                <div class="space-y-2">
                                    <Label for="familiares">Antecedentes Familiares</Label>
                                    <Textarea
                                        id="familiares"
                                        v-model="form.antecedentes.familiares"
                                        placeholder="Ej: Padre con diabetes tipo 2"
                                        rows="3"
                                    />
                                </div>

                                <!-- Antecedentes Quirúrgicos -->
                                <div class="space-y-2">
                                    <Label for="quirurgicos">Antecedentes Quirúrgicos</Label>
                                    <Textarea
                                        id="quirurgicos"
                                        v-model="form.antecedentes.quirurgicos"
                                        placeholder="Ej: Apendicectomía en 2010"
                                        rows="3"
                                    />
                                </div>

                                <!-- Hospitalizaciones -->
                                <div class="space-y-2">
                                    <Label for="hospitalizaciones">Hospitalizaciones</Label>
                                    <Textarea
                                        id="hospitalizaciones"
                                        v-model="form.antecedentes.hospitalizaciones"
                                        placeholder="Ej: Neumonía en 2018"
                                        rows="3"
                                    />
                                </div>
                            </CardContent>
                        </Card>

                        <!-- Observaciones -->
                        <Card class="mb-6">
                            <CardHeader>
                                <CardTitle>Observaciones Generales</CardTitle>
                                <CardDescription>Notas adicionales sobre el paciente</CardDescription>
                            </CardHeader>
                            <CardContent>
                                <Textarea
                                    v-model="form.observacion"
                                    placeholder="Observaciones generales del paciente..."
                                    rows="4"
                                />
                            </CardContent>
                        </Card>

                        <!-- Botón Guardar -->
                        <div class="flex justify-end">
                            <Button
                                type="submit"
                                :disabled="form.processing"
                                class="min-w-[140px]"
                            >
                                <Save v-if="!form.processing" class="mr-2 h-4 w-4" />
                                <span v-if="form.processing">Guardando...</span>
                                <span v-else>Guardar Cambios</span>
                            </Button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </AppLayout>
</template>
