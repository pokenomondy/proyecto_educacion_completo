import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dashboard_admin_flutter/Objetos/AgendadoServicio.dart';
import 'package:dashboard_admin_flutter/Objetos/Clientes.dart';
import 'package:dashboard_admin_flutter/Objetos/Cotizaciones.dart';
import 'package:dashboard_admin_flutter/Objetos/Objetos%20Auxiliares/CuentasBancaraias.dart';
import 'package:dashboard_admin_flutter/Objetos/Objetos%20Auxiliares/HistorialServiciosAgendados.dart';
import 'package:dashboard_admin_flutter/Objetos/Objetos%20Auxiliares/Carreras.dart';
import 'package:dashboard_admin_flutter/Objetos/Objetos%20Auxiliares/Materias.dart';
import 'package:dashboard_admin_flutter/Objetos/Objetos%20Auxiliares/Universidad.dart';
import 'package:dashboard_admin_flutter/Objetos/Solicitud.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:googleapis/driveactivity/v2.dart' as drive;
import 'package:shared_preferences/shared_preferences.dart';
import '../../Objetos/RegistrarPago.dart';
import '../../Objetos/Tutores_objet.dart';
import '../../Pages/Contabilidad/Pagos.dart';
import '../../Pages/Tutores.dart';
import '../../Providers/Providers.dart';
import '../Utiles/FuncionesUtiles.dart';
import 'CollectionReferences.dart';
import 'Load_Data.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';


import 'StreamBuilders.dart';

class Uploads{
  CollectionReferencias referencias =  CollectionReferencias();
  int timestamphoy = DateTime.now().millisecondsSinceEpoch ~/ 1000;

  Uploads() {
    _initialize();
  }

  Future<void> _initialize() async {
    await referencias.initCollections();
  }

  //SOLICITUDES
  //añadir servicio
  void addServicio (String servicio,String cotizacion,int idcotizacion,String materia, String carrera,DateTime fechaentrega, String resumen, String infocliente, int cliente,String urlarchivo) async{
  await referencias.initCollections();
  DateTime fechaactualizacion = DateTime.now();
  CollectionReference solicitud = referencias.solicitudes!;
  List<Cotizacion> cotizaciones = [];
  Solicitud newservice = Solicitud(servicio, idcotizacion, materia, fechaentrega, resumen, infocliente, cliente, DateTime.now(), "DISPONIBLE", cotizaciones,fechaactualizacion,urlarchivo,DateTime.now(),timestamphoy);
  print("subido con exito servicio $idcotizacion");
  await stream_builders().estadisticasEscrituraFirestore(1);
  await solicitud.doc("$idcotizacion").set(newservice.toMap());
}
  //Modificar un servicio
  Future<void> modifyServiciosolicitud(int index, String texto, DateTime dateTime, int idcotizacionfire) async {
    await referencias.initCollections();
    String variable = "";
    Map<String, dynamic> uploadinformacion = {};
    if (index == 0) {
      variable = "Servicio";
    } else if (index == 2) {
      variable = "materia";
    } else if (index == 3) {
      variable = "fechaentrega";
    } else if (index == 7) {
      variable = "resumen";
    } else if (index == 8) {
      variable = "infocliente";
    }

    CollectionReference solicitud = referencias.solicitudes!;
    if(index!=3){
      uploadinformacion = {
        '$variable': texto,
        'ultimaModificacion' : timestamphoy,
      };
    }else{
      uploadinformacion = {
        '$variable': dateTime,
        'ultimaModificacion' : timestamphoy,
      };
    }

    print("Upload Información: $uploadinformacion");
    await stream_builders().estadisticasEscrituraFirestore(1);
    await solicitud.doc(idcotizacionfire.toString()).update(uploadinformacion);
  }
  //añadir cotización
  Future<void> addCotizacion(int idcotizacion,int cotizacion,String uidtutor,String nombretutor,int tiempoconfirmacion, String comentariocotizacion, String Agenda, DateTime fechaconfirmacion) async {
    await referencias.initCollections();
    List<Cotizacion> cotizaciones = [];
    DocumentReference cotizacionReference = referencias.solicitudes!.doc(idcotizacion.toString());
    Cotizacion newcotizacion = Cotizacion(cotizacion, uidtutor, nombretutor, tiempoconfirmacion, comentariocotizacion, Agenda, fechaconfirmacion);
    await cotizacionReference.update({
      'cotizaciones' : FieldValue.arrayUnion([newcotizacion.toMap()]),
      'ultimaModificacion' : timestamphoy,
    });
    await stream_builders().estadisticasEscrituraFirestore(1);
  }

