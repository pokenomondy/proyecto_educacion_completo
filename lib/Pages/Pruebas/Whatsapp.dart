import 'dart:convert';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dashboard_admin_flutter/Objetos/AgendadoServicio.dart';
import 'package:dashboard_admin_flutter/Objetos/RegistrarPago.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as material;
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../Config/Config.dart';
import '../../Objetos/Whatsapp/UserWhats.dart';
import '../../Utils/EnviarMensajesWhataspp.dart';
import '../../Utils/RealtimeData/WhatsappBaseData.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';

class WhatsPruebas extends StatefulWidget {

  @override
  WhatsPruebasState createState() => WhatsPruebasState();

}

class WhatsPruebasState extends State<WhatsPruebas> {
  List<Map<String, dynamic>> plantillasmensajes = [];
  bool cargadoplantillas = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FilledButton(child: Text('Search'), onPressed: () async{
          print("obtener mensajes");
          plantillasmensajes = await enviarmensajewsp().getMessageTemplates();
          setState(() {
            cargadoplantillas = true;
          });
        }),
        FilledButton(child: Text('chat whats'), onPressed: (){
          material.Navigator.push(context, material.MaterialPageRoute(
            builder: (context)  => ChatWhatsPrincipal(),
          ));
        }),
        if(cargadoplantillas)
          Expanded(
              child: ListView.builder(
                  itemCount: plantillasmensajes.length,
                  itemBuilder: (contex,index){
                    final template = plantillasmensajes[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Column(
                        children: [
                          Text(template['name']),
                          Text(template['language']),
                          Text(template['status']),
                          Text(template['category']),

                          Container(
                            width: 300,
                            color: Colors.green,
                            child: Column(
                              children: [
                                for (var component in template['components'])
                                  dibujarcomponente(component),

                              ],
                            ),
                          ),
                          /*
                          FilledButton(child: Text('Ver'), onPressed: (){
                            material.Navigator.push(context, material.MaterialPageRoute(
                              builder: (context)  => PlantillaDetalle(),
                            ));
                          }),

                           */
                        ],
                      ),
                    );
                  })),
      ],
    );
  }

  Widget dibujarcomponente(component){
    //Headers
    if(component['type']=="HEADER"){
      if(component['format']=="TEXT"){
        return Text(
          component['text'],
          style: TextStyle(
            fontSize: 15.0,  // Tamaño del texto
            fontWeight: FontWeight.bold,  // Negrita
          ),
        );
      }else{
        return Text("Sin programar");
      }
    }
    //Body
    else if(component['type']=="BODY"){
      return Text(component['text']);
    }
    //Footers
    else if(component['type']=="FOOTER"){
      return Text("footer ${component['text']}");
    }
    //Else
    else{
      return Text("Sin programar");
    }
  }

}

class ChatWhatsPrincipal extends StatefulWidget {

  @override
  ChatWhatsPrincipalState createState() => ChatWhatsPrincipalState();

}

class ChatWhatsPrincipalState extends State<ChatWhatsPrincipal> {

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        PlantillaDetalle(),
      ],
    );
  }
}

class PlantillaDetalle extends StatefulWidget {

  @override
  PlantillaDetalleState createState() => PlantillaDetalleState();

}

class PlantillaDetalleState extends State<PlantillaDetalle> {
  bool carguemensajes = false;
  int numeroactivo = 0;
  Config configuracion = Config();
  String tokenwsp = "";
  final audioPlayer = AudioPlayer();
  bool isPlaying = false;
  UsuarioWhatsapp? usuarioWhatsapp;

  PlantillaDetalleState() {
    initenviarmensajewsp() ;
  }

  Future<void> initenviarmensajewsp() async {
    tokenwsp = configuracion.tokenwsp;
  }

  @override
  void initState() {

    audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() {
        isPlaying = state == PlayerState.playing;
      });
    });

    super.initState();
  }

  @override
  void dispose(){
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentwidth = MediaQuery.of(context).size.width;
    final currentheight = MediaQuery.of(context).size.height;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          color: Colors.red,
          width: currentwidth/2,
          height: currentheight,
          child: StreamBuilder(
            stream: WhatsappData().getMensajesWhatsapp(),
            builder: (context, snapshot){
              if (snapshot.hasError) {
                return Center(child: Text('Error al cargar los mensajes'));
              }
              if (!snapshot.hasData) {
                return Center(child: Text('cargando'));
              }

              List<UsuarioWhatsapp>? usuarios = snapshot.data;


              return Container(
                width: currentwidth / 2,
                height: currentheight,
                child: ListView.builder(
                  itemCount: usuarios?.length,
                  itemBuilder: (context, index) {
                    UsuarioWhatsapp usuario = usuarios![index];

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          carguemensajes = true;
                          usuarioWhatsapp = usuario;
                        });
                        //Aqui vamos a eliminar el numero de mensajes escuchados
                      },
                      child: Container(
                        width: currentwidth / 2,
                        color: Colors.green,
                        height: 70,
                        child: Column(
                          children: [
                            Text(usuario.numcel.toString()),
                            Text('chat'),
                            Text(usuario.ultimo_mensaje.toString()),
                            Text('mensajes no leidos = ${usuario.mensajes_novistos}')
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );


            },
          ),
        ),
        if(carguemensajes)
          ChatMensaje(usuarioWhatsapp: usuarioWhatsapp!,),
      ],
    );
  }




}

