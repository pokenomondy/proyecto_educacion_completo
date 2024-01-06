import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:googleapis/driveactivity/v2.dart';

class HistorialAgendado{
  DateTime fechacambio = DateTime.now();  //fecha del cambio
  String cambioant = "";
  String cambionew = "";
  String motivocambio = "";
  String codigo = "";

  HistorialAgendado(this.fechacambio,this.cambioant,this.cambionew,this.motivocambio,this.codigo);

  Map<String,dynamic> toMap(){
    return{
      'fechacambio' :fechacambio,
      "cambioant" : cambioant,
      "cambionew":cambionew,
      'motivocambio': motivocambio,
      'codigo' : codigo,
    };
  }

  // Método para convertir Timestamp a DateTime y luego a String
  static DateTime convertirTimestamp(Timestamp timestamp) {
    return timestamp.toDate();
  }

  Map<String, dynamic> toJson() {
    return {
      'fechacambio' :fechacambio.toIso8601String(),
      "cambioant" : cambioant,
      "cambionew":cambionew,
      'motivocambio': motivocambio,
      'codigo' : codigo,
    };
  }

  factory HistorialAgendado.fromJson(Map<String, dynamic> json) {
    return HistorialAgendado(
      DateTime.parse(json['fechacambio']),
      json['cambioant'],
      json['cambionew'],
      json['motivocambio'],
      json['codigo'],
    );
  }

}