  //SERVICIOS AGENDADOS
  //añadir servicio agendado
  Future<void> addServicioAgendado(String codigo,String sistema,String materia,String cliente,int preciocobrado,DateTime fechaentrega,String tutor,int preciotutor,String identificadorcodigo,int idsolicitud, int numerocontabilidadagenda,String entregado) async {
    print("el codigo es $codigo");
    await referencias.initCollections();
    DateTime fechasistema = DateTime.now();
    CollectionReference contabilidad = referencias.contabilidad!;
    List<RegistrarPago> pagos = [];
    ServicioAgendado newservicioagendado = ServicioAgendado(codigo, sistema, materia, fechasistema, cliente, preciocobrado, fechaentrega, tutor, preciotutor, identificadorcodigo,idsolicitud,numerocontabilidadagenda,pagos,entregado,"NO ENTREGADO",[],timestamphoy,"");
    await contabilidad.doc(codigo).set(newservicioagendado.toMap());
    await stream_builders().estadisticasEscrituraFirestore(1);

    cambiarEstadoSolicitud(idsolicitud,"AGENDADO");
  }
  //Cambiar estado de servicio, a agendado
  Future<void> cambiarEstadoSolicitud(int idsolicitud,String motivo) async{
    await referencias.initCollections();
    CollectionReference expiradoglobal = referencias.solicitudes!;
    Map<String, dynamic> dataAgendado = {
      'Estado': motivo,
      'ultimaModificacion' : timestamphoy,
    };
    await expiradoglobal.doc(idsolicitud.toString()).update(dataAgendado);
    await stream_builders().estadisticasEscrituraFirestore(1);
  }
  //modificar un servicio agendado
  Future<void> modifyServicioAgendado(int index,String codigo,String texto,String textoanterior,int valores,DateTime fechas)async {
    await referencias.initCollections();
    String variable = "";
    String fecha = "";
    CollectionReference contabilidad = referencias.contabilidad!;
    Map<String, dynamic> uploadinformacion = {};
    if(index == 1){
      variable = "materia";
    }else if(index == 4){
      variable = "preciocobrado";
    }else if(index == 7){
      variable = "preciotutor";
    }else if(index == 8){
      variable = "identificadorcodigo";
    }else if(index == 5){
      variable = "fechaentrega";
      texto = DateFormat('dd-MM-yyyy-hh:mm:ssa').format(fechas);
    }else if(index == 6){
      variable = "tutor";
    }

    if(index==4 || index==7){
      uploadinformacion = {
        "$variable": valores,
      };
    }else if(index == 5){
      uploadinformacion = {
        "$variable": fechas,
      };
    }else{
      uploadinformacion = {
        "$variable": "$texto",
      };
    }

    await contabilidad.doc(codigo).update(uploadinformacion);
    //Guardamos el historial del cambio
    HistorialAgendado newhistorial = HistorialAgendado(DateTime.now(), textoanterior, texto, variable,codigo);
    await contabilidad.doc(codigo).update({
      'historial' : FieldValue.arrayUnion([newhistorial.toMap()]),
      'ultimaModificacion' : DateTime.now().millisecondsSinceEpoch ~/ 1000,
    });
    await stream_builders().estadisticasEscrituraFirestore(1);
  }

