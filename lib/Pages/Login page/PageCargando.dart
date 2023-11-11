import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dashboard_admin_flutter/Dashboard.dart';
import 'package:dashboard_admin_flutter/Objetos/Clientes.dart';
import 'package:dashboard_admin_flutter/Pages/SolicitudesNew.dart';
import 'package:dashboard_admin_flutter/Utils/Firebase/Load_Data.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart' as material;
import '../../Objetos/Solicitud.dart';
import '../../Objetos/Tutores_objet.dart';
import '../../Utils/Firebase/ActualizarInformacion.dart';
import '../../Utils/Firebase/DeleteLocalData.dart';

class PageCargando extends StatefulWidget {

  const PageCargando({Key? key,
  }) : super(key: key);

  @override
  PageCargandoState createState() => PageCargandoState();
}

class PageCargandoState extends State<PageCargando> {
  bool cargacompleta = false;
  final db = FirebaseFirestore.instance; //inicializar firebase
  //Clientes
  String cliente_actual = "";
  List<Clientes> cliente_List = [];
  int cliente_numerocargado = 0;
  //Solicitudes
  String solicitud_actual = "";
  List<Solicitud> solicitud_list = [];
  int solicitudes_numerocargado = 0;
  //Tutores
  String tutor_actual = "";
  List<Tutores> tutor_List = [];
  int tutores_numerocargado = 0;

  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized(); // Asegura que Flutter esté inicializado
    loadconfiguraciones();
    super.initState();
  }

  Future loadconfiguraciones() async{
    cargaregular();
  }

  //Load datos regularmente
  Future <void> cargaregular() async{
    //Actualizamos clientes
    await ActualizarInformacion().actualizarclientes(
        onClienteAdded: (Clientes clienteactualizacion){
          setState(() {
            cliente_actual = clienteactualizacion.nombreCliente;
            cliente_List.add(clienteactualizacion);
            cliente_numerocargado = cliente_List.length;
          });
        }
    );
    //Actualizamos solicitudes
    await ActualizarInformacion().actualizarsolicitudes(
        onSolicitudAddedd: (Solicitud solicitudactualizaicon){
          setState(() {
            solicitud_actual = solicitudactualizaicon.idcotizacion.toString();
            solicitud_list.add(solicitudactualizaicon);
            solicitudes_numerocargado = solicitud_list.length + 471;
          });
        }
    );
    //Actualizar tutores
    await ActualizarInformacion().actualizartutores(
        onTutorAdded: (Tutores tutoractualizacion){
          setState(() {
            tutor_actual = tutoractualizacion.nombrewhatsapp;
            tutor_List.add(tutoractualizacion);
            tutores_numerocargado = tutor_List.length;
          });
        }
    );

    //actualizar tabla de materias
    //actualizar carreras
    //actualizar universidades
    //Configuración de plugins y licencias
    //configuiración de mensajes


    //Comprobemos que salio good?
    comporbaciondescargacorrecta();
  }
  Future <void> comporbaciondescargacorrecta() async{
    if(solicitudes_numerocargado==0){
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('solicitudes_list');
      await LoadData().obtenerSolicitudes(
        onSolicitudAdded: (Solicitud nuevaSolicitud) {
          setState(() {
            solicitud_actual = nuevaSolicitud.idcotizacion.toString();
            solicitud_list.add(nuevaSolicitud);
            solicitudes_numerocargado = solicitud_list.length + 471;
          });
        },
      );
    }
    if(cliente_numerocargado==0){
      await LoadData().obtenerclientes(
        onClienteAdded: (Clientes clienteactualizacion){
          setState(() {
            cliente_actual = clienteactualizacion.nombreCliente;
            cliente_List.add(clienteactualizacion);
            cliente_numerocargado = cliente_List.length;
          });
        }
      );
      print("esto no va a pasar");
    }
    if(tutores_numerocargado==0){
      await LoadData().obtenertutores(
        onTutorAdded: (Tutores nuevotutor){
          tutor_actual = nuevotutor.nombrewhatsapp;
          tutor_List.add(nuevotutor);
          tutores_numerocargado = tutor_List.length;
        }
      );
    }
    setState(() {
      cargacompleta = true;
    });
    //reiniciar licencias y plugins
    reiniciarcontador();
  }

  Future <void> reiniciarcontador()async{
    Map<String, dynamic> servicioData = {};
    CollectionReference actualizacion = db.collection("ACTUALIZACION");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    servicioData['verificadoractualizar'] = DateTime.now();
    await actualizacion.doc("Plugins").update(servicioData);
    prefs.remove('datos_descargados_plugins');
    prefs.remove('configuracion_plugins');
    LoadData().configuracion_plugins();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('Cargando variables'),
        Text("Cargando clientes $cliente_actual , numero $cliente_numerocargado cargados"),
        Text("cargando solicitudes $solicitud_actual, numero $solicitudes_numerocargado cargados"),
        Text("cargando tutores $tutor_actual, numero $tutores_numerocargado cargados"),
        Text("Cargando materias, cargando carreras, cargando universidades,plugins y licencias y mensajes"),
        ProgressBar(),
        if(cargacompleta==true)
          FilledButton(child: Text("cargado todo"), onPressed: (){
            material.Navigator.push(context, material.MaterialPageRoute(
              builder: (context)  => Dashboard(showSolicitudesNew: false, solicitud: Solicitud.empty(), showTutoresDetalles: false, tutor: Tutores.empty())
            ));
          }),
        FilledButton(child: Text("reiniciar solicitudesList"),
            onPressed: ()async{
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.remove('solicitudes_list');
              cargaregular();
            }),
      ],
    );
  }
}