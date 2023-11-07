import 'package:dashboard_admin_flutter/Utils/Firebase/Load_Data.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeleteLocalData{

  //solicitudes
  void eliminarsolicitudesLocal() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('solicitudes_list');
    await prefs.setBool('datos_descargados_listasolicitudes', false);
    print("eliinado solicitudes");
    LoadData().obtenerSolicitudes();
  }

  void eliinarTutoresLocal() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('tutores_list');
    await prefs.setBool('datos_descargados_tablatutores', false);
    print("eliminando tutores local");
    LoadData().obtenertutores();
  }

  void eliminarclientesLocal() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('clientes_list');
    await prefs.setBool('datos_descargados_tablaclientes', false);
    print("eliminando clientes local");
    LoadData().obtenerclientes();
  }

}