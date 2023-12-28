import 'package:dashboard_admin_flutter/Utils/Firebase/Load_Data.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeleteLocalData{

  Future deleteAllLocalData() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('configuracion_list_stream');
    await prefs.remove('cheched_solicitudes_descargadas_stream');
    await prefs.remove('cheched_solicitudes_descargadas_stream');
    await prefs.remove('solicitudes_list_stream');
    await prefs.remove('checked_serviciosAgendados');
    await prefs.remove('servicios_agendados_list_stream');
    await prefs.remove('checked_tutores_stream');
    await prefs.remove('tutores_list_stream');
    await prefs.remove('checked_materias_cache');
    await prefs.remove('materia_List_Stream');
    await prefs.remove('cheched_clientes_descargadas_stream');
    await prefs.remove('clientes_list_stream');
    await prefs.remove('checked_universidad_cache');
    await prefs.remove('universidades_List_Stream');
    await prefs.remove('checked_carrera_cache');
    await prefs.remove('carreras_List_Stream');
    //FALTAN NUEVAS VARIABLES
  }

  //solicitudes
  void eliminarsolicitudesLocal() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('solicitudes_list');
    await prefs.setBool('datos_descargados_listasolicitudes', false);
    print("eliinado solicitudes");
    //LoadData().obtenerSolicitudes();
  }

  void eliinarTutoresLocal() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('tutores_list');
    await prefs.setBool('datos_descargados_tablatutores', false);
    print("eliminando tutores local");
    //LoadData().obtenertutores();
  }

  void eliminarclientesLocal() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('clientes_list');
    await prefs.setBool('datos_descargados_tablaclientes', false);
    print("eliminando clientes local");
    //LoadData().obtenerclientes();
  }
}