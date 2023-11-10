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
import 'package:googleapis/driveactivity/v2.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Objetos/RegistrarPago.dart';
import '../../Objetos/Tutores_objet.dart';
import 'Load_Data.dart';
import 'package:intl/intl.dart';

class Uploads{
  final db = FirebaseFirestore.instance; //inicializar firebase

  //añadir servicio
  void addServicio (String servicio,String cotizacion,int idcotizacion,String materia, String carrera,DateTime fechaentrega, String resumen, String infocliente, int cliente,String urlarchivo) async{
  //Actualizador revisar
  db.collection("ACTUALIZACION").doc("ACTUALIZADORES").update({'fecha_servicios': DateTime.now()});
  DateTime fechaactualizacion = DateTime.now();
  //  
  CollectionReference solicitud = db.collection('SOLICITUDES');
  List<Cotizacion> cotizaciones = [];
  Solicitud newservice = Solicitud(servicio, idcotizacion, materia, fechaentrega, resumen, infocliente, cliente, DateTime.now(), "DISPONIBLE", cotizaciones,fechaactualizacion,urlarchivo,DateTime.now());
  print("subido con exito servicio $idcotizacion");
  await solicitud.doc("$idcotizacion").set(newservice.toMap());
  //Agregamos este servicio a la lista offline ya guardada
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String solicitudesJson = prefs.getString('solicitudes_list') ?? '';
  List<dynamic> CarreraData = jsonDecode(solicitudesJson);
  List solicitudList = CarreraData.map((tutorData) =>
      Solicitud.fromJson(tutorData as Map<String, dynamic>)).toList();
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

    CollectionReference solicitud = db.collection('SOLICITUDES');
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
    CollectionReference cotizacionadd = db.collection('SOLICITUDES').doc(idcotizacion.toString()).collection("COTIZACIONES");
    Cotizacion newcotizacion = Cotizacion(cotizacion, uidtutor, nombretutor, tiempoconfirmacion, comentariocotizacion, Agenda, fechaconfirmacion);
    await cotizacionadd.doc(uidtutor).set(newcotizacion.toMap());
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
    CollectionReference contabilidad = db.collection('CONTABILIDAD');
    List<RegistrarPago> pagos = [];
    ServicioAgendado newservicioagendado = ServicioAgendado(codigo, sistema, materia, fechasistema, cliente, preciocobrado, fechaentrega, tutor, preciotutor, identificadorcodigo,idsolicitud,numerocontabilidadagenda,pagos,entregado,"NO ENTREGADO");
    await contabilidad.doc(codigo).set(newservicioagendado.toMap());
    //Llamar servicios ya agendados y guardar el nuevo
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String solicitudesJson = prefs.getString('contabilidad_list') ?? '';
    List<dynamic> ServicioAgendadoData = jsonDecode(solicitudesJson);
    List serviciosagendadoList = ServicioAgendadoData.map((tutorData) =>
        ServicioAgendado.fromJson(tutorData as Map<String, dynamic>)).toList();
    //Ahora le metemos el nuevo
    serviciosagendadoList.add(newservicioagendado);
    //Ahora guardamos la lista
    String solicitudesJsondos = jsonEncode(serviciosagendadoList);
    await prefs.setString('contabilidad_list', solicitudesJsondos);
  }

  //modificar un servicio agendado
  Future<void> modifyServicioAgendado(int index,String codigo,String texto,String textoanterior,int valores,DateTime fechas)async {
    String variable = "";
    CollectionReference contabilidad = db.collection("CONTABILIDAD");
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
    HistorialAgendado newhistorial = HistorialAgendado(DateTime.now(), textoanterior, texto, variable);
    CollectionReference refhistorial = db.collection("CONTABILIDAD").doc(codigo).collection("HISTORIAL");
    await refhistorial.doc(fecha).set(newhistorial.toMap());
  }
  //Entregar trabajos tutores
  Future<void> modifyServicioAgendadoEntregado(String codigo)async {
    print("entregado de tutor");
    CollectionReference contabilidad = db.collection("CONTABILIDAD");
    Map<String, dynamic> uploadinformacion = {};
    uploadinformacion = {
      "entregadotutor": "ENTREGADO",
    };
    await contabilidad.doc(codigo).update(uploadinformacion);
  }
  //Entregar trabajos clientes
  Future<void> modifyServicioAgendadoEntregadoCliente(String codigo)async {
    print("entregado de Cliente");
    CollectionReference contabilidad = db.collection("CONTABILIDAD");
    Map<String, dynamic> uploadinformacion = {};
    uploadinformacion = {
      "entregadocliente": "ENTREGADO",
    };
    await contabilidad.doc(codigo).update(uploadinformacion);
  }

