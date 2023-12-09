import 'package:dashboard_admin_flutter/Config/theme.dart';
import 'package:dashboard_admin_flutter/Utils/Firebase/Uploads.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as dialog;
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import '../../Config/elements.dart';



class ConfigInicialPrimerAcceso extends StatefulWidget {
  @override
  ConfigInicialPrimerAccesoState createState() => ConfigInicialPrimerAccesoState();
}

class ConfigInicialPrimerAccesoState extends State<ConfigInicialPrimerAcceso> {
  //Colores
  late Color pickerColor = Color(0xff493a3a);
  late Color colorPrimaryColor = Color(0xff493a3a);
  late Color colorSecundarycolor = Color(0xff493a3a);
  final TextEditingController nombre_empresa = TextEditingController();
  final TextEditingController solicitud_empresa = TextEditingController();
  final TextEditingController confirmacion_empresa = TextEditingController();
  final ThemeApp theme = ThemeApp();


  void cambiarcolor(Color color) {
    setState(() => colorPrimaryColor = color);
  }

  @override
  Widget build(BuildContext context) {
    const double width = 920;
    return Center(
      child: ItemsCard(
        height: 420,
        width: width,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              //Nombre de empresa
             SizedBox(
               width: width*0.4,
               child: Column(
                 mainAxisAlignment: MainAxisAlignment.center,
                 children: [
                   Padding(
                     padding: const EdgeInsets.symmetric(vertical: 22),
                     child: Text(
                       "Configuracion inicial",
                       style: theme.styleText(25, true, theme.primaryColor),
                     ),
                   ),
                   Text(
                     'Nombre de empresa',
                     style: theme.styleText(14, true, theme.grayColor),
                   ),
                   SizedBox(
                     width: (width/2)*0.7,
                     child: RoundedTextField(
                       placeholder: "Nombre de empresa",
                       controller: nombre_empresa,
                     ),
                   ),
                   //Mnesaje de copiar
                   //Color primarío
                   Padding(
                     padding: const EdgeInsets.only(top: 20,bottom: 12),
                     child: Text(
                       'Colores de la empresa',
                       style: theme.styleText(14, true, theme.grayColor),
                     ),
                   ),
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
                 ],
               ),
             ),
              SizedBox(
                width: width*0.6,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: SizedBox(
                        child: Row(
                          children: [
                            Expanded(
                                child: Text(
                                  'Solicitud mensaje',
                                  style: theme.styleText(16, true, theme.grayColor),
                                  textAlign: TextAlign.center,
                                ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 20),
                              child: IconButton(
                                  icon: const Icon(
                                    dialog.Icons.info_outline,
                                    size: 20,
                                  ),
                                  onPressed: () => dialog.showDialog(
                                      context: context,
                                      builder: (BuildContext context) => tutorial()
                                  )
                              ),
                            )
                          ],
                        ),
                      )
                    ),
                    _SlideTextBox(
                      Icons: const [
                       dialog.Icons.message_outlined,
                        dialog.Icons.messenger_outline,
                      ],
                        children: [
                          MensajeTextBox(
                            placeholder: "Ingrese su mensaje de solicitud predeterminado",
                            controller: solicitud_empresa,
                          ),
                          MensajeTextBox(
                            solicitud: false,
                            placeholder: "Ingrese su mensaje de confirmacion predeterminado",
                            controller: confirmacion_empresa,
                          ),
                        ]
                    ),
                    //Botón color
                    //Color ventas
                    //Envíar info
                    PrimaryStyleButton(
                        width: 100,
                        tamanio: 14,
                        function: (){
                          String Primarycolor = colorToHex(colorPrimaryColor);
                          String Secundarycolor = colorToHex(colorSecundarycolor);
                          //Uploads().uploadconfiginicial(Primarycolor, Secundarycolor, nombre_empresa.text);
                          _redireccionaDashboarc();

                        }, text: "Enviar"
                    ),
                  ],
                ),
              )
            ],
          )
          //Primary Background
        ],
      ),
    );
  }

  dialog.Dialog tutorial(){
    return dialog.Dialog(
      backgroundColor: theme.primaryColor.withOpacity(0),
      child: ItemsCard(
        margin: 8,
        width: 400,
        height: 420,
        children: [
          Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 15),
              child: Text(
                "Ejemplo Mensajes",
                style: theme.styleText(22, true, theme.primaryColor)
              ),
          ),
          const _SlideTextBox(
              Icons: [
                dialog.Icons.message_outlined,
                dialog.Icons.messenger_outline,
              ],
              children: <Widget> [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 15.0),
                  child: Text(
                    "🔴TIPO SERVICIO = /servicio/\n🔴SOLICITUD = /idcotizacion/\n🔴MATERIA = /materia/\n🔴FECHA ENTREGA = /fechaentrega\n🔴HORA ENTREGA =  /horaentrega\n🔴RESUMEN = /resumen\n🔴INFORMACIÓN CLIENTE = /infocliente\n🔴ARCHIVOS =/urlarchivos/",
                    maxLines: null,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 15.0),
                  child: Text(
                    "CONFIRMACIONES DE SERVICIOS\n\nCONFIRMACIÓN DE /servicioplural/ DUFY ASESORÍAS\n\n/servicio/ CONFIRMADO\n\nMatería: /materia/\n/rolusuario/: /nombreusuario/\nPrecio: /preciousuario/\nFecha de entrega:/fecha de entrega/\nCódigo de confirmación: /codigo/\nID solicitud confirmada: /idsolicitud/",
                    maxLines: null,
                  ),
                ),
              ]
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 15.0),
            child: PrimaryStyleButton(
                width: 100,
                function: (){
                  Navigator.pop(context);
                }, text: "Cerrar"),
          )
        ],
      ),
    );
  }
  
  String colorToHex(Color color) {
    return '#' + color.value.toRadixString(16).padLeft(8, '0');
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
              buttonColor: theme.blackColor,
              tapColor: theme.primaryColor,
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

  void _redireccionaDashboarc() async{
      //Si no esta vacio, mande a dashbarod
      Navigator.pushReplacementNamed(context, '/home/dashboard');
      print("nos vamos a dashboard");
  }
}

