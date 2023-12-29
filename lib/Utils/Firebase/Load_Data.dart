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
  Future<Map<String, dynamic>> configuracion_inicial() async {
    await referencias.initCollections();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool datosDescargados = prefs.getBool('datos_descargados_configinicial') ?? false;

    if (!datosDescargados) {
      try {
        DocumentSnapshot getconfiguracioninicial = await referencias.configuracion!.doc("CONFIGURACION").get();
        int counter = 1;
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

          await  stream_builders().estadisticasLectutaFirestore(counter);
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




