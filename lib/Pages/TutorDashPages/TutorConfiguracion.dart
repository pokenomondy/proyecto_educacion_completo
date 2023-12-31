import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Config/Config.dart';
import '../../Utils/EnviarMensajesWhataspp.dart';
import '../../Utils/Firebase/Load_Data.dart';
import '../../Utils/Utiles/FuncionesUtiles.dart';

class ConfiguracionTutor extends StatefulWidget{
  const ConfiguracionTutor({super.key});

  @override
  _ConfiguracionTutorState createState() => _ConfiguracionTutorState();

}

class _ConfiguracionTutorState extends State<ConfiguracionTutor> {

  @override
  Widget build(BuildContext context) {
    final currentwidth = MediaQuery.of(context).size.width;
    return Column(
      children: [
        PrimaryColumnTutorConfig(currentwidth: currentwidth),
      ],
    );
  }

}

class PrimaryColumnTutorConfig extends StatefulWidget{
  final double currentwidth;

  const PrimaryColumnTutorConfig({Key?key,
    required this.currentwidth,
  }) :super(key: key);
  @override
  _PrimaryColumnTutorConfigState createState() => _PrimaryColumnTutorConfigState();

}

class _PrimaryColumnTutorConfigState extends State<PrimaryColumnTutorConfig> {
  final currentUser = FirebaseAuth.instance.currentUser;
  String nombretutor = "";
  String Correo_gmail = "";
  String plantillabuscador = "";

  @override
  void initState() {
    print("usuario iod ${currentUser?.uid}");
    loaddata().then((_) {
      setState(() {}); // Trigger a rebuild after data is loaded.
    });
    super.initState();
  }

  Future<void> loaddata() async {
    Map<String, dynamic> datos_tutor = await LoadData().getinfotutor(currentUser!);
    Correo_gmail = datos_tutor['Correo gmail'];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        //Botón para recuperar contraseña
        FilledButton(
          onPressed: () async {
            final FirebaseAuth _auth = FirebaseAuth.instance;
            try {
              await _auth.sendPasswordResetEmail(email: Correo_gmail);
              print("se le envio correo para contrasñea a $Correo_gmail");
              Utiles().notificacion("Se envio correo a $Correo_gmail", context, false, "se envio correo");
            } catch (e) {
              print("ocurrio un error");
            }
          },
          child: Text('Recuperar Contraseña'),
        ),
        //Botón para cerrar sesión
        FilledButton(child: Text('Cerrar sesión'), onPressed: (){
          signOut();
        }),
      ],
    );
  }

  void signOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      await FirebaseAuth.instance.signOut();
      // La sesión se ha cerrado correctamente
      context.go('/');
      //eliminar en cache infotutor
      prefs.remove('rol_usuario');
      prefs.remove('informacion_tutor');
      prefs.remove('datos_Descargados_verificar_rol');
      prefs.remove('datos_descargadios_getinfotutor');
    } catch (e) {
      print("Error al cerrar sesión: $e");
    }
  }
}