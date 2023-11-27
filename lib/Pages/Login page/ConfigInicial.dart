import 'package:dashboard_admin_flutter/Config/theme.dart';
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
  late Color pickerColor = Color(0xff493a3a);
  late Color colorPrimaryColor = Color(0xff493a3a);
  late Color colorSecundarycolor = Color(0xff493a3a);
  final TextEditingController nombre_empresa = TextEditingController();
  final ThemeApp theme = ThemeApp();

  void cambiarcolor(Color color) {
    setState(() => colorPrimaryColor = color);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ItemsCard(
        height: 350,
        width: 400,
        children: [
          //Nombre de empresa
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: Text(
              "Configuracion inicial",
              style: theme.styleText(23, true, theme.primaryColor),
            ),
          ),
          Text(
              'Nombre de empresa',
              style: theme.styleText(14, true, theme.grayColor),
          ),
          SizedBox(
            width: 350,
            child: RoundedTextField(
              placeholder: "Nombre de empresa",
              controller: nombre_empresa,
            ),
          ),
          //Mnesaje de copiar
          //Color primarío
          Padding(
            padding: const EdgeInsets.only(top: 10,bottom: 8),
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
          //Primary Background
          //Botón color
          //Color ventas
          //Envíar info
          PrimaryStyleButton(
            width: 100,
            tamanio: 14,
            function: (){
            String Primarycolor = colorToHex(colorPrimaryColor);
            String Secundarycolor = colorToHex(colorSecundarycolor);
            Uploads().uploadconfiginicial(Primarycolor, Secundarycolor, nombre_empresa.text);
            _redireccionaDashboarc();
          }, text: "Enviar"
          ),
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
            CircleAvatar(
              backgroundColor: colorcito,
              radius: 20.0,
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