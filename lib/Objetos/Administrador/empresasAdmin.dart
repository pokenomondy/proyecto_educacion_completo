class ClaveEmpresa{
  String Empresa = "";
  String Contrasena = "";

  ClaveEmpresa(this.Empresa,this.Contrasena);

  Map<String, dynamic> toMap(){
    return{
      "Empresa":Empresa,
      'Contrasena':Contrasena,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      "Empresa":Empresa,
      'Contrasena':Contrasena,
    };
  }

  factory ClaveEmpresa.fromJson(Map<String, dynamic> json) {
    return ClaveEmpresa(
      json['Empresa'],
      json['Contrasena'],

    );
  }
}