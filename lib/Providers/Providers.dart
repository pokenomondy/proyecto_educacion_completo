import 'package:dashboard_admin_flutter/Objetos/Configuracion/Configuracion_Configuracion.dart';
import 'package:fluent_ui/fluent_ui.dart';
import '../Objetos/AgendadoServicio.dart';

  class ConfiguracionAplicacion extends ChangeNotifier {
    ConfiguracionPlugins? config;

    void cargarConfiguracion(ConfiguracionPlugins configuracion){
      config = configuracion;
      notifyListeners();
    }

  }

  class ContabilidadProvider extends ChangeNotifier{
    List<ServicioAgendado> _todoslosServiciosAgendados = [];

    List<ServicioAgendado> get todoslosServiciosAgendados => _todoslosServiciosAgendados;

    void cargarTodosLosServicios(List<ServicioAgendado> servicios) {
      _todoslosServiciosAgendados = servicios;
      notifyListeners();
    }

    void clearServicios() {
      _todoslosServiciosAgendados.clear();
      notifyListeners();
    }

  }
