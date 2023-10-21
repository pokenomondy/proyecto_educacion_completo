import 'package:dashboard_admin_flutter/Utils/Firebase/Load_Data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../Objetos/Solicitud.dart';
import '../Utils/Drive Api/GoogleDrive.dart';

class ConfiguracionDatos extends StatefulWidget {
  @override
  _ConfiguracionDatosState createState() => _ConfiguracionDatosState();
}

class _ConfiguracionDatosState extends State<ConfiguracionDatos> {

  @override
  Widget build(BuildContext context) {
    final currentwidth = MediaQuery.of(context).size.width;
    final currentheight = MediaQuery.of(context).size.height-140;
    final tamanowidth = (currentwidth/3)-30;
    print("se dibuja la solicitud");
    return NavigationView(
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 12),
        child: Row(
          children: [
            PrimaryColumnDatos(currentwidth: tamanowidth,),
          ],
        ),
      ),
    );
  }
}

class PrimaryColumnDatos extends StatefulWidget {

  final double currentwidth;

  const PrimaryColumnDatos({Key?key,
    required this.currentwidth,
  }) :super(key: key);
  @override
  _PrimaryColumnDatosState createState() => _PrimaryColumnDatosState();
}

class _PrimaryColumnDatosState extends State<PrimaryColumnDatos> {
  String fechasolicitudeslocal = "";
  DateTime fechasolicitdeslocaldate = DateTime.now();
  String fechasolicitudesfirebase = "";
  DateTime fechasolicitudesfirebasedate = DateTime.now();
  List<Solicitud> solicitudesList = [];
  int numsolicitudes = 0;

  @override
  void initState() {
    loadactualizadores();
    super.initState();
  }

  void loadactualizadores()async{
    Map<String, dynamic> actualizadoresFechas = await LoadData().verificar_cambios();
    setState((){
      fechasolicitudesfirebase = actualizadoresFechas['fecha_firebase'];
      fechasolicitudesfirebasedate = DateTime.parse(fechasolicitudesfirebase);
      fechasolicitudeslocal = actualizadoresFechas['fecha_firebase'];
      fechasolicitdeslocaldate = DateTime.parse(fechasolicitudesfirebase);
    });
  }


  void actualizarsolicitudes() async{
    print("obtener solicitudes");
    await LoadData().obtenerSolicitudes(
      onSolicitudAdded: (Solicitud nuevaSolicitud) {
        setState(() {
          solicitudesList.add(nuevaSolicitud);
          numsolicitudes = solicitudesList.length + 471;
        });
      },
    );
  }




  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.currentwidth+400,
      child: Column(
        children: [
          Text('Primary Color: '),
          Text('Secundary Color: '),
          Text('Button color: '),
          Text('Descarga de datos, cambios ?'),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('solicitudes actualización guardada: ${DateFormat('dd/MM/yyyy hh:mm a').format(fechasolicitudesfirebasedate)}'),
              Text('solicitudes actualizacion firebase: ${DateFormat('dd/MM/yyyy hh:mm a').format(fechasolicitdeslocaldate)}'),
            ],
          ),
          FilledButton(
          child: Text('Actualizar solicitudes'),
          onPressed: (){
            actualizarsolicitudes();
            print("actualizar solicitudes verificando");
          }),
          Text(numsolicitudes.toString()),
          FilledButton(child: Text('Cerrar sesión'), onPressed: (){
            signOut();
          })
        ],
      ),
    );
  }

  void signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      // La sesión se ha cerrado correctamente
      context.go('/');
    } catch (e) {
      print("Error al cerrar sesión: $e");
    }
  }
}

