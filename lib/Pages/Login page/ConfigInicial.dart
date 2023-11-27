import 'package:dashboard_admin_flutter/Pages/Login%20page/LoginPage.dart';
import 'package:dashboard_admin_flutter/Utils/Firebase/Uploads.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as dialog;
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import '../../Config/Config.dart';
import '../../Dashboard.dart';
import '../../Objetos/Solicitud.dart';
import '../../Objetos/Tutores_objet.dart';
import '../../Utils/Utiles/FuncionesUtiles.dart';


class ConfigInicialPrimerAcceso extends StatefulWidget {
  @override
  ConfigInicialPrimerAccesoState createState() => ConfigInicialPrimerAccesoState();
}

class ConfigInicialPrimerAccesoState extends State<ConfigInicialPrimerAcceso> {
  //Colores
  Color pickerColor = Color(0xff493a3a);
  Color colorPrimaryColor = Color(0xff493a3a);
  Color colorSecundarycolor = Color(0xff493a3a);
  String nombre_empresa = "";
  Config configuracion = Config();

  //id carpeta solicitudes
  String idCarpetaSolciitudes = "";
  //id carpeta pagos
  String idCarpetaPagos = "";
  //mensajes de confirmaciones personalizado
  String mensaje_solicitudes = "";
  //Mensaje de confirmaciones
  String mensaje_confirmacion = "";
  bool configloaded = false;

  @override
  void initState() {
    super.initState();
    // Mover la lógica de inicialización aquí
    WidgetsFlutterBinding.ensureInitialized(); // Asegura que Flutter esté inicializado
    configuracion.initConfig().then((_) {
      setState((){
        configloaded = true;
      }); // Actualiza el estado para reconstruir el widget
    });
  }

  void cambiarcolor(Color color) {
    setState(() => colorPrimaryColor = color);
  }

  @override
  Widget build(BuildContext context) {
    if(configloaded==true){
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          width: 500,
          height: 500,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              //Mnesaje de copiar
              //Color primarío
              seleccionadorcolor(colorPrimaryColor, 'Color primario', (Color newColor) {
                setState(() {
                  colorPrimaryColor = newColor;
                });
              }),
              //Color secundario
              seleccionadorcolor(colorSecundarycolor, 'Color Secundario', (Color newColor) {
                setState(() {
                  colorSecundarycolor = newColor;
                });
              }),
              //Nombre de empresa
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Nombre de empresa'),
                  Container(
                    width: 500,
                    child: TextBox(
                      placeholder: 'Nombre de  ${configuracion.basicofecha} ${configuracion.basicoNormal}',
                      onChanged: (value){
                        setState(() {
                          nombre_empresa = value;
                        });
                      },
                      maxLines: null,
                    ),
                  ),
                ],
              ),
              //PLUGINS
              //id carpeta pagos - Estos solo cuando se tenga plugin activo
              if(configuracion.SolicitudesDriveApi==true)
                PluginsAdicional("Solicitudes Drive Api ${configuracion.SolicitudesDriveApiFecha}: ${configuracion.SolicitudesDriveApi}","Id carpeta solicitudes",(value){
                  setState(() {
                    idCarpetaSolciitudes = value;
                  });
                }),
              //id capreta solicitudes - Estoso lo cuando se tenga pugin activo{
              if(configuracion.PagosDriveApi==true)
                PluginsAdicional("Pagos Drive Api: ${configuracion.PagosDriveApiFecha } ${configuracion.PagosDriveApi}","Id carpeta pagos",(value){
                  setState(() {
                    idCarpetaPagos = value;
                  });
                }),
              //mensaje personalizado solicitudes
              mensajesPersonalizados('mensajes de solicitudes', 'solicitudes', 'Tipo de servicio: /servicio/'
                  '\n id cotización : /idcotizacion/'
                  '\n nombre materia : /materia/'
                  '\n fecha entrega : /fechaentrega/'
                  '\n hora entrega: /horaentrega/'
                  '\n información resumida : /resumen/'
                  '\n información detalalda : /infocliente/'
                  '\n url de archivos : /urlarchivos/ - Solo aplica con Dirve Api solicitud activo', (value){
                setState(() {
                  mensaje_solicitudes = value;
                });
              }),

