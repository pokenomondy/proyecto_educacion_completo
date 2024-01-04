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
  int ultimaModificacion = 1672534800;


  Clientes(this.carrera,this.universidad,this.nombreCliente,this.numero,this.nombrecompletoCliente, this.fechaActualizacion,this.procedencia,this.fechaContacto,this.ultimaModificacion);

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
      'ultimaModificacion' : ultimaModificacion,
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
      'ultimaModificacion' : ultimaModificacion,
    };
  }

  // Método .empty()
  factory Clientes.empty() {
    return Clientes(
      "", // carrera
      "", // universidad
      "", // nombreCliente
      0,  // numero
      "", // nombrecompletoCliente
      DateTime.now(), // fechaActualizacion
      "", // procedencia
      DateTime.now(), // fechaContacto
      0, // ultimaModificacion
    );
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
      json['ultimaModificacion'],
    );
  }
}