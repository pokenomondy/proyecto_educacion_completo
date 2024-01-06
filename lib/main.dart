import 'package:dashboard_admin_flutter/Dashboard.dart';
import 'package:dashboard_admin_flutter/Pages/Contabilidad/Pagos.dart';
import 'package:dashboard_admin_flutter/Pages/Login%20page/ConfigInicial.dart';
import 'package:dashboard_admin_flutter/Pages/Login%20page/LoginPage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'Config/Config.dart';
import 'Objetos/Solicitud.dart';
import 'Objetos/Tutores_objet.dart';
import 'Pages/CentroConfig.dart';
import 'Pages/Contabilidad/DashboardContabilidad.dart';
import 'Pages/MainTutores/DetallesTutores.dart';
import 'Pages/Pruebas/DashboardAdmin.dart';
import 'Pages/Pruebas/Whatsapp.dart';
import 'Pages/SolicitudesNew.dart';
import 'Pages/TutorDashPages/EntregasTutor.dart';
import 'Pages/TutorDashPages/MainTutoresDash.dart';
import 'Pages/TutorDashPages/TutorConfiguracion.dart';
import 'Pages/Tutores.dart';
import 'Pages/pages.dart';
import 'Providers/Providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
        apiKey: "AIzaSyAaDFOJuIohkPrVo0jEy0qnEPaFeiijvio",
        authDomain: "dufy-asesorias.firebaseapp.com",
        databaseURL: "https://dufy-asesorias-default-rtdb.firebaseio.com",
        projectId: "dufy-asesorias",
        storageBucket: "dufy-asesorias.appspot.com",
        messagingSenderId: "350250942752",
        appId: "1:350250942752:web:f8d0492c9cea9669dd1745",
        measurementId: "G-MH2TEMC9DB"
    ),
  );
  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyA_xNYL-1mikJJCsB8EQjNg6DyeKdNWyww",
          authDomain: "liba-education-app.firebaseapp.com",
          projectId: "liba-education-app",
          storageBucket: "liba-education-app.appspot.com",
          messagingSenderId: "1854378948",
          appId: "1:1854378948:web:82d700cb65df601544ca91",
          measurementId: "G-BZKDF684XY"
      ),
      name: 'LIBADB'
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => MensajesWhatsapp()),

        //Configuración
        ChangeNotifierProvider(create: (context) => ConfiguracionAplicacion()),
        //Contabilidad
        ChangeNotifierProvider(create: (context) => ContabilidadProvider()),
        //Solicitudes
        ChangeNotifierProvider(create: (context) => SolicitudProvider()),
        //Carreras
        ChangeNotifierProvider(create: (context) => CarrerasProvider()),
        //Materias
        ChangeNotifierProvider(create: (context) => MateriasVistaProvider()),
        //Clientes
        ChangeNotifierProvider(create: (context) => ClientesVistaProvider()),
        //Universidades
        ChangeNotifierProvider(create: (context) => UniversidadVistaProvider()),
        //Tutores
        ChangeNotifierProvider(create: (context) => VistaTutoresProvider()),
        //Vista de archivos
        ChangeNotifierProvider(create: (context) => ArchivoVistaDrive()),
        //Agenda de tutores Providers

      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {

  Config configuracion = Config();
  Solicitud solicitudVacia = Solicitud.empty();


  @override
  Widget build(BuildContext context) {
    final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
    final _shellNavigatorKey = GlobalKey<NavigatorState>();
    final GoRouter _router = GoRouter(
      routes: <RouteBase>[
        GoRoute(
          path: '/',
          builder: (BuildContext context, GoRouterState state) {
            return (Config.dufyadmon)?  const LoginPage(): InitPage();//InitPage(); LoginPage() DashboardAdmin();
          },
          routes: <RouteBase>[
            ShellRoute(
              builder: (context, state, child) {
                return Container(child: child,);
              },
              routes: <RouteBase>[
                GoRoute(
                    path: 'home',
                    builder: (BuildContext context, GoRouterState state) {
                      return Dashboard(showSolicitudesNew: false, showTutoresDetalles: false);
                    },
                    routes: <RouteBase>[
                      GoRoute(
                        path: 'configuracion_inicial',
                        builder: (BuildContext context, GoRouterState state) {
                          return ConfigInicialPrimerAcceso();
                        },)
                    ]
                ),
              ],
            ),
            GoRoute(path: 'homeTutor',
              builder: (BuildContext context, GoRouterState state) {
                return MainTutoresDash(showDetallesSolicitud: false,);
              },),
            GoRoute(path: 'EntregaTutor',
              builder: (BuildContext context, GoRouterState state) {
                return EntregaTutor();
              },),
            GoRoute(path: 'ConfiguracionTutor',
              builder: (BuildContext context, GoRouterState state) {
                return const ConfiguracionTutor();
              },)
          ],
        ),
      ],
    );


    return FluentApp.router(
      routerConfig: _router,
    );
  }

}