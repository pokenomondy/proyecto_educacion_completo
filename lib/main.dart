import 'package:dashboard_admin_flutter/Dashboard.dart';
import 'package:dashboard_admin_flutter/Pages/Login%20page/ConfigInicial.dart';
import 'package:dashboard_admin_flutter/Pages/Login%20page/LoginPage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:go_router/go_router.dart';

import 'Objetos/Solicitud.dart';
import 'Pages/TutorDashPages/EntregasTutor.dart';
import 'Pages/TutorDashPages/MainTutoresDash.dart';
import 'Pages/TutorDashPages/TutorConfiguracion.dart';

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
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key?key}):super(key:key);

  Solicitud solicitudVacia = Solicitud.empty();

  @override
  Widget build(BuildContext context) {
    final GoRouter router = GoRouter(
      routes: <RouteBase>[
        GoRoute(
          path: '/',
          builder: (BuildContext context, GoRouterState state) {
            return const LoginPage();
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
                    return Dashboard(showSolicitudesNew: false,solicitud: solicitudVacia,);
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
                return ConfiguracionTutor();
              },)
          ],
        ),
      ],
    );


    return FluentApp.router(
      routerConfig: router,
    );
  }



}
