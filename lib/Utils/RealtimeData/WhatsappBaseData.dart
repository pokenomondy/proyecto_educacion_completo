import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import '../Firebase/CollectionReferences.dart';

class WhatsappData {
  CollectionReferencias referencias = CollectionReferencias();


  Stream<List<Map<String, dynamic>>> getmensajesWhatsapp() async* {
    DatabaseReference reference = FirebaseDatabase.instance.reference().child('whatsapp_messages');

    yield* reference.onValue.map((event) {
      final List<Map<String, dynamic>> messages = [];

      if (event.snapshot.value != null && event.snapshot.value is Map<dynamic, dynamic>) {
        Map<dynamic, dynamic> values = event.snapshot.value as Map<dynamic, dynamic>;

        values.forEach((key, value) {
          // Asegurémonos de que cada elemento es un Map<String, dynamic>
          if (value is Map<String, dynamic>) {
            // Añadimos el identificador (key) al mapa
            value['id'] = key;
            messages.add(value);
          }
        });
      }

      return messages;
    });
  }
}