import 'package:googleapis/cloudsearch/v1.dart';

class UsuarioWhatsapp {
  int numcel = 0;
  String nombrecliente = "";
  DateTime ultimo_mensaje = DateTime.now();
  int mensajes_novistos = 0;

  UsuarioWhatsapp(this.numcel,this.nombrecliente,this.ultimo_mensaje,this.mensajes_novistos);

  Map<String,dynamic> toMap(){
    return{
      'numcel':numcel,
      'nombrecliente':nombrecliente,
      'ultimo_mensaje':ultimo_mensaje,
      'mensajes_novistos' : mensajes_novistos,
    };
  }
}

class MensajeWhatsapp{
  String idmensaje;
  Map<String, dynamic> messages = {};
  String urlarchivo = "";
  String usuario_mensaje = "";


  MensajeWhatsapp(this.idmensaje,this.messages,this.urlarchivo,this.usuario_mensaje);

}