<?php

namespace App\Http\Controllers;

use App\Models\Paciente;
use Illuminate\Http\Request;
use Inertia\Inertia;
use Inertia\Response;

class PacienteController extends Controller
{
    protected Paciente $pacienteModel;

    public function __construct(Paciente $pacienteModel)
    {
        $this->pacienteModel = $pacienteModel;
    }

    /**
     * Listar todos los pacientes
     */
    public function index(): Response
    {
        try {
            $pacientes = $this->pacienteModel->all();

            return Inertia::render('Pacientes/Index', [
                'pacientes' => $pacientes,
            ]);
        } catch (\Exception $e) {
            return Inertia::render('Pacientes/Index', [
                'pacientes' => [],
                'error' => $e->getMessage(),
            ]);
        }
    }

    /**
     * Mostrar un paciente específico
     */
    public function show(string $id): Response
    {
        try {
            $paciente = $this->pacienteModel->find($id);

            if (!$paciente) {
                abort(404, 'Paciente no encontrado');
            }

            return Inertia::render('Pacientes/Show', [
                'paciente' => $paciente,
            ]);
        } catch (\Exception $e) {
            abort(500, 'Error al cargar paciente: ' . $e->getMessage());
        }
    }

    /**
     * Crear un nuevo paciente
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'rut' => 'required|string',
            'nombre' => 'required|string',
            'apellido' => 'required|string',
            'fechaNacimiento' => 'required|date',
            'direccion' => 'required|string',
            'telefono' => 'required|string',
            'email' => 'nullable|email',
            'sexo' => 'required|in:M,F,Otro',
            'grupoSanguineo' => 'nullable|string',
            'alergias' => 'nullable|array',
            'enfermedadesCronicas' => 'nullable|array',
        ]);

        try {
            // Verificar si ya existe un paciente con ese RUT
            $existente = $this->pacienteModel->findByRut($validated['rut']);
            if ($existente) {
                return back()->withErrors(['rut' => 'Ya existe un paciente con este RUT']);
            }

            $id = $this->pacienteModel->create($validated);

            return redirect()->route('pacientes.show', $id)
                ->with('success', 'Paciente creado exitosamente');
        } catch (\Exception $e) {
            return back()->withErrors(['error' => 'Error al crear paciente: ' . $e->getMessage()]);
        }
    }

    /**
     * Actualizar un paciente
     */
    public function update(Request $request, string $id)
    {
        $validated = $request->validate([
            'rut' => 'sometimes|string',
            'nombre' => 'sometimes|string',
            'apellido' => 'sometimes|string',
            'fechaNacimiento' => 'sometimes|date',
            'direccion' => 'sometimes|string',
            'telefono' => 'sometimes|string',
            'email' => 'nullable|email',
            'sexo' => 'sometimes|in:M,F,Otro',
            'grupoSanguineo' => 'nullable|string',
            'alergias' => 'nullable|array',
            'enfermedadesCronicas' => 'nullable|array',
        ]);

        try {
            $this->pacienteModel->update($id, $validated);

            return back()->with('success', 'Paciente actualizado exitosamente');
        } catch (\Exception $e) {
            return back()->withErrors(['error' => 'Error al actualizar paciente: ' . $e->getMessage()]);
        }
    }

    /**
     * Eliminar un paciente
     */
    public function destroy(string $id)
    {
        try {
            $this->pacienteModel->delete($id);

            return redirect()->route('pacientes.index')
                ->with('success', 'Paciente eliminado exitosamente');
        } catch (\Exception $e) {
            return back()->withErrors(['error' => 'Error al eliminar paciente: ' . $e->getMessage()]);
        }
    }

    /**
     * Buscar pacientes
     */
    public function search(Request $request)
    {
        $query = $request->input('q', '');

        try {
            $pacientes = $this->pacienteModel->search($query);

            return response()->json([
                'pacientes' => $pacientes,
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'error' => $e->getMessage(),
                'pacientes' => [],
            ], 500);
        }
    }
}
