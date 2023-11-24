import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../Config/Config.dart';

class CollectionReferencias{
  FirebaseFirestore DufyFirestore = FirebaseFirestore.instance;
  FirebaseFirestore LibaFirestore = FirebaseFirestore.instanceFor(app: Firebase.app('LIBADB'));
  //Colecciones
  CollectionReference contabilidad = FirebaseFirestore.instance.collection('CONTABILIDAD');
  CollectionReference solicitudes = FirebaseFirestore.instance.collection('SOLICITUDES');
  CollectionReference clientes = FirebaseFirestore.instance.collection('CLIENTES');
  CollectionReference configuracion = FirebaseFirestore.instance.collection('ACTUALIZACION');
  CollectionReference tutores = FirebaseFirestore.instance.collection('TUTORES');
  CollectionReference tablasmaterias = FirebaseFirestore.instance.collection('TABLAS').doc("TABLAS").collection("MATERIAS");
  CollectionReference tablascarreras = FirebaseFirestore.instance.collection('TABLAS').doc("TABLAS").collection("CARRERAS");
  CollectionReference tablasuniversidades = FirebaseFirestore.instance.collection('TABLAS').doc("TABLAS").collection("UNIVERSIDADES");
  //Documentos
  DocumentReference configuracioninicial = FirebaseFirestore.instance.collection("ACTUALIZACION").doc("CONFIGURACION");
  
  //Libaewducation
  CollectionReference listaEmpresas = FirebaseFirestore.instanceFor(app: Firebase.app('LIBADB')).collection("CLAVES");

  CollectionReferencias() {
    initCollections();
  }

  Future<void> initCollections() async {
    if(Config.dufyadmon==true){
      contabilidad = DufyFirestore.collection('CONTABILIDAD');
      solicitudes = DufyFirestore.collection('SOLICITUDES');
      clientes = DufyFirestore.collection('CLIENTES');
      configuracion = DufyFirestore.collection('ACTUALIZACION');
      tutores = DufyFirestore.collection('TUTORES');
      tablasmaterias = DufyFirestore.collection('TABLAS').doc("TABLAS").collection("MATERIAS");
      tablascarreras = DufyFirestore.collection('TABLAS').doc("TABLAS").collection("CARRERAS");
      tablasuniversidades = DufyFirestore.collection('TABLAS').doc("TABLAS").collection("UNIVERSIDADES");
      configuracioninicial = DufyFirestore.collection("ACTUALIZACION").doc("CONFIGURACION");
    }else{
      contabilidad = LibaFirestore.collection('CONTABILIDAD');
      solicitudes = LibaFirestore.collection('SOLICITUDES');
      clientes = LibaFirestore.collection('CLIENTES');
      configuracion = LibaFirestore.collection('ACTUALIZACION');
      tutores = LibaFirestore.collection('TUTORES');
      tablasmaterias = LibaFirestore.collection('TABLAS').doc("TABLAS").collection("MATERIAS");
      tablascarreras = LibaFirestore.collection('TABLAS').doc("TABLAS").collection("CARRERAS");
      tablasuniversidades = LibaFirestore.collection('TABLAS').doc("TABLAS").collection("UNIVERSIDADES");
      configuracioninicial = LibaFirestore.collection("ACTUALIZACION").doc("CONFIGURACION");
    }
  }




}