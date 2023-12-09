import 'package:dashboard_admin_flutter/Config/Config.dart';
import 'package:dashboard_admin_flutter/Config/theme.dart';
import 'package:dashboard_admin_flutter/Utils/Firebase/Load_Data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../Objetos/Solicitud.dart';
import '../../Utils/Firebase/DeleteLocalData.dart';
import '../../Utils/Firebase/Uploads.dart';

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
    return NavigationView(
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 12),
        child: _PrimaryColumnDatos(currentwidth: tamanowidth,),
      ),
    );
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
    configuracion.initConfig().then((_) {
      setState(() {
        configloaded = true;
      });
    });
    super.initState();
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
      return const Text('cargando'); // Ejemplo de indicador de carga
    }else{
      return SizedBox(
        width: widget.currentwidth+400,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              //Nombre de la empresa
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text('Nombre de la empresa : ${configuracion.nombreempresa}',
                  style: ThemeApp().styleText(16, true, ThemeApp().primaryColor),),
              ),
              //Primary Color
              ThemeApp().colorRow(configuracion.primaryColor, "Primary Color: "),
              //Secundary Color
              ThemeApp().colorRow(configuracion.Secundarycolor, "Secundary Color: "),
              //Solicitudes con Drive Api
              if(configuracion.SolicitudesDriveApi==true)
                Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: Text('------ SOLICITUDES DRIVE API PLUGIN -----',
                        style: TextStyle(fontWeight: FontWeight.bold),),
                    ),
                    Text("id carpeta solicitudes = ${configuracion.idcarpetaSolicitudes}")
                  ],
                ),
              //Pagos con Drive Api
              if(configuracion.PagosDriveApi==true)
                Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: Text('------ PAGOS DRIVE API PLUGIN -----',
                        style: TextStyle(fontWeight: FontWeight.bold),),
                    ),
                    Text("id carpeta pagos = ${configuracion.idcarpetaPagos}")
                  ],
                ),
              //Plugins con fechas de validez del programa
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CartaPlugin(function: (){
                      print("Sistema basico");
                    }, titulo: "Sistema Básico", activacion: configuracion.basicoNormal, fecha: configuracion.basicofecha, ),
                    CartaPlugin(function: (){}, titulo: "Solicitudes Drive Api", activacion: configuracion.SolicitudesDriveApi, fecha: configuracion.SolicitudesDriveApiFecha),
                    CartaPlugin(function: (){}, titulo: "Pagos Drive Api", activacion: configuracion.PagosDriveApi, fecha: configuracion.PagosDriveApiFecha),
                    //Tutores
                    CartaPlugin(function: (){}, titulo: "Tutores System", activacion: false, fecha: DateTime(2023,1,1)),

                  ],
                ),
              ),
              //Mensajes personalizadas
              Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: Text('------ MENSAJES PERSONALIZADOS -----',
                      style: TextStyle(fontWeight: FontWeight.bold),),
                  ),
                  Text("Mensajes de Solicitudes = \n${configuracion.mensaje_solicitd}"),
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
                  Text("Mensajes de confirmaciones = \n${configuracion.mensaje_confirmacionCliente}"),
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
              PrimaryStyleButton(function: (){
                DeleteLocalData().eliminarsolicitudesLocal();
              }, text: "Reiniciar las solicitudes"),
              PrimaryStyleButton(function: (){
                DeleteLocalData().eliinarTutoresLocal();
              }, text: "Reiniciar Tutores"),
              PrimaryStyleButton(function: (){
                DeleteLocalData().eliminarclientesLocal();
              }, text: "Reiniciar Clientes"),
              //Cerrar sesión
              PrimaryStyleButton(function: signOut, text: "Cerrar Sesion"),
            ],
          ),
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