import 'dart:async';
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

      print("llamando contabilidad desde stream");
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
          String entregado = servicio.data().toString().contains('entregadotutor') ? servicio.get('entregadotutor') : 'NO APLICA < 10/10/23';
          String entregadocliente = servicio.data().toString().contains('entregadocliente') ? servicio.get('entregadocliente') : 'NO APLICA < 10/10/23';
          // Get payments as a stream
          Stream<List<RegistrarPago>> pagosStream =
          getRegistrarPagosContabilidadStream(codigo);

          print(codigo);

          await for (List<RegistrarPago> pagosList in pagosStream) {
            // Utilize the stream in your ServicioAgendado object
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
              pagosList,
              entregado,
              entregadocliente,
            );
            serviciosagendadoList.add(newservicioagendado);

            // Optional: If you only want to process the first value and then break the loop
            break;
          }

        }catch (e) {
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

  //Obtener lista de pagos en solicitudes
  Stream<List<RegistrarPago>> getRegistrarPagosContabilidadStream(String codigo) {
    CollectionReference refPagos =
    FirebaseFirestore.instance.collection("CONTABILIDAD").doc(codigo).collection("PAGOS");

    return refPagos.snapshots().map((querySnapshot) {
      List<RegistrarPago> pagosList = [];

      try {
        for (var pagoDoc in querySnapshot.docs) {
          // ... (existing code)

          String pagoCodigo = pagoDoc['codigo'];
          String tipopago = pagoDoc['tipopago'];
          int valor = pagoDoc['valor'];
          String metodopago = pagoDoc['metodopago'];
          String referencia = pagoDoc['referencia'];
          DateTime fechapago = pagoDoc['fechapago'].toDate();
          String id = pagoDoc.data().toString().contains('id') ? pagoDoc.get('id') : 'NO ID';

          print(valor);
          print(tipopago);

          RegistrarPago newpago = RegistrarPago(
              pagoCodigo, tipopago, valor, referencia, fechapago, metodopago, id);
          pagosList.add(newpago);
        }
      } catch (e) {
        print(e);
      }

      return pagosList;
    });
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
          String entregadocliente = servicio.data().toString().contains('entregadocliente') ? servicio.get('entregadocliente') : 'NO APLICA < 10/10/23';

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
              entregado,
              entregadocliente);
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
