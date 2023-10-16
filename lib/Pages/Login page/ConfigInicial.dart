import 'package:dashboard_admin_flutter/Utils/Firebase/Uploads.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as dialog;
import 'package:flutter_colorpicker/flutter_colorpicker.dart';



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

  void cambiarcolor(Color color) {
    setState(() => colorPrimaryColor = color);
  }

  @override
  Widget build(BuildContext context) {
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
                    placeholder: 'Nombre de empresa',
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
            //Primary Background
            //Botón color
            //Color ventas
            //Envíar info
            FilledButton(
                child: Text('Envíar'),
                onPressed: (){
                  String Primarycolor = colorToHex(colorPrimaryColor);
                  String Secundarycolor = colorToHex(colorSecundarycolor);
                  Uploads().uploadconfiginicial(Primarycolor, Secundarycolor, nombre_empresa);
                  _redireccionaDashboarc();
                }),
          ],
        ),
      ),
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
      Navigator.pushReplacementNamed(context, '/home/dashboard');
      print("nos vamos a dashboard");
  }
}