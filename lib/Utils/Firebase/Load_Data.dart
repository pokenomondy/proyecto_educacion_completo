import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dashboard_admin_flutter/Config/Config.dart';
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
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:googleapis/driveactivity/v2.dart' as drive;
import 'package:shared_preferences/shared_preferences.dart';
import '../../Objetos/Objetos Auxiliares/Universidad.dart';
import 'CollectionReferences.dart';

class LoadData {
  final db = FirebaseFirestore.instance; //inicializar firebase
  CollectionReferencias referencias =  CollectionReferencias();


  //Obtener en tiempo real, numero de servicio a publicar
  Stream<int> cargarnumerodesolicitudes() async* {
    await referencias.initCollections();
    CollectionReference referencesolicitudes = referencias.solicitudes!;
    await for (QuerySnapshot snapshot in referencesolicitudes.snapshots()) {
      int numDocumentos = snapshot.size;
      if(!Config.dufyadmon){
        yield numDocumentos + 1;
      }else{
        yield numDocumentos + 473;
      }
    }
  }

  //Obtener numero de contabilidades en tiempo real
  Stream<int> cargarnumerocontabilidad() async* {
    await referencias.initCollections();
    CollectionReference referencecontabilidad = referencias.contabilidad!;
    await for (QuerySnapshot snapshot in referencecontabilidad.snapshots()){
      int numDocumentos = snapshot.size;
      //print("numero obtenido $numDocumentos");
      yield numDocumentos + 922;
    }
  }

  //Leer configuración inicial, que es la priemra que hay
  Future<Map<String, dynamic>> configuracion_inicial() async {
    await referencias.initCollections();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool datosDescargados = prefs.getBool('datos_descargados_configinicial') ?? false;

    if (!datosDescargados) {
      try {
        DocumentSnapshot getconfiguracioninicial = await referencias.configuracion!.doc("CONFIGURACION").get();

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
        print("Error: $e, config inicial 0");
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
    await referencias.initCollections();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool datosDescargados = prefs.getBool('datos_descargados_plugins') ?? false;
    if (!datosDescargados) {
      try {
        print("descarngado plugins");
        DocumentSnapshot getplugins = await referencias.configuracion!.doc("Plugins").get();
        if (getplugins.exists) {
          DateTime basicoFecha = getplugins.get('basicoFecha').toDate() ?? DateTime.now();
          DateTime SolicitudesDriveApiFecha = getplugins.get('SolicitudesDriveApiFecha').toDate() ?? DateTime.now();
          DateTime PagosDriveApiFecha = getplugins.get('PagosDriveApiFecha').toDate() ?? DateTime.now();
          //Guardar variable
          DateTime verificador = getplugins.get('verificadoractualizar').toDate() ?? DateTime.now();

          Map<String, dynamic> uploadconfiguracion = {
            'basicoFecha' : basicoFecha.toIso8601String(),
            'SolicitudesDriveApiFecha' : SolicitudesDriveApiFecha.toIso8601String(),
            'PagosDriveApiFecha' : PagosDriveApiFecha.toIso8601String(),
            'verificador' : verificador.toIso8601String(),
          };

          String solicitudesJson = jsonEncode(uploadconfiguracion);
          await prefs.setString('configuracion_plugins', solicitudesJson);
          await prefs.setBool('datos_descargados_plugins', true);

          print("guardando plugins");

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
    await referencias.initCollections();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool datosDescargados = prefs.getBool('datos_descargados_config_mensajes') ?? false;

    if (!datosDescargados) {
      try {
        DocumentSnapshot getconfiguracioninicial = await referencias.configuracion!.doc("MENSAJES").get();

        if (getconfiguracioninicial.exists) {
          String msjsolicitudes = getconfiguracioninicial.get('SOLICITUD') ?? '';
          String msjconfirmacion_cliente = getconfiguracioninicial.get('CONFIRMACION_CLIENTE') ?? '';


          Map<String, dynamic> uploadconfiguracion = {
            'SOLICITUDES': msjsolicitudes,
            'CONFIRMACION_CLIENTE' : msjconfirmacion_cliente,
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
    await referencias.initCollections();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool datosDescargados = prefs.getBool('datos_descargadios_getinfotutor') ?? false;
    if (!datosDescargados) {
      //print("Datos de tutor de cero");
      DocumentSnapshot getutoradmin = await referencias.tutores!.doc(currentUser?.uid).get();
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
      //print("Datos de tutor cacheado");
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String solicitudesJson = prefs.getString('informacion_tutor') ?? '';
      Map<String, dynamic> datos_tutor = jsonDecode(solicitudesJson);
      return datos_tutor;
    }





  }

  Future<String> verificar_rol(User currentUser) async {
    await referencias.initCollections();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool datosDescargados = prefs.getBool('datos_Descargados_verificar_rol') ?? false;
    if(!datosDescargados){
      DocumentSnapshot getutoradmin = await referencias.tutores!.doc(currentUser?.uid).get();
      String rol = getutoradmin.get('rol') ?? '';
      await prefs.setString('rol_usuario', rol);
      await prefs.setBool('datos_Descargados_verificar_rol', true);
      return rol;
    }else{
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String rol = prefs.getString('rol_usuario') ?? 'TUTOR';
      return rol;
    }

  }

  Future tiempoactualizacion() async{
    await referencias.initCollections();
    try{
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String solicitudesJson = prefs.getString('configuracion_plugins') ?? '';
      Map<String, dynamic> configuracion = jsonDecode(solicitudesJson);
      DateTime verificador = configuracion['verificador'] != null ? DateTime.parse(configuracion['verificador']) : DateTime.now();
      Duration diferenciaTiempo = DateTime.now().difference(verificador);
      return diferenciaTiempo;
    }catch(e){
      //print('Error en tiempoActualizacion: $e');
      //print("duracion es cero");
      return Duration.zero;
    }
  }

  //Cargar lista de emrpesas y contraseñas
  Future cargaListaEmpresas() async{
    await referencias.initCollections();
    CollectionReference referencelistaempresas = referencias.listaEmpresas!;
    QuerySnapshot querylistaEmpresas = await referencelistaempresas.get();
    List<Map<String, dynamic>> listaClaves = [];
    for (var EmpresaDoc in querylistaEmpresas.docs){
      String Contrasena = EmpresaDoc['Contrasena'];
      String Empresa = EmpresaDoc['Empresa'];
      Map<String, dynamic> mapaEmpresa = {
        'Contrasena': Contrasena,
        'Empresa': Empresa,
      };
      listaClaves.add(mapaEmpresa);
    }

    return listaClaves;
  }
}




