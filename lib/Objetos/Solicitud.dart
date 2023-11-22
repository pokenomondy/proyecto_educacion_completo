import 'package:googleapis/driveactivity/v2.dart';

import 'Cotizaciones.dart';

class Solicitud {
  //variables de servicio
  String servicio = ""; //servicio
  int idcotizacion = 1; //idcotizacion
  String materia = ""; //materia
  DateTime fechaentrega = DateTime.now(); //fecha final
  int cliente = 0; //cliente
  DateTime fechasistema = DateTime.now(); //fecha sistema
  String estado = ""; //disponibilidad
  List<Cotizacion> cotizaciones; //lista de cotizaciones
  String resumen = ""; //Tema asignado
  String infocliente = ""; //Cronograma de avances
  DateTime fechaactualizacion = DateTime.now(); //fecha de verificación, si esta cambia, se debe solo leer esta para ver si se debe actualizar
  String urlArchivos = "";
  DateTime actualizarsolicitudes = DateTime.now();

  Solicitud(
      this.servicio,
      this.idcotizacion,
      this.materia,
      this.fechaentrega,
      this.resumen,
      this.infocliente,
      this.cliente,
      this.fechasistema,
      this.estado,
      this.cotizaciones,
      this.fechaactualizacion,
      this.urlArchivos,
      this.actualizarsolicitudes
      );

  // Constructor para crear una Solicitud vacía con valores predeterminados
  Solicitud.empty()
      : servicio = "",
        idcotizacion = 0,
        materia = "",
        fechaentrega = DateTime.now(),
        cliente = 0,
        fechasistema = DateTime.now(),
        estado = "",
        cotizaciones = [],
        resumen = "",
        infocliente = "",
        fechaactualizacion = DateTime.now(),
        urlArchivos = "",
        actualizarsolicitudes = DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'Servicio': servicio,
      'idcotizacion': idcotizacion,
      'materia': materia,
      'fechaentrega': fechaentrega, // Convert DateTime to a string representation
      'resumen': resumen,
      'infocliente': infocliente,
      'cliente': cliente,
      'fechasistema': fechasistema, // Convert DateTime to a string representation
      'Estado': estado,
      'fechaactualizacion':fechaactualizacion,
      'archivos':urlArchivos,
      'actualizarsolicitudes' : actualizarsolicitudes,
    };
  }

  factory Solicitud.fromJson(Map<String, dynamic> json) {
    return Solicitud(
      json['Servicio'],
      json['idcotizacion'],
      json['materia'],
      DateTime.parse(json['fechaentrega']),
      json['resumen'],
      json['infocliente'],
      json['cliente'],
      DateTime.parse(json['fechasistema']),
      json['Estado'],
      (json['cotizaciones'] as List<dynamic>)
          .map((cotizacionData) => Cotizacion.fromJson(cotizacionData))
          .toList(),
      DateTime.parse(json['fechaactualizacion']),
      json['archivos'],
      DateTime.parse(json['actualizarsolicitudes']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Servicio': servicio,
      'idcotizacion': idcotizacion,
      'materia': materia,
      'fechaentrega': fechaentrega.toIso8601String(),
      'resumen': resumen,
      'infocliente': infocliente,
      'cliente': cliente,
      'fechasistema': fechasistema.toIso8601String(),
      'Estado': estado,
      'cotizaciones': cotizaciones.map((cotizacion) => cotizacion.toJson()).toList(),
      'fechaactualizacion': fechaactualizacion.toIso8601String(),
      'archivos' : urlArchivos,
      'actualizarsolicitudes' : actualizarsolicitudes.toIso8601String(),
    };
  }
}
