import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dashboard_admin_flutter/Objetos/AgendadoServicio.dart';
import 'package:dashboard_admin_flutter/Objetos/Clientes.dart';
import 'package:dashboard_admin_flutter/Objetos/Cotizaciones.dart';
import 'package:dashboard_admin_flutter/Objetos/CuentasBancaraias.dart';
import 'package:dashboard_admin_flutter/Objetos/HistorialServiciosAgendados.dart';
import 'package:dashboard_admin_flutter/Objetos/Objetos%20Auxiliares/Carreras.dart';
import 'package:dashboard_admin_flutter/Objetos/Objetos%20Auxiliares/Materias.dart';
import 'package:dashboard_admin_flutter/Objetos/Objetos%20Auxiliares/Universidad.dart';
import 'package:dashboard_admin_flutter/Objetos/Solicitud.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:googleapis/driveactivity/v2.dart' as drive;
import 'package:shared_preferences/shared_preferences.dart';
import '../../Objetos/RegistrarPago.dart';
import '../../Objetos/Tutores_objet.dart';
import '../../Pages/Contabilidad/Pagos.dart';
import 'CollectionReferences.dart';
import 'Load_Data.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';


import 'StreamBuilders.dart';

class Uploads{
  final db = FirebaseFirestore.instance; //inicializar firebase
  CollectionReferencias referencias =  CollectionReferencias();

  Uploads() {
    CollectionReferencias().initCollections();
  }


  //añadir servicio
  void addServicio (String servicio,String cotizacion,int idcotizacion,String materia, String carrera,DateTime fechaentrega, String resumen, String infocliente, int cliente,String urlarchivo) async{
  DateTime fechaactualizacion = DateTime.now();
  CollectionReference solicitud = referencias.solicitudes!;
  List<Cotizacion> cotizaciones = [];
  Solicitud newservice = Solicitud(servicio, idcotizacion, materia, fechaentrega, resumen, infocliente, cliente, DateTime.now(), "DISPONIBLE", cotizaciones,fechaactualizacion,urlarchivo,DateTime.now());
  print("subido con exito servicio $idcotizacion");
  await solicitud.doc("$idcotizacion").set(newservice.toMap());
  //Agregamos este servicio a la lista offline ya guardada
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String solicitudesJson = prefs.getString('solicitudes_list') ?? '';
  List<dynamic> CarreraData = jsonDecode(solicitudesJson);
  List solicitudList = CarreraData.map((tutorData) => Solicitud.fromJson(tutorData as Map<String, dynamic>)).toList();
  solicitudList.add(newservice);
  //Ahora guardamos la lista
  String solicitudesJsondos = jsonEncode(solicitudList);
  await prefs.setString('solicitudes_list', solicitudesJsondos);
}
  //Modificar un servicio
  Future<void> modifyServiciosolicitud(int index, String texto, DateTime dateTime, int idcotizacionfire) async {
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
        'actualizarsolicitudes': DateTime.now(),
      };
    }else{
      uploadinformacion = {
        '$variable': dateTime,
        'actualizarsolicitudes': DateTime.now(),
      };
    }

    print("Upload Información: $uploadinformacion");

    //Modificar en local la información. //Adicional se debe actualizar la variable de actualización para que no se actualice ahorita que pase
    List<Solicitud> solicitudesList = await LoadData().obtenerSolicitudes();
    Solicitud solicitudEnLista = solicitudesList.where((solicitud) => solicitud.idcotizacion == idcotizacionfire).first;
    //Seguir trabajando en esta modificación

    await solicitud.doc(idcotizacionfire.toString()).update(uploadinformacion);
  }

