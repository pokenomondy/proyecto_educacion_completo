import 'package:googleapis/cloudsearch/v1.dart';

class ConfiguracionPlugins{
  String PrimaryColor = "";
  String SecundaryColor = "";
  String idcarpetaPagos = "";
  String idcarpetaSolicitudes = "";
  String nombre_empresa = "";

  ConfiguracionPlugins(this.PrimaryColor,this.SecundaryColor,this.idcarpetaPagos,this.idcarpetaSolicitudes,this.nombre_empresa);

  Map<String,dynamic> toMap(){
    return{
      'PrimaryColor' : PrimaryColor,
      'SecundaryColor' : SecundaryColor,
      'idcarpetaPagos' : idcarpetaPagos,
      'idcarpetaSolicitudes' : idcarpetaSolicitudes,
      'nombre_empresa' : nombre_empresa,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'PrimaryColor' : PrimaryColor,
      'SecundaryColor' : SecundaryColor,
      'idcarpetaPagos' : idcarpetaPagos,
      'idcarpetaSolicitudes' : idcarpetaSolicitudes,
      'nombre_empresa' : nombre_empresa,
    };
  }

  factory ConfiguracionPlugins.fromJson(Map<String, dynamic> json) {
    return ConfiguracionPlugins(
        json['PrimaryColor'],
        json['SecundaryColor'],
        json['idcarpetaPagos'],
        json['idcarpetaSolicitudes'],
        json['nombre_empresa'],
    );
  }
}