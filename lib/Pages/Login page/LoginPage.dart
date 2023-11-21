import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dashboard_admin_flutter/Config/Strings.dart';
import 'package:dashboard_admin_flutter/Objetos/Solicitud.dart';
import 'package:dashboard_admin_flutter/Utils/Utiles/FuncionesUtiles.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Config/theme.dart';


import '../../Objetos/Clientes.dart';
import '../../Utils/Firebase/Load_Data.dart';

  class LoginPage extends StatefulWidget {
    const LoginPage({super.key});

    @override
    LoginPageState createState() => LoginPageState();
  }

  class LoginPageState extends State<LoginPage> {
    final TextEditingController correo = TextEditingController();
    final TextEditingController contrasena = TextEditingController();
    final currentUser = FirebaseAuth.instance.currentUser;

    @override
    void initState(){
      super.initState();
      cargaregular();
      if (currentUser != null) {
        _redireccionaDashboarc(currentUser!.uid);
      }
      }

    String cliente_actual = "";
    List<Solicitud> cliente_List = [];
    int cliente_numerocargado = 0;
    final db = FirebaseFirestore.instance;
    Future <void> cargaregular() async{
      if(cliente_numerocargado==0){
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.remove('solicitudes_list');
        await LoadData().obtenerSolicitudes(
          onSolicitudAdded: (Solicitud nuevaSolicitud) {
            setState(() {
              cliente_actual = nuevaSolicitud.idcotizacion.toString();
              cliente_List.add(nuevaSolicitud);
              cliente_numerocargado = cliente_List.length + 471;
            });
          },
        );
      }
    }

    @override
    Widget build(BuildContext context) {
      final ThemeApp theme = ThemeApp();
      const double widthTextBox = 350;
      const double heigthTextBox = 40;
      return Center(
        child: ItemsCard(
          width: 450,
          height: 500,
          children: [
              CircularLogo(
                asset: "logo.png",
                containerColor: theme.primaryColor,
                width: 150,
                height: 150,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 25),
                child: Text(
                  'Inicio de Sesion',
                  style: theme.styleText(18, true, theme.grayColor),
                ),
              ),
              RoundedTextField(
                textAlign: TextAlign.start,
                topMargin: 5,
                bottomMargin: 5,
                height: heigthTextBox,
                width: widthTextBox,
                controller: correo,
                placeholder: "Correo electronico para acceder"
              ),
              RoundedTextField(
                textAlign: TextAlign.start,
                topMargin: 5,
                bottomMargin: 20,
                obscureText: true,
                width: widthTextBox,
                height: heigthTextBox,
                controller: contrasena,
                placeholder: "Contraseña",
              ),
              PrimaryStyleButton(
                function: login,
                text: "Iniciar Sesion",
              ),
              Text(Strings().appVersion,
                style: TextStyle(
                  fontSize: 11,
                  color: theme.colorazulventas,
                ),),
              BarraCarga(
                title: "Cargando solicitudes",
                cargados: cliente_numerocargado,
                total: 1300,
                width: 200,
              ),
              //Google
            ],
        ),
      );
    }

    Future<void> login()  async {
      //print('presionado login');
      try {
        final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: correo.text,
            password: contrasena.text
        );
        final User? user = credential.user;
        String? uid = user?.uid;
        //Lógica si es tutor o es administrador

        DocumentSnapshot getutoradmin = await FirebaseFirestore.instance.collection("TUTORES").doc(uid).get();

        if(getutoradmin.exists){
          String rol = getutoradmin.get('rol') ?? '';
          //print(rol);
          if(rol=="TUTOR"){
            context.go('/homeTutor');
          }else{
            context.go('/home');
          }
        }else{
          //print("vos no tenes rol, error gravisimo");
          context.go('/home');
        }
        Utiles().notificacion("Logueado con extio", context, false, "log");
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          //print('No user found for that email.');
          Utiles().notificacion("Usuario no encontrado con ese email", context, false, "log");
        } else if (e.code == 'wrong-password') {
          print('Wrong password provided for that user.');
          Utiles().notificacion("Contraseña inocrrecta", context, false, "log");
        }
      }
    }

    void _redireccionaDashboarc(String uid) async{
      Map<String, dynamic> configuracion_inicial = await LoadData().configuracion_inicial() as Map<String, dynamic>;
      DocumentSnapshot getutoradmin = await FirebaseFirestore.instance.collection("TUTORES").doc(currentUser?.uid).get();
      print(configuracion_inicial);

      if(getutoradmin.exists){
        String rol = getutoradmin.get('rol') ?? '';
        print("el rol es = ${rol}");
        if(rol=="TUTOR"){
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go('/homeTutor');
          });
        }else if(rol=="ADMIN"){
          if(configuracion_inicial.isEmpty){
            //Si esta vacio, mandar a configuración inicial
            print("nos vamos a config inicial");
            context.go('/home/configuracion_inicial');
          }else{
            //Si no esta vacio, mande a dashbarod
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.go('/home');
            });
            print("nos vamos a dashboard");
          }
          }else{
          print("no es ni admin, ni tutor");
        }
      }else{
        print("vos no estas ni creado ome");
      }
    }
  }