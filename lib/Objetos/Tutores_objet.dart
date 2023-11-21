import 'package:googleapis/shared.dart';
import 'CuentasBancaraias.dart';
import 'Objetos Auxiliares/Materias.dart';

class Tutores{
  //variables de tutor
  String nombrewhatsapp = "";
  String nombrecompleto = "";
  int numerowhatsapp = 0;
  String carrera = "";
  String correogmail = "";
  String univerisdad = "";
  String uid = "";
  List<Materia> materias = [];
  List<CuentasBancarias> cuentas = [];
  bool activo = true;
  //Variable para ver si se debe actualizar o no
  DateTime actualizartutores = DateTime.now();
  String rol;

  Tutores(this.nombrewhatsapp,this.nombrecompleto,this.numerowhatsapp,this.carrera,this.correogmail,this.univerisdad,this.uid,this.materias,this.cuentas,this.activo,this.actualizartutores,this.rol);

  Tutores.empty()
      : nombrewhatsapp = "",
        nombrecompleto = "",
        numerowhatsapp = 0,
        carrera = "",
        correogmail = "",
        univerisdad = "",
        uid = "",
        materias = [],
        cuentas = [],
        activo = false,
        actualizartutores = DateTime.now(),
        rol = "";

  Map<String, dynamic> toMap() {
    return{
      "nombre Whatsapp":nombrewhatsapp,
      "nombre completo":nombrecompleto,
      "numero whatsapp":numerowhatsapp,
      "carrera":carrera,
      "Correo gmail":correogmail,
      "Universidad":univerisdad,
      'uid':uid,
      'activo':activo,
      'actualizartutores' : actualizartutores,
      'rol' : rol,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      "nombre Whatsapp":nombrewhatsapp,
      "nombre completo":nombrecompleto,
      "numero whatsapp":numerowhatsapp,
      "carrera":carrera,
      "Correo gmail":correogmail,
      "Universidad":univerisdad,
      'uid':uid,
      'materias': materias.map((materia) => materia.toJson()).toList(),
      'cuentas': cuentas.map((cuenta) => cuenta.toJson()).toList(),
      'activo':activo,
      'actualizartutores' :actualizartutores.toIso8601String(),
      'rol' : rol,
    };
  }

  factory Tutores.fromJson(Map<String, dynamic> json) {
    return Tutores(
      json['nombre Whatsapp'],
      json['nombre completo'],
      json['numero whatsapp'],
      json['carrera'],
      json['Correo gmail'],
      json['Universidad'],
      json['uid'],
      (json['materias'] as List<dynamic>)
          .map((materiaData) => Materia.fromJson(materiaData))
          .toList(),
      (json['cuentas'] as List<dynamic>)
          .map((cuentaData) => CuentasBancarias.fromJson(cuentaData))
          .toList(),
      json['activo'],
      DateTime.parse(json['actualizartutores']),
      json['rol'],
    );
  }


}