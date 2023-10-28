import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dashboard_admin_flutter/Objetos/AgendadoServicio.dart';
import '../../Objetos/RegistrarPago.dart';

class Buscador{

  //Buscador de un servicio agendado en contabilidad
  Future<ServicioAgendado> buscaragendado(String codigobuscar) async {
    DocumentSnapshot getserviceagendado = await FirebaseFirestore.instance.collection("CONTABILIDAD").doc(codigobuscar).get();
    String codigo = getserviceagendado.get('codigo');
    String sistema = getserviceagendado.get('sistema');
    String materia = getserviceagendado.get('materia');
    DateTime fechasistema = getserviceagendado.get('fechasistema').toDate();
    String cliente = getserviceagendado.get('cliente');
    int preciocobrado = getserviceagendado.get('preciocobrado');
    DateTime fechaentrega = getserviceagendado.get('fechaentrega').toDate();
    String tutor = getserviceagendado.get('tutor');
    int preciotutor = getserviceagendado.get('preciotutor');
    String identificadorcodigo = getserviceagendado.get('identificadorcodigo');
    int idsolicitud = getserviceagendado.get('idsolicitud');
    int idcontable = getserviceagendado.get('idcontable');
    String entregadotutor = getserviceagendado.get('entregadotutor');
    String entregadocliente = getserviceagendado.get('entregadocliente');
    List<RegistrarPago> pagos = [];

    print("Campo 'codigo': $codigo");
    print("Campo 'sistema': $sistema");


    ServicioAgendado newservice = ServicioAgendado(codigo, sistema, materia, fechasistema, cliente, preciocobrado, fechaentrega, tutor, preciotutor, identificadorcodigo, idsolicitud, idcontable, pagos, entregadotutor,entregadocliente);

    return newservice;
  }
}