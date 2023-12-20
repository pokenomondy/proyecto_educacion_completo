import 'package:dashboard_admin_flutter/Objetos/Configuracion/Configuracion_Configuracion.dart';
import 'package:dashboard_admin_flutter/Objetos/Objetos%20Auxiliares/Universidad.dart';
import 'package:fluent_ui/fluent_ui.dart';
import '../Objetos/AgendadoServicio.dart';
import '../Objetos/Clientes.dart';
import '../Objetos/HistorialServiciosAgendados.dart';
import '../Objetos/Objetos Auxiliares/Carreras.dart';
import '../Objetos/Objetos Auxiliares/Materias.dart';
import '../Objetos/RegistrarPago.dart';
import '../Objetos/Solicitud.dart';
import '../Objetos/Tutores_objet.dart';

class ConfiguracionAplicacion extends ChangeNotifier {
  ConfiguracionPlugins? config;

  void cargarConfiguracion(ConfiguracionPlugins configuracion){
    config = configuracion;
    notifyListeners();
  }

}

//Contabilidad y Pagos provider en uno solo
class ContabilidadProvider extends ChangeNotifier{
  //Pagos
  List<RegistrarPago> _todosLosPagos = [];
  List<RegistrarPago> _pagosDelServicioSeleccionado = [];
  List<RegistrarPago> get pagosDelServicioSeleccionado => _pagosDelServicioSeleccionado;

  //Contabilidad
  List<ServicioAgendado> _todoslosServiciosAgendados = [];
  List<ServicioAgendado> get todoslosServiciosAgendados => _todoslosServiciosAgendados;
  //Seleccioanr servicio
  late ServicioAgendado _servicioSeleccionado;
  ServicioAgendado get servicioSeleccionado => _servicioSeleccionado;

  //Historial
  List<HistorialAgendado> _todosElHistorial = [];
  List<HistorialAgendado> _historialDelServicioSeleccionado = [];
  List<HistorialAgendado> get historialDelServicioSeleccionado => _historialDelServicioSeleccionado;


  //Contabilidad
  void cargarTodosLosServicios(List<ServicioAgendado> servicios) {
    _todoslosServiciosAgendados = servicios;
    cargarTodosLosPagos();
    cargarTodoElHistorial();
    notifyListeners();
  }

  void clearServicios() {
    _todoslosServiciosAgendados.clear();
    notifyListeners();
  }

  void agregarServicio(List<ServicioAgendado> servicios){
    _todoslosServiciosAgendados.addAll(servicios);
  }

  //Servicio seleccionado
  void seleccionarServicio(ServicioAgendado servicio) {
    _servicioSeleccionado = servicio;
    notifyListeners();
  }

  void limpiarServicioSeleccionado() {
    _servicioSeleccionado = ServicioAgendado.empty();
    notifyListeners();
  }

  //pagos
  void cargarTodosLosPagos(){
    _todosLosPagos = _todoslosServiciosAgendados.expand((servicio) => servicio.pagos).toList();
  }

  void clearPagos(){
    _pagosDelServicioSeleccionado.clear();
  }

  void actualizarPagosPorCodigo(String codigo) {
    // Filtra los pagos según el código seleccionado y actualiza la lista
    _pagosDelServicioSeleccionado.clear();
    _pagosDelServicioSeleccionado = _todosLosPagos
        .where((pago) => pago.codigo == codigo)
        .toList();
    notifyListeners();
  }

  //Historial
  void cargarTodoElHistorial(){
    _todosElHistorial = _todoslosServiciosAgendados.expand((servicio) => servicio.historial).toList();
  }

  void clearHistorial(){
    _historialDelServicioSeleccionado.clear();
  }

  void actualizarHistorialPorCodigo(String codigo) {
    _historialDelServicioSeleccionado = _todosElHistorial
        .where((historial) => historial.codigo == codigo)
        .toList();
    notifyListeners();
  }
}

//Solciitudes provider
class SolicitudProvider extends ChangeNotifier{
  List<Solicitud> _todaslasSolicitudes = [];
  List<Solicitud> _solicitudesDISPONIBLES = [];
  List<Solicitud> _solicitudesESPERANDO = [];

  List<Solicitud> get todaslasSolicitudes => _todaslasSolicitudes;
  List<Solicitud> get solicitudesDISPONIBLES => _solicitudesDISPONIBLES;
  List<Solicitud> get solicitudesESPERANDO => _solicitudesESPERANDO;

