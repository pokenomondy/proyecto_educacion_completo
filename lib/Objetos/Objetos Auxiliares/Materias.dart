class Materia {
  String nombremateria = "";

  Materia(this.nombremateria);

  Map<String, dynamic> toMap(){
    return{
      "nombremateria":nombremateria,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'nombremateria': nombremateria,
    };
  }

  factory Materia.fromJson(Map<String, dynamic> json) {
    return Materia(
      json['nombremateria'],
    );
  }

}