  //Entregar trabajos tutores
  Future<void> modifyServicioAgendadoEntregado(String codigo,String linkCarpeta)async {
    await referencias.initCollections();
    CollectionReference contabilidad = referencias.contabilidad!;
    Map<String, dynamic> uploadinformacion = {};
    uploadinformacion = {
      "entregadotutor": "ENTREGADO",
      'ultimaModificacion' : timestamphoy,
      'linkEntregaTutor' : linkCarpeta,
    };
    await contabilidad.doc(codigo).update(uploadinformacion);
    await stream_builders().estadisticasEscrituraFirestore(1);
  }
  //Entregar trabajos clientes
  Future<void> modifyServicioAgendadoEntregadoCliente(String codigo,String motivoentrega)async {
    await referencias.initCollections();
    String motivoentregaFirestore = "";
    if(motivoentrega == "CLIENTE"){
      motivoentregaFirestore = "ENTREGADO";
    }else if(motivoentrega == "NOENTREGAR"){
      motivoentregaFirestore = "NO ALMACENADO";
    }
    print("entregado de Cliente");
    CollectionReference contabilidad = referencias.contabilidad!;
    Map<String, dynamic> uploadinformacion = {};
    uploadinformacion = {
      "entregadocliente": motivoentregaFirestore,
    };
    await contabilidad.doc(codigo).update(uploadinformacion);
    await stream_builders().estadisticasEscrituraFirestore(1);
  }

  Future addinfotutor(String nombrewhatsapp,String nombrecompleto,int numerowhatsapp,String carrera,String correogmail,String univerisdad, uid) async{
    await referencias.initCollections();
    CollectionReference tutor = referencias.tutores!;
    List<Materia> materias = [];
    List<CuentasBancarias> cuentas = [];
    Tutores newtutor = Tutores(nombrewhatsapp, nombrecompleto, numerowhatsapp, carrera, correogmail, univerisdad, uid, materias, cuentas,true,DateTime.now(),"TUTOR",DateTime.now().millisecondsSinceEpoch ~/ 1000);
    await tutor.doc(uid).set(newtutor.toMap());
    await stream_builders().estadisticasEscrituraFirestore(1);
  }

