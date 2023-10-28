import 'RegistrarPago.dart';

class ServicioAgendado{
  String codigo = "";//Codigo
  String sistema = "";//SISTEMA - NACIONAL O INTERNACIONAL ( POR AHORA SOLO NACIONAL)
  String materia = "";//MATERIA
  DateTime fechasistema = DateTime.now();//FECHA SISTEMA CREADO
  String cliente = "";//CLIENTE LIGADO
  int preciocobrado = 0;//PRECIO COBRADO - > PRECIO DE NOSOTROS
  DateTime fechaentrega = DateTime.now();//FECHA DE ENTREGA CON HORA DE ENTREGA
  String tutor = "";//TUTOR
  int preciotutor = 0;//PRECIO TUTOR
  String identificadorcodigo = "0";//CODIGO - P / T
  int idsolicitud = 0;
  int idcontable = 0;
  //Agregar Pagos
  List<RegistrarPago> pagos = [];
  //Agregar estado si ha sido entregado o no entregado
  String entregadotutor = "";
  String entregadocliente = "";

  ServicioAgendado(this.codigo,this.sistema,this.materia,this.fechasistema,this.cliente,this.preciocobrado,this.fechaentrega,
      this.tutor,this.preciotutor,this.identificadorcodigo,this.idsolicitud,this.idcontable,this.pagos,this.entregadotutor,
      this.entregadocliente);

  Map<String,dynamic> toMap(){
    return{
      'codigo' :codigo,
      "sistema" : sistema,
      "materia":materia,
      'fechasistema': fechasistema,
      'cliente': cliente,
      'preciocobrado': preciocobrado,
      'fechaentrega': fechaentrega,
      'tutor': tutor,
      'preciotutor': preciotutor,
      'identificadorcodigo': identificadorcodigo,
      'idsolicitud': idsolicitud,
      'idcontable' : idcontable,
      'entregadotutor' : entregadotutor,
      'entregadocliente' : entregadocliente,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'codigo': codigo,
      'sistema': sistema,
      'materia': materia,
      'fechasistema': fechasistema.toIso8601String(),
      'cliente': cliente,
      'preciocobrado': preciocobrado,
      'fechaentrega': fechaentrega.toIso8601String(),
      'tutor': tutor,
      'preciotutor': preciotutor,
      'identificadorcodigo': identificadorcodigo,
      'idsolicitud': idsolicitud,
      'idcontable' : idcontable,
      'pagos': pagos.map((pagoData) => pagoData.toJson()).toList(),
      'entregadotutor' : entregadotutor,
      'entregadocliente' : entregadocliente,
    };
  }

  factory ServicioAgendado.fromJson(Map<String, dynamic> json) {
    return ServicioAgendado(
      json['codigo'],
      json['sistema'],
      json['materia'],
      DateTime.parse(json['fechasistema']),
      json['cliente'],
      json['preciocobrado'],
      DateTime.parse(json['fechaentrega']),
      json['tutor'],
      json['preciotutor'],
      json['identificadorcodigo'],
      json['idsolicitud'],
      json['idcontable'],
      (json['pagos'] as List<dynamic>)
          .map((pagoData) => RegistrarPago.fromJson(pagoData))
          .toList(),
      json['entregadotutor'],
      json['entregadocliente'],
    );
  }




}