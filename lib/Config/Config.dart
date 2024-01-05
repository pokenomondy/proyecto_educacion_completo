import 'dart:html';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:googleapis/driveactivity/v2.dart';
import '../Utils/Firebase/Load_Data.dart';
import '../Utils/Utiles/FuncionesUtiles.dart';
import 'package:flutter/material.dart' as material;


class Config {
  //Configuración inicial
  Color primaryColor = Color(0xFF235FD9); //NO SE PUEDE CAMBIAR, TOCA ELIMINAR
  Color Secundarycolor = Color(0xFF235FD9); //Color primario de la plataforma


  //info de tutor
  String rol = "";
  final currentUser = FirebaseAuth.instance.currentUser;

  Config() {
    initConfig();
  } //Inicializar la configuración

  Future<void> initConfig() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      rol = await LoadData().verificar_rol(currentUser);
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
  //pc = > 1200 , tablet <1200 y > 620 , celular < 620
  static const int responsivepc = 80;
  static const int responsivecelular = 5;
  static const int responsivetablet = 60;
  static const int tamanoHeightnormal = 80;
  //ahora heiht con menu
  static const int tamnoHeihtConMenu = 130;


  //Carpeta de Pagos
  String carpetapagos = "1HVgOvC-Jg8f5d-KE_m9hffKRZHJYy33N";
  //Carpeta de entregas de trabajos
  String carpetaentregatutores = "1I2RvuF9pOVgN5laPkahMdBoYaAY9Ma_1";
  //wsp token importante
  String tokenwsp = "EAAOWePbAwZCcBO3qCZB9mcNoAwqBOyw5JnPxQ6K22HCkJRtyZC7m4BjnsztuIGpEEaqGim9Pi1Avtte7iq3wjxN1WmNAjWRvQaYd0HZBOlNRcZCmRZAFAG4XaudmPt1qbBznsHNNjpL2IN1MkpOHow6iw3OWYvkaeZBKeOys99E1EGNibxpI550x7OpBUmrR4JqOD3ZAaieXZCZC4WFOCn";
  String apiurl =  "https://graph.facebook.com/v17.0/134108179779463/messages";
  static const bool dufyadmon = false;

  material.Text panelnavegacion(String text,bool isexpanded){
    Color textcolor = (isexpanded) ? Config.secundaryColor : primaryColor;
    return material.Text(text,style:
    TextStyle(
      color: textcolor,
      fontFamily: "Poppins",
      fontSize: 15,
      fontWeight: FontWeight.w700,
    )
    );
  }

}