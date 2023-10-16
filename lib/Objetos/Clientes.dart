class Clientes{
  String carrera = "";
  String universidad = "";
  String nombreCliente = "";
  int numero = 0;
  String nombrecompletoCliente = "";


  Clientes(this.carrera,this.universidad,this.nombreCliente,this.numero,this.nombrecompletoCliente);

  Map<String,dynamic> toMap(){
    return{
      'Carrera' :carrera,
      "Universidadd" : universidad,
      "nombreCliente":nombreCliente,
      'numero': numero,
      'nombrecompletoCliente': nombrecompletoCliente,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'Carrera': carrera,
      'Universidad': universidad,
      'nombreCliente': nombreCliente,
      'numero': numero,
      'nombrecompletoCliente': nombrecompletoCliente,
    };
  }

  factory Clientes.fromJson(Map<String, dynamic> json) {
    return Clientes(
      json['Carrera'],
      json['Universidad'],
      json['nombreCliente'],
      json['numero'],
      json['nombrecompletoCliente'],
    );
  }
}