  void cargarTodasLasSolicitudes(List<Solicitud> solicitudes){
    _todaslasSolicitudes = solicitudes;
    notifyListeners();
  }

  void clearSolicitudes(){
    _todaslasSolicitudes.clear();
    notifyListeners();
  }

  void actualizarEstados(){
    actualziarSolicitudesDisponibles();
    actualizarSolicitudesEsperando();
  }

  void actualziarSolicitudesDisponibles(){
    _solicitudesDISPONIBLES = _todaslasSolicitudes
        .where((solicitud) => solicitud.estado == "DISPONIBLE")
        .toList();
    notifyListeners();
  }

  void actualizarSolicitudesEsperando(){
    _solicitudesESPERANDO = _todaslasSolicitudes
        .where((solicitud) => solicitud.estado == "ESPERANDO")
        .toList();
    notifyListeners();
  }
}

//Tutores provider
class VistaTutoresProvider extends ChangeNotifier {
  List<Tutores> tutorseleccionado = [];
  List<Tutores> todosLosTutores = [];
  List<Tutores> _tutoresactivos = [];

  List<Tutores> get tutoresactivos => _tutoresactivos;
  List<Tutores> get todosLosTutoresSeleccioando => todosLosTutores;

  String filtro = "";

  void cargarTodosTutores(List<Tutores> tutor){
    todosLosTutores = tutor.toList();
    tutoresActivos();
    notifyListeners();
  }

  void setFiltro(String nuevoFiltro) {
    filtro = nuevoFiltro;
    cargarTutores();
    notifyListeners();
  }

  void cargarTutores() {
    tutorseleccionado = todosLosTutores
        .where((tutor) {
      switch (filtro) {
        case 'TutorA':
          return tutor.activo == true && tutor.rol == "TUTOR";
        case 'TutorInac':
          return tutor.rol == 'TUTOR' && tutor.activo == false;
        case 'ADMON':
          return tutor.rol == 'ADMIN';
        default:
          return true; // Sin filtro o filtro desconocido, mostrar todos
      }
    })
        .toList(); // Assign the loaded tutors to todosLosTutores
    notifyListeners();
  }

  void busquedatutor(String texto){
    tutorseleccionado = todosLosTutores
        .where((tutor) =>
    tutor.nombrewhatsapp == texto,
    ).toList();
    notifyListeners();
  }

  void clearTutores() {
    tutorseleccionado.clear(); // Clear the list
    notifyListeners();
  }

  void actualizarListas(){
    tutoresActivos();
    setFiltro('TutorA');
  }


  void tutoresActivos(){
    _tutoresactivos = todosLosTutores.where((tutor) =>
    tutor.activo == true && tutor.rol == "TUTOR").toList();
  }


}

//Carreras provider
class CarrerasProvider extends ChangeNotifier{
  List<Carrera> _todosLasCarreras = [];

  List<Carrera> get todosLasCarreras => _todosLasCarreras;

  void cargarTodasLasCarreras(List<Carrera> carreras){
    clearCarrera();
    _todosLasCarreras = carreras;
    notifyListeners();
  }

  void clearCarrera(){
    _todosLasCarreras.clear();
    notifyListeners();
  }
}

//Materias Provider
class MateriasVistaProvider extends ChangeNotifier{
  List<Materia> _todasLasMaterias = [];

  List<Materia> get todasLasMaterias => _todasLasMaterias;

  void cargarTodasLasMaterias(List<Materia> materias){
    _todasLasMaterias.addAll(materias);
    notifyListeners();
  }

  void clearMaterias(){
    _todasLasMaterias.clear();
    notifyListeners();
  }
}

//Clientes Provider
class ClientesVistaProvider extends ChangeNotifier{
  List<Clientes> _todosLosClientes = [];

  List<Clientes> get todosLosClientes => _todosLosClientes;

  void cargarTodosLosClientes(List<Clientes> clientes){
    clearClientes();
    _todosLosClientes.addAll(clientes);
    notifyListeners();
  }

  void clearClientes(){
    _todosLosClientes.clear();
    notifyListeners();
  }
}

//Universidades Provider
class UniversidadVistaProvider extends ChangeNotifier{
  List<Universidad> _todasLasUniversidades = [];

  List<Universidad> get todasLasUniversidades => _todasLasUniversidades;

  void cargarTodasLasUniversidades(List<Universidad> universidades){
    clearUniversidades();
    _todasLasUniversidades.addAll(universidades);
    notifyListeners();
  }

  void clearUniversidades(){
    _todasLasUniversidades.clear();
    notifyListeners();
  }
}