import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import '../../Objetos/Whatsapp/UserWhats.dart';
import '../Firebase/CollectionReferences.dart';

class WhatsappData {
  CollectionReferencias referencias = CollectionReferencias();


  Stream<List<UsuarioWhatsapp>> getMensajesWhatsapp() async* {
    DatabaseReference reference = FirebaseDatabase.instance.reference();

    await for (DatabaseEvent event in reference.onValue) {
      List<UsuarioWhatsapp> usuarios = [];

      if (event.snapshot.value != null && event.snapshot.value is Map<dynamic, dynamic>) {
        Map<dynamic, dynamic> values = event.snapshot.value as Map<dynamic, dynamic>;

        values.forEach((key, value) {
          if (value is Map<String, dynamic>) {
            value['id'] = key;
            int timestamp = value['ult_mensaje'] != null ? (value['ult_mensaje'] as int) : DateTime.now().millisecondsSinceEpoch;
            int mensajes_novistos = value['mensajes_novistos'] !=null ? value['mensajes_novistos'] as int : 0;
            DateTime fecha = DateTime.fromMillisecondsSinceEpoch(timestamp);
            int numcel = int.tryParse(key) ?? 0;
            UsuarioWhatsapp usuario = UsuarioWhatsapp(numcel, "S", fecha,mensajes_novistos);
            usuarios.add(usuario);
          }
        });
        yield usuarios;
      }
    }
  }

  Stream<List<MensajeWhatsapp>> getConversacionesWhatsapp(String numcel) async* {
    DatabaseReference reference =
    FirebaseDatabase.instance.reference().child(numcel).child("MENSAJES");

    await for (DatabaseEvent event in reference.onValue) {
      List<MensajeWhatsapp> mensajes = [];

      if (event.snapshot.value != null &&
          event.snapshot.value is Map<dynamic, dynamic>) {
        Map<dynamic, dynamic> values =
        event.snapshot.value as Map<dynamic, dynamic>;

        values.forEach((key, value) {
          if (value is Map<String, dynamic>) {
            // 'key' ya es el id del mensaje
            String archivo = value['archivo'];
            Map<String, dynamic> message = value['messages'];
            String usuario_mensaje = value['usuario_mensaje'];

            MensajeWhatsapp newmensaje =
            MensajeWhatsapp(key, message, archivo,usuario_mensaje);
            mensajes.add(newmensaje);
          }
        });

        yield mensajes;
      }
    }
  }



}