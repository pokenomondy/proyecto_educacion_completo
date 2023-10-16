class Carrera {
  String nombrecarrera = "";

  Carrera(this.nombrecarrera);

  Map<String, dynamic> toMap(){
    return{
      "nombre carrera":nombrecarrera,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre carrera': nombrecarrera,
    };
  }

  factory Carrera.fromJson(Map<String, dynamic> json) {
    return Carrera(
      json['nombre carrera'],
    );
  }

}