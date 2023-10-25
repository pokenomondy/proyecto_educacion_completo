import 'package:cloud_firestore/cloud_firestore.dart';

class CollectionRefs{
  //Aqui debería filtrarse sobre cuales usar, si  usar las de un solo proyecto, o el sistema con todos los proyectos
  static final CollectionReference contabilidad = FirebaseFirestore.instance.collection('CONTABILIDAD');
  static final CollectionReference solicitudes = FirebaseFirestore.instance.collection('SOLICITUDES');
  static final CollectionReference clientes = FirebaseFirestore.instance.collection('CLIENTES');

  static final CollectionReference configuracion = FirebaseFirestore.instance.collection('ACTUALIZACION');


// Agrega otras colecciones según las necesidades de tu proyecto
}