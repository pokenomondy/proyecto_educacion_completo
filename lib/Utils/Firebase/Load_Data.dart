import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dashboard_admin_flutter/Objetos/AgendadoServicio.dart';
import 'package:dashboard_admin_flutter/Objetos/Clientes.dart';
import 'package:dashboard_admin_flutter/Objetos/Cotizaciones.dart';
import 'package:dashboard_admin_flutter/Objetos/CuentasBancaraias.dart';
import 'package:dashboard_admin_flutter/Objetos/Objetos%20Auxiliares/Carreras.dart';
import 'package:dashboard_admin_flutter/Objetos/Objetos%20Auxiliares/Materias.dart';
import 'package:dashboard_admin_flutter/Objetos/RegistrarPago.dart';
import 'package:dashboard_admin_flutter/Objetos/Solicitud.dart';
import 'package:dashboard_admin_flutter/Objetos/Tutores_objet.dart';
import 'package:dashboard_admin_flutter/Pages/Estadisticas/Contabilida.dart';
import 'package:dashboard_admin_flutter/Utils/Firebase/ActualizarInformacion.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:googleapis/driveactivity/v2.dart' as drive;
import 'package:shared_preferences/shared_preferences.dart';

import '../../Objetos/Objetos Auxiliares/Universidad.dart';

class LoadData {
  final db = FirebaseFirestore.instance; //inicializar firebase

  //Obtener solicitudes en stream
  Stream<List<Solicitud>> getsolicitudstream(String estado) async* {
    CollectionReference refsolicitudes = FirebaseFirestore.instance.collection("SOLICITUDES");
    Stream<QuerySnapshot> querySolicitud = refsolicitudes.where('Estado', isEqualTo: estado).snapshots();

    await for (QuerySnapshot solicitudSnapshot in querySolicitud) {
      List<Solicitud> solicitudesList = [];

      for (var solicitudDoc in solicitudSnapshot.docs) {
        try {
          String servicio = solicitudDoc['Servicio'];
          int idcotizacion = solicitudDoc['idcotizacion'];
          String materia = solicitudDoc['materia'];
          DateTime fechaentrega = solicitudDoc['fechaentrega'].toDate();
          String resumen = solicitudDoc['resumen'];
          String infocliente = solicitudDoc['infocliente'];
          int cliente = solicitudDoc['cliente'];
          DateTime fechasistema = solicitudDoc['fechasistema'].toDate();
          String estado = solicitudDoc['Estado'];
          DateTime fechaactualizacion = solicitudDoc.data().toString().contains(
              'fechaactualizacion') ? solicitudDoc.get('fechaactualizacion')
              .toDate() : DateTime(2023, 1, 1, 0, 0); //Number
          String urlarchivo = solicitudDoc.data().toString().contains(
              'archivos') ? solicitudDoc.get('archivos') : 'No tiene Archivos';
          //escuchear streambuilder en tiempo real
          List<Cotizacion> cotizaciones = [];
          DateTime actualizarsolicitudes = solicitudDoc.data().toString()
              .contains('actualizarsolicitudes') ?
          solicitudDoc['actualizarsolicitudes'].toDate() :
          DateTime(2023,1,1,0,0); //Number


          Solicitud newsolicitud = Solicitud(
            servicio,
            idcotizacion,
            materia,
            fechaentrega,
            resumen,
            infocliente,
            cliente,
            fechasistema,
            estado,
            cotizaciones,
            fechaactualizacion,
            urlarchivo,
            actualizarsolicitudes,
          );
          solicitudesList.add(newsolicitud);
        } catch (e) {
          // Manejar excepciones aquí
          print("Error al procesar un documento: $e");
        }
      }

      yield solicitudesList;
    }
  }

