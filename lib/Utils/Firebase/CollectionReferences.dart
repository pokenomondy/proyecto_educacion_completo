import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Config/Config.dart';

class CollectionReferencias{
  //Realtime Data
  FirebaseDatabase? DatabaseRealtime ;
  //Firebases
  FirebaseFirestore DufyFirestore = FirebaseFirestore.instance;
  FirebaseFirestore LibaFirestore = FirebaseFirestore.instanceFor(app: Firebase.app('LIBADB'));
  //Autentication
  FirebaseAuth authdufy = FirebaseAuth.instance;
  FirebaseAuth authLiba = FirebaseAuth.instanceFor(app: Firebase.app('LIBADB'));
  FirebaseAuth? authdireccion ;

  //Colecciones
  CollectionReference? contabilidad;
  CollectionReference? solicitudes ;
  CollectionReference? clientes ;
  CollectionReference? configuracion;
  CollectionReference? tutores ;
  CollectionReference? tablasmaterias ;
  CollectionReference? tablascarreras  ;
  CollectionReference? tablasuniversidades ;
  //Documentos
  DocumentReference? infotutores;
  
  //Libaewducation
  CollectionReference listaEmpresas = FirebaseFirestore.instanceFor(app: Firebase.app('LIBADB')).collection("CLAVES");

  //Referencia de estaidistcas plugin
  CollectionReference? EstadisticaDriveSolicitudes;

  CollectionReferencias() {
    initCollections();
  }

  Future<void> initCollections() async {
    //Shared preferences cargar
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? nombre_empresa = prefs.getString("Nombre_Empresa");

    if(Config.dufyadmon==true){
      DatabaseRealtime = FirebaseDatabase.instance;
      contabilidad = DufyFirestore.collection('CONTABILIDAD');
      solicitudes = DufyFirestore.collection('SOLICITUDES');
      clientes = DufyFirestore.collection('CLIENTES');
      configuracion = DufyFirestore.collection('ACTUALIZACION');
      tutores = DufyFirestore.collection('TUTORES');
      tablasmaterias = DufyFirestore.collection('TABLAS').doc("TABLAS").collection("MATERIAS");
      tablascarreras = DufyFirestore.collection('TABLAS').doc("TABLAS").collection("CARRERAS");
      tablasuniversidades = DufyFirestore.collection('TABLAS').doc("TABLAS").collection("UNIVERSIDADES");
      authdireccion = authdufy;
      EstadisticaDriveSolicitudes = configuracion!.doc("CONFIGURACION").collection("DRIVESOLICITUDES");
    }else{
      DocumentReference referenceNoDufy = LibaFirestore.collection("EMPRESAS").doc(nombre_empresa);
      DatabaseRealtime = FirebaseDatabase.instanceFor(app: Firebase.app('LIBADB'));
      contabilidad = referenceNoDufy.collection('CONTABILIDAD');
      solicitudes = referenceNoDufy.collection('SOLICITUDES');
      clientes = referenceNoDufy.collection('CLIENTES');
      configuracion = referenceNoDufy.collection('ACTUALIZACION');
      tutores = referenceNoDufy.collection('TUTORES');
      tablasmaterias = referenceNoDufy.collection('TABLAS').doc("TABLAS").collection("MATERIAS");
      tablascarreras = referenceNoDufy.collection('TABLAS').doc("TABLAS").collection("CARRERAS");
      tablasuniversidades = referenceNoDufy.collection('TABLAS').doc("TABLAS").collection("UNIVERSIDADES");
      authdireccion = authLiba;
      EstadisticaDriveSolicitudes = referenceNoDufy.collection('ACTUALIZACION').doc("Plugins").collection("DRIVESOLICITUDES");
    }
  }




}