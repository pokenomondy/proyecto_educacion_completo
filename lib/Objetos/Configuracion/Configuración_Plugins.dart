import 'package:googleapis/cloudsearch/v1.dart';

class ConfiguracionPlugins{

  //Plugins - Aca se agregan mas si se necesitan
  DateTime PagosDriveApiFecha = DateTime.now();
  DateTime SolicitudesDriveApiFecha = DateTime.now();
  DateTime basicoFecha = DateTime.now();
  DateTime verificador = DateTime.now();


  ConfiguracionPlugins(this.PagosDriveApiFecha,this.SolicitudesDriveApiFecha,this.basicoFecha,this.verificador);

  Map<String,dynamic> toMap(){
    return{

      'PagosDriveApiFecha' : PagosDriveApiFecha,
      'SolicitudesDriveApiFecha' : SolicitudesDriveApiFecha,
      'basicoFecha' : basicoFecha,
      'verificador' : verificador,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'PagosDriveApiFecha' : PagosDriveApiFecha.toIso8601String(),
      'SolicitudesDriveApiFecha' : SolicitudesDriveApiFecha.toIso8601String(),
      'basicoFecha' : basicoFecha.toIso8601String(),
      'verificador' : verificador.toIso8601String(),
    };
  }

  factory ConfiguracionPlugins.fromJson(Map<String, dynamic> json) {
    return ConfiguracionPlugins(
      DateTime.parse(json['PagosDriveApiFecha']),
      DateTime.parse(json['SolicitudesDriveApiFecha']),
      DateTime.parse(json['basicoFecha']),
      DateTime.parse(json['verificador']),
    );
  }
}