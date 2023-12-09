import 'dart:html';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:googleapis/driveactivity/v2.dart';
import '../Utils/Firebase/Load_Data.dart';
import '../Utils/Utiles/FuncionesUtiles.dart';
import 'package:flutter/material.dart' as material;


class Config {
  //Configuración inicial
  Map<String, dynamic> configuracion_inicial = {}; // Configuración inicial del proyecto
  String nombreempresa = "Error, reportar"; //Nombre de la empresa del proyecto
  Color primaryColor = Color(0xFF235FD9); //Color primario de la plataforma
  Color Secundarycolor = Color(0xFF235FD9); //Color primario de la plataforma
  String idcarpetaPagos = "";
  String? idcarpetaSolicitudes;
  //plugins
  Map<String, dynamic> configuracion_plugins = {}; //plugins
  Map<String, dynamic> configuracion_mensajes = {}; //mensajes
  //booleanos de configuración
  bool PagosDriveApi = false;
  bool SolicitudesDriveApi = false;
  bool basicoNormal = false;
  //
  DateTime basicofecha = DateTime.now();
  DateTime SolicitudesDriveApiFecha = DateTime.now();
  DateTime PagosDriveApiFecha = DateTime.now();
  //info de tutor
  String rol = "";
  final currentUser = FirebaseAuth.instance.currentUser;
  //mensajes
  String mensaje_solicitd = "";
  String mensaje_confirmacionCliente = "";
  //Tiempo de actualizaicón
  Duration tiempoActualizacion = Duration.zero;

  Config() {
    initConfig();
  } //Inicializar la configuración

  Future<void> initConfig() async {
    configuracion_inicial = await LoadData().configuracion_inicial() as Map<String, dynamic>;
    configuracion_plugins = await LoadData().configuracion_plugins() as Map<String, dynamic>;
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      rol = await LoadData().verificar_rol(currentUser);
    } else {
      // Manejar el caso en que currentUser es nulo.
    }
    configuracion_mensajes = await LoadData().configuracion_mensajes();
    tiempoActualizacion = await LoadData().tiempoactualizacion();

    // Verificar si 'nombre_empresa' existe y no es nulo
    if (configuracion_inicial.containsKey('nombre_empresa')) {
      nombreempresa = configuracion_inicial['nombre_empresa'];
      primaryColor = Utiles().hexToColor(configuracion_inicial['Primarycolor']);
      Secundarycolor = Utiles().hexToColor(configuracion_inicial['Secundarycolor']);
      idcarpetaPagos = configuracion_inicial['idcarpetaPagos'];
      idcarpetaSolicitudes = configuracion_inicial['idcarpetaSolicitudes'];

    } else {
    }
    //se puede verificar cada día, como va esto, por si acaso, para ir borrando la base de datos y todo eso, etc
    if(configuracion_plugins.containsKey('basicoFecha')){
      basicofecha = configuracion_plugins['basicoFecha'] != null
          ? DateTime.parse(configuracion_plugins['basicoFecha'])
          : DateTime.now();
      if(basicofecha.isAfter(DateTime.now())){
        basicoNormal = true;
      }else{
        basicoNormal = false;
      }
      SolicitudesDriveApiFecha = configuracion_plugins['SolicitudesDriveApiFecha'] != null
          ? DateTime.parse(configuracion_plugins['SolicitudesDriveApiFecha'])
          : DateTime.now();
      if(SolicitudesDriveApiFecha.isAfter(DateTime.now())){
        SolicitudesDriveApi = true;
      }else{
        SolicitudesDriveApi = false;
      }
      PagosDriveApiFecha = configuracion_plugins['PagosDriveApiFecha'] != null
          ? DateTime.parse(configuracion_plugins['PagosDriveApiFecha'])
          : DateTime.now();
      if(PagosDriveApiFecha.isAfter(DateTime.now())){
        PagosDriveApi = true;
      }else{
        PagosDriveApi = false;
      }
    }

    if(configuracion_mensajes.containsKey('SOLICITUDES')){
      mensaje_solicitd = configuracion_mensajes['SOLICITUDES'];
      mensaje_confirmacionCliente = configuracion_mensajes['CONFIRMACION_CLIENTE'];
    }
  }

  //Configuraciones de diseño
  static const Color secundaryColor = Color(0xFFF0F2F2);
  static const Color primarycikirbackground =Color(0x1A000000);
  static const Color buttoncolor =Color(0xFF1E1E1E);
  static const Color colorazulventas = Color(0xFFB7DAFB);

  //Responsives
  int computador = 1200;
  int tablet = 620;
  int celular = 620;

  //Carpeta de Pagos
  String carpetapagos = "1HVgOvC-Jg8f5d-KE_m9hffKRZHJYy33N";
  //Carpeta de entregas de trabajos
  String carpetaentregatutores = "1I2RvuF9pOVgN5laPkahMdBoYaAY9Ma_1";
  //wsp token importante
  String tokenwsp = "EAAOWePbAwZCcBO3qCZB9mcNoAwqBOyw5JnPxQ6K22HCkJRtyZC7m4BjnsztuIGpEEaqGim9Pi1Avtte7iq3wjxN1WmNAjWRvQaYd0HZBOlNRcZCmRZAFAG4XaudmPt1qbBznsHNNjpL2IN1MkpOHow6iw3OWYvkaeZBKeOys99E1EGNibxpI550x7OpBUmrR4JqOD3ZAaieXZCZC4WFOCn";
  String apiurl =  "https://graph.facebook.com/v17.0/129380863588776/message_templates";
  String tokenwspsave = "EAAOWePbAwZCcBO3qCZB9mcNoAwqBOyw5JnPxQ6K22HCkJRtyZC7m4BjnsztuIGpEEaqGim9Pi1Avtte7iq3wjxN1WmNAjWRvQaYd0HZBOlNRcZCmRZAFAG4XaudmPt1qbBznsHNNjpL2IN1MkpOHow6iw3OWYvkaeZBKeOys99E1EGNibxpI550x7OpBUmrR4JqOD3ZAaieXZCZC4WFOCn";
  int santanderexplora = 129380863588776;
  int wsppruea = 1009871210202103;
  //IMPORTANTES, Esto cuando este en true, significa que el que esta conectado es DufyAsesorías principal, cuando sea false
  //es porque esta conectado cualquiera de nuestros clientes, esto para hacer un sistema unico para cada cliente.
  static const bool dufyadmon = true;
  //Para cambiar de base de datos, se debe cambiar esto a false, y luego se debe cambiar el inicializador del main, con eso ya estaría
  //correcto.



  material.Text panelnavegacion(String text,bool isexpanded){
    Color textcolor = (isexpanded) ? Config.secundaryColor : primaryColor;
    return material.Text(text,style:
    TextStyle(
      color: textcolor,
      fontFamily: "Poppins",
      fontSize: 15,
      fontWeight: FontWeight.w700,
    )
    );
  }

}