import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'Config.dart';

class Theme{
  Color primaryColor = const Color(0x1A000000);
  Color secundaryColor = const Color(0xFFF0F2F2);
  Color buttoncolor = const Color(0xFF1E1E1E);
  Color buttonSecundaryColor = const Color(0xFF0A76FC);
  Color redColor = Colors.redAccent;
  Color colorazulventas = const Color(0xFFB7DAFB);
  Color whitecolor = Colors.white;

  Theme () {
    Config config = Config();
    config.initConfig();
    primaryColor = config.primaryColor;

  }

  Widget colorRow(Color color, String text){
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Text(text,
            style: const TextStyle(
              fontFamily: "Poppins",
              fontWeight: FontWeight.bold
            ),
            ),
          ),
          Container(
            height: 20,
            width: 20,
            color: color,
            child: const Text(''),
          ),
        ],
      ),
    );
  }

  TextStyle styleText(double tamanio, bool isBold, Color color){
    return TextStyle(
        fontSize: tamanio,
        fontWeight: isBold? FontWeight.bold: FontWeight.w300,
        fontFamily: 'Poppins',
        color: color
    );
  }

}

class PrimaryStyleButton extends StatefulWidget{
  final bool invert;
  final VoidCallback function;
  final String text;
  final double tamanio;
  const PrimaryStyleButton({
    Key?key,
    required this.function,
    required this.text,
    this.invert = false,
    this.tamanio = 15,
  }):super(key: key);

  @override
  PrimaryStyleButtonState createState()=> PrimaryStyleButtonState();

}

class PrimaryStyleButtonState extends State<PrimaryStyleButton> {
  late Color buttonColor = !widget.invert ? Theme().buttonSecundaryColor : Theme().whitecolor;

  @override
  Widget build(BuildContext context) {
    double widthCalculate = widget.text.length * 9;
    double heigthCalculate = (widget.tamanio * 30) / 15;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: GestureDetector(
        onTapDown: (_) {
          setState(() {
            buttonColor = Theme().buttoncolor;
          });
        },
        onTapUp: (_) {
          setState(() {
            buttonColor = !widget.invert ? Theme().whitecolor : Theme().buttoncolor;
          });
        },
        onTap: () {
          widget.function();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: widthCalculate,
          height: heigthCalculate,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: buttonColor,
          ),
          child: Center(
            child: Text(
              widget.text,
              style: Theme().styleText(widget.tamanio, true, !widget.invert? Theme().whitecolor: Theme().buttonSecundaryColor ),
            ),
          ),
        ),
      ),
    );
  }
}

class CartaPlugin extends StatefulWidget{
  final String titulo;
  final bool activacion;
  final DateTime fecha;
  final VoidCallback function;

  const CartaPlugin({
    Key?key,
    required this.titulo,
    required this.activacion,
    required this.fecha,
    required this.function,
  }):super(key: key);

  @override
  CartaPluginState createState()=> CartaPluginState();

}

class CartaPluginState extends State<CartaPlugin>{

  @override
  Widget build(BuildContext context){
    TextStyle subtitulos = Theme().styleText(12, false, Theme().whitecolor);
    return Container(
      width: 150,
      height: 120,
      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: widget.activacion? Theme().buttonSecundaryColor: Theme().redColor,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
              widget.titulo,
            style: Theme().styleText(15, true, Theme().whitecolor),
          ),
          Text(
              widget.activacion? "Activo": "Inactivo",
            style: subtitulos,
          ),
          Text(
              "fecha de expiración:",
              style: Theme().styleText(12, true, Theme().whitecolor)
          ),
          Text(
              DateFormat('dd/MM/yyyy hh:mma').format(widget.fecha),
              style: subtitulos,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                PrimaryStyleButton(tamanio: 12, function: widget.function, text: widget.activacion? "Activar" : "Desactivar", invert: true,)
              ],
            ),
          )
        ],
      ),
    );
  }
}

