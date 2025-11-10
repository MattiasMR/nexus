import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'utils/app_colors.dart';
import 'services/auth_service.dart';
import 'features/auth/pages/login_page.dart';
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
    return MaterialApp(
      title: 'Nexus',
      debugShowCheckedModeBanner: false, // Elimina el banner DEBUG
      theme: _buildTheme(),
      initialRoute: '/login',
      routes: {
        '/login': (_) => const LoginPage(),
        '/home': (_) => const HomeScreen(),
        PatientListPage.routeName: (_) => const PatientListPage(),
        FichasMedicasListPage.routeName: (_) => const FichasMedicasListPage(),
        EstadisticasPage.routeName: (_) => const EstadisticasPage(),
      },
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
    final colorScheme = Theme.of(context).colorScheme;
    final authService = AuthService();
    final usuario = authService.usuarioActual;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Nexus', style: TextStyle(fontSize: 20)),
            if (usuario != null)
              Text(
                '${usuario.nombreCompleto} - ${usuario.rolTexto}',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w300),
              ),
          ],
        ),
        actions: [
          const Padding(
            padding: EdgeInsets.only(right: 8.0),
            child: Center(child: WeatherWidget()),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar Sesión',
            onPressed: () {
              authService.logout();
              Navigator.of(context).pushReplacementNamed('/login');
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
                Icon(
                  Icons.local_hospital,
                  size: 96,
                  color: colorScheme.primary,
                ),
                const SizedBox(height: 24),
                Text(
                  'Nexus',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 48),
                
                // Botón principal - Pacientes
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pushNamed(PatientListPage.routeName);
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
                    Navigator.of(context).pushNamed(FichasMedicasListPage.routeName);
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
                      Navigator.of(context).pushNamed(EstadisticasPage.routeName);
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
  }
}