  Stream<List<Cotizacion>> getcotizaciones(int idcotizacion) async* {
    CollectionReference refcotizacion = FirebaseFirestore.instance.collection(
        "SOLICITUDES").doc(idcotizacion.toString()).collection("COTIZACIONES");
    Stream<QuerySnapshot> querycotizacion = refcotizacion.snapshots();

    await for (QuerySnapshot cotizacionSnapshot in querycotizacion) {
      List<Cotizacion> cotizacionList = [];
      for (var cotizacionDoc in cotizacionSnapshot.docs) {
        int cotizacion = cotizacionDoc['Cotizacion'];
        String uidtutor = cotizacionDoc['uidtutor'];
        String nombretutor = cotizacionDoc['nombretutor'];
        int? tiempoconfirmacion = cotizacionDoc['Tiempo confirmacion'];
        String? comentariocotizacion = cotizacionDoc['Comentario Cotización'];
        String? Agenda = cotizacionDoc['Agenda'];
        DateTime fechaconfirmacion = cotizacionDoc.data()
            .toString()
            .contains('fechaconfirmacion') ? cotizacionDoc.get(
            'fechaconfirmacion').toDate() : DateTime.now();
        Cotizacion newcotizacion = Cotizacion(
            cotizacion,
            uidtutor,
            nombretutor,
            tiempoconfirmacion,
            comentariocotizacion,
            Agenda,
            fechaconfirmacion);
        cotizacionList.add(newcotizacion);
      }
      yield cotizacionList;
    }
  }

  //Obtener en tiempo real, numero de servicio a publicar
  Stream<int> cargarnumerodesolicitudes() async* {
    CollectionReference referencesolicitudes = db.collection("SOLICITUDES");
    await for (QuerySnapshot snapshot in referencesolicitudes.snapshots()) {
      int numDocumentos = snapshot.size;
      print("numero obtenido $numDocumentos");
      yield numDocumentos + 472;
    }
  }

  //Obtener numero de contabilidades en tiempo real
  Stream<int> cargarnumerocontabilidad() async* {
    CollectionReference referencecontabilidad = db.collection("CONTABILIDAD");
    await for (QuerySnapshot snapshot in referencecontabilidad.snapshots()){
      int numDocumentos = snapshot.size;
      print("numero obtenido $numDocumentos");
      yield numDocumentos + 922;
    }
  }

  /*
  //Guardar Solicitudes
  Future guardardatosSolicitudes(List<Solicitud> solicitudesList) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print("se guardan datos de parciales");
    String solicitudesJson = jsonEncode(solicitudesList);
    await prefs.setString('solicitudes_List', solicitudesJson);
    await prefs.setBool('datos_descargados_lista_solicitudes', true);
  }
   */

