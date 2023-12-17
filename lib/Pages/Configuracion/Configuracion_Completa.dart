import 'package:dashboard_admin_flutter/Config/Config.dart';
import 'package:dashboard_admin_flutter/Config/theme.dart';
import 'package:dashboard_admin_flutter/Objetos/Configuracion/Configuracion_Configuracion.dart';
import 'package:dashboard_admin_flutter/Utils/Firebase/Load_Data.dart';
import 'package:dashboard_admin_flutter/Utils/Firebase/StreamBuilders.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../Objetos/Solicitud.dart';
import '../../Utils/Firebase/DeleteLocalData.dart';
import '../../Utils/Firebase/Uploads.dart';

class ConfiguracionDatos extends StatefulWidget {
  const ConfiguracionDatos({super.key});

  @override
  ConfiguracionDatosState createState() => ConfiguracionDatosState();
}

class ConfiguracionDatosState extends State<ConfiguracionDatos> {

  @override
  Widget build(BuildContext context) {
    final currentwidth = MediaQuery.of(context).size.width;
    final tamanowidth = (currentwidth/1.5)-30;
    print("se dibuja la solicitud");
    return _PrimaryColumnDatos(currentwidth: tamanowidth,);
  }
}

class _PrimaryColumnDatos extends StatefulWidget {

  final double currentwidth;

  const _PrimaryColumnDatos({Key?key,
    required this.currentwidth,
  }) :super(key: key);
  @override
  _PrimaryColumnDatosState createState() => _PrimaryColumnDatosState();
}

class _PrimaryColumnDatosState extends State<_PrimaryColumnDatos> {
  List<Solicitud> solicitudesList = [];
  int numsolicitudes = 0;
  Config configuracion = Config();
  bool configloaded = false;
  String msgsolicitud = "";
  String msgsconfirmacioncliente = "";
  ConfiguracionPlugins? configuracionPlugin;


  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    final currentheight = MediaQuery.of(context).size.height;
    return StreamBuilder<ConfiguracionPlugins>(
      stream: stream_builders().getstreamConfiguracion(), // Utiliza la función que retorna el Stream
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          ConfiguracionPlugins configuracion = snapshot.data!;
          return Text("Configuración actualizada: ${configuracion.nombre_empresa}");
        } else if (snapshot.hasError) {
          return Text("Error: ${snapshot.error}");
        } else {
          return Text("Cargando...");
        }
      },
    );
  }

  void signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      // La sesión se ha cerrado correctamente
      context.go('/');
    } catch (e) {
      print("Error al cerrar sesión: $e");
    }
  }
}