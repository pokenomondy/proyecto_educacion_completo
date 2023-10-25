import 'package:dashboard_admin_flutter/Config/Config.dart';
import 'package:dashboard_admin_flutter/Utils/Firebase/Load_Data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../Objetos/Solicitud.dart';
import '../Utils/Drive Api/GoogleDrive.dart';
import '../Utils/Utiles/FuncionesUtiles.dart';

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
  Config configuracion = Config();
  bool configloaded = false;


  @override
  void initState() {
    loadactualizadores();
    configuracion.initConfig().then((_) {
      setState(() {
        configloaded = true;
      }); // Actualiza el estado para reconstruir el widget
    });
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
    if (!configloaded) {
      print("cargando vainas");
      // Configuración aún no cargada, muestra un indicador de carga o contenido temporal
      return Text('cargando'); // Ejemplo de indicador de carga
    }else{
      return Container(
        width: widget.currentwidth+400,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //Primary Color
            Row(
              children: [
                Text('Primary Color: '),
                Container(
                  height: 20,
                  width: 20,
                  color: configuracion.primaryColor,
                  child: Text('A'),
                ),
              ],
            ),
            //Secundary Color
            Row(
              children: [
                Text('Secundary Color: '),
                Container(
                  height: 20,
                  width: 20,
                  color: configuracion.Secundarycolor,
                  child: Text('A'),
                ),
              ],
            ),
            //Nombre de la empresa
            Text('Nombre de la empresa : ${configuracion.nombreempresa}'),
            //Cerrar sesión
            FilledButton(child: Text('Cerrar sesión'), onPressed: (){
              signOut();
            }),
            //Solicitudes con Drive Api
            Column(
              children: [
                Text('------ SOLICITUDES DRIVE API PLUGIN -----'),
                Text("id carpeta solicitudes = ${configuracion.idcarpetaSolicitudes}")
              ],
            ),
            //Pagos con Drive Api
            Column(
              children: [
                Text('------ PAGOS DRIVE API PLUGIN -----'),
                Text("id carpeta pagos = ${configuracion.idcarpetaPagos}")
              ],
            ),
            //Plugins con fechas de validez del programa

          ],
        ),
      );
    }
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

