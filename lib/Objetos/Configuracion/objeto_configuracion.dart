
class ConfiguracionPlugins{
  String primaryColor = "";
  String secundaryColor = "";
  String idcarpetaPagos = "";
  String idcarpetaSolicitudes = "";
  String nombreEmpresa = "";

  //Plugins - Aca se agregan mas si se necesitan
  DateTime pagosDriveApiFecha = DateTime.now();
  DateTime solicitudesDriveApiFecha = DateTime.now();
  DateTime basicoFecha = DateTime.now();
  DateTime tutoresSistemaFecha = DateTime.now();

  //Mensajes personalizados
  String mensajeConfirmacionCliente = "";
  String mensajeSolicitudes = "";

  int ultimaModificacion = 1672534800;


  ConfiguracionPlugins(this.primaryColor,this.secundaryColor,this.idcarpetaPagos,this.idcarpetaSolicitudes,this.nombreEmpresa,
      this.pagosDriveApiFecha,this.solicitudesDriveApiFecha,this.basicoFecha,this.mensajeConfirmacionCliente,this.mensajeSolicitudes,this.ultimaModificacion,this.tutoresSistemaFecha);

  Map<String,dynamic> toMap(){
    return{
      'PrimaryColor' : primaryColor,
      'SecundaryColor' : secundaryColor,
      'idcarpetaPagos' : idcarpetaPagos,
      'idcarpetaSolicitudes' : idcarpetaSolicitudes,
      'nombre_empresa' : nombreEmpresa,
      'PagosDriveApiFecha' : pagosDriveApiFecha,
      'SolicitudesDriveApiFecha' : solicitudesDriveApiFecha,
      'basicoFecha' : basicoFecha,
      'CONFIRMACION_CLIENTE' : mensajeConfirmacionCliente,
      'SOLICITUD' : mensajeSolicitudes,
      'ultimaModificacion' : ultimaModificacion,
      'tutoresSistemaFecha' : tutoresSistemaFecha,
    };
  }

  ConfiguracionPlugins.empty() {
    primaryColor = "";
    secundaryColor = "";
    idcarpetaPagos = "";
    idcarpetaSolicitudes = "";
    nombreEmpresa = "";
    pagosDriveApiFecha = DateTime(2023,1,1);
    solicitudesDriveApiFecha = DateTime(2023,1,1);
    basicoFecha = DateTime(2023,1,1);
    mensajeConfirmacionCliente = "";
    mensajeSolicitudes = "";
    ultimaModificacion = 0;
    tutoresSistemaFecha = DateTime(2023,1,1);
  }

  Map<String, dynamic> toJson() {
    return {
      'PrimaryColor' : primaryColor,
      'SecundaryColor' : secundaryColor,
      'idcarpetaPagos' : idcarpetaPagos,
      'idcarpetaSolicitudes' : idcarpetaSolicitudes,
      'nombre_empresa' : nombreEmpresa,
      'PagosDriveApiFecha' : pagosDriveApiFecha.toIso8601String(),
      'SolicitudesDriveApiFecha' : solicitudesDriveApiFecha.toIso8601String(),
      'basicoFecha' : basicoFecha.toIso8601String(),
      'CONFIRMACION_CLIENTE' : mensajeConfirmacionCliente,
      'SOLICITUD' : mensajeSolicitudes,
      'ultimaModificacion' : ultimaModificacion,
      'tutoresSistemaFecha' : tutoresSistemaFecha.toIso8601String(),
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
        DateTime.parse(json['tutoresSistemaFecha']),
    );
  }
}