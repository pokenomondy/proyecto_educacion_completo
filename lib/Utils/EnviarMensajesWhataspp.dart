import 'dart:convert';
import 'package:dashboard_admin_flutter/Config/Config.dart';
import 'package:dashboard_admin_flutter/Objetos/AgendadoServicio.dart';
import 'package:http/http.dart' as http;
import '../Config/Config.dart';
import '../Config/Config.dart';


class enviarmensajewsp{
  String tokenwsp = "";
  String apiurl =  "";
  Config configuracion = Config();

  //Listar plantillas, obtenerlas
  Future<List<Map<String, dynamic>>> getMessageTemplates() async {
    try {
      print(tokenwsp);
      print(apiurl);

      final headers = {
        'Authorization': 'Bearer ${tokenwsp}',
        'Content-Type': 'application/json',
      };

      final response = await http.get(Uri.parse(apiurl), headers: headers);

      print(response.body);

      if (response.statusCode == 200) {
        // Convierte la respuesta JSON a una lista de mapas y devuelve el resultado
        final responseData = jsonDecode(response.body);

        if (responseData.containsKey("data") && responseData["data"] is List) {
          // La clave "data" existe y es una lista
          return List<Map<String, dynamic>>.from(responseData["data"]);
        } else {
          print('Error: La respuesta JSON no contiene una lista en la clave "data".');
          return [];
        }
      } else {
        // Maneja el error según tus necesidades
        print('Error al obtener las plantillas: ${response.statusCode}');
        print('Error al obtener las plantillas: ${response.body}');
        return [];
      }
    } catch (e) {
      // Maneja el error según tus necesidades
      print('Error al obtener las plantillas: $e');
      return [];
    }
  }








  enviarmensajewsp() {
    initenviarmensajewsp() ;
  }

  Future<void> initenviarmensajewsp() async {
    tokenwsp = configuracion.tokenwsp;
    apiurl = configuracion.apiurl;
  }

  //Notificación cuando un trabajo esta entregado a admin
  void sendMessageAvisoTrabajoEntregadoAdmin(String phoneNumber, ServicioAgendado selectedServicio) async{
    String templateName = "trabajoentregadoadminaviso";
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
                'text': '${selectedServicio!.materia}'
              },{'type': 'text',
                'text': '${selectedServicio.codigo}'
              },{'type': 'text',
                'text': '${selectedServicio.fechaentrega}'
              },{'type': 'text',
                'text': '${selectedServicio.tutor}'
              },{'type': 'text',
                'text': '${selectedServicio.cliente}'
              },
            ]
          }
        ]
      }
    };
    final headers = {
      'Authorization': 'Bearer ${tokenwsp}',
      'Content-Type': 'application/json'
    };
    final response = await http.post(Uri.parse(apiurl), headers: headers, body: jsonEncode(payload));
    if (response.statusCode == 200) {
      print('Mensaje enviado con éxito');
    } else {
      print('Error al enviar el mensaje: ${response.statusCode}');
    }

  }


  void CreatePlantilla() async{
    final headers = {
      'Authorization': 'Bearer ${tokenwsp}',
      'Content-Type': 'application/json'
    };
    final payload = {
      "name": "seasonal_promotion",
      "language": "en_US",
      "category": "MARKETING",
      "components": [
        {
          "type": "HEADER",
          "format": "TEXT",
          "text": "Our {{1}} is on!",
          "example": {
            "header_text": [
              "Summer Sale"
            ]
          }
        },
        {
          "type": "BODY",
          "text": "Shop now through {{1}} and use code {{2}} to get {{3}} off of all merchandise.",
          "example": {
            "body_text": [
              [
                "the end of August","25OFF","25%"
              ]
            ]
          }
        },
        {
          "type": "FOOTER",
          "text": "Use the buttons below to manage your marketing subscriptions"
        },
        {
          "type":"BUTTONS",
          "buttons": [
            {
              "type": "QUICK_REPLY",
              "text": "Unsubscribe from Promos"
            },
            {
              "type":"QUICK_REPLY",
              "text": "Unsubscribe from All"
            }
          ]
        }
      ]
    };

    final response = await http.post(Uri.parse(apiurl), headers: headers, body: jsonEncode(payload));
    if (response.statusCode == 200) {
      print('Plantilla subida con exito ');
    } else {
      print('Error al subir el mensaje: ${response.statusCode}');
      print(response.body);
    }
  }



}


