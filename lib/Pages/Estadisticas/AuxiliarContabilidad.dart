import 'dart:typed_data';
import 'dart:convert';
import 'dart:html';
import 'package:cloud_firestore/cloud_firestore.dart' as cloud;
import 'package:dashboard_admin_flutter/Objetos/Solicitud.dart';
import 'package:excel/excel.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import '../../Objetos/AgendadoServicio.dart';
import '../../Objetos/RegistrarPago.dart';
import '../../Utils/Firebase/Load_Data.dart';
import '../../Utils/Firebase/StreamBuilders.dart';

class ContabilidadCompleta extends StatefulWidget{

  @override
  ContabilidadCompletaState createState() => ContabilidadCompletaState();

}

class ContabilidadCompletaState extends State<ContabilidadCompleta> {
  List<ServicioAgendado> contabilidadList = [];
  List<RegistrarPago> pagosList = [];
  bool carguelistas = false;

  @override
  void dispose() {
    // Cierra tu controlador de stream en el dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentheight = MediaQuery.of(context).size.height-60;
    return Column(
      children: [
        StreamBuilder<List<ServicioAgendado>>(
          stream: stream_builders().getServiciosAgendados(),
          builder: (context, snapshot) {
            List<ServicioAgendado> servicioagendadoList = [];
            if (snapshot.hasError) {
              return Center(
                  child: Text('Error al cargar las solicitudes'));
            }
            if (!snapshot.hasData) {
              return Center(child: Text('cargando'));
            }

            servicioagendadoList = snapshot.data!;

            return Container(
                height: currentheight,
                child: ListView.builder(
                    itemCount: servicioagendadoList.length, // Agrega itemCount aquí
                    itemBuilder: (context,index) {
                      ServicioAgendado? servicio = servicioagendadoList[index];

                      return Row(
                        children: [
                          Text("EL codigo es ${servicio.codigo}",style: TextStyle(
                              fontSize: 1),),
                          Text(servicio.pagos.length.toString()),
                        ],
                      );
                    }
                )
            );
          },
        ),
      ],
    );
  }

  /*
  StreamBuilder<cloud.QuerySnapshot<Map<String, dynamic>>> escucharnumerodepagos(String codigo){
    return StreamBuilder(
        stream: cloud.FirebaseFirestore.instance.collection("CONTABILIDAD").doc(codigo).collection("PAGOS").snapshots(),
        builder: (context,snapshot){
          if(!snapshot.hasData) return Text('CARGANDO NO HAY NADA');
          List<RegistrarPago> pagos = [];
          for(var pagoDoc in snapshot.data!.docs){
            RegistrarPago newpago = RegistrarPago(
              pagoDoc['codigo'],
              pagoDoc['tipopago'],
              pagoDoc['valor'],
              pagoDoc['referencia'],
              pagoDoc['fechapago'].toDate(),
              pagoDoc['metodopago'],
              pagoDoc.data().toString().contains('id') ? pagoDoc.get('id') : 'NO ID',
            );
            pagos.add(newpago);
            anadirpagosacache(codigo, newpago);
          }
          return Text(pagos.length.toString(),style: TextStyle(
              fontSize: 1));
        }
    );
  }
  
   */

  /*
  void anadirpagosacache(String codigo, RegistrarPago newpago) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<ServicioAgendado>? serviciosagendadoList = await stream_builders().cargarserviciosagendados();
    int solicitudIndex = serviciosagendadoList!.indexWhere((solicitud) => solicitud.codigo == codigo);

    print("guardando pago en cache $codigo");
    if (solicitudIndex != -1) {
      // Verificar si el pago ya existe para evitar duplicados
      bool pagoExistente = serviciosagendadoList[solicitudIndex].pagos.any((pago) => pago.codigo == newpago.codigo);

      if (!pagoExistente) {
        // Agregar el nuevo pago a la lista existente
        serviciosagendadoList[solicitudIndex].pagos.add(newpago);

        // Guardar la lista actualizada en SharedPreferences
        String solicitudesJsondos = jsonEncode(serviciosagendadoList);
        await prefs.setString('servicios_agendados_list_stream', solicitudesJsondos);
      }
    }
  }
  
   */

}