  void addinfotutor(String nombrewhatsapp,String nombrecompleto,int numerowhatsapp,String carrera,String correogmail,String univerisdad, uid) async{
    CollectionReference tutor = db.collection("TUTORES");
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

    CollectionReference tutores = db.collection('TUTORES');
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
    CollectionReference cuentas = db.collection("TUTORES").doc(uidtutor.toString()).collection("CUENTAS");
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
    CollectionReference materias = db.collection("TUTORES").doc(uidtutor.toString()).collection("MATERIA");
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
    CollectionReference cliente = db.collection("CLIENTES");
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
    CollectionReference cliente = db.collection("CLIENTES");
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
  Future<void> addPago(int idconfirmacion, String codigo, String tipopago, int valor, String referencia, DateTime fechapago, String metodopago) async {
    List<RegistrarPago> pagoaregistrar = [];
    int numeropagosregistrados = await obtenerNumeroDePagosRegistrados(idconfirmacion);
    CollectionReference pago = db.collection("CONTABILIDAD").doc(codigo).collection("PAGOS");
    RegistrarPago newpago = RegistrarPago(codigo, tipopago, valor, referencia, fechapago, metodopago, "$numeropagosregistrados-$referencia");
    pagoaregistrar.add(newpago);
    await pago.doc("$numeropagosregistrados-$referencia").set(newpago.toMap());

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String solicitudesJson = prefs.getString('contabilidad_list') ?? '';
    List<dynamic> ServicioAgendadoData = jsonDecode(solicitudesJson);
    List serviciosagendadoList = ServicioAgendadoData.map((tutorData) =>
        ServicioAgendado.fromJson(tutorData as Map<String, dynamic>)).toList();

    // Encontrar la solicitud
    int solicitudIndex = serviciosagendadoList.indexWhere((solicitud) => solicitud.codigo == codigo);

    if (solicitudIndex != -1) {
      // Agregar el nuevo pago a la lista existente
      serviciosagendadoList[solicitudIndex].pagos.add(newpago);

      // Guardar la lista actualizada en SharedPreferences
      String solicitudesJsondos = jsonEncode(serviciosagendadoList);
      await prefs.setString('contabilidad_list', solicitudesJsondos);
    }
  }
  Future<int> obtenerNumeroDePagosRegistrados(int idConfirmacion) async {
    CollectionReference pagosCollection = db.collection("CONTABILIDAD").doc(idConfirmacion.toString()).collection("PAGOS");
    QuerySnapshot querySnapshot = await pagosCollection.get();
    // Obtén la cantidad de documentos en la colección de pagos
    int numeroDePagos = querySnapshot.size;
    return numeroDePagos + 1;
  }
  //Modificar servicio cancelado en base de datos y forma local
  Future<void> modificarcancelado(int idcotizacion,int preciocobrado,int preciotutor) async {
    CollectionReference solicitud = db.collection("CONTABILIDAD");
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
    CollectionReference carreraCollection = db.collection("TABLAS").doc("TABLAS").collection("CARRERAS");
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
    CollectionReference universidadCollection = db.collection("TABLAS").doc("TABLAS").collection("UNIVERSIDADES");
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
  Future<void> uploadconfiginicial(String Primarycolor,String Secundarycolor,String nombre_empresa) async{
    CollectionReference actualizadores = db.collection("ACTUALIZACION");
    Map<String, dynamic> uploadconfiguracion = {
      'Primarycolor':  Primarycolor,
      'Secundarycolor':  Secundarycolor,
      'nombre_empresa':  nombre_empresa,
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
    CollectionReference actualizadores = db.collection("ACTUALIZACION");
    Map<String, dynamic> uploadconfiguracion = {
      '$s':  text,
    };
    await actualizadores.doc("MENSAJES").update(uploadconfiguracion);
  }





}