              //mensajes personalizados confirmacion serivico
              mensajesPersonalizados('mensajes de confirmacion servicio', 'confirmación', 'Tipo de servicio: /servicio/'
                  '\nServicio plural : /servicioplural/'
                  '\n nombre materia : /materia/'
                  '\n rol o usuario : /rolusuario/'
                  '\n nombre usuario: /nombreusuario/'
                  '\n precio usuario: /preciousuario/'
                  '\n Fecha de entrega: /fechaentrega/'
                  '\n codigo confirmación: /codigo/'
                  '\n id solicitud confirmada: /idsolicitud/'
                  '\n Toca ver cuales mas pueden agregarse...', (value){
                setState(() {
                  mensaje_confirmacion = value;
                });
              }),

              //Envíar info
              FilledButton(
                  child: Text('Envíar'),
                  onPressed: (){
                    GuardarConfigInicicial();
                  }),
            ],
          ),
        ),
      );
    }else{
      return Text('cargando');
    }
  }

  void GuardarConfigInicicial(){
    String Primarycolor = colorToHex(colorPrimaryColor);
    String Secundarycolor = colorToHex(colorSecundarycolor);

    //Cosas obligatorias a llenar
    if(nombre_empresa.isEmpty && mensaje_solicitudes.isEmpty && mensaje_confirmacion.isEmpty){
      Utiles().notificacion("Debe colocar el nombre de empresa y mensajes", context, false, "log");
    }else{
      print("$nombre_empresa - ${mensaje_solicitudes}");
      Utiles().notificacion("Configuración inicial guaradada", context, true, "log");
      //mensajes
      Uploads().uploadconfigmensajeinicial(mensaje_confirmacion,mensaje_solicitudes);
      //upload config ionicial
      Uploads().uploadconfiginicial(Primarycolor, Secundarycolor, nombre_empresa,idCarpetaPagos,idCarpetaSolciitudes);
      _redireccionaDashboarc();
    }


  }

  Widget PluginsAdicional(String titulo,String placeholder, Function(String) onChanged){
    return Column(
      children: [
        Text(titulo),
        Container(
          width: 500,
          child: TextBox(
            placeholder: placeholder,
            onChanged: onChanged,
            maxLines: null,
          ),
        ),
      ],
    );
  }
  
  Widget mensajesPersonalizados(String titulo,String placeholder,String instrucciones,Function(String) onChanged){
    return Row(
      children: [
        Column(
          children: [
            Text(titulo),
            Container(
              width: 500,
              child: TextBox(
                placeholder: placeholder,
                onChanged: onChanged,
                maxLines: null,
              ),
            ),
          ],
        ),
        Column(
          children: [
            Text(instrucciones)
          ],
        )
      ],
    );
  }

  String colorToHex(Color color) {
    return '#' + color.value.toRadixString(16).padLeft(8, '0');
  }

  Widget seleccionadorcolor(Color colorcito,String colortext,Function(Color) onColorChanged){
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FilledButton(
          onPressed: (){
            changecolordialog(colorcito,onColorChanged);
          },
          child: Text(colortext),
        ),
        CircleAvatar(
          backgroundColor: colorcito,
          radius: 20.0,
        ),
      ],
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

  void _redireccionaDashboarc() async{
      //Si no esta vacio, mande a dashbarod
    Navigator.push(
      context,
      dialog.MaterialPageRoute(builder: (context) => Dashboard(showSolicitudesNew: false, solicitud: Solicitud.empty(), showTutoresDetalles: false, tutor: Tutores.empty(),)),
    );
      print("nos vamos a dashboard");
  }
}