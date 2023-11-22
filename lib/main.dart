import 'package:dashboard_admin_flutter/Dashboard.dart';
import 'package:dashboard_admin_flutter/Pages/Login%20page/ConfigInicial.dart';
import 'package:dashboard_admin_flutter/Pages/Login%20page/LoginPage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'Objetos/Solicitud.dart';
import 'Objetos/Tutores_objet.dart';
import 'Pages/Contabilidad/DashboardContabilidad.dart';
import 'Pages/MainTutores/DetallesTutores.dart';
import 'Pages/TutorDashPages/EntregasTutor.dart';
import 'Pages/TutorDashPages/MainTutoresDash.dart';
import 'Pages/TutorDashPages/TutorConfiguracion.dart';
import 'Pages/pages.dart';

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
      )
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => MateriasProvider()),
        ChangeNotifierProvider(create: (context) => CuentasProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {

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
            return const CreacionWidgets();//LoginPage();//InitPage();
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
                    return Dashboard(showSolicitudesNew: false,solicitud: solicitudVacia, showTutoresDetalles: false, tutor: Tutores.empty(),);
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
                return MainTutoresDash();
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