  //Modificar infomración de tutor
  Future<void> modifyinfotutor(int index,String texto,String uid, int num, BuildContext context) async{
    await referencias.initCollections();
    String variable = "";
    bool activo = false;
    Map<String, dynamic> uploadinformacion = {};
    if(index == 1){
      variable = "nombre completo";
    }else if(index == 2){
      variable = "numero whatsapp";
    }else if(index == 3){
      variable = "carrera";
    }else if(index == 5){
      variable = "Universidad";
    }else if(index == 6){
      variable = "activo";
      activo = Utiles().textoToBool(texto);
    }

    if(index == 1 || index == 3 || index == 5){
      uploadinformacion = {
        '$variable': texto,
        'ultimaModificacion' : DateTime.now().millisecondsSinceEpoch ~/ 1000,
      };
    }else if(index == 2){
      uploadinformacion = {
        '$variable': num,
        'ultimaModificacion' : DateTime.now().millisecondsSinceEpoch ~/ 1000,
      };
    }else if(index == 6){
      uploadinformacion = {
        '$variable' : activo,
        'ultimaModificacion' : DateTime.now().millisecondsSinceEpoch ~/ 1000,
      };
    }

    CollectionReference tutores = referencias.tutores!;
    await tutores.doc(uid).update(uploadinformacion);
    await stream_builders().estadisticasEscrituraFirestore(1);
  }
  //añadir cuentas
  Future<void> addCuentaBancaria(String uidtutor,String Tipocuenta, String NumeroCuenta, String NumeroCedula, String NombreCuenta) async {
    await referencias.initCollections();
    DocumentReference cuentas = referencias.tutores!.doc(uidtutor.toString())!;
    CuentasBancarias newcuenta = CuentasBancarias(Tipocuenta, NumeroCuenta, NumeroCedula, NombreCuenta);
    await cuentas.update({
      'cuentas' :FieldValue.arrayUnion([newcuenta.toMap()]),
      'ultimaModificacion' : timestamphoy,
    });
    await stream_builders().estadisticasEscrituraFirestore(1);
  }
  //Subir materia de tutor
  void addMateriaTutor(String uidtutor,String nombremateria,{Function(Materia)? onMateriaAdded}) async{
    await referencias.initCollections();
    DocumentReference materias = referencias.tutores!.doc(uidtutor.toString());
    Materia newmateria = Materia(nombremateria,DateTime.now().millisecondsSinceEpoch ~/ 1000);
    await materias.update({
      'materias' : FieldValue.arrayUnion([newmateria.toMap()]),
      'ultimaModificacion' : timestamphoy,
    });
    await stream_builders().estadisticasEscrituraFirestore(1);
  }
  //CLIENTES
  //Añadimos cliente
  Future<void> addCliente(String carrera, String universidad, String nombreCliente, int numero,String nombrecompletoCliente,String procedencia) async {
    await referencias.initCollections();
    CollectionReference cliente = referencias.clientes!;
    Clientes newcliente = Clientes(carrera, universidad, nombreCliente, numero,nombrecompletoCliente,DateTime.now(),procedencia,DateTime.now(),DateTime.now().millisecondsSinceEpoch ~/ 1000);
    await cliente.doc(numero.toString()).set(newcliente.toMap());
    await stream_builders().estadisticasEscrituraFirestore(1);
  }
  //Modificaar cliente
  Future<void> modifyCliente(int index,String numerocliente,String cambio)async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await referencias.initCollections();
    CollectionReference refcliente = referencias.clientes!;
    Map<String, dynamic> uploadinformacion = {};
    String variable = "";
    if(index ==0){
      variable = 'Carrera';
    }else if(index==1){
      variable = 'Universidadd';
    }else if(index==4){
      variable = 'nombrecompletoCliente';
    }

    uploadinformacion = {
      "$variable": "$cambio",
    };

