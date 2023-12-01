class PagoDebeCliente {
  DateTime fecha;
  String codigo;
  String materia;
  String cliente;
  String debeCliente;
  double sumPrecioTutorReal;

  PagoDebeCliente({
    required this.fecha,
    required this.codigo,
    required this.materia,
    required this.cliente,
    required this.debeCliente,
    required this.sumPrecioTutorReal,
  });
}

class PagoDebeTutor {
  DateTime fecha;
  String tutor;
  String codigo;
  String materia;
  String debeTutor;
  double sumPrecioTutorReal;

  PagoDebeTutor({
    required this.fecha,
    required this.tutor,
    required this.codigo,
    required this.materia,
    required this.debeTutor,
    required this.sumPrecioTutorReal,
  });
}

class OrganizadorPagos {
  List<PagoDebeCliente> pagosClientes = [];
  List<PagoDebeTutor> pagosTutores = [];

  // Métodos para agregar pagos a las listas correspondientes
  void agregarPagoCliente(PagoDebeCliente pagoCliente) {
    pagosClientes.add(pagoCliente);
  }

  void agregarPagoTutor(PagoDebeTutor pagoTutor) {
    pagosTutores.add(pagoTutor);
  }
}