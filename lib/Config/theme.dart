import 'package:flutter/material.dart';
import 'package:googleapis/drive/v2.dart';
import 'package:intl/intl.dart';
import 'Config.dart';

class ThemeApp{
  Color primaryColor = const Color(0x1A000000);
  Color secundaryColor = const Color(0xFFF0F2F2);
  Color buttoncolor = const Color(0xFF1E1E1E);
  Color buttonSecundaryColor = const Color(0xFF0A76FC);
  Color redColor = Colors.redAccent;
  Color colorazulventas = const Color(0xFFB7DAFB);
  Color whitecolor = Colors.white;

  ThemeApp () {
    Config config = Config();
    config.initConfig();
    primaryColor = config.primaryColor;
    secundaryColor = config.Secundarycolor;
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
  late Color buttonColor = !widget.invert ? ThemeApp().buttonSecundaryColor : ThemeApp().whitecolor;

  @override
  Widget build(BuildContext context) {
    double widthCalculate = widget.text.length * 9;
    double heigthCalculate = (widget.tamanio * 30) / 15;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: GestureDetector(
        onTapDown: (_) {
          setState(() {
            buttonColor = ThemeApp().buttoncolor;
          });
        },
        onTapUp: (_) {
          setState(() {
            buttonColor = !widget.invert ? ThemeApp().whitecolor : ThemeApp().buttoncolor;
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
              style: ThemeApp().styleText(widget.tamanio, true, !widget.invert? ThemeApp().whitecolor: ThemeApp().buttonSecundaryColor ),
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
    TextStyle subtitulos = ThemeApp().styleText(12, false, ThemeApp().whitecolor);
    return Container(
      width: 150,
      height: 120,
      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: widget.activacion? ThemeApp().buttonSecundaryColor: ThemeApp().redColor,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
              widget.titulo,
            style: ThemeApp().styleText(15, true, ThemeApp().whitecolor),
          ),
          Text(
              widget.activacion? "Activo": "Inactivo",
            style: subtitulos,
          ),
          Text(
              "fecha de expiración:",
              style: ThemeApp().styleText(12, true, ThemeApp().whitecolor)
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

class CircularLogo extends StatefulWidget{

  final String asset;
  final double width;
  final double height;
  final Color containerColor;
  final double border;
  final bool shadow;

  const CircularLogo({
    Key?key,
    required this.asset,
    this.width = 100,
    this.height = 100,
    this.containerColor = Colors.white,
    this.border = -1,
    this.shadow = false,
  }):super(key: key);

  @override
  CircularLogoState createState() => CircularLogoState();

}

class CircularLogoState extends State<CircularLogo>{

  @override
  Widget build(BuildContext context){
    final double border = widget.border == -1 ? (widget.width + widget.height)/4 : widget.border;
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(border),
        color: widget.containerColor,
        boxShadow: widget.shadow ? [BoxShadow(
          blurRadius: 7,
          spreadRadius: 2,
          offset: const Offset(0, 4),
          color: Colors.black.withOpacity(0.20),
        )] : null,
      ),
      child:  Center(
        child: Image.asset(
          widget.asset,
          width: widget.width*0.75,
          height: widget.height*0.75,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

}

class ItemsCard extends StatelessWidget{
  final List<Widget> children;
  final double width;
  final double height;
  final double margin;
  final MainAxisAlignment alignementColumn;
  final Color cardColor;
  final double border;
  final bool shadow;
  final Color shadowColor;

  const ItemsCard({
    Key?key,
    required this.children,
    this.alignementColumn = MainAxisAlignment.center,
    this.width = -1,
    this.height = -1,
    this.margin = 5,
    this.border = 20,
    this.cardColor = Colors.white,
    this.shadow = true,
    this.shadowColor = Colors.black
  }):super(key:key);

  @override
  Widget build(BuildContext context){
    return Container(
      margin: EdgeInsets.all(margin),
      width: width != -1 ? width : null,
      height: height != -1 ? height: null,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(border),
        color: cardColor,
        boxShadow: shadow ? [BoxShadow(
          color: shadowColor.withOpacity(0.2),
          offset: const Offset(0, 4),
          blurRadius: 7,
          spreadRadius: 2,
        )] : null,
      ),
      child: Column(
        mainAxisAlignment: alignementColumn,
        children: children,
      ),
    );
  }

}