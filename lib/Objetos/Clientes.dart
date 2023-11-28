class Clientes{
  String carrera = "";
  String universidad = "";
  String nombreCliente = "";
  int numero = 0;
  String nombrecompletoCliente = "";
  DateTime fechaActualizacion = DateTime.now();
  //Nuevas variables
  String procedencia = "";
  DateTime fechaContacto = DateTime.now();

  Clientes(this.carrera,this.universidad,this.nombreCliente,this.numero,this.nombrecompletoCliente, this.fechaActualizacion,this.procedencia,this.fechaContacto);

  Map<String,dynamic> toMap(){
    return{
      'Carrera' :carrera,
      "Universidadd" : universidad,
      "nombreCliente":nombreCliente,
      'numero': numero,
      'nombrecompletoCliente': nombrecompletoCliente,
      'fechaActualizacion' : fechaActualizacion,
      'procedencia' : procedencia,
      'fechaContacto' : fechaContacto,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'Carrera': carrera,
      'Universidad': universidad,
      'nombreCliente': nombreCliente,
      'numero': numero,
      'nombrecompletoCliente': nombrecompletoCliente,
      'fechaActualizacion' : fechaActualizacion.toIso8601String(),
      'procedencia' : procedencia,
      'fechaContacto' : fechaContacto.toIso8601String(),
    };
  }

  factory Clientes.fromJson(Map<String, dynamic> json) {
    return Clientes(
      json['Carrera'],
      json['Universidad'],
      json['nombreCliente'],
      json['numero'],
      json['nombrecompletoCliente'],
      DateTime.parse(json['fechaActualizacion']),
      json['procedencia'],
      DateTime.parse(json['fechaContacto']),
    );
  }
}