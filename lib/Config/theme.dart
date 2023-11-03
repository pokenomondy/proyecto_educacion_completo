import 'package:flutter/material.dart';

import 'Config.dart';

class Theme{
  Color primaryColor = const Color(0x1A000000);
  Color secundaryColor = const Color(0xFFF0F2F2);
  Color buttoncolor = const Color(0xFF1E1E1E);
  Color buttonSecundaryColor = const Color(0xFF0A76FC);
  Color colorazulventas = const Color(0xFFB7DAFB);
  Color whitecolor = Colors.white;

  Theme () {
    Config config = Config();
    config.initConfig();
    primaryColor = config.primaryColor;

  }

  GestureDetector primaryStyleButton(VoidCallback function, String text){
    double widthCalculate = text.length * 9;
    return GestureDetector(
      onTap: (){
        function();
      },
      child: Container(
          width: widthCalculate,
          height: 30,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Theme().buttonSecundaryColor,
          ),
          child: Center(
            child: Text( text,
              style: styleText(15, true, whitecolor)),
          )
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