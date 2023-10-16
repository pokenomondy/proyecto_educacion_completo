class Cotizacion{
  int cotizacion = 0; //preciocotización
  String uidtutor = ""; //uidtutor
  String nombretutor = ""; //nombretutor
  int? tiempoconfirmacion = 0; //tiempo de confirmación
  String? comentariocotizacion = ""; //comentario de cotizacion
  String? Agenda = ""; //a si fue agendado al tutor xd
//Aqui vamos a haerle fecha de confirmación maxima del tutor
  DateTime fechaconfirmacion = DateTime.now();

  Cotizacion(this.cotizacion,this.uidtutor,this.nombretutor,this.tiempoconfirmacion,this.comentariocotizacion,this.Agenda,this.fechaconfirmacion);

  Map<String,dynamic> toMap(){
    return{
      'Cotizacion' :cotizacion,
      "uidtutor" : uidtutor,
      "nombretutor":nombretutor,
      'Tiempo confirmacion': tiempoconfirmacion,
      "Comentario Cotización": comentariocotizacion,
      "Agenda": Agenda,
      "fechaconfirmacion":fechaconfirmacion,
    };
  }
  Map<String, dynamic> toJson() {
    return {
      'cotizacion': cotizacion,
      'uidtutor': uidtutor,
      'nombretutor': nombretutor,
      'tiempoconfirmacion': tiempoconfirmacion,
      'comentariocotizacion': comentariocotizacion,
      'Agenda': Agenda,
      'fechaconfirmacion':fechaconfirmacion.toIso8601String(),
    };
  }

  factory Cotizacion.fromJson(Map<String, dynamic> json) {
    return Cotizacion(
      json['cotizacion'],
      json['uidtutor'],
      json['nombretutor'],
      json['tiempoconfirmacion'],
      json['comentariocotizacion'],
      json['Agenda'],
      DateTime.parse(json['fechaconfirmacion']),
    );
  }
}