//añadir cotización
  Future<void> addCotizacion(int idcotizacion,int cotizacion,String uidtutor,String nombretutor,int tiempoconfirmacion, String comentariocotizacion, String Agenda, DateTime fechaconfirmacion) async {
    List<Cotizacion> cotizaciones = [];
    DocumentReference cotizacionReference = referencias.solicitudes!.doc(idcotizacion.toString());
    Cotizacion newcotizacion = Cotizacion(cotizacion, uidtutor, nombretutor, tiempoconfirmacion, comentariocotizacion, Agenda, fechaconfirmacion);
    await cotizacionReference.update({
      'cotizaciones' : FieldValue.arrayUnion([newcotizacion.toMap()]),
    });
    //cargar las solitiudes y añadir esta nueva cotización
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String solicitudesJson = prefs.getString('solicitudes_list') ?? '';
    List<dynamic> CarreraData = jsonDecode(solicitudesJson);
    List solicitudList = CarreraData.map((tutorData) =>
        Solicitud.fromJson(tutorData as Map<String, dynamic>)).toList();
    //encontrar la solicitud
    int solicitudIndex = solicitudList.indexWhere((solicitud) => solicitud.idcotizacion == idcotizacion);
    solicitudList[solicitudIndex].cotizaciones.add(newcotizacion);
    //guardar
    String solicitudesJsondos = jsonEncode(solicitudList);
    await prefs.setString('solicitudes_list', solicitudesJsondos);
  }

  //añadir servicio agendado
  Future<void> addServicioAgendado(String codigo,String sistema,String materia,String cliente,int preciocobrado,DateTime fechaentrega,String tutor,int preciotutor,String identificadorcodigo,int idsolicitud, int numerocontabilidadagenda,String entregado) async {
    DateTime fechasistema = DateTime.now();
    CollectionReference contabilidad = referencias.contabilidad!;
    List<RegistrarPago> pagos = [];
    ServicioAgendado newservicioagendado = ServicioAgendado(codigo, sistema, materia, fechasistema, cliente, preciocobrado, fechaentrega, tutor, preciotutor, identificadorcodigo,idsolicitud,numerocontabilidadagenda,pagos,entregado,"NO ENTREGADO",[]);
    await contabilidad.doc(codigo).set(newservicioagendado.toMap());
    //Llamar servicios ya agendados y guardar el nuevo
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String solicitudesJson = prefs.getString('contabilidad_list') ?? '';
    List<dynamic> ServicioAgendadoData = jsonDecode(solicitudesJson);
    List serviciosagendadoList = ServicioAgendadoData.map((tutorData) =>
        ServicioAgendado.fromJson(tutorData as Map<String, dynamic>)).toList();
    //Ahora le metemos el nuevoxxxx
    serviciosagendadoList.add(newservicioagendado);
    //Ahora guardamos la lista
    String solicitudesJsondos = jsonEncode(serviciosagendadoList);
    await prefs.setString('contabilidad_list', solicitudesJsondos);
  }

  //modificar un servicio agendado
  Future<void> modifyServicioAgendado(int index,String codigo,String texto,String textoanterior,int valores,DateTime fechas)async {
    await referencias.initCollections();
    String variable = "";
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

    String fecha = DateFormat('dd-MM-yyyy-hh:mm:ssa').format(DateTime.now());
    await contabilidad.doc(codigo).update(uploadinformacion);
    //Guardamos el historial del cambio
    HistorialAgendado newhistorial = HistorialAgendado(DateTime.now(), textoanterior, texto, variable,codigo);
    await contabilidad.doc(codigo).update({
      'historial' : FieldValue.arrayUnion([newhistorial.toMap()]),
    });
  }
  //Entregar trabajos tutores
  Future<void> modifyServicioAgendadoEntregado(String codigo)async {
    print("entregado de tutor");
    CollectionReference contabilidad = referencias.contabilidad!;
    Map<String, dynamic> uploadinformacion = {};
    uploadinformacion = {
      "entregadotutor": "ENTREGADO",
    };
    await contabilidad.doc(codigo).update(uploadinformacion);
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
  }

  void addinfotutor(String nombrewhatsapp,String nombrecompleto,int numerowhatsapp,String carrera,String correogmail,String univerisdad, uid) async{
    CollectionReference tutor = referencias.tutores!;
    List<Materia> materias = [];
    List<CuentasBancarias> cuentas = [];
    Tutores newtutor = Tutores(nombrewhatsapp, nombrecompleto, numerowhatsapp, carrera, correogmail, univerisdad, uid, materias, cuentas,true,DateTime.now(),"TUTOR");
    await tutor.doc(uid).set(newtutor.toMap());
    print("se subio un nuevo tutor");
    print(newtutor);
    //agregamos este tutor a la lista de tutores ya creada
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String solicitudesJson = prefs.getString('tutores_list') ?? '';
    List<dynamic> ClienteData = jsonDecode(solicitudesJson);
    List tutoresList = ClienteData.map((tutorData) => Tutores.fromJson(tutorData as Map<String, dynamic>)).toList();
    tutoresList.add(newtutor);
    //Ahora guardamos la lista con el nuevo tutor agregado
    String solicitudesJsonsave = jsonEncode(tutoresList);
    await prefs.setString('tutores_list', solicitudesJsonsave);
    //Ya queda subido el nuevo tutor
  }
  //Modificar infomración de tutor
  Future<void> modifyinfotutor(int index,String texto,Tutores tutor, int num) async{
    String variable = "";
    Map<String, dynamic> uploadinformacion = {};
    if(index == 1){
      variable = "nombre completo";
    }else if(index == 2){
      variable = "numero whatsapp";
    }

    if(index == 1){
      uploadinformacion = {
        '$variable': texto,
      };
    }else if(index == 2){
      uploadinformacion = {
        '$variable': num,
      };
    }

    CollectionReference tutores = referencias.tutores!;
    await tutores.doc(tutor.uid).update(uploadinformacion);

    //Modificar
    List<Tutores> tutoresList = [];
    SharedPreferences prefs = await SharedPreferences.getInstance();
    tutoresList = await LoadData().obtenertutores();
    Tutores tutorEnLista = tutoresList.where((tutore) => tutore.uid == tutor.uid).first;
    if(index == 1){
      tutorEnLista.nombrecompleto = texto;
    }else if(index == 2){
      tutorEnLista.numerowhatsapp =  num;
    }
    String updatedTutoresJson = jsonEncode(tutoresList.map((tutor) => tutor.toJson()).toList());
    prefs.setString('tutores_list', updatedTutoresJson);
  }

  //añadir cuentas
  Future<void> addCuentaBancaria(String uidtutor,String Tipocuenta, String NumeroCuenta, String NumeroCedula, String NombreCuenta) async {
    CollectionReference cuentas = referencias.tutores!;
    CuentasBancarias newcuenta = CuentasBancarias(Tipocuenta, NumeroCuenta, NumeroCedula, NombreCuenta);
    print("Subido nueva cuenta bancaria");
    await cuentas.doc(Tipocuenta).set(newcuenta.toMap());
    //Actualizar de forma local
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<Tutores> tutoresList = await LoadData().obtenertutores();
    // Encontrar al tutor
    int tutorIndex = tutoresList.indexWhere((tutor) => tutor.uid == uidtutor);
    if (tutorIndex != -1) {
      // Agregar el nuevo pago a la lista existente
      tutoresList[tutorIndex].cuentas.add(newcuenta);
      // Guardar la lista actualizada en SharedPreferences
      String solicitudesJsondos = jsonEncode(tutoresList);
      await prefs.setString('tutores_list', solicitudesJsondos);
    }
  }
  //Subir materia de tutor
  void addMateriaTutor(String uidtutor,String nombremateria,{Function(Materia)? onMateriaAdded}) async{
    CollectionReference materias = referencias.tutores!.doc(uidtutor.toString()).collection("MATERIA");
    Materia newmateria = Materia(nombremateria);
    await materias.doc(nombremateria).set(newmateria.toMap());
    //Actualizar de forma local
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<Tutores> tutoresList = await LoadData().obtenertutores();
    // Encontrar al tutor
    int tutorIndex = tutoresList.indexWhere((tutor) => tutor.uid == uidtutor);
    if (tutorIndex != -1) {
      // Agregar el nuevo pago a la lista existente
      tutoresList[tutorIndex].materias.add(newmateria);
      if (onMateriaAdded != null) {
        onMateriaAdded(newmateria);
      }
      // Guardar la lista actualizada en SharedPreferences
      String solicitudesJsondos = jsonEncode(tutoresList);
      await prefs.setString('tutores_list', solicitudesJsondos);
    }
  }
  //Añadimos cliente
  Future<void> addCliente(String carrera, String universidad, String nombreCliente, int numero,String nombrecompletoCliente) async {
    CollectionReference cliente = referencias.clientes!;
    Clientes newcliente = Clientes(carrera, universidad, nombreCliente, numero,nombrecompletoCliente,DateTime.now());
    await cliente.doc(numero.toString()).set(newcliente.toMap());
    //Obtenemos los clientes pasados, para agregar el nuevo cliente que agregamos
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String solicitudesJson = prefs.getString('clientes_list') ?? '';
    List<dynamic> ClienteData = jsonDecode(solicitudesJson);
    List clientesList = ClienteData.map((ClienteData) =>
        Clientes.fromJson(ClienteData as Map<String, dynamic>)).toList();
    //Ahora metamosle el nuevo cliente y guardemoslo
    clientesList.add(newcliente);
    String solicitudesJsonother = jsonEncode(clientesList);
    print("añadimos nuevo cliente");
    await prefs.setString('clientes_list', solicitudesJsonother);
  }
  //actualizar prospecto a cliente
  Future<void> prospectoacliente(String nombreCliente, String nombrecompletoCliente, int numero ) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    CollectionReference cliente = referencias.clientes!;
    Map<String, dynamic> datosActualizados = {
      "nombreCliente": nombreCliente,
      "nombrecompletoCliente": nombrecompletoCliente,
    };
    await cliente.doc(numero.toString()).update(datosActualizados);
    //agregar info actualizada de clientes en local
    String solicitudesJson = prefs.getString('clientes_list') ?? '';
    List<dynamic> ClienteData = jsonDecode(solicitudesJson);
    List clientesList = ClienteData.map((ClienteData) =>
        Clientes.fromJson(ClienteData as Map<String, dynamic>)).toList();

    // Actualizar la lista de clientes local con el cliente actualizado
    int indexToUpdate = clientesList.indexWhere((cliente) => cliente.numero == numero);
    if (indexToUpdate != -1) {
      clientesList[indexToUpdate].nombreCliente = nombreCliente;
      clientesList[indexToUpdate].nombrecompletoCliente = nombrecompletoCliente;
    }
    String clientesJson = jsonEncode(clientesList);
    await prefs.setString('clientes_list', clientesJson);
  }
  //Registramos un nuevo pago a servicio
  Future<void> addPago(int idconfirmacion, ServicioAgendado servicio, String tipopago, int valor, String referencia, DateTime fechapago, String metodopago, BuildContext context) async {
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
      });
    }else if(tipopago == "REEMBOLSOTUTOR"){
      int nuevosaldocliente = servicio.preciotutor - valor;
      await pagoReference.update({
        'pagos': FieldValue.arrayUnion([newpago.toMap()]),
        'preciotutor' : nuevosaldocliente,
      });
    }else{
      await pagoReference.update({
        'pagos': FieldValue.arrayUnion([newpago.toMap()]),
      });
    }
  }
  Future<int> obtenerNumeroDePagosRegistrados(int idcontable) async {
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

  }
  //Agregar carrera a tabla
  Future<void> addCarrera(String nombrecarrera) async {
    CollectionReference carreraCollection = referencias.tablascarreras!;
    Carrera newcarrera = Carrera(nombrecarrera);
    await carreraCollection.doc(nombrecarrera).set(newcarrera.toMap());
    //Obtenemos tablas de carreras agregadas
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String solicitudesJson = prefs.getString('carreras_List') ?? '';
    List<dynamic> CarreraData = jsonDecode(solicitudesJson);
    List carreraList = CarreraData.map((tutorData) =>
        Carrera.fromJson(tutorData as Map<String, dynamic>)).toList();
    carreraList.add(newcarrera);
    //guardar carreras
    String solicitudesJsondos = jsonEncode(carreraList);
    await prefs.setString('carreras_List', solicitudesJsondos);
  }
  //Agregar unversidad a tabla
  Future<void> addUniversidad(String nombreuniversidad) async {
    CollectionReference universidadCollection = referencias.tablasuniversidades!;
    Universidad newuniversidad = Universidad(nombreuniversidad);
    await universidadCollection.doc(nombreuniversidad).set(newuniversidad.toMap());
    //Obtenemos tablas de carreras agregadas
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String solicitudesJson = prefs.getString('universidades_List') ?? '';
    List<dynamic> CarreraData = jsonDecode(solicitudesJson);
    List carreraList = CarreraData.map((tutorData) =>
        Universidad.fromJson(tutorData as Map<String, dynamic>)).toList();
    carreraList.add(newuniversidad);
    //guardar carreras
    String solicitudesJsondos = jsonEncode(carreraList);
    await prefs.setString('universidades_List', solicitudesJsondos);
  }
  //Envíar configuración inicial
  Future<void> uploadconfiginicial(String Primarycolor,String Secundarycolor,String nombre_empresa,String idcarpetaPagos,String idcarpetaSol) async{
    await referencias.initCollections();
    CollectionReference actualizadores = referencias.configuracion!;
    Map<String, dynamic> uploadconfiguracion = {
      'Primarycolor':  Primarycolor,
      'Secundarycolor':  Secundarycolor,
      'nombre_empresa':  nombre_empresa,
      'idcarpetaPagos' : idcarpetaPagos,
      'idcarpetaSolicitudes' : idcarpetaSol,
    };
    await actualizadores.doc("CONFIGURACION").set(uploadconfiguracion);
    //Ahora, como es la primera vez, toca guardar de forma local
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String solicitudesJson = jsonEncode(uploadconfiguracion);
    await prefs.setString('configuracion_inicial_List', solicitudesJson);
    await prefs.setBool('datos_descargados_configinicial', true);
  }
  //uploadmsgs
  Future<void> uploadconfigmensaje(String text, String s) async{
    await referencias.initCollections();
    CollectionReference actualizadores = referencias.configuracion!;
    Map<String, dynamic> uploadconfiguracion = {
      '$s':  text,
    };
    await actualizadores.doc("MENSAJES").update(uploadconfiguracion);
  }
  Future<void> uploadconfigmensajeinicial(String mensajeconfirmacion,String mensajesolicitud) async {
    await referencias.initCollections();
    CollectionReference actualizadores = referencias.configuracion!;
    Map<String, dynamic> uploadconfiguracion = {
      'CONFIRMACION_CLIENTE':  mensajeconfirmacion,
      'SOLICITUD' : mensajesolicitud,
    };
    await actualizadores.doc("MENSAJES").set(uploadconfiguracion);
  }





}