    await refcliente.doc(numerocliente).update(uploadinformacion);
    await stream_builders().estadisticasEscrituraFirestore(1);

  }

  //actualizar prospecto a cliente
  Future<void> prospectoacliente(String nombreCliente, String nombrecompletoCliente, int numero ) async {
    await referencias.initCollections();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    CollectionReference cliente = referencias.clientes!;
    Map<String, dynamic> datosActualizados = {
      "nombreCliente": nombreCliente,
      "nombrecompletoCliente": nombrecompletoCliente,
      'ultimaModificacion' : timestamphoy,
    };
    await cliente.doc(numero.toString()).update(datosActualizados);
    await stream_builders().estadisticasEscrituraFirestore(1);

  }
  //Registramos un nuevo pago a servicio
  Future<void> addPago(int idconfirmacion, ServicioAgendado servicio, String tipopago, int valor, String referencia, DateTime fechapago, String metodopago, BuildContext context) async {
    await referencias.initCollections();
    List<RegistrarPago> pagos = [];
    int numeropagosregistrados = await obtenerNumeroDePagosRegistrados(idconfirmacion);
    DocumentReference pagoReference = referencias.contabilidad!.doc(servicio.codigo);;
    RegistrarPago newpago = RegistrarPago(servicio.codigo, tipopago, valor, referencia, fechapago, metodopago, "$numeropagosregistrados-$referencia",DateTime.now());
    // Actualizar la lista de pagos en el documento del servicio agendado
    if(tipopago == "REEMBOLSOCLIENTE"){
      int nuevosaldocliente = servicio.preciocobrado - valor;
      await pagoReference.update({
        'pagos': FieldValue.arrayUnion([newpago.toMap()]),
        'preciocobrado' : nuevosaldocliente,
        'ultimaModificacion' : DateTime.now().millisecondsSinceEpoch ~/ 1000,
      });
    }else if(tipopago == "REEMBOLSOTUTOR"){
      int nuevosaldocliente = servicio.preciotutor - valor;
      await pagoReference.update({
        'pagos': FieldValue.arrayUnion([newpago.toMap()]),
        'preciotutor' : nuevosaldocliente,
        'ultimaModificacion' : DateTime.now().millisecondsSinceEpoch ~/ 1000,
      });
    }else{
      await pagoReference.update({
        'pagos': FieldValue.arrayUnion([newpago.toMap()]),
        'ultimaModificacion' : DateTime.now().millisecondsSinceEpoch ~/ 1000,
      });
    }
    await stream_builders().estadisticasEscrituraFirestore(1);
  }

  Future<int> obtenerNumeroDePagosRegistrados(int idcontable) async {
    await referencias.initCollections();
    List<ServicioAgendado>? serviciosAgendados = await stream_builders().cargarserviciosagendados();

    // Verifica si serviciosAgendados no es nulo y no está vacío
    if (serviciosAgendados != null && serviciosAgendados.isNotEmpty) {
      // Filtra los servicios agendados para encontrar el que coincide con el idConfirmacion
      ServicioAgendado servicioEncontrado = serviciosAgendados.firstWhere(
            (servicio) => servicio.idcontable == idcontable,
        orElse: () => ServicioAgendado.empty(), // O utiliza otro constructor o inicialización
      );

      // Obtén la cantidad de pagos y suma 1
      int numeroDePagos = servicioEncontrado.pagos.length;
      return numeroDePagos + 1;
    }

    // Si no hay servicios agendados, retorna 1 como número inicial
    return 1;
  }
  //Modificar servicio cancelado en base de datos y forma local
  Future<void> modificarcancelado(int idcotizacion,int preciocobrado,int preciotutor) async {
    await referencias.initCollections();
    CollectionReference solicitud = referencias.contabilidad!;
    DocumentSnapshot serviciosnapshot = await solicitud.doc(idcotizacion.toString()).get();
    Map<String, dynamic> servicioData = serviciosnapshot.data() as Map<String, dynamic>;

    //Actualizar precios
    servicioData['preciocobrado'] = preciocobrado;
    servicioData['preciotutor'] = preciotutor;

    await solicitud.doc(idcotizacion.toString()).update(servicioData);

    //Actualizar la lista en tiempo real, de lo que se hace
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String solicitudesJson = prefs.getString('contabilidad_list') ?? '';
    List<dynamic> solicitudListData = jsonDecode(solicitudesJson);

    // Buscar y actualizar la solicitud correspondiente en la lista
    for (int i = 0; i < solicitudListData.length; i++) {
      Map<String, dynamic> solicitudMap = solicitudListData[i] as Map<String, dynamic>;
      if (solicitudMap['idcontable'] == idcotizacion) {
        print("entramos = ${solicitudMap['idcontable']}");
        solicitudMap['preciotutor'] = preciotutor;
        solicitudMap['preciocobrado'] = preciocobrado;
        solicitudListData[i] = solicitudMap;
        break;
      }
    }

    // Guardar la lista actualizada
    String solicitudesJsondos = jsonEncode(solicitudListData);
    await prefs.setString('contabilidad_list', solicitudesJsondos);
    await stream_builders().estadisticasEscrituraFirestore(1);

  }
  //Agregar carrera a tabla
  Future<void> addCarrera(String nombrecarrera) async {
    await referencias.initCollections();
    CollectionReference carreraCollection = referencias.tablascarreras!;
    Carrera newcarrera = Carrera(nombrecarrera,DateTime.now().millisecondsSinceEpoch ~/ 1000);
    await carreraCollection.doc(nombrecarrera).set(newcarrera.toMap());
    await stream_builders().estadisticasEscrituraFirestore(1);
  }
  //Agregar unversidad a tabla
  Future<void> addUniversidad(String nombreuniversidad) async {
    await referencias.initCollections();
    CollectionReference universidadCollection = referencias.tablasuniversidades!;
    Universidad newuniversidad = Universidad(nombreuniversidad,DateTime.now().millisecondsSinceEpoch ~/ 1000);
    await universidadCollection.doc(nombreuniversidad).set(newuniversidad.toMap());
    await stream_builders().estadisticasEscrituraFirestore(1);
  }
  //Envíar configuración inicial
  Future<void> addconfiginicial(String Primarycolor,String Secundarycolor,String nombre_empresa,String idcarpetaPagos,String idcarpetaSol,String confirmacion, String solicitud) async{
    await referencias.initCollections();
    CollectionReference actualizadores = referencias.configuracion!;
    Map<String, dynamic> uploadConfiguracion = {
      'Primarycolor':  Primarycolor,
      'Secundarycolor':  Secundarycolor,
      'nombre_empresa':  nombre_empresa,
      'idcarpetaPagos' : idcarpetaPagos,
      'idcarpetaSolicitudes' : idcarpetaSol,
    };
    Map<String, dynamic> uploadMensajes = {
      'CONFIRMACION_CLIENTE':  confirmacion,
      'SOLICITUD':  solicitud,
    };

    print("condiguración subida, se esccuha?, parece que no");

    await actualizadores.doc("CONFIGURACION").set(uploadConfiguracion);
    await actualizadores.doc("MENSAJES").set(uploadMensajes);
    //mensajes
    await stream_builders().estadisticasEscrituraFirestore(1);
  }
  //actualizar color
  Future<void> modifyColors(int index,String color) async{
    await referencias.initCollections();
    CollectionReference actualizadores = referencias.configuracion!;
    String variable = "";

    if(index==0){
      variable = "Primarycolor";
    }else if(index==1){
      variable = "Secundarycolor";
    }

    Map<String, dynamic> uploadinformacion = {
      '$variable': color,
    };

    await actualizadores.doc("CONFIGURACION").update(uploadinformacion);
    await stream_builders().estadisticasEscrituraFirestore(1);

  }
  //actualizar mensajes
  Future<void> modifyMensajes(int index,String mensaje) async{
    await referencias.initCollections();
    CollectionReference actualizadores = referencias.configuracion!;
    String variable = "";

    if(index==0){
      variable = "SOLICITUD";
    }else if(index==1){
      variable = "CONFIRMACION_CLIENTE";
    }

    Map<String, dynamic> uploadinformacion = {
      '$variable': mensaje,
    };

      await actualizadores.doc("MENSAJES").update(uploadinformacion);
    await stream_builders().estadisticasEscrituraFirestore(1);

  }




  //uploadmsgs
  Future<void> uploadconfigmensaje(String text, String s) async{
    await referencias.initCollections();
    CollectionReference actualizadores = referencias.configuracion!;
    Map<String, dynamic> uploadconfiguracion = {
      '$s':  text,
    };
    await actualizadores.doc("MENSAJES").update(uploadconfiguracion);
    await stream_builders().estadisticasEscrituraFirestore(1);
  }
  Future<void> uploadconfigmensajes(String mensajeconfirmacion,String mensajesolicitud) async {
    await referencias.initCollections();
    CollectionReference actualizadores = referencias.configuracion!;
    Map<String, dynamic> uploadconfiguracion = {
      'CONFIRMACION_CLIENTE':  mensajeconfirmacion,
      'SOLICITUD' : mensajesolicitud,
    };
    await actualizadores.doc("MENSAJES").set(uploadconfiguracion);
    await stream_builders().estadisticasEscrituraFirestore(1);
  }






  Future<void> addnewmateria(String nombremateria) async{
    await referencias.initCollections();
    CollectionReference referencemateria = referencias.tablasmaterias!;
    Materia newmateria = Materia(nombremateria,DateTime.now().millisecondsSinceEpoch ~/ 1000);
    await referencemateria.doc(nombremateria).set(newmateria.toMap());
    await stream_builders().estadisticasEscrituraFirestore(1);
  }




}

