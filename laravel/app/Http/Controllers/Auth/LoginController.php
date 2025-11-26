<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Inertia\Inertia;
use Inertia\Response;
use Illuminate\Http\RedirectResponse;

class LoginController extends Controller
{
    /**
     * Mostrar el formulario de login
     */
    public function showLoginForm(): Response
    {
        return Inertia::render('Auth/Login');
    }

    /**
     * Manejar el intento de login
     */
    public function login(Request $request): RedirectResponse
    {
        $request->validate([
            'email' => 'required|email',
            'password' => 'required|string',
        ]);

        try {
            // Intentar autenticación con Firebase
            $credentials = [
                'email' => $request->email,
                'password' => $request->password,
                'rol' => 'admin', // Solo permitir acceso a administradores
            ];

            if (Auth::attempt($credentials, $request->boolean('remember'))) {
                $request->session()->regenerate();

                return redirect()->intended(route('dashboard'));
            }

            // Si falla, verificar si es por rol incorrecto
            $credentialsWithoutRole = [
                'email' => $request->email,
                'password' => $request->password,
            ];

            if (Auth::guard('web')->validate($credentialsWithoutRole)) {
                return back()->withErrors([
                    'email' => 'Esta aplicación es solo para administradores. Por favor, usa la aplicación de profesionales o pacientes.',
                ])->onlyInput('email');
            }

            return back()->withErrors([
                'email' => 'Las credenciales proporcionadas no coinciden con nuestros registros.',
            ])->onlyInput('email');

        } catch (\Exception $e) {
            logger()->error('Error en login: ' . $e->getMessage());
            
            return back()->withErrors([
                'email' => 'Ocurrió un error al intentar iniciar sesión. Por favor, intenta nuevamente.',
            ])->onlyInput('email');
        }
    }

    /**
     * Cerrar sesión
     */
    public function logout(Request $request): RedirectResponse
    {
        Auth::guard('web')->logout();

        $request->session()->invalidate();
        $request->session()->regenerateToken();

        return redirect()->route('login');
    }
}
