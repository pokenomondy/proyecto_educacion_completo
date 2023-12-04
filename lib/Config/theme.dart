import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fluent_ui/fluent_ui.dart';

class ThemeApp{
  Color primaryColor = const Color(0xFF235FD9);
  Color secundaryColor = const Color(0xFF235FD9);
  Color buttoncolor = const Color(0xFF1E1E1E);
  Color buttonSecundaryColor = const Color(0xFF0A76FC);
  Color redColor = const Color(0xFFF83636);
  Color colorazulventas = const Color(0xFFB7DAFB);
  Color whitecolor = const Color(0xFFFFFFFF);
  Color blackColor = const Color(0xFF000000);
  Color grayColor = const Color(0xFF444444);

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

  Dialog errorDialog(String text, BuildContext context){
    return Dialog(
      backgroundColor: whitecolor.withOpacity(0),
      child: ItemsCard(
        shadow: true,
        width: 200,
        height: 200,
        children: [
          Icon(Icons.error, size: 70, color: redColor,),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Text(text),
          ),
          PrimaryStyleButton(
              width: 100,
              buttonColor: redColor,
              function: (){
                Navigator.pop(context);
              }, text: "Cerrar")
        ],
      ),
    );
  }

  Dialog ConfirmDialog(String text, BuildContext context){
    return Dialog(
      backgroundColor: whitecolor.withOpacity(0),
      child: ItemsCard(
        shadow: true,
        width: 250,
        height: 250,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: Icon(Icons.info, size: 70, color: primaryColor,),
          ),
          Expanded(
              child:
              SizedBox(
                width: 220,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Text(
                    text,
                    maxLines: null,
                    textAlign: TextAlign.center,
                  ),
                ),
              )),
          Container(
            margin: const EdgeInsets.only(bottom: 15.0),
            width: 180,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                PrimaryStyleButton(
                    width: 80,
                    function: (){
                      Navigator.pop(context);
                    }, text: "Aceptar"),
                PrimaryStyleButton(
                    width: 80,
                    buttonColor: redColor,
                    function: (){
                      Navigator.pop(context);
                    }, text: "Cerrar"),
              ]
            ),
          )
        ],
      ),
    );
  }

}

class PrimaryStyleButton extends StatefulWidget{
  final bool invert;
  final VoidCallback function;
  final String text;
  final double tamanio;
  final Color buttonColor;
  final Color tapColor;
  final double width;
  const PrimaryStyleButton({
    Key?key,
    required this.function,
    required this.text,
    this.buttonColor = const Color(0xFF235FD9),
    this.invert = false,
    this.tamanio = 15,
    this.width = -1,
    this.tapColor = const Color(0xFF151515),
  }):super(key: key);

  @override
  PrimaryStyleButtonState createState()=> PrimaryStyleButtonState();

}

class PrimaryStyleButtonState extends State<PrimaryStyleButton> {
  late Color buttonColor = !widget.invert ? widget.buttonColor : ThemeApp().whitecolor;

  @override
  Widget build(BuildContext context) {
    double widthCalculate = widget.width == -1 ? widget.text.length * 9: widget.width;
    double heigthCalculate = (widget.tamanio * 30) / 15;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 4),
      child: GestureDetector(
        onTapDown: (_) {
          setState(() {
            buttonColor = widget.tapColor;
          });
        },
        onTapUp: (_) {
          setState(() {
            buttonColor = widget.invert ? ThemeApp().whitecolor : widget.buttonColor;
          });
        },
        onTap: widget.function,
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
              style: ThemeApp().styleText(widget.tamanio, true, !widget.invert? ThemeApp().whitecolor: widget.buttonColor ),
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
    final ThemeApp theme = ThemeApp();
    TextStyle subtitulos = theme.styleText(12, false, theme.whitecolor);
    return Container(
      width: 150,
      height: 120,
      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: widget.activacion? theme.buttonSecundaryColor: theme.redColor,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
              widget.titulo,
            style: theme.styleText(15, true, theme.whitecolor),
          ),
          Text(
              widget.activacion? "Activo": "Inactivo",
            style: subtitulos,
          ),
          Text(
              "fecha de expiración:",
              style: theme.styleText(12, true, theme.whitecolor)
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
    this.containerColor = const Color(0xFFFFFFFF),
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
    final ThemeApp theme = ThemeApp();
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
          color: theme.blackColor.withOpacity(0.20),
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
  final CrossAxisAlignment alignementCrossColumn;
  final Color cardColor;
  final double border;
  final bool shadow;
  final Color shadowColor;
  final double verticalPadding;
  final double horizontalPadding;

  const ItemsCard({
    Key?key,
    required this.children,
    this.alignementColumn = MainAxisAlignment.center,
    this.alignementCrossColumn = CrossAxisAlignment.center,
    this.width = -1,
    this.height = -1,
    this.margin = 5,
    this.border = 20,
    this.cardColor = const Color(0xFFFFFFFF),
    this.shadow = true,
    this.shadowColor = const Color(0xFF030303),
    this.verticalPadding = 0,
    this.horizontalPadding = 0,
  }):super(key:key);

  @override
  Widget build(BuildContext context){
    return Container(
      margin: EdgeInsets.all(margin),
      width: width != -1 ? width : null,
      height: height != -1 ? height : null,
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
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: verticalPadding, horizontal: horizontalPadding),
        child: Column(
          mainAxisAlignment: alignementColumn,
          crossAxisAlignment: alignementCrossColumn,
          children: children,
        ),
      ),
    );
  }

}

