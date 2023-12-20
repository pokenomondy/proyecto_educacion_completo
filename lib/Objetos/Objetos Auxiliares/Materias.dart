class Materia {
  String nombremateria = "";
  int ultimaModificacion = 1672534800;

  Materia(this.nombremateria,this.ultimaModificacion);

  Map<String, dynamic> toMap(){
    return{
      "nombremateria":nombremateria,
      'ultimaModificacion' : ultimaModificacion,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'nombremateria': nombremateria,
      'ultimaModificacion' : ultimaModificacion,
    };
  }

  factory Materia.fromJson(Map<String, dynamic> json) {
    return Materia(
      json['nombremateria'],
      json['ultimaModificacion'],
    );
  }

}