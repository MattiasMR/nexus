<?php

namespace App\Http\Controllers\Settings;

use App\Http\Controllers\Controller;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rules\Password;
use Inertia\Inertia;
use Inertia\Response;
use Kreait\Firebase\Contract\Auth as FirebaseAuth;

class PasswordController extends Controller
{
    /**
     * Show the user's password settings page.
     */
    public function edit(): Response
    {
        return Inertia::render('settings/Password');
    }

    /**
     * Update the user's password.
     */
    public function update(Request $request): RedirectResponse
    {
        $validated = $request->validate([
            'current_password' => ['required', 'current_password'],
            'password' => ['required', Password::defaults(), 'confirmed'],
        ]);

        try {
            $user = $request->user();
            $auth = app(FirebaseAuth::class);
            
            // Actualizar contraseña en Firebase Auth
            $auth->updateUser($user->uid, [
                'password' => $validated['password'],
            ]);

            return back()->with('success', 'Contraseña actualizada correctamente');
        } catch (\Exception $e) {
            logger()->error("Error actualizando contraseña: " . $e->getMessage());
            
            if (str_contains($e->getMessage(), 'WEAK_PASSWORD')) {
                return back()->withErrors(['password' => 'La contraseña es muy débil.']);
            }
            
            return back()->withErrors(['password' => 'Error al actualizar la contraseña. Intenta nuevamente.']);
        }
    }
}
