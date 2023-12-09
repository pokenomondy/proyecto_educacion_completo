import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as material;
import '../../Utils/EnviarMensajesWhataspp.dart';
import '../../Utils/RealtimeData/WhatsappBaseData.dart';

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
            builder: (context)  => PlantillaDetalle(),
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

class PlantillaDetalle extends StatefulWidget {

  @override
  PlantillaDetalleState createState() => PlantillaDetalleState();

}

class PlantillaDetalleState extends State<PlantillaDetalle> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        StreamBuilder(
          stream: WhatsappData().getmensajesWhatsapp(),
          builder: (context, snapshot){
            if (snapshot.hasError) {
              return Center(child: Text('Error al cargar los mensajes'));
            }
            if (!snapshot.hasData) {
              return Center(child: Text('cargando'));
            }

            List<Map<String, dynamic>>? mensajeswhatsap = snapshot.data;
            print("a cargado ${mensajeswhatsap?.length}");
            print(mensajeswhatsap);
            return Text("");
          },
        ),
      ],
    );
  }
}