import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dashboard_admin_flutter/Config/Strings.dart';
import 'package:dashboard_admin_flutter/Objetos/Solicitud.dart';
import 'package:dashboard_admin_flutter/Utils/Utiles/FuncionesUtiles.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../Config/Config.dart';
import '../../Config/theme.dart';
import '../../Utils/Firebase/CollectionReferences.dart';
import '../../Utils/Firebase/Load_Data.dart';

  class LoginPage extends StatefulWidget {
    const LoginPage({super.key});

    @override
    LoginPageState createState() => LoginPageState();
  }

  class LoginPageState extends State<LoginPage> {
    final TextEditingController correo = TextEditingController();
    final TextEditingController contrasena = TextEditingController();
    User? currentUser;
    FirebaseAuth? authdirection;
    CollectionReference? firestoredirection;
    CollectionReferencias referencias =  CollectionReferencias();


    @override
    void initState(){
      super.initState();
      redireccion();
      }

    Future redireccion() async{
      if(Config.dufyadmon==true){
        currentUser = FirebaseAuth.instance.currentUser;
        authdirection = FirebaseAuth.instance;
      }else{
        currentUser =  FirebaseAuth.instanceFor(app: Firebase.app('LIBADB')).currentUser;
        authdirection = FirebaseAuth.instanceFor(app: Firebase.app('LIBADB'));
      }

      if (currentUser != null) {
        _redireccionaDashboarc(currentUser!.uid,currentUser!,Config.dufyadmon);
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
            ],
        ),
      );
    }

    Future<void> login()  async {
      Map<String, dynamic> configuracion_inicial = await LoadData().configuracion_inicial() as Map<String, dynamic>;
      DocumentSnapshot getutoradmin = await referencias.tutores!.doc(currentUser?.uid).get();

      try {
        final credential = await authdirection!.signInWithEmailAndPassword(
            email: correo.text,
            password: contrasena.text
        );
        final User? user = credential.user;
        String? uid = user?.uid;
        //Lógica si es tutor o es administrador

        DocumentSnapshot getutoradmin = await referencias.tutores!.doc(uid).get();

        _redireccionaDashboarc(uid!,user!,Config.dufyadmon);

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

    void _redireccionaDashboarc(String uid, User currentUser, bool dufyadmon) async{
      Map<String, dynamic> configuracion_inicial = await LoadData().configuracion_inicial() as Map<String, dynamic>;
      DocumentSnapshot getutoradmin = await referencias.tutores!.doc(currentUser?.uid).get();
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