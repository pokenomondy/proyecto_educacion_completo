import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:dashboard_admin_flutter/Objetos/Clientes.dart';
import 'package:dashboard_admin_flutter/Objetos/Objetos%20Auxiliares/Universidad.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dashboard_admin_flutter/Objetos/Objetos%20Auxiliares/CuentasBancaraias.dart';
import 'package:dashboard_admin_flutter/Objetos/Objetos%20Auxiliares/HistorialServiciosAgendados.dart';
import 'package:dashboard_admin_flutter/Objetos/Objetos%20Auxiliares/Carreras.dart';
import 'package:dashboard_admin_flutter/Objetos/Objetos%20Auxiliares/Materias.dart';
import 'package:dashboard_admin_flutter/Objetos/Solicitud.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Objetos/AgendadoServicio.dart';
import '../../Objetos/Cotizaciones.dart';
import '../../Objetos/Configuracion/objeto_configuracion.dart';
import '../../Objetos/RegistrarPago.dart';
import '../../Objetos/Tutores_objet.dart';
import '../../Providers/Providers.dart';
import 'CollectionReferences.dart';
import 'package:rxdart/rxdart.dart';

class stream_builders{
  CollectionReferencias referencias =  CollectionReferencias();
  Queue<int> colaActualizaciones = Queue<int>();
  Queue<int> colaActualizacionesEscritura = Queue<int>();


  //Estos metodos, generan una lectura, esta la debe asumir LIBA SOLUCIONES
  //Update de estadisticas de lectura
  Future<void> estadisticasLectutaFirestore(int numLecturas) async {
    colaActualizaciones.add(numLecturas);

    if (colaActualizaciones.length == 1) {
      await _procesarColaActualizaciones();
    }
  }
  Future<void> _procesarColaActualizaciones() async {
    while (colaActualizaciones.isNotEmpty) {
      int numLecturas = colaActualizaciones.removeFirst();
      await referencias.initCollections();
      CollectionReference rutaEstadisticasFirestore = referencias.configuracion!.doc("Plugins").collection("LECTURA_ESCRITURA");

      final fechaActual = DateTime.now();
      final fechaActualString = DateFormat('dd-MM-yyyy').format(fechaActual);

      final estadisticasDoc = rutaEstadisticasFirestore.doc(fechaActualString);
      final estadisticaSnapshot = await estadisticasDoc.get();

      if(estadisticaSnapshot.exists){
        await estadisticasDoc.update({
          'lecturas_subidas' : FieldValue.increment(numLecturas),
        });
      }else{
        await estadisticasDoc.set({
          'lecturas_subidas' : FieldValue.increment(numLecturas),
          'fecha': fechaActual,
        });
      }
      await Future.delayed(Duration(seconds: 2));
    }
  }
  //update de estadisticas de escritura
  Future<void> estadisticasEscrituraFirestore(int numLecturas) async {
    colaActualizacionesEscritura.add(numLecturas);

    if (colaActualizacionesEscritura.length == 1) {
      await _procesarColaEscritura();
    }
  }
  Future<void> _procesarColaEscritura() async {
    while (colaActualizacionesEscritura.isNotEmpty) {
      int numLecturas = colaActualizacionesEscritura.removeFirst();
      await referencias.initCollections();
      CollectionReference rutaEstadisticasFirestore = referencias.configuracion!.doc("Plugins").collection("LECTURA_ESCRITURA");

      final fechaActual = DateTime.now();
      final fechaActualString = DateFormat('dd-MM-yyyy').format(fechaActual);

      final estadisticasDoc = rutaEstadisticasFirestore.doc(fechaActualString);
      final estadisticaSnapshot = await estadisticasDoc.get();

      if(estadisticaSnapshot.exists){
        await estadisticasDoc.update({
          'escrituras_subidas' : FieldValue.increment(numLecturas),
        });
      }else{
        await estadisticasDoc.set({
          'escrituras_subidas' : FieldValue.increment(numLecturas),
          'fecha': fechaActual,
        });
      }
      await Future.delayed(Duration(seconds: 2));
    }
  }