class RoundedTextField extends StatefulWidget{
  final TextEditingController controller;
  final String placeholder;
  final double width;
  final double height;
  final double border;
  final TextAlign textAlign;
  final bool obscureText;
  final double topMargin;
  final double leftMargin;
  final double bottomMargin;
  final double rightMargin;
  final double textSize;
  final bool textWeight;
  final Color textColor;
  final Color textboxColor;
  const RoundedTextField({
    Key?key,
    required this.controller,
    required this.placeholder,
    this.width = -1,
    this.height = -1,
    this.border = 20,
    this.textAlign = TextAlign.center,
    this.obscureText = false,
    this.topMargin = 10,
    this.leftMargin = 10,
    this.bottomMargin = 10,
    this.rightMargin = 10,
    this.textSize = 14,
    this.textColor = const Color(0xFF030303),
    this.textWeight = false,
    this.textboxColor = const Color(0xFFFFFFFF),
  }):super(key: key);

  @override
  RoundedTextFieldState createState() => RoundedTextFieldState();

}

class RoundedTextFieldState extends State<RoundedTextField>{

  @override
  Widget build(BuildContext context){
    final ThemeApp theme = ThemeApp();
    return Container(
      margin: EdgeInsets.only(top: widget.topMargin, bottom: widget.bottomMargin, left: widget.leftMargin, right: widget.rightMargin),
      width: widget.width != -1 ? widget.width : null,
      height: widget.height != -1 ? widget.height : null,
      child: TextBox(
        decoration: BoxDecoration(
          color: widget.textboxColor,
          borderRadius: BorderRadius.circular(widget.border),
          boxShadow: [BoxShadow(
            color: theme.blackColor.withOpacity(0.3),
            blurRadius: 7,
            spreadRadius: 2,
            offset: const Offset(0, 3)
          )]
        ),
        style: theme.styleText(
            widget.textSize,
            widget.textWeight,
            widget.textColor
        ),
        textAlign: widget.textAlign,
        placeholder: widget.placeholder,
        onChanged: (value){
          widget.controller.text = value;
        },
        obscureText: widget.obscureText,
      ),
    );
  }

}

class BarraCarga extends StatefulWidget{
  final int total;
  final double width;
  final double heigth;
  final double border;
  final int cargados;
  final Color barColor;
  final Color backColor;
  final String title;

  const BarraCarga({
    Key?key,
    required this.title,
    required this.total,
    required this.cargados,
    this.width = 200,
    this.heigth = 12,
    this.barColor = const Color(0xFF235FD9),
    this.backColor = const Color(0xFFFFFFFF),
    this.border = 80,
  }):super(key:key);

  @override
  BarraCargaState createState() => BarraCargaState();
}

class BarraCargaState extends State<BarraCarga>{

  @override
  Widget build(BuildContext context){
    final double carga = widget.cargados >= widget.total ? 1 : widget.cargados / widget.total;
    final double horizontalPadding = widget.width < 200 ? (12 * widget.width) / 200 : 12;
    final double itemCardWidth = widget.width + widget.heigth * 5 + horizontalPadding;
    return ItemsCard(
      width: itemCardWidth,
      height: widget.heigth * 5,
      alignementCrossColumn: CrossAxisAlignment.start,
      border: 15,
      cardColor: const Color(0xFFE0E0E0),
      shadow: false,
      horizontalPadding: horizontalPadding,
      children: [
        Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(widget.width >= 300 ? "${widget.title} - ${widget.cargados} de ${widget.total}" : widget.title)
                ),
                Container(
                  width: widget.width - horizontalPadding,
                  height: widget.heigth,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(widget.border),
                      color: widget.backColor
                  ),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [AnimatedContainer(
                        width: (widget.width - horizontalPadding) * carga,
                        height: widget.heigth,
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(widget.border),
                            color: widget.barColor
                        ),
                      ),
                      ]
                  ),
                ),
              ],
            ),
          //////// Insertar Imagen
          AnimatedContainer(
            margin: const EdgeInsets.only(left: 8),
            width: widget.heigth*4,
            height: widget.heigth*4,
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(360),
              color: const Color(0xFFFFFFFF)
            ),
            child: Icon(
              widget.cargados >= widget.total ? Icons.done_outline_rounded : Icons.cookie,
              weight: 300,
              size: widget.heigth * 2.8,
              color: widget.barColor,
            ),
          )
          ],
        )
      ],
    );
  }


}