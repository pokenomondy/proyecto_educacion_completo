import 'dart:convert';
import 'package:http/http.dart' as http;

class enviarmensajewsp{

  void sendMessage(String templateName, String phoneNumber, String message, String token, String apiurl) async {
    final payload = {
      'messaging_product': 'whatsapp',
      'to': phoneNumber,
      'type': 'template',
      'template': {
        'name': templateName,
        'language': {'code': 'es'},
        'components': [
          {
            'type': 'body',
            'parameters': [
              {'type': 'text',
              'text': '1'
              },{'type': 'text',
                'text': '2'
              },{'type': 'text',
                'text': '3'
              },{'type': 'text',
                'text': '4'
              },{'type': 'text',
                'text': '5'
              },{'type': 'text',
                'text': '6'
              },{'type': 'text',
                'text': '7'
              }
            ]
          }
        ]
      }
    };

    final headers = {
      'Authorization': 'Bearer ${token}',
      'Content-Type': 'application/json'
    };

    final response = await http.post(Uri.parse(apiurl), headers: headers, body: jsonEncode(payload));

    if (response.statusCode == 200) {
      print('Mensaje enviado con éxito');
    } else {
      print('Error al enviar el mensaje: ${response.statusCode}');
    }
  }
}


