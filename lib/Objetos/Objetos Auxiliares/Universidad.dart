class Universidad {
  String nombreuniversidad = "";

  Universidad(this.nombreuniversidad);

  Map<String, dynamic> toMap(){
    return{
      "nombre Universidad":nombreuniversidad,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre Universidad': nombreuniversidad,
    };
  }

  factory Universidad.fromJson(Map<String, dynamic> json) {
    return Universidad(
      json['nombre Universidad'],
    );
  }
}