class _SlideTextBox extends StatefulWidget{
  final List<Widget> children;
  final List<IconData> Icons;

  const _SlideTextBox({
    Key?key,
    required this.children,
    required this.Icons,
  }):super(key: key);

  _SlideTextBoxState createState() => _SlideTextBoxState();

}

class _SlideTextBoxState extends State<_SlideTextBox> with SingleTickerProviderStateMixin{

  final ThemeApp themeApp = ThemeApp();
  late List<bool> activo = [for(int i = 0; i < widget.children.length; i++) i == 0];
  late Widget widgetActivo;

  @override
  Widget build(BuildContext context){
    for(int i=0; i<widget.children.length; i++){
      if(activo[i]){
        widgetActivo = widget.children[i];
      }
    }
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: hallarBotones(),
          ),
          widgetActivo
        ],
      ),
    );
  }

  List<Row> hallarBotones(){
    const double iconSize = 16;
    return widget.Icons.asMap().entries.map((entry) {
      final index = entry.key;
      final icon = entry.value;
      final String text = index == 0 ? "Solicitud" : "Confirmacion";

      return Row(
        children: [
          Padding(
              padding: const EdgeInsets.only(left: 5),
              child: Text(text)
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
          width: iconSize * 2,
          height: iconSize * 2,
          alignment: Alignment.center,
          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
          decoration: BoxDecoration(
            color: activo[index] ? themeApp.primaryColor : themeApp.whitecolor,
            borderRadius: BorderRadius.circular(80),
            boxShadow: [BoxShadow(
              spreadRadius: 2,
              blurRadius: 7,
              color: themeApp.grayColor.withOpacity(0.15),
              offset: const Offset(0, 3)
            )]
          ),
          child: IconButton(
            onPressed: () {
              setState(() {
                activo = List.generate(widget.children.length, (i) => i == index);
              });
            },
            icon: Icon(icon, size: iconSize, color: activo[index] ? themeApp.whitecolor : themeApp.primaryColor,),
          ),
        ),
      ]
      );
    }).toList();
  }

}