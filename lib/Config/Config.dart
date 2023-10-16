import 'package:flutter/material.dart';
import '../Utils/Firebase/Load_Data.dart';

class Config {
  Map<String, dynamic> configuracion_inicial = {}; // Inicializa como un mapa vacío
  String nombreempresa = "";
  Color primaryColor = Color(0xFF235FD9);
  Config() {
    initConfig();
  }

  Future<void> initConfig() async {
    configuracion_inicial = await LoadData().configuracion_inicial() as Map<String, dynamic>;

    // Verificar si 'nombre_empresa' existe y no es nulo
    if (configuracion_inicial.containsKey('nombre_empresa')) {
      nombreempresa = configuracion_inicial['nombre_empresa'];
    } else {
      // Manejar el caso en el que 'nombre_empresa' está ausente o es nulo
    }
    // Verificar si 'Primarycolor' existe y no es nulo
    if (configuracion_inicial.containsKey('Primarycolor')) {
      primaryColor = hexToColor(configuracion_inicial['Primarycolor']);
    } else {
      // Manejar el caso en el que 'Primarycolor' está ausente o es nulo
    }
  }

  Color hexToColor(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    return Color(int.parse(hexColor, radix: 16));
  }

  //Configuraciones de diseño
  static const Color secundaryColor = Color(0xFFF0F2F2);
  static const Color primarycikirbackground =Color(0x1A000000);
  static const Color buttoncolor =Color(0xFF1E1E1E);
  //Colores de contabilida
  static const Color colorazulventas = Color(0xFFB7DAFB);


  Text panelnavegacion(String text,bool isexpanded){
    Color textcolor = (isexpanded) ? Config.secundaryColor : primaryColor;
    return Text(text,style:
    TextStyle(
      color: textcolor,
      fontFamily: "Poppins",
      fontSize: 15,
      fontWeight: FontWeight.w700,
    )
    );
  }


}