  //Configuración de Streambuilders, 3 streambuilders, CONFIGURACIÓN
  Stream<ConfiguracionPlugins> getstreamConfiguracion(BuildContext context) async*{
    await referencias.initCollections();
    CollectionReference refconfiguracion = referencias.configuracion!;
    SharedPreferences prefs = await SharedPreferences.getInstance();
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
      int counter = 0;
      Map<String, dynamic> dataConfiguracion = snapshots['configuracion'].data() as Map<String, dynamic>;
      Map<String, dynamic> dataPlugins = snapshots['plugins'].data() as Map<String, dynamic>;
      Map<String, dynamic> dataMensajes = snapshots['mensajes'].data() as Map<String, dynamic>;
      print("Ejectuando Configuración Stream");

      //documetno configuración
      String PrimaryColor = dataConfiguracion['Primarycolor'] ?? '';
      String SecundaryColor = dataConfiguracion['Secundarycolor'] ?? '';
      String idcarpetaPagos = dataConfiguracion['idcarpetaPagos'] ?? '';
      String idcarpetaSolicitudes = dataConfiguracion['idcarpetaSolicitudes'] ?? '';
      String nombre_empresa = dataConfiguracion['nombre_empresa'] ?? '';

      //documento plugins
      DateTime basicoFecha = dataPlugins.containsKey('basicoFecha') ? dataPlugins['basicoFecha'].toDate() : DateTime(2024,1,1);
      DateTime PagosDriveApiFecha = dataPlugins.containsKey('PagosDriveApiFecha') ? dataPlugins['PagosDriveApiFecha'].toDate() :  DateTime(2024,1,1);
      DateTime SolicitudesDriveApiFecha = dataPlugins.containsKey('SolicitudesDriveApiFecha') ? dataPlugins['SolicitudesDriveApiFecha'].toDate() :  DateTime(2024,1,1);
      DateTime tutoresSistemaFecha = dataPlugins.containsKey('tutoresSistemaFecha') ? dataPlugins['tutoresSistemaFecha'].toDate() :  DateTime(2024,1,1);

      //Documento mensajes
      String CONFIRMACION_CLIENTE = dataMensajes['CONFIRMACION_CLIENTE'] ?? '';
      String SOLICITUD = dataMensajes['SOLICITUD'] ?? '';
      int ultimaModificacion = dataMensajes.containsKey('ultimaModificacion') ? dataMensajes['ultimaModificacion'] : 1672534800;

      ConfiguracionPlugins newconfig = ConfiguracionPlugins(PrimaryColor, SecundaryColor, idcarpetaPagos, idcarpetaSolicitudes, nombre_empresa, PagosDriveApiFecha, SolicitudesDriveApiFecha, basicoFecha, CONFIRMACION_CLIENTE, SOLICITUD,ultimaModificacion,tutoresSistemaFecha);

      String configJson = jsonEncode(newconfig);
      await prefs.setString('configuracion_list_stream', configJson);
      await prefs.setBool('cheched_solicitudes_descargadas_stream', true);
      //carguemos a provider
      final ConfiguracionProvider = context.read<ConfiguracionAplicacion>();
      ConfiguracionProvider.cargarConfiguracion(newconfig);
      counter = counter+3; //son 3 documentos diferentes los que se leen, por eso debe ser asi
      estadisticasLectutaFirestore(counter);
      print("se han contado de configuración $counter");
      yield newconfig;
    }
  }
  Future<ConfiguracionPlugins> cargarconfiguracion() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String solicitudesJson = prefs.getString('configuracion_list_stream') ?? '';
    Map<String, dynamic> clienteData = jsonDecode(solicitudesJson);
    ConfiguracionPlugins configuracion = ConfiguracionPlugins.fromJson(clienteData);
    return configuracion; // Return a single instance, not a list
  }

  // STREAMBUILDER DE SOLICITUDES
  Stream<List<Solicitud>> getTodasLasSolicitudes(BuildContext context) async*{
    final solicitudProvider = context.read<SolicitudProvider>();
    CollectionReference refsolicitud = referencias.solicitudes!;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool solicitudescache = prefs.getBool('cheched_solicitudes_descargadas_stream') ?? false;
    Stream<QuerySnapshot> querySolicitud;
    int fehaUlt= await soliticudesUltimaFecha();
    if(!solicitudescache){
      querySolicitud = refsolicitud.snapshots();
    }else{
      querySolicitud = refsolicitud.where('ultimaModificacion', isGreaterThan: fehaUlt).snapshots();
      List<Solicitud>? solicitudList = await cargarsolicitudes();
      final solicitudproviderder =  context.read<SolicitudProvider>();
      solicitudproviderder.cargarTodasLasSolicitudes(solicitudList!);
      print("ya cacheados SOLICITUDES");
    }
    await for (QuerySnapshot solicitudSnapshot in querySolicitud) {
      List<Solicitud> solicitudList = [];
      print("Ejecutando Solciitudes Stream");

      int counter = 0;

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
        int ultimaModificacion = solicitudDoc.data().toString().contains('ultimaModificacion') ? solicitudDoc.get('ultimaModificacion') : 0; //Number
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

        print("consultado solicitud $idcotizacion");
        Solicitud newsolicitud = Solicitud(servicio, idcotizacion, materia, fechaentrega, resumen, infocliente, cliente, fechasistema, estado, cotizaciones,fechaactualizacion,urlarchivo,actualizarsolicitudes,ultimaModificacion);
        solicitudList.add(newsolicitud);
        counter++;
      }

      print("entrando a solicitudes $solicitudescache");
      if(!solicitudescache){
        print("chceado solicitud primera vez");
        String solicitudesJson = jsonEncode(solicitudList);
        await prefs.setString('solicitudes_list_stream', solicitudesJson);
        await prefs.setBool('cheched_solicitudes_descargadas_stream', true);
        solicitudProvider.cargarTodasLasSolicitudes(solicitudList);
      }else{
        print("ya existed, toca modificar o agregar");
        List<Solicitud>? solicitudCacheado = await cargarsolicitudes();
        for (var solicitud in solicitudList) {
          int indexExistente = solicitudCacheado!.indexWhere((s) => s.idcotizacion == solicitud.idcotizacion);

          if (indexExistente != -1) {
            solicitudProvider.modifySolicitud(solicitud);
          } else {
            solicitudProvider.addNewSolicitud(solicitud);
          }
        }
        String solicitudesJson = jsonEncode(solicitudProvider.todaslasSolicitudes);
        await prefs.setString('solicitudes_list_stream', solicitudesJson);
      }

      estadisticasLectutaFirestore(counter);
      print("se han contado de solicitudes $counter");
      yield solicitudList;
    }
  }
  Future<List<Solicitud>?> cargarsolicitudes() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String solicitudesJson = prefs.getString('solicitudes_list_stream') ?? '';
    if(solicitudesJson.isEmpty){
      List<Solicitud> solicitudList = [];
      return solicitudList;
    }else{
      List<dynamic> clienteData = jsonDecode(solicitudesJson);
      List<Solicitud> solicitudeslist = clienteData.map((clienteData) =>
          Solicitud.fromJson(clienteData as Map<String, dynamic>)).toList();
      return solicitudeslist;
    }
  }
  Future soliticudesUltimaFecha() async{
    List<Solicitud>? solicitudesList = await cargarsolicitudes();
    if (solicitudesList!.isEmpty) {
      return 1672534800;
    }else{
      int ultimaModificacion = solicitudesList
          .map((servicio) => servicio.ultimaModificacion)
          .reduce((maxTimestamp, currentTimestamp) =>
      maxTimestamp > currentTimestamp ? maxTimestamp : currentTimestamp);
      return ultimaModificacion;
    }
  }

  //Streambuilders de servicios agendados
  Stream<List<ServicioAgendado>> getServiciosAgendados(BuildContext context,String rol,String nombretutor) async* {
    final serviciosAgendadosProvider =  context.read<ContabilidadProvider>();
    CollectionReference refcontabilidad = referencias.contabilidad!;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? agendadocache = prefs.getBool('checked_serviciosAgendados') ?? false;
    Stream<QuerySnapshot> queryContabilidad;
    int fehaUlt= await serviciosAgendadosUltimaFecha();
    if(rol == "ADMIN"){
      if(!agendadocache){
        queryContabilidad = refcontabilidad.snapshots();
        print("sin chacear");
      }else{
        queryContabilidad = refcontabilidad.where('ultimaModificacion', isGreaterThan: fehaUlt).snapshots();
        List<ServicioAgendado> serviciosAgendadosList = await cargarserviciosagendados();
        serviciosAgendadosProvider.cargarTodosLosServicios(serviciosAgendadosList);
        print("ya cacheados");
      }
    }else{
      if(!agendadocache){
        queryContabilidad = refcontabilidad.where('tutor', isEqualTo: nombretutor).snapshots();
      }else{
        queryContabilidad = refcontabilidad.where('tutor', isEqualTo: nombretutor,).where('ultimaModificacion', isGreaterThan: fehaUlt).snapshots();
        List<ServicioAgendado> serviciosAgendadosList = await cargarserviciosagendados();
        serviciosAgendadosProvider.cargarTodosLosServicios(serviciosAgendadosList);
      }
    }

    await for (QuerySnapshot servicioSnapshot in queryContabilidad) {
      List<ServicioAgendado> serviciosAgendadosList = [];

      print("Ejecutando Contabilidad Stream");
      int counter = 0;

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
          int ultimaModificacion = servicio.data().toString().contains('ultimaModificacion') ? servicio.get('ultimaModificacion') : 1672534800; //Number

          print("consultando el codigo $codigo");
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
              ultimaModificacion
          );

          serviciosAgendadosList.add(newservicioagendado);
          counter++;
        } catch (e) {
          print(e);
        }
      }

      if(!agendadocache){
        String solicitudesJson = jsonEncode(serviciosAgendadosList);
        await prefs.setString('servicios_agendados_list_stream', solicitudesJson);
        await prefs.setBool('checked_serviciosAgendados', true);
        serviciosAgendadosProvider.cargarTodosLosServicios(serviciosAgendadosList);
      }else{
        List<ServicioAgendado> serrvicioscacheado = await cargarserviciosagendados();
        for (var servicio in serviciosAgendadosList) {
          int indexExistente = serrvicioscacheado.indexWhere((s) => s.codigo == servicio.codigo);
          if (indexExistente != -1) {
            serviciosAgendadosProvider.modifyServicio(servicio);
          }else{
            serviciosAgendadosProvider.addNewServicio(servicio);
          }
        }
        String solicitudesJson = jsonEncode(serviciosAgendadosProvider.todoslosServiciosAgendados);
        await prefs.setString('servicios_agendados_list_stream', solicitudesJson);
      }
      estadisticasLectutaFirestore(counter);
      print("se han contado de contabilidad $counter");
      yield serviciosAgendadosList;
    }
  }
  Future cargarserviciosagendados() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String solicitudesJson = prefs.getString('servicios_agendados_list_stream') ?? '';
    if (solicitudesJson.isEmpty) {
      List<ServicioAgendado> serviciosAgendadosList= [];
      return serviciosAgendadosList;
    }else{
      List<dynamic> clienteData = jsonDecode(solicitudesJson);
      List<ServicioAgendado> serviciosAgendadosList = clienteData.map((clienteData) =>
          ServicioAgendado.fromJson(clienteData as Map<String, dynamic>)).toList();
      return serviciosAgendadosList;
    }
  }
  Future serviciosAgendadosUltimaFecha() async{
    List<ServicioAgendado> serviciosAgendadosList = await cargarserviciosagendados();
    if (serviciosAgendadosList.isEmpty) {
      return 1672534800;
    }else{
      int ultimaModificacion = serviciosAgendadosList
          .map((servicio) => servicio.ultimaModificacion)
          .reduce((maxTimestamp, currentTimestamp) =>
      maxTimestamp > currentTimestamp ? maxTimestamp : currentTimestamp);
      return ultimaModificacion;
    }
  }

  // STREAMBUILDER DE TUTORES
  Stream<List<Tutores>> getTodosLosTutores(BuildContext context) async* {
    final tutoresProviderUso =  context.read<VistaTutoresProvider>();
    CollectionReference refTutores = referencias.tutores!;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? serviciosAgendadosCache = prefs.getBool('checked_tutores_stream') ?? false;
    Stream<QuerySnapshot> queryTutores;
    int fehaUlt= await tutoresUltimaFecha();
    if(!serviciosAgendadosCache){
      queryTutores = refTutores.snapshots();
      print("sin chacear");
    }else{
      queryTutores = refTutores.where('ultimaModificacion', isGreaterThan: fehaUlt).snapshots();
      List<Tutores> tutoresList = await cargarTutoresList();
      tutoresProviderUso.cargarTodosTutores(tutoresList);
      print("ya cacheados");
    }
    await for (QuerySnapshot tutoresSnapshot in queryTutores) {
      List<Tutores> tutoresList = [];
      print("Ejecutando Tutores Stream");

      int counter = 0;

      for (var TutorDoc in tutoresSnapshot.docs) {
        String nombrewhatsapp = TutorDoc['nombre Whatsapp'];
        String nombrecompleto = TutorDoc['nombre completo'];
        int numerowhatsapp = TutorDoc['numero whatsapp'];
        String carrera = TutorDoc['carrera'];
        String correogmail = TutorDoc['Correo gmail'];
        String univerisdad = TutorDoc['Universidad'];
        String uid = TutorDoc['uid'];
        bool activo = TutorDoc.data().toString().contains('activo') ? TutorDoc.get('activo') : true;
        DateTime actualizartutores = TutorDoc.data().toString().contains('actualizartutores') ? TutorDoc.get('actualizartutores').toDate() : DateTime(2023,1,1,0,0); //Number
        String rol = TutorDoc.data().toString().contains('rol') ? TutorDoc.get('rol') : "TUTOR";
        int ultimaModificacion = TutorDoc.data().toString().contains('ultimaModificacion') ? TutorDoc.get('ultimaModificacion') : 1672534800;
        List<Materia> materiaList = [];
        if (TutorDoc.data() !=null && TutorDoc.data().toString().contains('materias')) {
          var MateriaData = TutorDoc['materias'] as List<dynamic>;
          materiaList = MateriaData.map((MateriaDato) {
            String nombremateria = MateriaDato['nombremateria'];
            int ultimaModificacion = MateriaDato.containsKey('ultimaModificacion') ? MateriaDato['ultimaModificacion'] : 1672534800;
            Materia newmateria = Materia(nombremateria,ultimaModificacion);
            return newmateria;
          }).toList();
        }

        List<CuentasBancarias> cuentasBancariasList = [];
        if (TutorDoc.data() !=null && TutorDoc.data().toString().contains('cuentas')) {
          var MateriaData = TutorDoc['cuentas'] as List<dynamic>;
          cuentasBancariasList = MateriaData.map((cuentaDato) {
            String tipoCuenta = cuentaDato['tipoCuenta'];
            String numeroCuenta = cuentaDato['numeroCuenta'];
            String numeroCedula = cuentaDato['numeroCedula'];
            String nombreCuenta = cuentaDato['nombreCuenta'];
            CuentasBancarias newcuentaBancaria = CuentasBancarias(tipoCuenta, numeroCuenta, numeroCedula, nombreCuenta);
            return newcuentaBancaria;
          }).toList();
        }
        Tutores newTutores = Tutores(nombrewhatsapp, nombrecompleto, numerowhatsapp, carrera, correogmail, univerisdad, uid, materiaList, cuentasBancariasList, activo, actualizartutores, rol,ultimaModificacion);
        tutoresList.add(newTutores);
        counter++;
      }

      if(!serviciosAgendadosCache){
        String solicitudesJson = jsonEncode(tutoresList);
        await prefs.setString('tutores_list_stream', solicitudesJson);
        await prefs.setBool('checked_tutores_stream', true);
        tutoresProviderUso.cargarTodosTutores(tutoresList);
      }
      else{
        List<Tutores> tutorescacheado = tutoresProviderUso.todosLosTutores;
        for (var tutor in tutoresList) {
          int indexExistente = tutorescacheado.indexWhere((s) => s.uid == tutor.uid);
          print("revisando tutor ${tutor.uid}");
          if (indexExistente != -1) {
            tutoresProviderUso.modifyTutor(tutor);
            print("tutor ya existente");
          }else{
            tutoresProviderUso.addNewTutor(tutor);
            print("agregando nuevo tutor");
          }
        }
        print("guardando en cache");
        String solicitudesJson = jsonEncode(tutoresProviderUso.todosLosTutores);
        await prefs.setString('tutores_list_stream', solicitudesJson);
      }
      estadisticasLectutaFirestore(counter);
      print("se han contado de tutores $counter");
      yield tutoresList;
    }


  }
  Future cargarTutoresList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String solicitudesJson = prefs.getString('tutores_list_stream') ?? '';
    if (solicitudesJson.isEmpty) {
      List<Tutores> tutoresList= [];
      return tutoresList;
    }else{
      List<dynamic> clienteData = jsonDecode(solicitudesJson);
      List<Tutores> tutoresList = clienteData.map((clienteData) =>
          Tutores.fromJson(clienteData as Map<String, dynamic>)).toList();
      return tutoresList;
    }
  }
  Future tutoresUltimaFecha() async{
    List<Tutores> tutoresList = await cargarTutoresList();
    if (tutoresList.isEmpty) {
      return 1672534800;
    }else{
      int ultimaModificacion = tutoresList
          .map((servicio) => servicio.ultimaModificacion)
          .reduce((maxTimestamp, currentTimestamp) =>
      maxTimestamp > currentTimestamp ? maxTimestamp : currentTimestamp);
      return ultimaModificacion;
    }
  }

  //STREAMBUILDER DE MATERIAS
  Stream<List<Materia>> getTodasLasMaterias(BuildContext context) async*{
    CollectionReference refMaterias = referencias.tablasmaterias!;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? materiascache = prefs.getBool('checked_materias_cache') ?? false;
    Stream<QuerySnapshot> queryMaterias;
    int fehaUlt= await materiaUltimaFechacache();
    if(!materiascache){
      queryMaterias = refMaterias.snapshots();
      print("sin cache");
    }else{
      queryMaterias = refMaterias.where('ultimaModificacion', isGreaterThan: fehaUlt).snapshots();
      List<Materia> materiaList = await cargarMaterias();
      final materiasProvider =  context.read<MateriasVistaProvider>();
      materiasProvider.clearMaterias();
      materiasProvider.cargarTodasLasMaterias(materiaList);
      print("ya cacheados");
    }

    await for (QuerySnapshot MateriaSnapshot in queryMaterias) {
      List<Materia> materiaList = [];
      print("Ejecutando Materias Stream");
      int counter = 0;
      for (var MateriaDoc in MateriaSnapshot.docs) {
        String nombremateria = MateriaDoc['nombremateria'];
        int ultimaModificacion = MateriaDoc.data().toString().contains('ultimaModificacion') ? MateriaDoc.get('ultimaModificacion') : 1672534800; //Number

        Materia newmateria = Materia(nombremateria, ultimaModificacion);
        materiaList.add(newmateria);
        print("cargando materia $nombremateria");
        counter++;
      }

      if(!materiascache){
        String solicitudesJson = jsonEncode(materiaList);
        await prefs.setString('materia_List_Stream', solicitudesJson);
        await prefs.setBool('checked_materias_cache', true);
        final materiasProvider =  context.read<MateriasVistaProvider>();
        materiasProvider.clearMaterias();
        materiasProvider.cargarTodasLasMaterias(materiaList);
      }else{
        List<Materia> materiacacheadoList = await cargarMaterias();
        materiacacheadoList = materiacacheadoList
            .where((servicioCachado) =>
        materiaList.indexWhere((s) => s.nombremateria == servicioCachado.nombremateria) == -1)
            .toList();
        materiacacheadoList.addAll(materiaList);
        String solicitudesJson = jsonEncode(materiacacheadoList);
        await prefs.setString('materia_List_Stream', solicitudesJson);
        final materiasProvider =  context.read<MateriasVistaProvider>();
        materiasProvider.clearMaterias();
        materiasProvider.cargarTodasLasMaterias(materiacacheadoList);
      }

      estadisticasLectutaFirestore(counter);
      print("se han contado de materias $counter");
      yield materiaList;
    }
  }
  Future cargarMaterias() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String solicitudesJson = prefs.getString('materia_List_Stream') ?? '';
    if (solicitudesJson.isEmpty) {
      List<Materia> materiaList= [];
      return materiaList;
    }else{
      List<dynamic> materiaData = jsonDecode(solicitudesJson);
      List<Materia> materiaList = materiaData.map((materiaDataa) =>
          Materia.fromJson(materiaDataa as Map<String, dynamic>)).toList();
      return materiaList;
    }
  }
  Future materiaUltimaFechacache() async{
    List<Materia> materiaList = await cargarMaterias();
    if (materiaList.isEmpty) {
      return 1672534800;
    }else{
      int ultimaModificacion = materiaList
          .map((servicio) => servicio.ultimaModificacion)
          .reduce((maxTimestamp, currentTimestamp) =>
      maxTimestamp > currentTimestamp ? maxTimestamp : currentTimestamp);
      return ultimaModificacion;
    }
  }

  //STREAMBUILDER DE CLIENTES
  Stream<List<Clientes>> getTodosLosClientes(BuildContext context) async*{
    final clienteProviderUso = context.read<ClientesVistaProvider>();
    CollectionReference refclientes = referencias.clientes!;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool clientescache = prefs.getBool('cheched_clientes_descargados') ?? false;
    Stream<QuerySnapshot> queryCLientes;
    int fehaUlt= await clientesUltimaFecha();
    if(!clientescache){
      queryCLientes = refclientes.snapshots();
      print("sin chacear");
    }else{
      queryCLientes = refclientes.where('ultimaModificacion', isGreaterThan: fehaUlt).snapshots();
      List<Clientes>? clientesList = await cargarclientes();
      clienteProviderUso.cargarTodosLosClientes(clientesList!);
      print("ya cacheados");
    }
    await for (QuerySnapshot clienteSnapshot in queryCLientes) {
      List<Clientes> clienteList = [];
      print("Ejecutando Clientes Stream");
      int counter = 0;

      for (var clienteDoc in clienteSnapshot.docs) {
        String Carrera = clienteDoc['Carrera'];
        String Universidadd = clienteDoc['Universidadd'];
        String nombreCliente = clienteDoc['nombreCliente'];
        int numero = clienteDoc['numero'];
        String nombrecompletoCliente = clienteDoc.data().toString().contains('nombrecompletoCliente') ? clienteDoc.get('nombrecompletoCliente') : 'NO REGISTRADO';
        DateTime fechaActualizacion = clienteDoc.data().toString().contains('fechaActualizacion') ? clienteDoc.get('fechaActualizacion').toDate() : DateTime(2023,1,1,0,0); //Number
        String procedencia = clienteDoc.data().toString().contains('procedencia') ? clienteDoc.get('procedencia') : 'VIEJO';
        DateTime fechaContacto = clienteDoc.data().toString().contains('fechaContacto') ? clienteDoc.get('fechaContacto').toDate() : DateTime(2023,1,1,0,0); //Number
        int ultimaModificacion = clienteDoc.data().toString().contains('ultimaModificacion') ? clienteDoc.get('ultimaModificacion') : 0; //Number

        print("consultado cliente $numero");
        Clientes newClientes = Clientes(Carrera, Universidadd, nombreCliente, numero,nombrecompletoCliente,fechaActualizacion,procedencia,fechaContacto,ultimaModificacion);
        clienteList.add(newClientes);
        counter++;
      }
      if(!clientescache){
        print("cliente no cahceados");
        String solicitudesJson = jsonEncode(clienteList);
        await prefs.setString('clientes_list_stream', solicitudesJson);
        clienteProviderUso.cargarTodosLosClientes(clienteList);
      }else{
        print("cliente ya cahceados");
        List<Clientes>? clientescacheado = await cargarclientes();
        for (var cliente in clienteList) {
          int indexExistente = clientescacheado!.indexWhere((s) => s.numero.toString() == cliente.numero.toString());
          if (indexExistente != -1) {
            print("actualizar cliente");
            clienteProviderUso.modifyCliente(cliente);
          } else {
            print("cliente nuevo");
            clienteProviderUso.addNewCliente(cliente);
          }
        }
        clientescacheado!.addAll(clienteList);
        String solicitudesJson = jsonEncode(clientescacheado);
        await prefs.setString('clientes_list_stream', solicitudesJson);
      }

      await prefs.setBool('cheched_clientes_descargados', true);
      estadisticasLectutaFirestore(counter);
      print("se han contado de clientes $counter");
      yield clienteList;
    }
  }
  Future<List<Clientes>?> cargarclientes() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String solicitudesJson = prefs.getString('clientes_list_stream') ?? '';
    if(solicitudesJson.isEmpty){
      List<Clientes> clientesList = [];
      return clientesList;
    }else{
      List<dynamic> clienteData = jsonDecode(solicitudesJson);
      List<Clientes> clienteList = clienteData.map((clienteData) =>
          Clientes.fromJson(clienteData as Map<String, dynamic>)).toList();
      return clienteList;
    }
  }
  Future clientesUltimaFecha() async{
    List<Clientes>? clientesList = await cargarclientes();
    if (clientesList!.isEmpty) {
      return 1672534800;
    }else{
      int ultimaModificacion = clientesList
          .map((servicio) => servicio.ultimaModificacion)
          .reduce((maxTimestamp, currentTimestamp) =>
      maxTimestamp > currentTimestamp ? maxTimestamp : currentTimestamp);
      return ultimaModificacion;
    }
  }

  //STREAMBUILDER DE UNIVERSIDADES
  Stream<List<Universidad>> getTodasLasUniversidades(BuildContext context) async*{
    final universidadProvider =  context.read<UniversidadVistaProvider>();
    CollectionReference refUniversidades = referencias.tablasuniversidades!;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? universidadcache = prefs.getBool('checked_universidad_cache') ?? false;
    Stream<QuerySnapshot> queryUniversidades;
    int fehaUlt= await universidadUltimaFechacache();
    if(!universidadcache){
      queryUniversidades = refUniversidades.snapshots();
      print("sin cache");
    }else{
      queryUniversidades = refUniversidades.where('ultimaModificacion', isGreaterThan: fehaUlt).snapshots();
      List<Universidad> universidadList = await cargarUniversidades();
      universidadProvider.cargarTodasLasUniversidades(universidadList);
    }

    await for (QuerySnapshot UniversidadSnapshot in queryUniversidades) {
      List<Universidad> universidadList = [];
      print("Ejecutando Universidad Stream");

      int counter = 0;


      for (var UniversidadDoc in UniversidadSnapshot.docs) {
        String nombreuniversidad = UniversidadDoc['nombre Universidad'];
        int ultimaModificacion = UniversidadDoc.data().toString().contains('ultimaModificacion') ? UniversidadDoc.get('ultimaModificacion') : 1672534800; //Number

        Universidad newuniversidad = Universidad(nombreuniversidad,ultimaModificacion);
        universidadList.add(newuniversidad);
        print("cargando universidad $nombreuniversidad");
        counter++;
      }
      if(!universidadcache){
        String solicitudesJson = jsonEncode(universidadList);
        await prefs.setString('universidades_List_Stream', solicitudesJson);
        await prefs.setBool('checked_universidad_cache', true);
        universidadProvider.cargarTodasLasUniversidades(universidadList);
      }else{
        List<Universidad> universidadCacheadoList = await cargarUniversidades();
        universidadCacheadoList = universidadCacheadoList
            .where((servicioCachado) =>
        universidadList.indexWhere((s) => s.nombreuniversidad == servicioCachado.nombreuniversidad) == -1)
            .toList();
        universidadCacheadoList.addAll(universidadList);
        String solicitudesJson = jsonEncode(universidadCacheadoList);
        await prefs.setString('universidades_List_Stream', solicitudesJson);
        universidadProvider.cargarTodasLasUniversidades(universidadCacheadoList);
      }
      estadisticasLectutaFirestore(counter);
      print("se han contado de universidades $counter");
      yield universidadList;
    }

  }
  Future cargarUniversidades() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String solicitudesJson = prefs.getString('universidades_List_Stream') ?? '';
    if (solicitudesJson.isEmpty) {
      List<Universidad> universidadList= [];
      return universidadList;
    }else{
      List<dynamic> materiaData = jsonDecode(solicitudesJson);
      List<Universidad> universidadList = materiaData.map((materiaDataa) =>
          Universidad.fromJson(materiaDataa as Map<String, dynamic>)).toList();
      return universidadList;
    }
  }
  Future universidadUltimaFechacache() async{
    List<Universidad> universidadList = await cargarUniversidades();
    if (universidadList.isEmpty) {
      return 1672534800;
    }else{
      int ultimaModificacion = universidadList
          .map((servicio) => servicio.ultimaModificacion)
          .reduce((maxTimestamp, currentTimestamp) =>
      maxTimestamp > currentTimestamp ? maxTimestamp : currentTimestamp);
      return ultimaModificacion;
    }
  }


  //STREAMBUILDER DE CARRERAS
  Stream<List<Carrera>> getTodasLasCarreras(BuildContext context) async*{
    final carreraProviderUso =  context.read<CarrerasProvider>();
    CollectionReference refCarreras = referencias.tablascarreras!;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? carreracache = prefs.getBool('checked_carrera_cache') ?? false;
    Stream<QuerySnapshot> queryCarreras;
    int fehaUlt= await carreraUltimaFechacache();
    if(!carreracache){
      queryCarreras = refCarreras.snapshots();
      print("sin cache");
    }else{
      queryCarreras = refCarreras.where('ultimaModificacion', isGreaterThan: fehaUlt).snapshots();
      List<Carrera> carreraList = await cargarCarreras();
      carreraProviderUso.cargarTodasLasCarreras(carreraList);
    }
    await for (QuerySnapshot CarrerasSnapshot in queryCarreras) {
      print("Ejecutando Carrera Stream");
      List<Carrera> carreraList = [];
      int counter = 0;

      for (var CarreraDoc in CarrerasSnapshot.docs) {
        String nombrecarrera = CarreraDoc['nombre carrera'];
        int ultimaModificacion = CarreraDoc.data().toString().contains('ultimaModificacion') ? CarreraDoc.get('ultimaModificacion') : 1672534800; //Number

        Carrera newcarrera = Carrera(nombrecarrera,ultimaModificacion);
        carreraList.add(newcarrera);
        print("cargando carrera $nombrecarrera");
        counter++;
      }
      if(!carreracache){
        String solicitudesJson = jsonEncode(carreraList);
        await prefs.setString('carreras_List_Stream', solicitudesJson);
        await prefs.setBool('checked_carrera_cache', true);
        carreraProviderUso.cargarTodasLasCarreras(carreraList);
      }else{
        List<Carrera> carreraCacheadoList = await cargarCarreras();
        carreraCacheadoList = carreraCacheadoList
            .where((servicioCachado) =>
        carreraList.indexWhere((s) => s.nombrecarrera == servicioCachado.nombrecarrera) == -1)
            .toList();
        carreraCacheadoList.addAll(carreraList);
        String solicitudesJson = jsonEncode(carreraCacheadoList);
        await prefs.setString('carreras_List_Stream', solicitudesJson);
        carreraProviderUso.cargarTodasLasCarreras(carreraCacheadoList);
      }

      estadisticasLectutaFirestore(counter);
      print("se han contado de carreras $counter");
      yield carreraList;
    }
  }
  Future cargarCarreras() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String solicitudesJson = prefs.getString('carreras_List_Stream') ?? '';
    if (solicitudesJson.isEmpty) {
      List<Carrera> carreraList= [];
      return carreraList;
    }else{
      List<dynamic> materiaData = jsonDecode(solicitudesJson);
      List<Carrera> carreraList = materiaData.map((materiaDataa) =>
          Carrera.fromJson(materiaDataa as Map<String, dynamic>)).toList();
      return carreraList;
    }
  }
  Future carreraUltimaFechacache() async{
    List<Carrera> carreraList = await cargarCarreras();
    if (carreraList.isEmpty) {
      return 1672534800;
    }else{
      int ultimaModificacion = carreraList
          .map((servicio) => servicio.ultimaModificacion)
          .reduce((maxTimestamp, currentTimestamp) =>
      maxTimestamp > currentTimestamp ? maxTimestamp : currentTimestamp);
      return ultimaModificacion;
    }
  }

  //STREAMBUILDER DE - DRIVE API USAGE - USO DE FIREBASE USAGE


}


