import 'package:flutter/material.dart';
import '../Utils/Firebase/Load_Data.dart';
import '../Utils/Utiles/FuncionesUtiles.dart';

class Config {
  Map<String, dynamic> configuracion_inicial = {
  }; // Configuración inicial del proyecto
  String nombreempresa = "Error, reportar"; //Nombre de la empresa del proyecto
  Color primaryColor = Color(0xFF235FD9); //Color primario de la plataforma
  Color Secundarycolor = Color(0xFF235FD9); //Color primario de la plataforma
  String idcarpetaPagos = "";
  String idcarpetaSolicitudes = "";
  Config() {
    initConfig();
  } //Inicializar la configuración

  Future<void> initConfig() async {
    configuracion_inicial = await LoadData().configuracion_inicial() as Map<String, dynamic>;

    // Verificar si 'nombre_empresa' existe y no es nulo
    if (configuracion_inicial.containsKey('nombre_empresa')) {
      nombreempresa = configuracion_inicial['nombre_empresa'];
    } else {
    }
    // Verificar si 'Primarycolor' existe y no es nulo
    if (configuracion_inicial.containsKey('Primarycolor')) {
      primaryColor = Utiles().hexToColor(configuracion_inicial['Primarycolor']);
    } else {
    }
    // secundary color
    if (configuracion_inicial.containsKey('Primarycolor')) {
      Secundarycolor = Utiles().hexToColor(configuracion_inicial['Secundarycolor']);
    } else {
    }
    //Llamar idCarpetaPagos
    if (configuracion_inicial.containsKey('idcarpetaPagos')) {
      idcarpetaPagos = configuracion_inicial['idcarpetaPagos'];
    } else {
    }
    //Llamar idcarpetaSolicitudes
    if (configuracion_inicial.containsKey('idcarpetaSolicitudes')) {
      idcarpetaSolicitudes = configuracion_inicial['idcarpetaSolicitudes'];
    } else {
    }

  }

  //Configuraciones de diseño
  static const Color secundaryColor = Color(0xFFF0F2F2);
  static const Color primarycikirbackground =Color(0x1A000000);
  static const Color buttoncolor =Color(0xFF1E1E1E);
  static const Color colorazulventas = Color(0xFFB7DAFB);

  //Responsives
  int computador = 1200;
  int tablet = 620;
  int celular = 620;

  //Carpeta de Solicitudes
  String carpetasolicitudes = "1UhZBywK1XjkIJDQH0xpaAzzqVRevG3iD";
  //Carpeta de Pagos
  String carpetapagos = "1HVgOvC-Jg8f5d-KE_m9hffKRZHJYy33N";

  //IMPORTANTES, Esto cuando este en true, significa que el que esta conectado es DufyAsesorías principal, cuando sea false
  //es porque esta conectado cualquiera de nuestros clientes, esto para hacer un sistema unico para cada cliente.
  bool dufyadmon = true;
  //Para cambiar de base de datos, se debe cambiar esto a false, y luego se debe cambiar el inicializador del main, con eso ya estaría
  //correcto.



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