  //Tablas de materias
  Future tablasmateria() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool datosDescargados = prefs.getBool('datos_descargados_tablamateria') ?? false;
    if (!datosDescargados) {
      print("a descargar materias por primera vez");
      CollectionReference referencetablamaterias = await FirebaseFirestore.instance.collection("TABLAS").doc("TABLAS").collection("MATERIAS");
      QuerySnapshot queryMaterias = await referencetablamaterias.get();
      List<Materia> materiaList = [];

      for (var MateriaDoc in queryMaterias.docs) {
        String nombremateria = MateriaDoc['nombremateria'];
        print(nombremateria);

        Materia newmateria = Materia(nombremateria);
        materiaList.add(newmateria);
      }
      guardardatostablamaterias(materiaList);
      return materiaList;
    } else {
      print("ya descargadas la tabla materias");
      String solicitudesJson = prefs.getString('tablamaterias_list') ?? '';
      List<dynamic> TablaMateriaData = jsonDecode(solicitudesJson);
      List materiaList = TablaMateriaData.map((MateriaData) =>
          Materia.fromJson(MateriaData)).toList();
      return materiaList;
    }
  }

  Future guardardatostablamaterias(List<Materia> materiaList) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print("se guardan datos de tabla materias");
    String solicitudesJson = jsonEncode(materiaList);
    await prefs.setString('tablamaterias_list', solicitudesJson);
    await prefs.setBool('datos_descargados_tablamateria', true);
  }

  //Clientes, revisar
  Future obtenerclientes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool datosDescargados = prefs.getBool('datos_descargados_tablaclientes') ??
        false;
    if (!datosDescargados) {
      print("a descargar clientes por primera vez");
      CollectionReference referencetablaclientes = await FirebaseFirestore
          .instance.collection("CLIENTES");
      QuerySnapshot queryClientes = await referencetablaclientes.get();
      List<Clientes> clientesList = [];

      for (var ClienteDoc in queryClientes.docs) {
        String Carrera = ClienteDoc['Carrera'];
        String Universidadd = ClienteDoc['Universidadd'];
        String nombreCliente = ClienteDoc['nombreCliente'];
        int numero = ClienteDoc['numero'];
        String nombrecompletoCliente = ClienteDoc.data().toString().contains('nombrecompletoCliente') ? ClienteDoc.get('nombrecompletoCliente') : 'NO REGISTRADO';

        print("$Carrera $Universidadd $nombreCliente $numero");

        Clientes newClientes = Clientes(
            Carrera, Universidadd, nombreCliente, numero,nombrecompletoCliente);
        clientesList.add(newClientes);
      }
      guardardatostablaclientes(clientesList);
      return clientesList;
    } else {
      print("ya descargadas la clientes tablas");
      String solicitudesJson = prefs.getString('clientes_list') ?? '';
      List<dynamic> ClienteData = jsonDecode(solicitudesJson);
      List clientesList = ClienteData.map((ClienteData) =>
          Clientes.fromJson(ClienteData as Map<String, dynamic>)).toList();
      return clientesList;
    }
  }

  Future guardardatostablaclientes(List<Clientes> clientesList) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String solicitudesJson = jsonEncode(clientesList);
    await prefs.setString('clientes_list', solicitudesJson);
    await prefs.setBool('datos_descargados_tablaclientes', true);
  }

  //Tutores, guardar
  Future obtenertutores() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool datosDescargados = prefs.getBool('datos_descargados_tablatutores') ?? false;
    if (!datosDescargados) {
      print("a descargar tutores por primera vez");
      CollectionReference referencetablaclientes = await FirebaseFirestore
          .instance.collection("TUTORES");
      QuerySnapshot queryTutores = await referencetablaclientes.get();
      List<Tutores> tutoresList = [];

      for (var TutorDoc in queryTutores.docs) {
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

        //Cargamos materias
        QuerySnapshot materiasDocs = await TutorDoc.reference.collection(
            "MATERIA").get();
        List<Materia> materiaList = [];
        for (var materiaDoc in materiasDocs.docs) {
          String nombremateria = materiaDoc['nombremateria'];
          print(nombremateria);

          Materia newmateria = Materia(nombremateria);
          materiaList.add(newmateria);
        }

        //Cargamos cuentas Bancarias
        QuerySnapshot cuentaDocs = await TutorDoc.reference.collection(
            "CUENTAS").get();
        List<CuentasBancarias> cuentasBancariasList = [];
        for (var cuentaDoc in cuentaDocs.docs) {
          String tipoCuenta = cuentaDoc['tipoCuenta'];
          String numeroCuenta = cuentaDoc['numeroCuenta'];
          String numeroCedula = cuentaDoc['numeroCedula'];
          String nombreCuenta = cuentaDoc['nombreCuenta'];

          CuentasBancarias newcuentaBancaria = CuentasBancarias(
              tipoCuenta, numeroCuenta, numeroCedula, nombreCuenta);
          cuentasBancariasList.add(newcuentaBancaria);
        }


        Tutores newTutores = Tutores(
            nombrewhatsapp,
            nombrecompleto,
            numerowhatsapp,
            carrera,
            correogmail,
            univerisdad,
            uid,
            materiaList,
            cuentasBancariasList,
            activo,
            actualizartutores,
            rol
        );
        tutoresList.add(newTutores);
      }
      guardardatostablatutores(tutoresList);
      return tutoresList;
    } else {
        print("ya descargadas la tutores tablas");
      String solicitudesJson = prefs.getString('tutores_list') ?? '';
      List<dynamic> ClienteData = jsonDecode(solicitudesJson);
      List tutoresList = ClienteData.map((tutorData) =>
          Tutores.fromJson(tutorData as Map<String, dynamic>)).toList();
      return tutoresList;
    }
  }

  Future guardardatostablatutores(List<Tutores> clientesList) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String solicitudesJson = jsonEncode(clientesList);
    await prefs.setString('tutores_list', solicitudesJson);
    await prefs.setBool('datos_descargados_tablatutores', true);
  }

  //Carrareas Listas
  Future obtenercarreras() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool datosDescargados = prefs.getBool('datos_descargados_listacarreras') ??
        false;
    if (!datosDescargados) {
      print("a descargar carreras por priemra vez");
      CollectionReference referencetablascarrera = await FirebaseFirestore
          .instance.collection("TABLAS").doc("TABLAS").collection("CARRERAS");
      QuerySnapshot QueryCarreras = await referencetablascarrera.get();
      List<Carrera> carreraList = [];
      for (var CarreraDoc in QueryCarreras.docs) {
        String nombrecarrera = CarreraDoc['nombre carrera'];
        Carrera newcarrera = Carrera(nombrecarrera);
        carreraList.add(newcarrera);
        print(nombrecarrera);
        guardarCarreras(carreraList);
      }
      return carreraList;
    } else {
      print("ya descargadas la carreras tablas");
      String solicitudesJson = prefs.getString('carreras_List') ?? '';
      List<dynamic> CarreraData = jsonDecode(solicitudesJson);
      List carreraList = CarreraData.map((tutorData) =>
          Carrera.fromJson(tutorData as Map<String, dynamic>)).toList();
      return carreraList;
    }
  }

  Future guardarCarreras(List<Carrera> carreraList) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String solicitudesJson = jsonEncode(carreraList);
    await prefs.setString('carreras_List', solicitudesJson);
    await prefs.setBool('datos_descargados_listacarreras', true);
  }

  //Lista de euniversidades
  Future obtenerUniversidades() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool datosDescargados = prefs.getBool(
        'datos_descargados_listauniversidades') ?? false;
    if (!datosDescargados) {
      print("a descargar universidades por priemra vez");
      CollectionReference referencetablascarrera = await FirebaseFirestore
          .instance.collection("TABLAS").doc("TABLAS").collection(
          "UNIVERSIDADES");
      QuerySnapshot QueryCarreras = await referencetablascarrera.get();
      List<Universidad> universidadList = [];
      for (var CarreraDoc in QueryCarreras.docs) {
        String nombreuniversidad = CarreraDoc['nombre Universidad'];
        Universidad newcarrera = Universidad(nombreuniversidad);
        universidadList.add(newcarrera);
        print(nombreuniversidad);
        guardarUniversidades(universidadList);
      }
      return universidadList;
    } else {
      print("ya descargadas la universidades tablas");
      String solicitudesJson = prefs.getString('universidades_List') ?? '';
      List<dynamic> CarreraData = jsonDecode(solicitudesJson);
      List carreraList = CarreraData.map((tutorData) =>
          Universidad.fromJson(tutorData as Map<String, dynamic>)).toList();
      return carreraList;
    }
  }

  Future guardarUniversidades(List<Universidad> carreraList) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String solicitudesJson = jsonEncode(carreraList);
    await prefs.setString('universidades_List', solicitudesJson);
    await prefs.setBool('datos_descargados_listauniversidades', true);
  }


  //Obtenemos todas las solicitudes - esto para empezar a probar a hacer estadisticas
  Future obtenerSolicitudes({Function(Solicitud)? onSolicitudAdded}) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool datosDescargados = prefs.getBool('datos_descargados_listasolicitudes') ?? false;
    if (!datosDescargados) {
      print("descagando por primera vez");
      CollectionReference referencetablassolicitud = await FirebaseFirestore.instance.collection("SOLICITUDES");
      QuerySnapshot QuerySolicitud = await referencetablassolicitud.get();
      List<Solicitud> solicitudList = [];
      for (var solicitudDoc in QuerySolicitud.docs) {
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

        print(idcotizacion);

        //Cargamos cotizaciones
        QuerySnapshot cotizacionDocs = await solicitudDoc.reference.collection("COTIZACIONES").get();
        List<Cotizacion> cotizaciones = [];
        for(var cotizacionDoc in cotizacionDocs.docs){
          int cotizacionTutor = cotizacionDoc['Cotizacion'];
          String uidtutor = cotizacionDoc['uidtutor'];
          String nombretutor = cotizacionDoc['nombretutor'];
          int tiempoconfirmacion = cotizacionDoc['Tiempo confirmacion'];
          String comentariocotizacion = cotizacionDoc['Comentario Cotización'];
          String Agenda = cotizacionDoc['Agenda'];
          DateTime fechaconfirmacion = cotizacionDoc.data().toString().contains('fechaconfirmacion') ? cotizacionDoc.get('fechaconfirmacion').toDate() : DateTime.now(); //Number

          Cotizacion newcotizacion = Cotizacion(cotizacionTutor, uidtutor, nombretutor, tiempoconfirmacion, comentariocotizacion, Agenda, fechaconfirmacion);
          cotizaciones.add(newcotizacion);
        }

        Solicitud newsolicitud = Solicitud(servicio, idcotizacion, materia, fechaentrega, resumen, infocliente, cliente, fechasistema, estado, cotizaciones,fechaactualizacion,urlarchivo,actualizarsolicitudes);
        solicitudList.add(newsolicitud);

        if (onSolicitudAdded != null) {
          onSolicitudAdded(newsolicitud);
        }

      }
      //guardar solicitudes
      guardaDatosSolicitudes(solicitudList);
      return solicitudList;
    }else{
      print("ya descargadas");
      String solicitudesJson = prefs.getString('solicitudes_list') ?? '';
      List<dynamic> CarreraData = jsonDecode(solicitudesJson);
      List solicitudList = CarreraData.map((tutorData) =>
          Solicitud.fromJson(tutorData as Map<String, dynamic>)).toList();
      return solicitudList;
    }
  }


  Future guardaDatosSolicitudes(List<Solicitud> solicitudList) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String solicitudesJson = jsonEncode(solicitudList);
    await prefs.setString('solicitudes_list', solicitudesJson);
    await prefs.setBool('datos_descargados_listasolicitudes', true);
    print("guardando solicitudes");
  }

   

  /*
//Obtener contabilidad
  Future obtenerContabilidad() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool datosDescargados = prefs.getBool('datos_descargados_listacontabilidad') ?? false;

    if (!datosDescargados) {
      print("Descargando contabilidad por primera vez");
      CollectionReference referencecontabilidad = FirebaseFirestore.instance.collection("CONTABILIDAD");
      QuerySnapshot querycontabilidad = await referencecontabilidad.get();
      List<ServicioAgendado> serviciosagendadoList = [];

      for (var contabilidadDoc in querycontabilidad.docs) {
        String codigo = contabilidadDoc['codigo'];
        String sistema = contabilidadDoc['sistema'];
        String materia = contabilidadDoc['materia'];
        DateTime fechasistema = contabilidadDoc['fechasistema'].toDate();
        String cliente = contabilidadDoc['cliente'];
        int preciocobrado = contabilidadDoc['preciocobrado'];
        DateTime fechaentrega = contabilidadDoc['fechaentrega'].toDate();
        String tutor = contabilidadDoc['tutor'];
        int preciotutor = contabilidadDoc['preciotutor'];
        String identificadorcodigo = contabilidadDoc['identificadorcodigo'];
        int idsolicitud = contabilidadDoc['idsolicitud'];
        int idcontable = contabilidadDoc['idcontable'];
        String entregado = contabilidadDoc.data().toString().contains('entregadotutor') ? contabilidadDoc.get('entregadotutor') : 'NO APLICA';

        print(idcontable);
        print(codigo);

        // Obtener pagos en primera descarga
        QuerySnapshot registroPagosDoc = await contabilidadDoc.reference.collection("PAGOS").get();
        List<RegistrarPago> pagos = [];

        for (var pagoDoc in registroPagosDoc.docs) {
          String pagoCodigo = pagoDoc['codigo'];
          String tipopago = pagoDoc['tipopago'];
          int valor = pagoDoc['valor'];
          String metodopago = pagoDoc['metodopago'];
          String referencia = pagoDoc['referencia'];
          DateTime fechapago = pagoDoc['fechapago'].toDate();
          String id = pagoDoc.data().toString().contains('id') ? pagoDoc.get('id') : 'NO ID';


          RegistrarPago newpago = RegistrarPago(pagoCodigo, tipopago, valor, referencia, fechapago, metodopago,id);
          pagos.add(newpago);
        }

        ServicioAgendado newservicioagendado = ServicioAgendado(codigo, sistema, materia, fechasistema, cliente, preciocobrado, fechaentrega, tutor, preciotutor, identificadorcodigo, idsolicitud, idcontable, pagos,entregado);
        serviciosagendadoList.add(newservicioagendado);
      }

      // Guardar los datos descargados en SharedPreferences
      guardaDatosContabilidad(serviciosagendadoList);

      return serviciosagendadoList;
    } else {
      print("Contabilidad ya descargada");
      String contabilidadJson = prefs.getString('contabilidad_list') ?? '';
      List<dynamic> ServicioAgendadoData = jsonDecode(contabilidadJson);
      List<ServicioAgendado> serviciosagendadoList = ServicioAgendadoData.map((tutorData) => ServicioAgendado.fromJson(tutorData as Map<String, dynamic>)).toList();
      return serviciosagendadoList;
    }
  }

  Future guardaDatosContabilidad(List<ServicioAgendado> servicioagendado) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String solicitudesJson = jsonEncode(servicioagendado);
    await prefs.setString('contabilidad_list', solicitudesJson);
    await prefs.setBool('datos_descargados_listacontabilidad', true);
  }

   */

  //cambios de servicios empezamos, toca pensar en como se puede realizar de mejor forma
  /*
  Future verificar_cambios() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool datosDescargados = prefs.getBool('verificacionesGeneral') ?? false;
    if(!datosDescargados) {
      //Actualización de solicitudes de servicios
      DocumentSnapshot getfecha_servicios = await FirebaseFirestore.instance.collection("ACTUALIZACION").doc('ACTUALIZADORES').get();
      DateTime fecha_servicios = getfecha_servicios.get('fecha_servicios').toDate();
      //Guardar fecha actualización servicio
      await prefs.setString("verificacionSolicitudes", fecha_servicios.toString());
      await prefs.setBool("verificacionesGeneral", true);
      Map<String, dynamic> actualizadores_fechas = {
        'fecha_local':  fecha_servicios.toUtc().toIso8601String(),
        'fecha_firebase':  fecha_servicios.toUtc().toIso8601String(),};

      return actualizadores_fechas;
    }else{
      //Verificando inicialmente las solicitudes
      String getverificacionSolicitudes = prefs.getString('verificacionSolicitudes') ?? '';
      DateTime getverificacionsolicitdlocalcon = DateTime.parse(getverificacionSolicitudes);
      DocumentSnapshot getfecha_servicios = await FirebaseFirestore.instance.collection("ACTUALIZACION").doc('ACTUALIZADORES').get();
      DateTime fecha_servicios = getfecha_servicios.get('fecha_servicios').toDate();
      print('local $getverificacionsolicitdlocalcon');
      print('firebase $fecha_servicios');
      if(fecha_servicios==getverificacionsolicitdlocalcon){
        Map<String, dynamic> actualizadores_fechas = {
          'fecha_local': getverificacionSolicitudes.toString(),
          'fecha_firebase': fecha_servicios.toUtc().toIso8601String(),
        };
        print("fechas iguales, no actualiza");
        return actualizadores_fechas;
      }else{
        //volver a descargar solicitudes, adicional retornar listas normales
        print("fechas distintas");
        await prefs.setString("verificacionSolicitudes", fecha_servicios.toString());
        //obtenerSolicitudes();
        Map<String, dynamic> actualizadores_fechas = {
          'fecha_local': fecha_servicios.toString(),
          'fecha_firebase': fecha_servicios.toString(),
        };
        return actualizadores_fechas;
      }
    }

  }

   */

  //Verificar cada cierto 30 minutos, actualización de variables entre todas las plataformas



  //Leer configuración inicial, que es la priemra que hay
  Future<Map<String, dynamic>> configuracion_inicial() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool datosDescargados = prefs.getBool('datos_descargados_configinicial') ?? false;

    if (!datosDescargados) {
      try {
        DocumentSnapshot getconfiguracioninicial = await FirebaseFirestore.instance.collection("ACTUALIZACION").doc("CONFIGURACION").get();

        if (getconfiguracioninicial.exists) {
          String primaryColor = getconfiguracioninicial.get('Primarycolor') ?? '';
          String Secundarycolor = getconfiguracioninicial.get('Secundarycolor') ?? '';
          String nombre_empresa = getconfiguracioninicial.get('nombre_empresa') ?? '';
          String idcarpetaPagos = getconfiguracioninicial.get('idcarpetaPagos') ?? '';
          String idcarpetaSolicitudes = getconfiguracioninicial.get('idcarpetaSolicitudes') ?? '';

          Map<String, dynamic> uploadconfiguracion = {
            'Primarycolor': primaryColor,
            'Secundarycolor': Secundarycolor,
            'nombre_empresa': nombre_empresa,
            'idcarpetaPagos' : idcarpetaPagos,
            'idcarpetaSolicitudes' : idcarpetaSolicitudes,
          };

          String solicitudesJson = jsonEncode(uploadconfiguracion);
          await prefs.setString('configuracion_inicial_List', solicitudesJson);
          await prefs.setBool('datos_descargados_configinicial', true);

          return uploadconfiguracion;
        } else {
          // El documento no existe, puedes devolver una lista vacía o lo que sea adecuado para tu aplicación.
          return {};
        }
      } catch (e) {
        print("Error: $e");
        return {};
      }
    } else {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String solicitudesJson = prefs.getString('configuracion_inicial_List') ?? '';
      if (solicitudesJson.isNotEmpty) {
        Map<String, dynamic> configuracion = jsonDecode(solicitudesJson);
        return configuracion;
      } else {
        return {};
      }
    }
  }

  //Leer plugins, para ver cuales estan o no estan
  Future<Map<String, dynamic>> configuracion_plugins() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool datosDescargados = prefs.getBool('datos_descargados_plugins') ?? false;
    if (!datosDescargados) {
      try {
        print("descarngado plugins");
        DocumentSnapshot getplugins = await FirebaseFirestore.instance.collection("ACTUALIZACION").doc("Plugins").get();
        if (getplugins.exists) {
          bool PagosDriveApi = getplugins.get('PagosDriveApi') ?? '';
          bool SolicitudesDriveApi = getplugins.get('SolicitudesDriveApi') ?? '';
          bool TutoresBanca = getplugins.get('TutoresBanca') ?? '';
          bool basicoNormal = getplugins.get('basicoNormal') ?? '';
          DateTime basicoFecha = getplugins.get('basicoFecha').toDate() ?? DateTime.now();
          DateTime SolicitudesDriveApiFecha = getplugins.get('SolicitudesDriveApiFecha').toDate() ?? DateTime.now();
          DateTime PagosDriveApiFecha = getplugins.get('PagosDriveApiFecha').toDate() ?? DateTime.now();
          //Guardar variable
          DateTime verificador = getplugins.get('verificadoractualizar').toDate() ?? DateTime.now();

          Map<String, dynamic> uploadconfiguracion = {
            'PagosDriveApi': PagosDriveApi,
            'SolicitudesDriveApi': SolicitudesDriveApi,
            'TutoresBanca': TutoresBanca,
            'basicoNormal' : basicoNormal,
            'basicoFecha' : basicoFecha.toIso8601String(),
            'SolicitudesDriveApiFecha' : SolicitudesDriveApiFecha.toIso8601String(),
            'PagosDriveApiFecha' : PagosDriveApiFecha.toIso8601String(),
            'verificador' : verificador.toIso8601String(),
          };

          String solicitudesJson = jsonEncode(uploadconfiguracion);
          await prefs.setString('configuracion_plugins', solicitudesJson);
          await prefs.setBool('datos_descargados_plugins', true);

          return uploadconfiguracion;
        } else {
          return {};
        }
      } catch (e) {
        print("Error: $e");
        return {};
      }
    } else {
      CollectionReference actualizacion = db.collection("ACTUALIZACION");
      DocumentSnapshot actualizacionsnapshots = await actualizacion.doc("Plugins").get();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String solicitudesJson = prefs.getString('configuracion_plugins') ?? '';
      Map<String, dynamic> servicioData = actualizacionsnapshots.data() as Map<String, dynamic>;
      if (solicitudesJson.isNotEmpty) {
        Map<String, dynamic> configuracion = jsonDecode(solicitudesJson);
        //Verificador de tiempo
        return configuracion;
      } else {
        return {};
      }
    }
  }

  //Mnesajes personalizados
  Future<Map<String, dynamic>> configuracion_mensajes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool datosDescargados = prefs.getBool('datos_descargados_config_mensajes') ?? false;

    if (!datosDescargados) {
      try {
        DocumentSnapshot getconfiguracioninicial = await FirebaseFirestore.instance.collection("ACTUALIZACION").doc("MENSAJES").get();

        if (getconfiguracioninicial.exists) {
          String msjsolicitudes = getconfiguracioninicial.get('SOLICITUD') ?? '';

          Map<String, dynamic> uploadconfiguracion = {
            'SOLICITUDES': msjsolicitudes,
          };

          String solicitudesJson = jsonEncode(uploadconfiguracion);
          await prefs.setString('configuracion_mensajes_list', solicitudesJson);
          await prefs.setBool('datos_descargados_config_mensajes', true);

          return uploadconfiguracion;
        } else {
          // El documento no existe, puedes devolver una lista vacía o lo que sea adecuado para tu aplicación.
          return {};
        }
      } catch (e) {
        print("Error: $e");
        return {};
      }
    } else {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String solicitudesJson = prefs.getString('configuracion_mensajes_list') ?? '';
      await prefs.setBool('datos_descargados_config_mensajes', false); //hAY QUE BORRAR ESTO DESPUES DE GENERAR EL CHACHEADO
      if (solicitudesJson.isNotEmpty) {
        Map<String, dynamic> configuracion = jsonDecode(solicitudesJson);
        return configuracion;
      } else {
        return {};
      }
    }
  }

  //Tutores en local
  Future getinfotutor(User currentUser) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool datosDescargados = prefs.getBool('datos_descargadios_getinfotutor') ?? false;
    if (!datosDescargados) {
      print("Datos de tutor de cero");
      DocumentSnapshot getutoradmin = await FirebaseFirestore.instance.collection("TUTORES").doc(currentUser?.uid).get();
      String nametutor = getutoradmin.get('nombre Whatsapp');
      String Correo_gmail = getutoradmin.get('Correo gmail');
      Map<String, dynamic> datos_tutor = {
        'nombre Whatsapp': nametutor,
        'Correo gmail' : Correo_gmail,
      };

      String solicitudesJson = jsonEncode(datos_tutor);
      await prefs.setString('informacion_tutor', solicitudesJson);
      await prefs.setBool('datos_descargadios_getinfotutor', true);
      return datos_tutor;
    }else{
      print("Datos de tutor cacheado");
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String solicitudesJson = prefs.getString('informacion_tutor') ?? '';
      Map<String, dynamic> datos_tutor = jsonDecode(solicitudesJson);
      return datos_tutor;
    }





  }

  Future<String> verificar_rol(User currentUser) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool datosDescargados = prefs.getBool('datos_Descargados_verificar_rol') ?? false;
    if(!datosDescargados){
      print("descargando rol de cero");
      DocumentSnapshot getutoradmin = await FirebaseFirestore.instance.collection("TUTORES").doc(currentUser?.uid).get();
      String rol = getutoradmin.get('rol') ?? '';
      await prefs.setString('rol_usuario', rol);
      await prefs.setBool('datos_Descargados_verificar_rol', true);
      return rol;
    }else{
      print("rol totalmente cacheado");
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String rol = prefs.getString('rol_usuario') ?? 'TUTOR';
      return rol;
    }

  }

  Future verificar_tiempos_Cache() async{
    Map<String, dynamic> servicioData = {};
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String solicitudesJson = prefs.getString('configuracion_plugins') ?? '';
    if (solicitudesJson.isNotEmpty) {
      Map<String, dynamic> configuracion = jsonDecode(solicitudesJson);
      //Verificador de tiempo
      DateTime verificador = configuracion['verificador'] != null
          ? DateTime.parse(configuracion['verificador'])
          : DateTime.now();
      Duration diferenciaTiempo = DateTime.now().difference(verificador);
      print("tiempo recorrido ${diferenciaTiempo.inMinutes}");
      //Reiniciar todas las variables de configuración, por si acaso
      if(diferenciaTiempo.inMinutes >= 60){
        CollectionReference actualizacion = db.collection("ACTUALIZACION");
        servicioData['verificadoractualizar'] = DateTime.now();
        await actualizacion.doc("Plugins").update(servicioData);
        //Revisar clientes

        //Revisar tablas de materias y carreras

        //Revisar solicitudes para actualización
        ActualizarInformacion().actualizarsolicitudes();
        //Revisar tutores ? Quiero los de tutores
        ActualizarInformacion().actualizartutores();
        //Revisar pagos?

        //Revisar plugins -- Licencias
        await prefs.setBool('datos_descargados_plugins', false);
        await configuracion_plugins();
        //Revisar configuración inicial

        //Revisar configuración de mensajes

        return configuracion;
      }else{
        return configuracion;
      }
    } else {
      return {};
    }
  }


}




