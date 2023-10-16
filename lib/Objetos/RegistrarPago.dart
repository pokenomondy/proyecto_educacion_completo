class RegistrarPago{
  String id = "";
  String codigo = "";//Codigo
  String tipopago = "";
  int valor = 0;
  String metodopago = "";
  String referencia = "";
  DateTime fechapago = DateTime.now();


  RegistrarPago(this.codigo,this.tipopago,this.valor,this.referencia,this.fechapago,this.metodopago,this.id);

  Map<String,dynamic> toMap(){
    return{
      'codigo' :codigo,
      'tipopago' :tipopago,
      'valor' :valor,
      'metodopago' :metodopago,
      'referencia' :referencia,
      'fechapago' :fechapago,
      'id':id,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'codigo': codigo,
      'tipopago': tipopago,
      'valor': valor,
      'referencia': referencia,
      'fechapago': fechapago.toIso8601String(),
      'metodopago': metodopago,
       'id' : id,
    };
  }

  factory RegistrarPago.fromJson(Map<String, dynamic> json) {
    return RegistrarPago(
      json['codigo'],
      json['tipopago'],
      json['valor'],
      json['referencia'],
      DateTime.parse(json['fechapago']),
      json['metodopago'],
      json['id'],
    );
  }

}