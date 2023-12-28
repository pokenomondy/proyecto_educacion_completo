import 'package:googleapis/cloudsearch/v1.dart';

class ConfiguracionPlugins{
  String PrimaryColor = "";
  String SecundaryColor = "";
  String idcarpetaPagos = "";
  String idcarpetaSolicitudes = "";
  String nombre_empresa = "";

  //Plugins - Aca se agregan mas si se necesitan
  DateTime PagosDriveApiFecha = DateTime.now();
  DateTime SolicitudesDriveApiFecha = DateTime.now();
  DateTime basicoFecha = DateTime.now();

  //Mensajes personalizados
  String CONFIRMACION_CLIENTE = "";
  String SOLICITUD = "";

  int ultimaModificacion = 1672534800;


  ConfiguracionPlugins(this.PrimaryColor,this.SecundaryColor,this.idcarpetaPagos,this.idcarpetaSolicitudes,this.nombre_empresa,
      this.PagosDriveApiFecha,this.SolicitudesDriveApiFecha,this.basicoFecha,this.CONFIRMACION_CLIENTE,this.SOLICITUD,this.ultimaModificacion);

  Map<String,dynamic> toMap(){
    return{
      'PrimaryColor' : PrimaryColor,
      'SecundaryColor' : SecundaryColor,
      'idcarpetaPagos' : idcarpetaPagos,
      'idcarpetaSolicitudes' : idcarpetaSolicitudes,
      'nombre_empresa' : nombre_empresa,
      'PagosDriveApiFecha' : PagosDriveApiFecha,
      'SolicitudesDriveApiFecha' : SolicitudesDriveApiFecha,
      'basicoFecha' : basicoFecha,
      'CONFIRMACION_CLIENTE' : CONFIRMACION_CLIENTE,
      'SOLICITUD' : SOLICITUD,
      'ultimaModificacion' : ultimaModificacion,
    };
  }

  ConfiguracionPlugins.empty() {
    PrimaryColor = "";
    SecundaryColor = "";
    idcarpetaPagos = "";
    idcarpetaSolicitudes = "";
    nombre_empresa = "";
    PagosDriveApiFecha = DateTime(2023,1,1);
    SolicitudesDriveApiFecha = DateTime(2023,1,1);
    basicoFecha = DateTime(2023,1,1);
    CONFIRMACION_CLIENTE = "";
    SOLICITUD = "";
    ultimaModificacion = 0;
  }

  Map<String, dynamic> toJson() {
    return {
      'PrimaryColor' : PrimaryColor,
      'SecundaryColor' : SecundaryColor,
      'idcarpetaPagos' : idcarpetaPagos,
      'idcarpetaSolicitudes' : idcarpetaSolicitudes,
      'nombre_empresa' : nombre_empresa,
      'PagosDriveApiFecha' : PagosDriveApiFecha.toIso8601String(),
      'SolicitudesDriveApiFecha' : SolicitudesDriveApiFecha.toIso8601String(),
      'basicoFecha' : basicoFecha.toIso8601String(),
      'CONFIRMACION_CLIENTE' : CONFIRMACION_CLIENTE,
      'SOLICITUD' : SOLICITUD,
      'ultimaModificacion' : ultimaModificacion,
    };
  }

  factory ConfiguracionPlugins.fromJson(Map<String, dynamic> json) {
    return ConfiguracionPlugins(
        json['PrimaryColor'],
        json['SecundaryColor'],
        json['idcarpetaPagos'],
        json['idcarpetaSolicitudes'],
        json['nombre_empresa'],
        DateTime.parse(json['PagosDriveApiFecha']),
        DateTime.parse(json['SolicitudesDriveApiFecha']),
        DateTime.parse(json['basicoFecha']),
        json['CONFIRMACION_CLIENTE'],
        json['SOLICITUD'],
        json['ultimaModificacion'],
    );
  }
}