import 'package:googleapis/cloudsearch/v1.dart';

class ConfiguracionPlugins{
  //Mensajes personalizados
  String CONFIRMACION_CLIENTE = "";
  String SOLICITUD = "";

  ConfiguracionPlugins(this.CONFIRMACION_CLIENTE,this.SOLICITUD);

  Map<String,dynamic> toMap(){
    return{
      'CONFIRMACION_CLIENTE' : CONFIRMACION_CLIENTE,
      'SOLICITUD' : SOLICITUD,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'CONFIRMACION_CLIENTE' : CONFIRMACION_CLIENTE,
      'SOLICITUD' : SOLICITUD,
    };
  }

  factory ConfiguracionPlugins.fromJson(Map<String, dynamic> json) {
    return ConfiguracionPlugins(
      json['CONFIRMACION_CLIENTE'],
      json['SOLICITUD'],
    );
  }
}