import 'dart:convert';
import 'package:dashboard_admin_flutter/Config/Config.dart';
import 'package:http/http.dart' as http;
import '../Config/Config.dart';
import '../Config/Config.dart';


class enviarmensajewsp{
  String tokenwsp = "";
  String apiurl =  "";
  Config configuracion = Config();

  enviarmensajewsp() {
    initenviarmensajewsp() ;
  }

  Future<void> initenviarmensajewsp() async {
    tokenwsp = configuracion.tokenwsp;
    apiurl = configuracion.apiurl;
  }

  //Enviarmensaje de prueba, este no sirve aun
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

  //Notificación cuando un trabajo esta entregado a admin
  void sendMessageAvisoTrabajoEntregadoAdmin(String phoneNumber,String codigo,String cliente,String fechaentrega,String nombretutor) async{
    String templateName = "trabajoentregadoadmon";
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
                'text': '$codigo'
              },{'type': 'text',
                'text': '$cliente'
              },{'type': 'text',
                'text': '$fechaentrega'
              },{'type': 'text',
                'text': '$nombretutor'
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

  //Envíar mensaje a el tutor y adicional enviar mensaje a administrador, para confirmar que se envio
  void sendMessageAvisoConfirmacionTutor(String phoneNumber,String tipoServicio,String materia,String nombretutor, String preciotutor,String fechaentrega, String codigoconfirmacion, String idsolicitudconfirmada) async{

}


}


