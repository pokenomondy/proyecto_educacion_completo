import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dashboard_admin_flutter/Objetos/HistorialServiciosAgendados.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Objetos/AgendadoServicio.dart';
import '../../Objetos/RegistrarPago.dart';
import 'CollectionReferences.dart';

class stream_builders{
  CollectionReferencias referencias =  CollectionReferencias();

  //Streambuilders de servicios agendados
  Stream<List<ServicioAgendado>> getServiciosAgendados() async* {
    CollectionReference refcontabilidad = referencias.contabilidad;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool datosDescargados = prefs.getBool('checked_serviciosAgendados') ?? false;

    Stream<QuerySnapshot> queryContabilidad = refcontabilidad.snapshots();
    await for (QuerySnapshot servicioSnapshot in queryContabilidad) {
      List<ServicioAgendado> serviciosAgendadosList = [];

      print("llamando contabilidad desde stream");

      // First, load the basic information without payments
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
          // Obtener los pagos directamente del documento
          List<RegistrarPago> pagos = [];
          if (servicio.data() != null && servicio.data().toString().contains('pagos')) {
            var pagosData = servicio['pagos'] as List<dynamic>;
            pagos = pagosData.map((pagoData) {
              DateTime fechaPago = pagoData['fechapago'] != null ? RegistrarPago.convertirTimestamp(pagoData['fechapago']) : DateTime.now();
              String codigo = pagoData['codigo'] ?? '';
              String tipopago = pagoData['tipopago'] ?? '';
              int valor = pagoData['valor'] ?? 0;
              String referencia = pagoData['referencia'] ?? '';
              String metodopago = pagoData['metodopago'] ?? '';
              String id = pagoData['id'] ?? '';
              DateTime fecharegistro = pagoData['fecharegistro'] != null ? RegistrarPago.convertirTimestamp(pagoData['fecharegistro']) : DateTime(2023,11,1);


              RegistrarPago nuevoPago = RegistrarPago(codigo, tipopago, valor, referencia, fechaPago, metodopago, id,fecharegistro);
              return nuevoPago;
            }).toList();
          }
          //Obtener el historial del documento
          List<HistorialAgendado> historial = [];
          if (servicio.data() != null && servicio.data().toString().contains('historial')) {
            var historialData = servicio['historial'] as List<dynamic>;
            historial = historialData.map((historialItem) {
              DateTime fechacambio = historialItem['fechacambio'] != null
                  ? HistorialAgendado.convertirTimestamp(historialItem['fechacambio'])
                  : DateTime.now();
              String cambioant = historialItem['cambioant'] ?? '';
              String cambionew = historialItem['cambionew'] ?? '';
              String motivocambio = historialItem['motivocambio'] ?? '';
              String codigo = historialItem['codigo'] ?? '';

              HistorialAgendado nuevoHistorial = HistorialAgendado(
                fechacambio,
                cambioant,
                cambionew,
                motivocambio,
                codigo,
              );
              return nuevoHistorial;
            }).toList();
          }


          // Create ServicioAgendado without payments
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
            pagos, // Empty payments list initially
            entregado,
            entregadocliente,
            historial,
          );

          serviciosAgendadosList.add(newservicioagendado);
        } catch (e) {
          print(e);
        }
      }

      String solicitudesJson = jsonEncode(serviciosAgendadosList);
      await prefs.setString('servicios_agendados_list_stream', solicitudesJson);
      await prefs.setBool('checked_serviciosAgendados', true);

      yield serviciosAgendadosList;

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
    CollectionReference refcontabilidad = referencias.contabilidad;
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
              entregadocliente,
              []);
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
