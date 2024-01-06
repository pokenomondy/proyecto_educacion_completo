import 'dart:async';
import 'package:dashboard_admin_flutter/Config/Config.dart';
import 'package:dashboard_admin_flutter/Config/theme.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Objetos/AgendadoServicio.dart';
import '../../Objetos/Configuracion/objeto_configuracion.dart';
import '../../Utils/Firebase/StreamBuilders.dart';
import '../../Utils/Utiles/FuncionesUtiles.dart';
import '../Estadisticas/CalendarioData.dart';
import 'EntregasTutor.dart';
import 'TutorConfiguracion.dart';

class MainTutoresDash extends StatefulWidget {
  final bool showDetallesSolicitud;

  const MainTutoresDash({Key? key,
    required this.showDetallesSolicitud,
  }) : super(key: key);

  @override
  MainTutoresDashState createState() => MainTutoresDashState();
}

class MainTutoresDashState extends State<MainTutoresDash> {
  int _currentPage = 0;
  Config configuracion = Config();
  bool configloaded = false;

  late StreamController<ConfiguracionPlugins> _streamController;
  late StreamController<List<ServicioAgendado>> _streamControllerServiciosAgendados;

  @override
  void initState() {
    _streamController = StreamController<ConfiguracionPlugins>();
    _streamControllerServiciosAgendados = StreamController<List<ServicioAgendado>>();
    super.initState();
    _initStream();
  }

  @override
  void dispose() {
    _streamController.close();
    super.dispose();
  }

  _initStream() async {
    //Cargar nombre de tutor
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? nameTutor = prefs.getString('NameTutor');
    //Configuración stream
    Stream<ConfiguracionPlugins> stream = stream_builders().getstreamConfiguracion(context);
    _streamController.addStream(stream);
    //Contabilidad stream
    Stream<List<ServicioAgendado>> streamservicios = stream_builders().getServiciosAgendados(context,"ADMIN",nameTutor!);
    _streamControllerServiciosAgendados.addStream(streamservicios);
  }


  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: _streamController.stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            print(snapshot.error);
            return Text('Error: ${snapshot.error}');
          } else {
            final configuracion = snapshot.data;

            List<NavigationPaneItem> getItems(){
              if(widget.showDetallesSolicitud){
                return <NavigationPaneItem>[
                  PaneItem(icon: const Icon(FluentIcons.home),
                    title:  Config().panelnavegacion("AGENDA",_currentPage == 0),
                    body: EntregaTutor(), //Este puede variar, entre detalles y solicitudes
                    selectedTileColor:ButtonState.all(Utiles().hexToColor(configuracion!.primaryColor)),
                  ),
                ];
              }else{
                return <NavigationPaneItem>[
                  PaneItem(icon: const Icon(FluentIcons.home),
                    title:  Config().panelnavegacion("AGENDA",_currentPage == 0),
                    body: CalendarioData(), //Este puede variar, entre detalles y solicitudes
                    selectedTileColor:ButtonState.all(Utiles().hexToColor(configuracion!.primaryColor)),
                  ),
                  PaneItem(icon: const Icon(FluentIcons.home),
                    title:  Config().panelnavegacion("Config Tutor",_currentPage == 2),
                    body: const ConfiguracionTutor(), //Este puede variar, entre detalles y solicitudes
                    selectedTileColor:ButtonState.all(Utiles().hexToColor(configuracion.primaryColor)),
                  ),
                ];

              }
            }

            if(configuracion!.basicoFecha.isBefore(DateTime.now())){
              return const Text('Vencio la licencia');
            }else if(configuracion.tutoresSistemaFecha.isBefore(DateTime.now())){
              return const Text('No esta el plugin activo de tutores para esto, contacta para activar');
            }else{
              return NavigationView(
                appBar: NavigationAppBar(
                  title: Container(
                    margin:  const EdgeInsets.only(left: 20),
                    child: Row(
                      children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 20.0, left: 5.0,),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(configuracion.nombreEmpresa, style: ThemeApp().styleText(35, true, ThemeApp().grayColor),),
                                  //AQUI VIENEN STREAMBUILDERS QUE SE NECESITAN
                                  StreamBuilder<List<ServicioAgendado>>(
                                    stream: _streamControllerServiciosAgendados.stream,
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        return const CircularProgressIndicator();
                                      } else if (snapshot.hasError) {
                                        return Text('Error: ${snapshot.error}');
                                      } else {
                                        // No mostrar nada, ya que el stream está vacío
                                        return const Text(''); // O cualquier otro widget que no muestre nada
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                pane: NavigationPane(
                  size: const NavigationPaneSize(
                    openMaxWidth: 50.00,
                    openMinWidth: 50.00,
                  ),
                  items: getItems(),
                  selected: _currentPage,
                  onChanged: (index) => setState(() {
                    _currentPage = index;
                  }),
                ),
              );
            }
          }
        }
      );
    }
  }
