import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Objetos/AgendadoServicio.dart';
import '../../Objetos/RegistrarPago.dart';

class stream_builders{

  //Streambuilders de servicios agendados
  Stream<List<ServicioAgendado>> getServiciosAgendados() async* {
    CollectionReference refcontabilidad = FirebaseFirestore.instance.collection("CONTABILIDAD");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool datosDescargados = prefs.getBool('checked_serviciosAgendados') ?? false;

    Stream<QuerySnapshot> queryContabilidad = refcontabilidad.snapshots();
    await for (QuerySnapshot servicioSnapshot in queryContabilidad) {
      List<ServicioAgendado> serviciosagendadoList = [];

      for (var servicio in servicioSnapshot.docs) {
        try {
          String codigo = servicio['codigo'];
          String sistema = servicio['sistema'];
          String materia = servicio['materia'];
          DateTime fechasistema = servicio['fechasistema'].toDate();
          String cliente = servicio['cliente'];
          int preciocobrado = servicio['preciocobrado'];
          DateTime fechaentrega = servicio['fechaentrega'].toDate();
          String tutor = servicio['tutor'];
          int preciotutor = servicio['preciotutor'];
          String identificadorcodigo = servicio['identificadorcodigo'];
          int idsolicitud = servicio['idsolicitud'];
          int idcontable = servicio['idcontable'];
          List<RegistrarPago> pagos = [];
          String entregado = servicio.data().toString().contains('entregadotutor') ? servicio.get('entregadotutor') : 'NO APLICA < 10/10/23';

          print(idcontable);
          //Guardamos en objeto y ya lo pasamos para tutor
          ServicioAgendado newservicioagendado = ServicioAgendado(
              codigo,
              sistema,
              materia,
              fechasistema,
              cliente,
              preciocobrado,
              fechaentrega,
              tutor,
              preciotutor,
              identificadorcodigo,
              idsolicitud,
              idcontable,
              pagos,
              entregado);
          serviciosagendadoList.add(newservicioagendado);
        } catch (e) {
          print(e);
        }
      }
      String solicitudesJson = jsonEncode(serviciosagendadoList);
      await prefs.setString('servicios_agendados_list_stream', solicitudesJson);
      await prefs.setBool('checked_serviciosAgendados', true);

      yield serviciosagendadoList;
    }

  }
  Future<List<ServicioAgendado>?> cargarserviciosagendados() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String solicitudesJson = prefs.getString('servicios_agendados_list_stream') ?? '';
    List<dynamic> clienteData = jsonDecode(solicitudesJson);
    List<ServicioAgendado> clientesList = clienteData.map((clienteData) =>
        ServicioAgendado.fromJson(clienteData as Map<String, dynamic>)).toList();
    return clientesList;
  }


  //Obtener contabilidad en stream, servicios AGENDADOA
  Stream<List<ServicioAgendado>> getServiciosAgendadosTutor(String nombretutor) async* {
    CollectionReference refcontabilidad = FirebaseFirestore.instance.collection("CONTABILIDAD");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Stream<QuerySnapshot> queryContabilidad = refcontabilidad.where('tutor', isEqualTo: nombretutor).snapshots();

    await for (QuerySnapshot servicioSnapshot in queryContabilidad) {
      List<ServicioAgendado> serviciosagendadoList = [];

      for (var servicio in servicioSnapshot.docs) {
        try {
          String codigo = servicio['codigo'];
          String sistema = servicio['sistema'];
          String materia = servicio['materia'];
          DateTime fechasistema = servicio['fechasistema'].toDate();
          String cliente = servicio['cliente'];
          int preciocobrado = servicio['preciocobrado'];
          DateTime fechaentrega = servicio['fechaentrega'].toDate();
          String tutor = servicio['tutor'];
          int preciotutor = servicio['preciotutor'];
          String identificadorcodigo = servicio['identificadorcodigo'];
          int idsolicitud = servicio['idsolicitud'];
          int idcontable = servicio['idcontable'];
          List<RegistrarPago> pagos = [];
          String entregado = servicio.data().toString().contains('entregadotutor') ? servicio.get('entregadotutor') : 'NO APLICA < 10/10/23';

          print(idcontable);
          //Guardamos en objeto y ya lo pasamos para tutor
          ServicioAgendado newservicioagendado = ServicioAgendado(
              codigo,
              sistema,
              materia,
              fechasistema,
              cliente,
              preciocobrado,
              fechaentrega,
              tutor,
              preciotutor,
              identificadorcodigo,
              idsolicitud,
              idcontable,
              pagos,
              entregado);
          serviciosagendadoList.add(newservicioagendado);
        } catch (e) {
          print(e);
        }
      }
      String solicitudesJson = jsonEncode(serviciosagendadoList);
      await prefs.setString('servicios_agendado_tutor', solicitudesJson);
      yield serviciosagendadoList;
    }
  }
  Future<List<ServicioAgendado>?> cargaragendatutor() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String solicitudesJson = prefs.getString('servicios_agendado_tutor') ?? '';
    List<dynamic> clienteData = jsonDecode(solicitudesJson);
    List<ServicioAgendado> clientesList = clienteData.map((clienteData) =>
        ServicioAgendado.fromJson(clienteData as Map<String, dynamic>)).toList();
    return clientesList;
  }

}

//
