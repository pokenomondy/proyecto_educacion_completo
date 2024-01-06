import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dashboard_admin_flutter/Objetos/Administrador/empresasAdmin.dart';
import 'package:dashboard_admin_flutter/Objetos/Tutores_objet.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:googleapis/cloudsearch/v1.dart';

import '../../Objetos/Objetos Auxiliares/CuentasBancaraias.dart';
import '../../Objetos/Objetos Auxiliares/Materias.dart';
import 'CollectionReferences.dart';

class UploadAdmin{
  CollectionReferencias referencias =  CollectionReferencias();
  int timestamphoy = DateTime.now().millisecondsSinceEpoch ~/ 1000;

  UploadAdmin() {
    _initialize();
  }

  Future<void> _initialize() async {
    await referencias.initCollections();
  }

  //Añadi nueva empresa
  Future addNuevaEmpresa(String Empresa, String Contrasena, int timeLicencia)async{
    DateTime fechaActual = DateTime.now();
    //Nueva fecha
    DateTime nuevaFecha = fechaActual.add(Duration(days: timeLicencia));
    await referencias.initCollections();
    CollectionReference referenceNewEmresa = referencias.claves!;
    CollectionReference referenceNewEmpresaLista = referencias.LibaFirestore.collection("EMPRESAS");
    //Crear claves
    ClaveEmpresa newClaveEmpresa = ClaveEmpresa(Empresa, Contrasena);
    await referenceNewEmresa.doc(Empresa).set(newClaveEmpresa.toMap());
    //Crear documento principal de empresa
    Map<String, dynamic> infovacia = {
      '1':'1',
    };
    await referenceNewEmpresaLista.doc(Empresa).set(infovacia);
    //Agreguemos configuracion a empresa
    Map<String, dynamic> infoConfiguracion = {
      'basicoFecha' : nuevaFecha,
    };
    await referenceNewEmpresaLista.doc(Empresa).collection("ACTUALIZACION").doc("Plugins").set(infoConfiguracion);
  }

  //Añadir administrador a nueva empresa
  Future addNewAdministrador(String nombreEmpresa, String correo, String Pass, int numcel) async{
    await referencias.initCollections();
    CollectionReference referenceNewEmpresaLista = referencias.LibaFirestore.collection("EMPRESAS").doc(nombreEmpresa).collection("TUTORES");
    List<Materia> materias = [];
    List<CuentasBancarias> cuentas = [];
    String uidtutor = referencias.authdireccion!.currentUser!.uid;
    Tutores newtutor = Tutores("ADMINISTRADOR", "", numcel , "", correo, "", uidtutor , materias, cuentas, true, DateTime.now(), "ADMIN",timestamphoy);
    await referenceNewEmpresaLista.doc(uidtutor).set(newtutor.toMap());
  }

  //Crear nuevo Tutor
  Future<void> createUserWithEmailAndPassword(TextEditingController correoGmail,TextEditingController password,String nombreEmpres, int numcel) async {
    await referencias.initCollections();
    try {
      final credential = await referencias.authdireccion!.createUserWithEmailAndPassword(email: correoGmail.text, password: password.text,);
      referencias.initCollections();
      await addNewAdministrador(nombreEmpres,correoGmail.text,password.text,numcel);
      referencias.authdireccion!.signOut();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print("contraseña mala");
      } else if (e.code == 'email-already-in-use') {
        print("email ya usado");
      }
    } catch (e) {
      print(e);
      print("error no se creo");
    }
  }


}