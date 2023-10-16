class CuentasBancarias {
  String tipoCuenta;
  String numeroCuenta;
  String numeroCedula;
  String nombreCuenta;

  CuentasBancarias(this.tipoCuenta, this.numeroCuenta, this.numeroCedula, this.nombreCuenta);

  Map<String, dynamic> toMap() {
    return {
      'tipoCuenta': tipoCuenta,
      'numeroCuenta': numeroCuenta,
      'numeroCedula': numeroCedula,
      'nombreCuenta': nombreCuenta,
    };
  }
  Map<String, dynamic> toJson() {
    return {
      "tipoCuenta":tipoCuenta,
      "numeroCuenta":numeroCuenta,
      "numeroCedula":numeroCedula,
      "nombreCuenta":nombreCuenta,
    };
  }

  factory CuentasBancarias.fromJson(Map<String, dynamic> json) {
    return CuentasBancarias(
      json['tipoCuenta'],
      json['numeroCuenta'],
      json['numeroCedula'],
      json['nombreCuenta'],
    );
  }
}