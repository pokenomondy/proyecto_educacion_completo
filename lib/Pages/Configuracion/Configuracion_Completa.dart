import 'package:dashboard_admin_flutter/Config/Config.dart';
import 'package:dashboard_admin_flutter/Config/theme.dart';
import 'package:dashboard_admin_flutter/Objetos/Configuracion/Configuracion_Configuracion.dart';
import 'package:dashboard_admin_flutter/Utils/Firebase/Load_Data.dart';
import 'package:dashboard_admin_flutter/Utils/Firebase/StreamBuilders.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../Objetos/Solicitud.dart';
import '../../Providers/Providers.dart';
import '../../Utils/Firebase/DeleteLocalData.dart';
import '../../Utils/Firebase/Uploads.dart';
import '../../Utils/Utiles/FuncionesUtiles.dart';

class ConfiguracionDatos extends StatefulWidget {
  const ConfiguracionDatos({super.key});

  @override
  ConfiguracionDatosState createState() => ConfiguracionDatosState();
}

class ConfiguracionDatosState extends State<ConfiguracionDatos> {

  @override
  Widget build(BuildContext context) {
    final currentwidth = MediaQuery.of(context).size.width;
    final tamanowidth = (currentwidth/1.5)-30;
    print("se dibuja la solicitud");
    return _PrimaryColumnDatos(currentwidth: tamanowidth,);
  }
}

class _PrimaryColumnDatos extends StatefulWidget {

  final double currentwidth;

  const _PrimaryColumnDatos({Key?key,
    required this.currentwidth,
  }) :super(key: key);
  @override
  _PrimaryColumnDatosState createState() => _PrimaryColumnDatosState();
}

class _PrimaryColumnDatosState extends State<_PrimaryColumnDatos> {
  List<Solicitud> solicitudesList = [];
  int numsolicitudes = 0;
  Config configuracion = Config();
  bool configloaded = false;
  String msgsolicitud = "";
  String msgsconfirmacioncliente = "";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final currentheight = MediaQuery.of(context).size.height;
    return Consumer<ConfiguracionAplicacion>(
        builder: (context, ConfigProvider, child) {
          ConfiguracionPlugins? configuracioncargada = ConfigProvider.config;

          return Column(
            children: [
              Container(
                width: widget.currentwidth+400,
                height: currentheight-110,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          //Nombre de la empresa
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text('Nombre de la empresa : ${configuracioncargada!.nombre_empresa}',
                              style: ThemeApp().styleText(16, true, ThemeApp().primaryColor),),
                          ),
                          //Primary Color
                          ThemeApp().colorRow(Utiles().hexToColor(configuracioncargada!.PrimaryColor), "Primary Color: "),
                          //Secundary Color
                          ThemeApp().colorRow(Utiles().hexToColor(configuracioncargada!.SecundaryColor), "Secundary Color: "),
                          //Solicitudes con Drive Api
                          if(obtenerBool(configuracioncargada.SolicitudesDriveApiFecha)==true)
                            Column(
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(top: 10),
                                  child: Text('------ SOLICITUDES DRIVE API PLUGIN -----',
                                    style: TextStyle(fontWeight: FontWeight.bold),),
                                ),
                                Text("id carpeta solicitudes = ${configuracioncargada.idcarpetaSolicitudes}")
                              ],
                            ),
                          //Pagos con Drive Api
                          if(obtenerBool(configuracioncargada.PagosDriveApiFecha)==true)
                            Column(
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(top: 10),
                                  child: Text('------ PAGOS DRIVE API PLUGIN -----',
                                    style: TextStyle(fontWeight: FontWeight.bold),),
                                ),
                                Text("id carpeta pagos = ${configuracioncargada.idcarpetaPagos}")
                              ],
                            ),
                          //Plugins con fechas de validez del programa
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CartaPlugin(function: (){
                                    print("Sistema basico");
                                  }, titulo: "Sistema Básico", activacion: obtenerBool(configuracioncargada!.basicoFecha), fecha: configuracioncargada!.basicoFecha, ),
                                  CartaPlugin(function: (){}, titulo: "Solicitudes Drive Api", activacion: obtenerBool(configuracioncargada!.SolicitudesDriveApiFecha), fecha: configuracioncargada!.SolicitudesDriveApiFecha),
                                  CartaPlugin(function: (){}, titulo: "Pagos Drive Api", activacion: obtenerBool(configuracioncargada!.PagosDriveApiFecha), fecha: configuracioncargada!.PagosDriveApiFecha),
                                  //Tutores
                                  CartaPlugin(function: (){}, titulo: "Tutores System", activacion: false, fecha: DateTime(2023,1,1)),

                                ],
                              ),
                            ),
                          ),
                          Column(
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(top: 10),
                                child: Text('------ MENSAJES PERSONALIZADOS -----',
                                  style: TextStyle(fontWeight: FontWeight.bold),),
                              ),
                              Text("Mensajes de Solicitudes = ${configuracioncargada!.SOLICITUD}"),
                              Container(
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                width: 200,
                                child: TextBox(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  placeholder: 'Mensaje solicitdes',
                                  onChanged: (value){
                                    setState(() {
                                      msgsolicitud = value;
                                    });
                                  },
                                  maxLines: null,
                                ),
                              ),
                              PrimaryStyleButton(function: (){
                                Uploads().uploadconfigmensaje(msgsolicitud,"SOLICITUD");
                              }, text: "Subir mensaje solicitud"),
                              Text("Mensajes de Solicitudes = ${configuracioncargada!.CONFIRMACION_CLIENTE}"),
                              Container(
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                width: 200,
                                child: TextBox(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  placeholder: 'Mensaje Confirmaciones clientes',
                                  onChanged: (value){
                                    setState(() {
                                      msgsconfirmacioncliente = value;
                                    });
                                  },
                                  maxLines: null,
                                ),
                              ),
                              PrimaryStyleButton(function: (){
                                Uploads().uploadconfigmensaje(msgsconfirmacioncliente,"CONFIRMACION_CLIENTE");
                              }, text: "Subir mensaje confirmacion"),
                            ],
                          ),
                          //Eliminar base de datos de solicitudesList
                          Padding(
                            padding: EdgeInsets.only(top: 10),
                            child: Text('------ REINICIAR VARIABLES -----',
                              style: TextStyle(fontWeight: FontWeight.bold),),
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              PrimaryStyleButton(function: (){
                                DeleteLocalData().eliminarsolicitudesLocal();
                              }, text: "Reiniciar las solicitudes"),
                              PrimaryStyleButton(function: (){
                                DeleteLocalData().eliinarTutoresLocal();
                              }, text: "Reiniciar Tutores"),
                              PrimaryStyleButton(function: (){
                                DeleteLocalData().eliminarclientesLocal();
                              }, text: "Reiniciar Clientes"),
                            ],
                          ),
                          //Cerrar sesión
                          PrimaryStyleButton(function: signOut, text: "Cerrar Sesion"),
                          //Experimentos
                          Padding(
                            padding: EdgeInsets.only(top: 10),
                            child: Text('------ FUNCIONES EXPERIMENTALES -----',
                              style: TextStyle(fontWeight: FontWeight.bold),),
                          ),
                          //Bases de datos en Stream
                        ],
                      ),
                    ],
                  ),
                ),
              )
            ],
          );
        }
    );
  }

  bool obtenerBool(DateTime fecha) {
    DateTime fechaActual = DateTime.now();
    return fecha.isAfter(fechaActual);
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