class ChatMensaje extends StatefulWidget {
  final UsuarioWhatsapp usuarioWhatsapp;

  const ChatMensaje({Key?key,
    required this.usuarioWhatsapp,
  }) :super(key: key);
  @override
  ChatMensajeState createState() => ChatMensajeState();
}

class ChatMensajeState extends State<ChatMensaje> {
  String mensaje_enviar = "";

  @override
  Widget build(BuildContext context) {
    final currentwidth = MediaQuery.of(context).size.width;
    final currentheight = MediaQuery.of(context).size.height;
    return Container(
      width: currentwidth/2-10,
      height: currentheight-10,
      child: Column(
        children: [
          Text(widget.usuarioWhatsapp.numcel.toString()),
          StreamBuilder(
            stream: WhatsappData().getConversacionesWhatsapp(widget.usuarioWhatsapp.numcel.toString()),
            builder: (context, snapshot){
              if (snapshot.hasError) {
                return Center(child: Text('Error al cargar los mensajes'));
              }
              if (!snapshot.hasData) {
                return Center(child: Text('cargando'));
              }

              print("sreambuilder recibido");

              List<MensajeWhatsapp>? mensajes = snapshot.data;
              mensajes?.sort((a, b) => b.messages['timestamp'].compareTo(a.messages['timestamp']));

              return Container(
                width: currentwidth / 2,
                height: currentheight-80,
                child: ListView.builder(
                  reverse: true,
                  itemCount: mensajes?.length,
                  itemBuilder: (context, index) {
                    MensajeWhatsapp mensaje = mensajes![index];

                    return Card(
                      child: Column(
                        children: [
                          cargarmensaje(mensaje,'573214031073'),
                        ],
                      ),
                    );
                  },
                ),
              );


            },
          ),
          Row(
            children: [
              Container(
                color: Colors.red,
                width: currentwidth/2-80,
                height: 40,
                child: TextBox(
                  decoration: BoxDecoration(
                    color: Config.secundaryColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  onChanged: (value){
                    setState(() {
                      mensaje_enviar = value;
                    });
                  },
                  maxLines: null,
                ),
              ),
              FilledButton(child: Text('send'), onPressed: (){
                enviarmensajewsp().enviarmensajetexto(widget.usuarioWhatsapp.numcel,mensaje_enviar);
              }),
            ],
          ),

        ],
      ),
    );
  }

  Widget cargarmensaje(MensajeWhatsapp mensaje,String num){
    if(mensaje.messages['type']=="text"){
      bool usuario = mensaje.usuario_mensaje == "ADMIN";
      Color colorusuario = usuario ? Colors.green : Colors.red ;
      int timestamp = int.tryParse(mensaje.messages['timestamp'].toString()) ?? 0;
      print(timestamp);

      return Container(
        color: colorusuario,
        child: Column(
          children: [
            Text("${mensaje.messages['text']['body']}"),
            Text("${DateTime.fromMillisecondsSinceEpoch(timestamp*1000)}"),
          ],
        ),
      );
    }
    else if(mensaje.messages['type']=="document"){
      String filename = mensaje.messages['document']['filename'];
      return GestureDetector(child:
      Text("Ver pdf $filename "),
        onTap: (){
          _launchUrl(mensaje.urlarchivo);
        },
      );
    }
    else if(mensaje.messages['type']=="image"){
      if(mensaje.urlarchivo==""){
        return Text('Cargando imagen');
      }else{
        return GestureDetector(
          child: Image.network(mensaje.urlarchivo,
            width: 200,
            height: 200,
            fit: BoxFit.cover,
          ),onTap: (){
          _launchUrl(mensaje.urlarchivo);
        },
        );
      }

    }
    else if(mensaje.messages['type']=="audio"){
      return GestureDetector(child:
      Text("Escuchar audio "),
        onTap: (){
          _launchUrl(mensaje.urlarchivo);
        },
      );
    }
    else{
      return Text('no programado');
    }

  }

  void _launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'No se pudo abrir el enlace $url';
    }
  }

}

class MensajesWhatsapp extends ChangeNotifier {
  List<MensajeWhatsapp> _mensajeswhatsap = [];

  // Método para eliminar todas las conversaciones
  void clearConversaciones() {
    _mensajeswhatsap.clear();
    notifyListeners();
  }

  // Método para agregar una conversación
  void addConversacion(MensajeWhatsapp mensajes) {
    _mensajeswhatsap.add(mensajes);
    notifyListeners(); // Notificar a los oyentes que la lista de conversaciones ha cambiado
  }

  // Getter para obtener la lista de conversaciones
  List<MensajeWhatsapp> get conversaciones => _mensajeswhatsap;
}
