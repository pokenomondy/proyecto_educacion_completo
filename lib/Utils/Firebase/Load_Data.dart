import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dashboard_admin_flutter/Config/Config.dart';
import 'package:dashboard_admin_flutter/Objetos/AgendadoServicio.dart';
import 'package:dashboard_admin_flutter/Objetos/Clientes.dart';
import 'package:dashboard_admin_flutter/Objetos/Configuracion/objeto_configuracion.dart';
import 'package:dashboard_admin_flutter/Objetos/Cotizaciones.dart';
import 'package:dashboard_admin_flutter/Objetos/Objetos%20Auxiliares/CuentasBancaraias.dart';
import 'package:dashboard_admin_flutter/Objetos/Objetos%20Auxiliares/Carreras.dart';
import 'package:dashboard_admin_flutter/Objetos/Objetos%20Auxiliares/Materias.dart';
import 'package:dashboard_admin_flutter/Objetos/RegistrarPago.dart';
import 'package:dashboard_admin_flutter/Objetos/Solicitud.dart';
import 'package:dashboard_admin_flutter/Objetos/Tutores_objet.dart';
import 'package:dashboard_admin_flutter/Pages/Estadisticas/Contabilida.dart';
import 'package:dashboard_admin_flutter/Utils/Firebase/StreamBuilders.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:googleapis/driveactivity/v2.dart' as drive;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Objetos/Objetos Auxiliares/Universidad.dart';
import '../../Providers/Providers.dart';
import 'CollectionReferences.dart';

class LoadData {
  final db = FirebaseFirestore.instance; //inicializar firebase
  CollectionReferencias referencias =  CollectionReferencias();

  //Leer configuración inicial, que es la priemra que hay
  Future<ConfiguracionPlugins> configuracion_inicial() async {
    await referencias.initCollections();
    DocumentSnapshot documentConfiguracion = await referencias.configuracion!.doc("CONFIGURACION").get();
    DocumentSnapshot documentPlugins = await referencias.configuracion!.doc("Plugins").get();

    //documetno configuración
    String PrimaryColor = documentConfiguracion['Primarycolor'] ?? '';
    String SecundaryColor = documentConfiguracion['Secundarycolor'] ?? '';
    String idcarpetaPagos = documentConfiguracion['idcarpetaPagos'] ?? '';
    String idcarpetaSolicitudes = documentConfiguracion['idcarpetaSolicitudes'] ?? '';
    String nombre_empresa = documentConfiguracion['nombre_empresa'] ?? '';


    ConfiguracionPlugins newconfig = ConfiguracionPlugins(PrimaryColor, SecundaryColor, idcarpetaPagos, idcarpetaSolicitudes, nombre_empresa, DateTime.now(), DateTime.now(), DateTime.now(), "CONFIRMACION_CLIENTE", "SOLICITUD",0,DateTime.now());

    await  stream_builders().estadisticasLectutaFirestore(1);
    return newconfig;
  }


  //Tutores en local
  Future getinfotutor(User currentUser) async {
    await referencias.initCollections();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool datosDescargados = prefs.getBool('datos_descargadios_getinfotutor') ?? false;
    if (!datosDescargados) {
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
      await  stream_builders().estadisticasLectutaFirestore(1);
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
      await  stream_builders().estadisticasLectutaFirestore(1);
      return rol;
    }else{
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String rol = prefs.getString('rol_usuario') ?? 'TUTOR';
      return rol;
    }

  }


  //Cargar lista de emrpesas y contraseñas -- Este contador lo asume Liba Soluciones
  Future cargaListaEmpresas() async{
    await referencias.initCollections();
    CollectionReference referencelistaempresas = referencias.claves!;
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




