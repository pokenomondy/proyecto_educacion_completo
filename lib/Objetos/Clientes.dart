import 'package:googleapis/driveactivity/v2.dart';

class Clientes{
  String carrera = "";
  String universidad = "";
  String nombreCliente = "";
  int numero = 0;
  String nombrecompletoCliente = "";
  DateTime fechaActualizacion = DateTime.now();


  Clientes(this.carrera,this.universidad,this.nombreCliente,this.numero,this.nombrecompletoCliente, this.fechaActualizacion);

  Map<String,dynamic> toMap(){
    return{
      'Carrera' :carrera,
      "Universidadd" : universidad,
      "nombreCliente":nombreCliente,
      'numero': numero,
      'nombrecompletoCliente': nombrecompletoCliente,
      'fechaActualizacion' : fechaActualizacion,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'Carrera': carrera,
      'Universidad': universidad,
      'nombreCliente': nombreCliente,
      'numero': numero,
      'nombrecompletoCliente': nombrecompletoCliente,
      'fechaActualizacion' : fechaActualizacion.toIso8601String(),
    };
  }

  factory Clientes.fromJson(Map<String, dynamic> json) {
    return Clientes(
      json['Carrera'],
      json['Universidad'],
      json['nombreCliente'],
      json['numero'],
      json['nombrecompletoCliente'],
      DateTime.parse(json['fechaActualizacion']),
    );
  }
}