import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'firebase_options.dart';
import 'utils/app_colors.dart';
import 'providers/auth_provider.dart';
import 'features/auth/login_page.dart';
import 'features/auth/hospital_selector_page.dart';
import 'features/pacientes/patient_list_page.dart';
import 'features/fichas_medicas/pages/fichas_medicas_list_page.dart';
import 'features/estadisticas/estadisticas_page.dart';
import 'shared/widgets/weather_widget.dart';

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
            title: 'Nexus Medical',
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
        final needsHospital = authProvider.needsHospitalSelection;
        
        final isLoginRoute = state.matchedLocation == '/login';
        final isHospitalSelectorRoute = state.matchedLocation == '/select-hospital';
        
        // Mientras carga, no redirigir
        if (isLoading) {
          return null;
        }
        
        // Si no está autenticado y no está en login, ir a login
        if (!isAuthenticated && !isLoginRoute) {
          return '/login';
        }
        
        // Si está autenticado pero necesita seleccionar hospital
        if (isAuthenticated && needsHospital && !isHospitalSelectorRoute) {
          return '/select-hospital';
        }
        
        // Si está autenticado, tiene hospital y está en login, ir a home
        if (isAuthenticated && !needsHospital && isLoginRoute) {
          return '/';
        }
        
        // Si está autenticado, tiene hospital y está en selector, ir a home
        if (isAuthenticated && !needsHospital && isHospitalSelectorRoute) {
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
        
        // Ruta de selección de hospital
        GoRoute(
          path: '/select-hospital',
          builder: (context, state) => const HospitalSelectorPage(),
        ),
        
        // Ruta principal (home)
        GoRoute(
          path: '/',
          builder: (context, state) => const HomeScreen(),
        ),
        
        // Rutas de funcionalidades
        GoRoute(
          path: '/pacientes',
          builder: (context, state) => const PatientListPage(),
        ),
        GoRoute(
          path: '/fichas-medicas',
          builder: (context, state) => const FichasMedicasListPage(),
        ),
        GoRoute(
          path: '/estadisticas',
          builder: (context, state) => const EstadisticasPage(),
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

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final usuario = authProvider.currentUser;
        final hospital = authProvider.activeHospital;

        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Nexus', style: TextStyle(fontSize: 20)),
                if (usuario != null && hospital != null)
                  Text(
                    '${usuario.displayName} - ${hospital.nombre}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
              ],
            ),
            actions: [
              // Cambiar hospital (si tiene múltiples)
              if (authProvider.userHospitals.length > 1)
                IconButton(
                  icon: const Icon(Icons.swap_horiz),
                  tooltip: 'Cambiar Hospital',
                  onPressed: () {
                    context.push('/select-hospital');
                  },
                ),
              const Padding(
                padding: EdgeInsets.only(right: 8.0),
                child: Center(child: WeatherWidget()),
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
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(
                      Icons.local_hospital,
                      size: 96,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Nexus',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 48),
                    
                    // Botón principal - Pacientes
                    ElevatedButton.icon(
                      onPressed: () {
                        context.push('/pacientes');
                      },
                      icon: const Icon(Icons.people),
                      label: const Text('Ver pacientes'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Fichas médicas
                    OutlinedButton.icon(
                      onPressed: () {
                        context.push('/fichas-medicas');
                      },
                      icon: const Icon(Icons.note_alt),
                      label: const Text('Ver fichas médicas'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Estadísticas (solo médicos y admin)
                    if (usuario != null && usuario.puedeVerEstadisticas)
                      OutlinedButton.icon(
                        onPressed: () {
                          context.push('/estadisticas');
                        },
                        icon: const Icon(Icons.analytics),
                        label: const Text('Estadísticas y Dashboard'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}