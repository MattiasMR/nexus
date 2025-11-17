/// Constantes de permisos del sistema
/// Basado en el modelo de base de datos

class AppPermissions {
  // ========== PERMISOS MÉDICOS (Flutter) ==========
  
  /// Ver lista de pacientes
  static const String verPacientes = 'ver_pacientes';
  
  /// Crear consultas médicas
  static const String crearConsultas = 'crear_consultas';
  
  /// Editar consultas médicas
  static const String editarConsultas = 'editar_consultas';
  
  /// Ver fichas médicas de pacientes
  static const String verFichasMedicas = 'ver_fichas_medicas';
  
  /// Editar fichas médicas
  static const String editarFichasMedicas = 'editar_fichas_medicas';
  
  /// Crear recetas médicas
  static const String crearRecetas = 'crear_recetas';
  
  /// Solicitar exámenes de laboratorio
  static const String solicitarExamenes = 'solicitar_examenes';
  
  /// Ver resultados de exámenes
  static const String verExamenes = 'ver_examenes';
  
  // ========== PERMISOS ADMINISTRADORES (Laravel) ==========
  
  /// Gestionar usuarios del hospital
  static const String gestionarUsuarios = 'gestionar_usuarios';
  
  /// Gestionar profesionales médicos
  static const String gestionarProfesionales = 'gestionar_profesionales';
  
  /// Gestionar pacientes
  static const String gestionarPacientes = 'gestionar_pacientes';
  
  /// Ver reportes y estadísticas
  static const String verReportes = 'ver_reportes';
  
  /// Configurar opciones del hospital
  static const String configurarHospital = 'configurar_hospital';
  
  /// Gestionar catálogo de exámenes
  static const String gestionarExamenesCatalogo = 'gestionar_examenes_catalogo';
  
  /// Gestionar catálogo de medicamentos
  static const String gestionarMedicamentosCatalogo = 'gestionar_medicamentos_catalogo';
  
  // ========== PERMISOS SUPER ADMIN ==========
  
  /// Gestionar hospitales del sistema
  static const String gestionarHospitales = 'gestionar_hospitales';
  
  /// Gestionar todos los usuarios del sistema
  static const String gestionarTodosUsuarios = 'gestionar_todos_usuarios';
  
  /// Acceso total al sistema
  static const String accesoTotal = 'acceso_total';

  // ========== CONJUNTOS DE PERMISOS POR ROL ==========
  
  /// Permisos predeterminados para médicos
  static const List<String> defaultMedicoPermisos = [
    verPacientes,
    crearConsultas,
    editarConsultas,
    verFichasMedicas,
    editarFichasMedicas,
    crearRecetas,
    solicitarExamenes,
    verExamenes,
  ];
  
  /// Permisos predeterminados para enfermeras
  static const List<String> defaultEnfermeraPermisos = [
    verPacientes,
    crearConsultas,
    verFichasMedicas,
    verExamenes,
  ];
  
  /// Permisos predeterminados para admins
  static const List<String> defaultAdminPermisos = [
    verPacientes,
    gestionarUsuarios,
    gestionarProfesionales,
    gestionarPacientes,
    verReportes,
    configurarHospital,
    gestionarExamenesCatalogo,
    gestionarMedicamentosCatalogo,
  ];
  
  // ========== HELPERS ==========
  
  /// Obtener descripción legible de un permiso
  static String getPermissionDescription(String permission) {
    switch (permission) {
      case verPacientes:
        return 'Ver lista de pacientes';
      case crearConsultas:
        return 'Crear consultas médicas';
      case editarConsultas:
        return 'Editar consultas médicas';
      case verFichasMedicas:
        return 'Ver fichas médicas';
      case editarFichasMedicas:
        return 'Editar fichas médicas';
      case crearRecetas:
        return 'Prescribir recetas';
      case solicitarExamenes:
        return 'Solicitar exámenes';
      case verExamenes:
        return 'Ver resultados de exámenes';
      case gestionarUsuarios:
        return 'Gestionar usuarios';
      case gestionarProfesionales:
        return 'Gestionar profesionales';
      case gestionarPacientes:
        return 'Gestionar pacientes';
      case verReportes:
        return 'Ver reportes y estadísticas';
      case configurarHospital:
        return 'Configurar hospital';
      case gestionarExamenesCatalogo:
        return 'Gestionar catálogo de exámenes';
      case gestionarMedicamentosCatalogo:
        return 'Gestionar catálogo de medicamentos';
      case gestionarHospitales:
        return 'Gestionar hospitales';
      case gestionarTodosUsuarios:
        return 'Gestionar todos los usuarios';
      case accesoTotal:
        return 'Acceso total al sistema';
      default:
        return permission;
    }
  }
}
