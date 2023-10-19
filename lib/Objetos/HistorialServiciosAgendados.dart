import 'package:googleapis/driveactivity/v2.dart';

class HistorialAgendado{
  DateTime fechacambio = DateTime.now();  //fecha del cambio
  String cambioant = "";
  String cambionew = "";
  String motivocambio = "";

  HistorialAgendado(this.fechacambio,this.cambioant,this.cambionew,this.motivocambio);

  Map<String,dynamic> toMap(){
    return{
      'fechacambio' :fechacambio,
      "cambioant" : cambioant,
      "cambionew":cambionew,
      'motivocambio': motivocambio,
    };
  }

}