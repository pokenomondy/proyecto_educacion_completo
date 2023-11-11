import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dashboard_admin_flutter/Config/Config.dart';
import 'package:dashboard_admin_flutter/Config/Strings.dart';
import 'package:dashboard_admin_flutter/Utils/Utiles/FuncionesUtiles.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:go_router/go_router.dart';
import '../../Config/theme.dart';
import '../../Utils/Firebase/Load_Data.dart';

  class LoginPage extends StatefulWidget {
    const LoginPage({super.key});

    @override
    LoginPageState createState() => LoginPageState();
  }

  class LoginPageState extends State<LoginPage> {
    String correo = "";
    String contrasena = "";
    final currentUser = FirebaseAuth.instance.currentUser;

    @override
    void initState(){
      super.initState();
      //print("usuario ingresado $currentUser");
      if (currentUser != null) {
        _redireccionaDashboarc(currentUser!.uid);
      }
      }

    @override
    Widget build(BuildContext context) {
      const double widthTextBox = 350;
      const EdgeInsets marginTextBox = EdgeInsets.only(top: 10, bottom: 1);
      return Center(
        child: Container(
          width: 500,
          height: 450,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(
              color: Config.buttoncolor.withOpacity(0.08),
              offset: const Offset(0, 3),
              blurRadius: 8,
              spreadRadius: 3
            )],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: Text(
                    'Inicio de Sesion',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18
                  ),
                ),
              ),
              Container(
                width: widthTextBox,
                margin: marginTextBox,
                child: TextBox(
                  decoration: BoxDecoration(
                    color: Config.secundaryColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  placeholder: 'Correo electronico para acceder',
                  onChanged: (value){
                    setState(() {
                      correo = value;
                    });
                  },
                  maxLines: null,
                ),
              ),
              Container(
                width: widthTextBox,
                margin: marginTextBox,
                child: TextBox(
                  decoration: BoxDecoration(
                    color: Config.secundaryColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  placeholder: 'Contraseña',
                  onChanged: (value){
                    setState(() {
                      contrasena = value;
                    });
                  },
                  obscureText: true,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 8),
                child: PrimaryStyleButton(function: login, text: "Iniciar Sesion",)
              ),
                Text(Strings().appVersion,
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme().colorazulventas,
                  ),),
              //Google
            ],
          ),
        ),
      );
    }

    Future<void> login()  async {
      //print('presionado login');
      try {
        final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: correo,
            password: contrasena
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