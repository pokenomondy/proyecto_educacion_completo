class Carrera {
  String nombrecarrera = "";
  int ultimaModificacion = 1672534800;


  Carrera(this.nombrecarrera,this.ultimaModificacion);

  Map<String, dynamic> toMap(){
    return{
      "nombre carrera":nombrecarrera,
      'ultimaModificacion':ultimaModificacion,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre carrera': nombrecarrera,
      'ultimaModificacion' : ultimaModificacion,
    };
  }

  factory Carrera.fromJson(Map<String, dynamic> json) {
    return Carrera(
      json['nombre carrera'],
      json['ultimaModificacion'],

    );
  }

}