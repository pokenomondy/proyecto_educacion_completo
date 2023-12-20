class Universidad {
  String nombreuniversidad = "";
  int ultimaModificacion = 1672534800;

  Universidad(this.nombreuniversidad,this.ultimaModificacion);

  Map<String, dynamic> toMap(){
    return{
      "nombre Universidad":nombreuniversidad,
      'ultimaModificacion' : ultimaModificacion,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre Universidad': nombreuniversidad,
      'ultimaModificacion' : ultimaModificacion,
    };
  }

  factory Universidad.fromJson(Map<String, dynamic> json) {
    return Universidad(
      json['nombre Universidad'],
      json['ultimaModificacion'],
    );
  }
}