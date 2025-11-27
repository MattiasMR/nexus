<?php

namespace App\Http\Controllers\Settings;

use App\Http\Controllers\Controller;
use App\Http\Requests\Settings\ProfileUpdateRequest;
use App\Models\Usuario;
use Illuminate\Contracts\Auth\MustVerifyEmail;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Inertia\Inertia;
use Inertia\Response;
use Kreait\Firebase\Contract\Auth as FirebaseAuth;

class ProfileController extends Controller
{
    /**
     * Show the user's profile settings page.
     */
    public function edit(Request $request): Response
    {
        return Inertia::render('settings/Profile', [
            'mustVerifyEmail' => $request->user() instanceof MustVerifyEmail,
            'status' => $request->session()->get('status'),
        ]);
    }

    /**
     * Update the user's profile information.
     */
    public function update(ProfileUpdateRequest $request): RedirectResponse
    {
        $validated = $request->validated();
        $user = $request->user();
        
        try {
            $usuarioModel = new Usuario();
            
            // Preparar datos para actualizar
            $updateData = [];
            
            if (isset($validated['name'])) {
                $updateData['displayName'] = $validated['name'];
            }
            
            if (isset($validated['email']) && $validated['email'] !== $user->email) {
                // Verificar que el email no esté en uso
                $emailExiste = $usuarioModel->findByEmail($validated['email']);
                if ($emailExiste && $emailExiste['id'] !== $user->uid) {
                    return back()->withErrors(['email' => 'Este correo ya está en uso por otro usuario.']);
                }
                
                $updateData['email'] = $validated['email'];
            }
            
            if (!empty($updateData)) {
                // Actualizar en Firestore
                $usuarioModel->update($user->uid, $updateData);
                
                // Actualizar en Firebase Auth
                $auth = app(FirebaseAuth::class);
                $authUpdateData = [];
                
                if (isset($updateData['email'])) {
                    $authUpdateData['email'] = $updateData['email'];
                }
                if (isset($updateData['displayName'])) {
                    $authUpdateData['displayName'] = $updateData['displayName'];
                }
                
                if (!empty($authUpdateData)) {
                    $auth->updateUser($user->uid, $authUpdateData);
                }
            }

            return back()->with('success', 'Perfil actualizado correctamente');
        } catch (\Exception $e) {
            logger()->error("Error actualizando perfil: " . $e->getMessage());
            return back()->withErrors(['email' => 'Error al actualizar el perfil. Intenta nuevamente.']);
        }
    }

    /**
     * Delete the user's profile.
     */
    public function destroy(Request $request): RedirectResponse
    {
        $request->validate([
            'password' => ['required', 'current_password'],
        ]);

        $user = $request->user();

        try {
            $usuarioModel = new Usuario();
            $auth = app(FirebaseAuth::class);
            
            // Cerrar sesión
            Auth::logout();
            
            // Eliminar de Firebase Auth
            $auth->deleteUser($user->uid);
            
            // Eliminar de Firestore
            $usuarioModel->delete($user->uid);
            
            $request->session()->invalidate();
            $request->session()->regenerateToken();

            return redirect('/')->with('success', 'Tu cuenta ha sido eliminada permanentemente');
        } catch (\Exception $e) {
            logger()->error("Error eliminando cuenta: " . $e->getMessage());
            return back()->withErrors(['password' => 'Error al eliminar la cuenta. Intenta nuevamente.']);
        }
    }
}
