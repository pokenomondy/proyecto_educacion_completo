import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dashboard_admin_flutter/Objetos/HistorialServiciosAgendados.dart';
import 'package:dashboard_admin_flutter/Objetos/Solicitud.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Objetos/AgendadoServicio.dart';
import '../../Objetos/Cotizaciones.dart';
import '../../Objetos/Configuracion/Configuracion_Configuracion.dart';
import '../../Objetos/RegistrarPago.dart';
import '../../Providers/Providers.dart';
import 'CollectionReferences.dart';
import 'package:rxdart/rxdart.dart';

class stream_builders{
  CollectionReferencias referencias =  CollectionReferencias();

  //Streambuilders de servicios agendados
  Stream<List<ServicioAgendado>> getServiciosAgendados(BuildContext context) async* {
    CollectionReference refcontabilidad = referencias.contabilidad!;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool datosDescargados = prefs.getBool('checked_serviciosAgendados') ?? false;

    Stream<QuerySnapshot> queryContabilidad = refcontabilidad.snapshots();
    await for (QuerySnapshot servicioSnapshot in queryContabilidad) {
      List<ServicioAgendado> serviciosAgendadosList = [];

      print("Ejecutando Contabilidad Stream");

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
      final ConfiguracionProvider = Provider.of<ContabilidadProvider>(context, listen: false);
      ConfiguracionProvider.cargarTodosLosServicios(serviciosAgendadosList);
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

  //Obtener contabilidad en stream, Serbivio agendado de tutor
  Stream<List<ServicioAgendado>> getServiciosAgendadosTutor(String nombretutor) async* {
    CollectionReference refcontabilidad = referencias.contabilidad!;
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

  //Podemos configurar filtros de manteneres 2 meses de información o algo así, por si acaso
  // STREAMBUILDER DE SOLICITUDES
  Stream<List<Solicitud>> getTodasLasSolicitudes() async*{
      CollectionReference refsolicitud = referencias.solicitudes!;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool datosDescargados = prefs.getBool('cheched_solicitudes_descargadas_stream') ?? false;

      Stream<QuerySnapshot> querySolicitud = refsolicitud.snapshots();
      await for (QuerySnapshot solicitudSnapshot in querySolicitud) {
        List<Solicitud> solicitudList = [];

        for (var solicitudDoc in solicitudSnapshot.docs) {
          String servicio = solicitudDoc['Servicio'];
          int idcotizacion = solicitudDoc['idcotizacion'];
          String materia = solicitudDoc['materia'];
          DateTime fechaentrega = solicitudDoc['fechaentrega'].toDate();
          String resumen = solicitudDoc['resumen'];
          String infocliente = solicitudDoc['infocliente'];
          int cliente = solicitudDoc['cliente'];
          DateTime fechasistema = solicitudDoc['fechasistema'].toDate();
          String estado = solicitudDoc['Estado'];
          DateTime fechaactualizacion = solicitudDoc.data().toString().contains('fechaactualizacion') ? solicitudDoc.get('fechaactualizacion').toDate() : DateTime(2023,1,1,0,0); //Number
          String urlarchivo = solicitudDoc.data().toString().contains('archivos') ? solicitudDoc.get('archivos') : 'No tiene Archivos';
          DateTime actualizarsolicitudes = solicitudDoc.data().toString().contains('actualizarsolicitudes') ? solicitudDoc.get('actualizarsolicitudes').toDate() : DateTime(2023,1,1,0,0); //Number
          List<Cotizacion> cotizaciones = [];
          if (solicitudDoc.data() != null && solicitudDoc.data().toString().contains('cotizaciones')) {
            var CotizacionData = solicitudDoc['cotizaciones'] as List<dynamic>;
            cotizaciones = CotizacionData.map((CotizaDato) {
              int cotizacionTutor = CotizaDato['Cotizacion'];
              String uidtutor = CotizaDato['uidtutor'];
              String nombretutor = CotizaDato['nombretutor'];
              int tiempoconfirmacion = CotizaDato['Tiempo confirmacion'];
              String comentariocotizacion = CotizaDato['Comentario Cotización'];
              String Agenda = CotizaDato['Agenda'];
              DateTime fechaconfirmacion = CotizaDato['fechaconfirmacion'] != null ? RegistrarPago.convertirTimestamp(CotizaDato['fechaconfirmacion']) : DateTime.now();

              Cotizacion newcotizacion = Cotizacion(cotizacionTutor, uidtutor, nombretutor, tiempoconfirmacion, comentariocotizacion, Agenda, fechaconfirmacion);
              return newcotizacion;
            }).toList();
          }
          Solicitud newsolicitud = Solicitud(servicio, idcotizacion, materia, fechaentrega, resumen, infocliente, cliente, fechasistema, estado, cotizaciones,fechaactualizacion,urlarchivo,actualizarsolicitudes);
          solicitudList.add(newsolicitud);
        }

        String solicitudesJson = jsonEncode(solicitudList);
        await prefs.setString('solicitudes_list_stream', solicitudesJson);
        await prefs.setBool('cheched_solicitudes_descargadas_stream', true);

        yield solicitudList;
      }
    }
  Future<List<Solicitud>?> cargarsolicitudes() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String solicitudesJson = prefs.getString('solicitudes_list_stream') ?? '';
    List<dynamic> clienteData = jsonDecode(solicitudesJson);
    List<Solicitud> solicitudeslist = clienteData.map((clienteData) =>
        Solicitud.fromJson(clienteData as Map<String, dynamic>)).toList();
    return solicitudeslist;
  }

  //Configuración de Streambuilders, 3 streambuilders
  Stream<ConfiguracionPlugins> getstreamConfiguracion(BuildContext context) async*{
    CollectionReference refconfiguracion = referencias.configuracion!;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool datosDescargados = prefs.getBool('cached_configuracion_descargadas') ?? false;
    ConfiguracionPlugins? newconfig;
    Stream<DocumentSnapshot> queryConfiguracion = refconfiguracion.doc("CONFIGURACION").snapshots();
    Stream<DocumentSnapshot> queryPlugins = refconfiguracion.doc("Plugins").snapshots();
    Stream<DocumentSnapshot> queryMensajes = refconfiguracion.doc("MENSAJES").snapshots();
    final combinedStream = CombineLatestStream.combine3(
        queryConfiguracion,
        queryPlugins,
        queryMensajes,
            (configuracion, plugins, mensajes) => {
          'configuracion': configuracion,
          'plugins': plugins,
          'mensajes': mensajes,
        },
      );
    await for (Map<String, dynamic> snapshots in combinedStream) {
      Map<String, dynamic> dataConfiguracion = snapshots['configuracion'].data() as Map<String, dynamic>;
      Map<String, dynamic> dataPlugins = snapshots['plugins'].data() as Map<String, dynamic>;
      Map<String, dynamic> dataMensajes = snapshots['mensajes'].data() as Map<String, dynamic>;
      print("ejectuando Configuración Stream");

      //documetno configuración
      String PrimaryColor = dataConfiguracion['Primarycolor'] ?? '';
      String SecundaryColor = dataConfiguracion['Secundarycolor'] ?? '';
      String idcarpetaPagos = dataConfiguracion['idcarpetaPagos'] ?? '';
      String idcarpetaSolicitudes = dataConfiguracion['idcarpetaSolicitudes'] ?? '';
      String nombre_empresa = dataConfiguracion['nombre_empresa'] ?? '';

      //documento plugins
      DateTime basicoFecha = dataPlugins.containsKey('basicoFecha') ? dataPlugins['basicoFecha'].toDate() : DateTime.now();
      DateTime PagosDriveApiFecha = dataPlugins.containsKey('PagosDriveApiFecha') ? dataPlugins['PagosDriveApiFecha'].toDate() : DateTime.now();
      DateTime SolicitudesDriveApiFecha = dataPlugins.containsKey('SolicitudesDriveApiFecha') ? dataPlugins['SolicitudesDriveApiFecha'].toDate() : DateTime.now();

      //Documento mensajes
      String CONFIRMACION_CLIENTE = dataMensajes['CONFIRMACION_CLIENTE'] ?? '';
      String SOLICITUD = dataMensajes['SOLICITUD'] ?? '';

      ConfiguracionPlugins newconfig = ConfiguracionPlugins(PrimaryColor, SecundaryColor, idcarpetaPagos, idcarpetaSolicitudes, nombre_empresa, PagosDriveApiFecha, SolicitudesDriveApiFecha, basicoFecha, CONFIRMACION_CLIENTE, SOLICITUD);

      String configJson = jsonEncode(newconfig);
      await prefs.setString('configuracion_list_stream', configJson);
      await prefs.setBool('cheched_solicitudes_descargadas_stream', true);
      //carguemos a provider
      final ConfiguracionProvider = Provider.of<ConfiguracionAplicacion>(context, listen: false);
      ConfiguracionProvider.cargarConfiguracion(newconfig);
      yield newconfig!;
    }
  }
  Future<List<ConfiguracionPlugins>?> cargarconfiguracion() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String solicitudesJson = prefs.getString('configuracion_list_stream') ?? '';
    List<dynamic> clienteData = jsonDecode(solicitudesJson);
    List<ConfiguracionPlugins> configuracionPlugins = clienteData.map((clienteData) =>
        ConfiguracionPlugins.fromJson(clienteData as Map<String, dynamic>)).toList();
    return configuracionPlugins;
  }

}


