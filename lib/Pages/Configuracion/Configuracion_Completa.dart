import 'package:dashboard_admin_flutter/Config/Config.dart';
import 'package:dashboard_admin_flutter/Config/theme.dart';
import 'package:dashboard_admin_flutter/Objetos/Configuracion/objeto_configuracion.dart';
import 'package:dashboard_admin_flutter/Utils/Firebase/Load_Data.dart';
import 'package:dashboard_admin_flutter/Utils/Firebase/StreamBuilders.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart' as dialog;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../Objetos/Solicitud.dart';
import '../../Providers/Providers.dart';
import '../../Utils/Firebase/DeleteLocalData.dart';
import '../../Utils/Firebase/Uploads.dart';
import '../../Utils/Utiles/FuncionesUtiles.dart';
import '../Login page/ConfigInicial.dart';

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
  late Color pickerColor = Color(0xff493a3a);
  int numsolicitudes = 0;
  Config configuracion = Config();
  bool configloaded = false;
  String msgsolicitud = "";
  String msgsconfirmacioncliente = "";
  List<bool> editarcasilla = List.generate(2, (index) => false);
  Color colorcambio = Color(0xff493a3a);
  List<bool> editarcasillamensajes = List.generate(2, (index) => false);
  TextEditingController controllersolicitud = TextEditingController();
  TextEditingController controllerconfirmacion = TextEditingController();


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
                            child: Text('Nombre de la empresa : ${configuracioncargada!.nombreEmpresa}',
                              style: ThemeApp().styleText(16, true, ThemeApp().primaryColor),),
                          ),
                          //Primary Color
                          editColor('Color principal',configuracioncargada!.primaryColor,0),
                          //Secundary Color
                          editColor('Color secundario',configuracioncargada!.secundaryColor,1),
                          //Solicitudes con Drive Api
                          if(obtenerBool(configuracioncargada.solicitudesDriveApiFecha)==true)
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
                          if(obtenerBool(configuracioncargada.pagosDriveApiFecha)==true)
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
                                  CartaPlugin(function: (){}, titulo: "Solicitudes Drive Api", activacion: obtenerBool(configuracioncargada!.solicitudesDriveApiFecha), fecha: configuracioncargada!.solicitudesDriveApiFecha),
                                  CartaPlugin(function: (){}, titulo: "Pagos Drive Api", activacion: obtenerBool(configuracioncargada!.pagosDriveApiFecha), fecha: configuracioncargada!.pagosDriveApiFecha),
                                  //Tutores
                                  CartaPlugin(function: (){}, titulo: "Tutores System", activacion: obtenerBool(configuracioncargada!.tutoresSistemaFecha), fecha: configuracioncargada!.tutoresSistemaFecha),

                                ],
                              ),
                            ),
                          ),
                          //Mensajes personalizados
                          const Padding(
                            padding: EdgeInsets.only(top: 10),
                            child: Text('------ MENSAJES PERSONALIZADOS -----',
                              style: TextStyle(fontWeight: FontWeight.bold),),
                          ),
                          editMensajes('Mensajes Solicitud',configuracioncargada.mensajeSolicitudes,0,controllersolicitud),
                          editMensajes('Mensajes de confirmación',configuracioncargada.mensajeConfirmacionCliente,1,controllerconfirmacion),
                          //Cerrar sesión
                          PrimaryStyleButton(function: signOut, text: "Cerrar Sesion"),
                          //Experimentos
                          Padding(
                            padding: EdgeInsets.only(top: 10),
                            child: Text('------ FUNCIONES EXPERIMENTALES -----',
                              style: TextStyle(fontWeight: FontWeight.bold),),
                          ),
                          //Bases de datos en Stream
                          Text('Numero de lecturas en Drive'),
                          Text('Numero de lecturas en base de datos'),
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

  Widget editColor(String title, String color,int index){
    const double verticalPadding = 3.0;

    return Row(
      children: [
        if (!editarcasilla[index])
          Padding(
            padding: const EdgeInsets.symmetric(vertical: verticalPadding),
            child: Row(
              children: [
                ThemeApp().colorRow(Utiles().hexToColor(color), title),
                GestureDetector(
                  onTap: (){
                    setState(() {
                      editarcasilla[index] = !editarcasilla[index];
                    });
                  },
                  child: const Icon(FluentIcons.edit),
                )
              ],
            )
          ),
        if (editarcasilla[index])
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
            child: Row(
              children: [
                Row(
                  children: [
                    seleccionadorcolor(colorcambio, 'Color primario', (Color newColor) {
                      setState(() {
                        colorcambio = newColor;
                      });
                    }),
                    //Actualizar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3.0),
                      child: GestureDetector(
                        onTap: () async{
                          //cambiando de color
                          Uploads().modifyColors(index,colorToHex(colorcambio) );
                          setState(() {
                            editarcasilla[index] = !editarcasilla[index];
                          });
                        },
                        child: const Icon(FluentIcons.check_list),
                      ),
                    ),
                    //cancelar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3.0),
                      child: GestureDetector(
                        onTap: (){
                          setState(() {
                            editarcasilla[index] = !editarcasilla[index]; // Alterna entre los modos de visualización y edición
                          });
                        },
                        child: const Icon(FluentIcons.cancel),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
      ],
    );
  }

  Widget editMensajes(String title,String mensaje, int index, TextEditingController controller){
    const double verticalPadding = 3.0;
    //meter al controller el texto
    controller = TextEditingController(text: mensaje);


    return Row(
      children: [
        if (!editarcasillamensajes[index])
          Padding(
              padding: const EdgeInsets.symmetric(vertical: verticalPadding),
              child: Row(
                children: [
                  Text("${title} = ${mensaje}"),
                  GestureDetector(
                    onTap: (){
                      setState(() {
                        editarcasillamensajes[index] = !editarcasillamensajes[index];
                      });
                    },
                    child: const Icon(FluentIcons.edit),
                  )
                ],
              )
          ),
        if (editarcasillamensajes[index])
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
            child: Row(
              children: [
                Row(
                  children: [
                    //cambio
                    Container(
                      width: 120,
                      child: TextBox(
                        controller: controller,
                        maxLines: null,
                      ),
                    ),
                    //Actualizar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3.0),
                      child: GestureDetector(
                        onTap: () async{
                          print("el texto es ${controller.text}");
                          Uploads().modifyMensajes(index, controller.text);
                          setState(() {
                            editarcasillamensajes[index] = !editarcasillamensajes[index];
                          });
                        },
                        child: const Icon(FluentIcons.check_list),
                      ),
                    ),
                    //cancelar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3.0),
                      child: GestureDetector(
                        onTap: (){
                          setState(() {
                            editarcasillamensajes[index] = !editarcasillamensajes[index]; // Alterna entre los modos de visualización y edición
                          });
                        },
                        child: const Icon(FluentIcons.cancel),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
      ],
    );

  }

  String colorToHex(Color color) {
    return '#' + color.value.toRadixString(16).padLeft(8, '0');
  }

  bool obtenerBool(DateTime fecha) {
    DateTime fechaActual = DateTime.now();
    return fecha.isAfter(fechaActual);
  }

  Widget seleccionadorcolor(Color colorcito,String colortext,Function(Color) onColorChanged){
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: SizedBox(
        width: 200,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            PrimaryStyleButton(
                buttonColor: ThemeApp().blackColor,
                tapColor: ThemeApp().primaryColor,
                tamanio: 14,
                function: (){
                  changecolordialog(colorcito,onColorChanged);
                },
                text: colortext
            ),
            GestureDetector(
              onTap: (){
                changecolordialog(colorcito,onColorChanged);
              },
              child: CircleAvatar(
                backgroundColor: colorcito,
                radius: 20.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void changecolordialog(Color colorcito, Function(Color) onColorChanged){
    dialog.showDialog(
        context: context,
        builder: (BuildContext context){
          return dialog.AlertDialog(
            title: const Text('Escoger color'),
            content: SingleChildScrollView(
              child: ColorPicker(
                pickerColor: pickerColor,
                onColorChanged: (color) {
                  setState(() {
                    pickerColor = color;
                    colorcito = color; // Actualiza colorPrimaryColor con el nuevo color
                  });
                },
              ),
            ),
            actions: [
              FilledButton(
                child: const Text('Select'),
                onPressed: () {
                  onColorChanged(colorcito);
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        }
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