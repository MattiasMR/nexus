import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'firebase_options.dart';
import 'utils/app_colors.dart';
import 'providers/auth_provider.dart';
import 'features/auth/login_page.dart';
import 'features/auth/register_page.dart';
import 'features/paciente/mi_ficha_medica_page.dart';
import 'features/paciente/mis_citas_page.dart';
import 'features/paciente/mis_recetas_page.dart';
import 'features/paciente/mis_documentos_page.dart';
import 'features/paciente/perfil_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider()..initialize(),
        ),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return MaterialApp.router(
            title: 'Nexus Medical - Pacientes',
            debugShowCheckedModeBanner: false,
            theme: _buildTheme(),
            routerConfig: _createRouter(authProvider),
          );
        },
      ),
    );
  }

  /// Configurar router con rutas protegidas
  GoRouter _createRouter(AuthProvider authProvider) {
    return GoRouter(
      initialLocation: '/login',
      refreshListenable: authProvider,
      redirect: (context, state) {
        final isAuthenticated = authProvider.isAuthenticated;
        final isLoading = authProvider.isLoading;
        
        final isLoginRoute = state.matchedLocation == '/login';
        final isRegisterRoute = state.matchedLocation == '/register';
        
        // Mientras carga, no redirigir
        if (isLoading) {
          return null;
        }
        
        // Si no está autenticado y no está en login/register, ir a login
        if (!isAuthenticated && !isLoginRoute && !isRegisterRoute) {
          return '/login';
        }
        
        // Si está autenticado y está en login o register, ir a home
        if (isAuthenticated && (isLoginRoute || isRegisterRoute)) {
          return '/';
        }
        
        return null;
      },
      routes: [
        // Ruta de login
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginPage(),
        ),
        
        // Ruta de registro
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterPage(),
        ),
        
        // Ruta principal (home) - Dashboard del paciente
        GoRoute(
          path: '/',
          builder: (context, state) => const HomeScreen(),
        ),
        
        // Mi Ficha Médica
        GoRoute(
          path: '/mi-ficha',
          builder: (context, state) => const MiFichaMedicaPage(),
        ),
        
        // Mis Citas
        GoRoute(
          path: '/mis-citas',
          builder: (context, state) => const MisCitasPage(),
        ),
        
        // Mis Recetas
        GoRoute(
          path: '/mis-recetas',
          builder: (context, state) => const MisRecetasPage(),
        ),
        
        // Mis Documentos
        GoRoute(
          path: '/mis-documentos',
          builder: (context, state) => const MisDocumentosPage(),
        ),
        
        // Perfil
        GoRoute(
          path: '/perfil',
          builder: (context, state) => const PerfilPage(),
        ),
      ],
    );
  }

  ThemeData _buildTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.primaryLight,
        surface: AppColors.surface,
      ),
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}

/// Pantalla principal - Dashboard del Paciente
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final usuario = authProvider.currentUser;

        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Nexus Medical', style: TextStyle(fontSize: 20)),
                if (usuario != null)
                  Text(
                    'Bienvenido, ${usuario.nombre}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.person),
                tooltip: 'Mi Perfil',
                onPressed: () {
                  context.push('/perfil');
                },
              ),
              IconButton(
                icon: const Icon(Icons.logout),
                tooltip: 'Cerrar Sesión',
                onPressed: () async {
                  await authProvider.signOut();
                },
              ),
            ],
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              // Determinar número de columnas según ancho
              int crossAxisCount = 2;
              if (constraints.maxWidth > 900) {
                crossAxisCount = 4;
              } else if (constraints.maxWidth > 600) {
                crossAxisCount = 3;
              }

              return Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Card de bienvenida
                    Card(
                      color: AppColors.primary,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hola ${usuario?.nombreCompleto ?? ""}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Gestiona tu salud de manera fácil y segura',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Text(
                      'Accesos Rápidos',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),

                    // Grid de opciones
                    Expanded(
                      child: GridView.count(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 1.0,
                    children: [
                      _buildMenuCard(
                        context,
                        icon: Icons.medical_information,
                        title: 'Mi Ficha Médica',
                        subtitle: 'Ver mi historial',
                        onTap: () {
                          context.push('/mi-ficha');
                        },
                      ),
                      _buildMenuCard(
                        context,
                        icon: Icons.folder_shared,
                        title: 'Mis Documentos',
                        subtitle: 'Subir y ver documentos',
                        onTap: () {
                          context.push('/mis-documentos');
                        },
                      ),
                      _buildMenuCard(
                        context,
                        icon: Icons.calendar_today,
                        title: 'Mis Citas',
                        subtitle: 'Ver y agendar',
                        onTap: () {
                          context.push('/mis-citas');
                        },
                      ),
                      _buildMenuCard(
                        context,
                        icon: Icons.medication,
                        title: 'Mis Recetas',
                        subtitle: 'Ver recetas médicas',
                        onTap: () {
                          context.push('/mis-recetas');
                        },
                      ),
                      ],
                    ),
                  ),
                ],
              ),
            );
            },
          ),
        );
      },
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 36,
                color: AppColors.primary,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}