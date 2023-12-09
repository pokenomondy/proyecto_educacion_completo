import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dashboard_admin_flutter/Objetos/AgendadoServicio.dart';
import 'package:dashboard_admin_flutter/Objetos/Objetos%20Auxiliares/Universidad.dart';
import 'package:dashboard_admin_flutter/Objetos/Tutores_objet.dart';
import 'package:dashboard_admin_flutter/Pages/ShowDialogs/SolicitudesDialogs.dart';
import 'package:dashboard_admin_flutter/Utils/Firebase/CollectionReferences.dart';
import 'package:flutter/material.dart' as material;
import 'package:dashboard_admin_flutter/Utils/Firebase/Load_Data.dart';
import 'package:dashboard_admin_flutter/Utils/Firebase/StreamBuilders.dart';
import 'package:dashboard_admin_flutter/Pages/MainTutores/NotaTutores.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../Config/Config.dart';
import 'package:intl/intl.dart';
import '../Dashboard.dart';
import '../Objetos/Cotizaciones.dart';
import '../Objetos/Objetos Auxiliares/Carreras.dart';
import '../Objetos/Objetos Auxiliares/Materias.dart';
import '../Objetos/Solicitud.dart';
import '../Utils/Firebase/Uploads.dart';
import 'MainTutores/DetallesTutores.dart';

class TutoresVista extends StatefulWidget {
  @override
  TutoresVistaVistaState createState() => TutoresVistaVistaState();
}

class TutoresVistaVistaState extends State<TutoresVista> {
  final GlobalKey<SecundaryColumnTutoresState> materiasdeTutoresVista = GlobalKey<SecundaryColumnTutoresState>();
  Config configuracion = Config();
  List<Tutores> tutoresList = [];
  bool cargadodata = false;

  @override
  void initState() {
    loadtablas();
    super.initState();
  }

  Future<void> loadtablas() async {
    tutoresList = await LoadData().obtenertutores();
    setState(() {
      cargadodata=true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentwidth = MediaQuery.of(context).size.width;
    final tamanowidth = (currentwidth/3)-60;
    return NavigationView(
      content: Row(
        children: [
          if(currentwidth>=configuracion.computador)
            if(cargadodata==true)
              Row(children: [
                _Creartutores(currentwidth: tamanowidth,tutoresList: tutoresList,),
                _BusquedaTutor(currentwidth: tamanowidth,),
                _CrearTutorNuevo(currentwidth: tamanowidth),
              ],),
          if(currentwidth < 1200 && currentwidth > 620)
            Container(
                width: currentwidth,
                child: TutoresResponsiveVista(tutoresList: tutoresList,)),
          if(currentwidth <= 620)
            Container(
                width: currentwidth,
                child: TutoresResponsiveVista(tutoresList: tutoresList,)),

        ],
      ),
    );
  }
}

class TutoresResponsiveVista extends StatefulWidget {
  final List<Tutores> tutoresList;

  const TutoresResponsiveVista({Key?key,
    required this.tutoresList,
  }) :super(key: key);
  @override
  _TutoresResponsiveVistaState createState() => _TutoresResponsiveVistaState();
}

class _TutoresResponsiveVistaState extends State<TutoresResponsiveVista> {
  int _selectedpage = 0;

  @override
  Widget build(BuildContext context) {
    final currentwidth = MediaQuery.of(context).size.width;
    return Container(
      child: NavigationView(
        pane: NavigationPane(
          selected: _selectedpage,
          onChanged: (index) => setState(() {
            _selectedpage = index;
          }),
          displayMode: PaneDisplayMode.top,
          items: <NavigationPaneItem>[
            PaneItem(
              icon:  const Icon(FluentIcons.home),
              title: const Text('Tutores'),
              body:  _Creartutores(currentwidth: currentwidth,tutoresList: widget.tutoresList,),
            ),
            PaneItem(
              icon:  const Icon(FluentIcons.home),
              title: const Text('Busqueda'),
              body: _BusquedaTutor(currentwidth: currentwidth,),
            ),
            PaneItem(
              icon:  const Icon(FluentIcons.home),
              title: const Text('Nuevo tutor'),
              body:  _CrearTutorNuevo(currentwidth: currentwidth),
            ),
          ],
        ),
      ),
    );
  }
}

class _Creartutores extends StatefulWidget{
  final double currentwidth;
  final List<Tutores> tutoresList;

  const _Creartutores({Key?key,
    required this.currentwidth,
    required this.tutoresList,
  }) :super(key: key);

  @override
  _CreartutoresrState createState() => _CreartutoresrState();

}

class _CreartutoresrState extends State<_Creartutores> {

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.currentwidth,
      child: Column(
        children: [
          const Text('Tutores'),
         _TarjetaTutores(tutoresList: widget.tutoresList),
        ],
      ),
    );
  }
}

class _TarjetaTutores extends StatefulWidget{
  final List<Tutores> tutoresList;


  const _TarjetaTutores({Key?key,
    required this.tutoresList,
  }) :super(key: key);


  @override
  _TarjetaTutoresState createState() => _TarjetaTutoresState();

}

class _TarjetaTutoresState extends State<_TarjetaTutores> {
  String? selectedTipoCuenta;
  List<String> tipoCuentaList = ['NEQUI','PAYPAL','BANCOLOMBIA','DAVIPLATA','BINANCE'];
  String numeroCuenta = "";
  String cedula = "";
  String nombreCedula = "";
  List<Materia> materiaList = [];
  Materia? selectedMateria;
  List<Solicitud> solicitudesList = [];
  bool dataLoaded = false;

  List<Tutores> tutoresList = [];
  String Busqueda = "";
  Tutores? selectedTutor;

  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized(); // Asegura que Flutter esté inicializado
    loadtablas(); // Cargar los datos al inicializar el widget
    cargartutores();
    super.initState();
  }

  Future<void> loadtablas() async {
    materiaList = await LoadData().tablasmateria();
    solicitudesList = await LoadData().obtenerSolicitudes();
    setState(() {
      dataLoaded=true;
    });
    print("load tablas ejecutandose");
  }

  Future cargartutores() async{
    tutoresList = await LoadData().obtenertutores();
    final tutoresProvider = Provider.of<VistaTutoresProvider>(context, listen: false);
    tutoresProvider.clearTutores();
    tutoresProvider.setFiltro('TutorA');
    tutoresProvider.cargarTodosTutores(tutoresList);
  }

  @override
  Widget build(BuildContext context) {
    final currentheight = MediaQuery.of(context).size.height;
    return Consumer<VistaTutoresProvider>(
        builder: (context, tutorProvider, child) {
          List<Tutores> tutores = tutorProvider.tutorseleccionado;

          return Column(
            children: [
              contarTutoresRoles(tutoresList),
              Container(
                  height: currentheight-180,
                  child: ListView.builder(
                      itemCount: tutores.length,
                      itemBuilder: (context,index) {
                        Tutores? tutor = tutores[index];

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5,horizontal: 8),
                          child: material.Container(
                            color: (tutor.activo) ? material.Colors.green : material.Colors.red,
                            child: Card(
                              child:Column(
                                children: [
                                  //nombre y numero de wasap
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(child: Text(tutor.nombrewhatsapp)),
                                      GestureDetector(
                                        onTap: () {
                                          final textToCopy = tutor.numerowhatsapp.toString();
                                          Clipboard.setData(ClipboardData(text: textToCopy));
                                        },
                                        child:Text(tutor.numerowhatsapp.toString()),

                                      ),
                                    ],
                                  ),
                                  GestureDetector(
                                    onTap: (){
                                      material.Navigator.push(context, material.MaterialPageRoute(
                                        builder: (context)  => Dashboard(showSolicitudesNew: false, solicitud: Solicitud.empty(),tutor: tutor,showTutoresDetalles: true,),
                                      ));
                                    },
                                    child: Text('add'),
                                  ),
                                  //# de materias manejadas
                                  Text("${tutor.materias.length.toString()} materias registradas"),
                                  //# de cuentas bancarias registradas
                                  Text("${tutor.cuentas.length.toString()} cuentas registradas"),
                                  //nombre del tutor
                                  Text("${tutor.nombrecompleto}"),
                                  //carrera y universidad
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(child: Text(tutor.carrera)),
                                      Expanded(child: Text(tutor.univerisdad)),
                                    ],
                                  ),
                                  Text('Activo? ${tutor.activo}'),
                                  if(dataLoaded==true)
                                    Text('ult fecha ${DateFormat('dd/MM/yy').format(ultimaFechaCotizacionTutor(tutor.nombrewhatsapp))}')
                                ],
                              ),
                            ),
                          ),
                        );
                      }
                  )
              ),
            ],
          );

        }
    );
  }

  Widget contarTutoresRoles(List<Tutores> tutores){
    //Nos interesan tutores - activos - inactivos - admin
    int tutoresActivos = tutores
        .where((tutor) => tutor.activo == true && tutor.rol == "TUTOR")
        .length;
    int administradores = tutores
        .where((tutor) => tutor.activo == true && tutor.rol == "ADMIN")
        .length;
    int tutoreInactivos = tutores
        .where((tutor) => tutor.activo == false && tutor.rol == "TUTOR")
        .length;

    final tutoresProvider = Provider.of<VistaTutoresProvider>(context, listen: false);

    return Column(
      children: [
        Text('$tutoresActivos tutores activos, $tutoreInactivos tutores inactivos'),
        Text('$administradores administradores activos'),
        Row(
          children: [
            FilledButton(child: Text('Tutor A'), onPressed: () {
              tutoresProvider.setFiltro('TutorA');
            }),

            FilledButton(child: Text('Tutor Inac'), onPressed: () {
              tutoresProvider.setFiltro('TutorInac');
            }),

            FilledButton(child: Text('ADMON'), onPressed: () {
              tutoresProvider.setFiltro('ADMON');
            }),
          ],
        ),
        Container(
          height: 30,
          width: 200,
          child: AutoSuggestBox<Tutores>(
            items: tutores.map<AutoSuggestBoxItem<Tutores>>(
                  (tutor) => AutoSuggestBoxItem<Tutores>(
                value: tutor,
                label: tutor.nombrewhatsapp,
                onFocusChange: (focused) {
                  if (focused) {
                  }
                },
              ),
            )
                .toList(),
            onSelected: (item) {
              setState(() {
                print("seleccionado ${item.label}");
                selectedTutor = item.value; // Actualizar el valor seleccionado
                tutoresProvider.busquedatutor(selectedTutor!.nombrewhatsapp!);
              });
            },
          ),
        ),
      ],
    );
  }

  DateTime ultimaFechaCotizacionTutor(String tutorname) {
    Cotizacion? ultimaCotizacion;
    DateTime? fechaUltimaCotizacion;

    for (Solicitud solicitud in solicitudesList) {
      for (Cotizacion cotizacion in solicitud.cotizaciones) {
        if (cotizacion.nombretutor == tutorname) {
          // Calcular la fecha de cotización
          DateTime fechaCotizacion = solicitud.fechasistema.add(Duration(minutes: cotizacion.tiempoconfirmacion ?? 0));

          // Comprobar si es la cotización más reciente
          if (ultimaCotizacion == null || fechaCotizacion.isAfter(fechaUltimaCotizacion!)) {
            ultimaCotizacion = cotizacion;
            fechaUltimaCotizacion = fechaCotizacion;
          }
        }
      }
    }

    // Verificar si se encontró alguna cotización
    if (ultimaCotizacion != null) {
      return fechaUltimaCotizacion!;
    } else {
      return DateTime.now(); // Puedes manejar el caso cuando no hay cotizaciones, retornando null o una fecha predeterminada
    }
  }

}

class _BusquedaTutor extends StatefulWidget{
  final double currentwidth;

  const _BusquedaTutor({Key?key,
    required this.currentwidth,
  }) :super(key: key);

  @override
  _BusquedaTutorState createState() => _BusquedaTutorState();

}

class _BusquedaTutorState extends State<_BusquedaTutor> {
  String materiabusqueda = "";
  List<Tutores> tutoresList = [];
  List<Tutores> tutoresFiltrados = [];
  bool _cargadotutoresfiltradosmateria = false;
  Materia? selectedMateria;
  Materia? selectedMateriados;
  Materia? selectedMateriatres;
  Materia? selectedMateriacuatro;
  Materia? selectedMateriacinco;
  List<Materia> materiaList = [];
  bool _materiacargarauto = false;
  List<Carrera> carreraList = [];
  Carrera? selectedCarrera;
  Carrera? selectedCarrerados;
  Carrera? selectedCarreratres;
  Carrera? selectedCarreracuatro;
  Carrera? selectedCarrercinco;
  List<Solicitud> solicitudesList = [];
  List<ServicioAgendado> serviciosagendadosList = [];
  Map<String, Map<String, double>> tutorNotas = {};
  List<double> tutorCalificaiconGlobal = [];
  TutorEvaluator? tutorEvaluator;

  @override
  void initState() {
    loadDataTablasMaterias(); // Cargar los datos al inicializar el widget
    super.initState();
  }

  Future<void> loadDataTablasMaterias() async {
    materiaList = await LoadData().tablasmateria();
    carreraList = await LoadData().obtenercarreras();
    solicitudesList = await LoadData().obtenerSolicitudes();
    serviciosagendadosList = (await stream_builders().cargarserviciosagendados())!;
    setState(() {
      _materiacargarauto = true;
    });
  }

  void copiarNumerosWhatsApp() {
    if (tutoresFiltrados.isNotEmpty) {
      String numerosWhatsApp = tutoresFiltrados.map((tutor) {
        return tutor.numerowhatsapp.toString();
      }).join('\n');

      Clipboard.setData(ClipboardData(text: numerosWhatsApp));
    } else {
    }
  }

  Future<void> busquedatutor(String materiabusqueda, String materiabusquedados, String materiaTres, String materiaCuatro, String materiaCinco,String carreraUno,String carreraDos,
      String carreraTres, String carreraCuatro, String carreraCinco
      ) async {
    if (materiabusqueda.isEmpty){
      tutoresFiltrados.clear();
    }else{
      tutoresList = await LoadData().obtenertutores();
      tutoresFiltrados = tutoresList.where((tutor) {
        return tutor.activo;
      }).where((tutor) {
        return tutor.materias.any((materia) =>
        materia.nombremateria == materiabusqueda);
      }).toList();
      print("materia buscado $materiabusqueda");
      print("tutores filtrados $tutoresFiltrados");

      tutorEvaluator = TutorEvaluator(solicitudesList, serviciosagendadosList, tutoresFiltrados, selectedMateria,);
      tutorNotas = tutorEvaluator!.tutorNotas;

      // Ordenar la lista tutoresFiltrados por notaoficial de mayor a menor
      tutoresFiltrados.sort((tutor1, tutor2) {
        double? nota1 = tutorEvaluator?.retornocalificacion(tutor1);
        double? nota2 = tutorEvaluator?.retornocalificacion(tutor2);
        return nota2!.compareTo(nota1!);
      });

      setState(() {
        _cargadotutoresfiltradosmateria = true;
      });
    }
  }


  String _truncateLabel(String label) {
    const int maxLength = 20; // Define la longitud máxima permitida para la etiqueta
    if (label.length > maxLength) {
      return label.substring(0, maxLength - 3) + '...'; // Agrega puntos suspensivos
    }
    return label;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.currentwidth+100,
      color: Colors.green,
      child:Column(
        children: [
          const Text('Busqueda'),
          if(_materiacargarauto==true)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Container(
                      height: 30,
                      width: 200,
                      child: AutoSuggestBox<Materia>(
                        items: materiaList.map<AutoSuggestBoxItem<Materia>>(
                              (materia) => AutoSuggestBoxItem<Materia>(
                            value: materia,

                            label: _truncateLabel(materia.nombremateria),
                            onFocusChange: (focused) {
                              if (focused) {
                                debugPrint('Focused #${materia.nombremateria} - ');
                              }
                            },
                          ),
                        )
                            .toList(),

                        onSelected: (item) {
                          setState(() {
                            selectedMateria = item.value; // Actualizar el valor seleccionado
                          }
                          );
                        },
                        textInputAction: TextInputAction.done,
                        onChanged: (text, reason) {
                          if (text.isEmpty ) {
                            setState(() {
                              print("vacio");
                              selectedMateria = null; // Limpiar la selección cuando se borra el texto
                            });
                          }
                        },
                      ),
                    ),
                    Container(
                      height: 30,
                      width: 200,
                      child: AutoSuggestBox<Materia>(
                        items: materiaList.map<AutoSuggestBoxItem<Materia>>(
                              (materia) => AutoSuggestBoxItem<Materia>(
                            value: materia,
                            label: _truncateLabel(materia.nombremateria),
                            onFocusChange: (focused) {
                              if (focused) {
                                debugPrint('Focused #${materia.nombremateria} - ');
                              }
                            },
                          ),
                        )
                            .toList(),
                        onSelected: (item) {
                          setState(() {
                            print("seleccionado ${item.label}");
                            selectedMateriados = item.value; // Actualizar el valor seleccionado
                          });
                        },
                        textInputAction: TextInputAction.done,
                        onChanged: (text, reason) {
                          if (text.isEmpty) {
                            setState(() {
                              selectedMateriados = null; // Limpiar la selección cuando se borra el texto
                            });
                          }
                        },
                      ),
                    ),
                    Container(
                      height: 30,
                      width: 200,
                      child: AutoSuggestBox<Materia>(
                        items: materiaList.map<AutoSuggestBoxItem<Materia>>(
                              (materia) => AutoSuggestBoxItem<Materia>(
                            value: materia,
                            label: _truncateLabel(materia.nombremateria),
                            onFocusChange: (focused) {
                              if (focused) {
                                debugPrint('Focused #${materia.nombremateria} - ');
                              }
                            },
                          ),
                        )
                            .toList(),
                        onSelected: (item) {
                          setState(() {
                            print("seleccionado ${item.label}");
                            selectedMateriatres = item.value; // Actualizar el valor seleccionado
                          });
                        },
                        textInputAction: TextInputAction.done,
                        onChanged: (text, reason) {
                          if (text.isEmpty) {
                            setState(() {
                              selectedMateriatres = null; // Limpiar la selección cuando se borra el texto
                            });
                          }
                        },
                      ),
                    ),
                    Container(
                      height: 30,
                      width: 200,
                      child: AutoSuggestBox<Materia>(
                        items: materiaList.map<AutoSuggestBoxItem<Materia>>(
                              (materia) => AutoSuggestBoxItem<Materia>(
                            value: materia,
                            label: _truncateLabel(materia.nombremateria),
                            onFocusChange: (focused) {
                              if (focused) {
                                debugPrint('Focused #${materia.nombremateria} - ');
                              }
                            },
                          ),
                        )
                            .toList(),
                        onSelected: (item) {
                          setState(() {
                            print("seleccionado ${item.label}");
                            selectedMateriacuatro = item.value; // Actualizar el valor seleccionado
                          });
                        },
                        textInputAction: TextInputAction.done,
                        onChanged: (text, reason) {
                          if (text.isEmpty) {
                            setState(() {
                              selectedMateriacuatro = null; // Limpiar la selección cuando se borra el texto
                            });
                          }
                        },
                      ),
                    ),
                    Container(
                      height: 30,
                      width: 200,
                      child: AutoSuggestBox<Materia>(
                        items: materiaList.map<AutoSuggestBoxItem<Materia>>(
                              (materia) => AutoSuggestBoxItem<Materia>(
                            value: materia,
                            label: _truncateLabel(materia.nombremateria),
                            onFocusChange: (focused) {
                              if (focused) {
                                debugPrint('Focused #${materia.nombremateria} - ');
                              }
                            },
                          ),
                        )
                            .toList(),
                        onSelected: (item) {
                          setState(() {
                            print("seleccionado ${item.label}");
                            selectedMateriacinco = item.value; // Actualizar el valor seleccionado
                          });
                        },
                        textInputAction: TextInputAction.done,
                        onChanged: (text, reason) {
                          if (text.isEmpty) {
                            setState(() {
                              selectedMateriacinco = null; // Limpiar la selección cuando se borra el texto
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Container(
                      height: 30,
                      width: 200,
                      child: AutoSuggestBox<Carrera>(
                        items: carreraList.map<AutoSuggestBoxItem<Carrera>>(
                              (carrera) => AutoSuggestBoxItem<Carrera>(
                            value: carrera,
                            label: _truncateLabel(carrera.nombrecarrera),
                            onFocusChange: (focused) {
                              if (focused) {
                                debugPrint('Focused #${carrera.nombrecarrera} - ');
                              }
                            },
                          ),
                        )
                            .toList(),

                        onSelected: (item) {
                          setState(() {
                            selectedCarrera = item.value; // Actualizar el valor seleccionado
                          }
                          );
                        },
                        textInputAction: TextInputAction.done,
                        onChanged: (text, reason) {
                          if (text.isEmpty ) {
                            setState(() {
                              print("vacio");
                              selectedCarrera = null; // Limpiar la selección cuando se borra el texto
                            });
                          }
                        },
                      ),
                    ),
                    Container(
                      height: 30,
                      width: 200,
                      child: AutoSuggestBox<Carrera>(
                        items: carreraList.map<AutoSuggestBoxItem<Carrera>>(
                              (carrera) => AutoSuggestBoxItem<Carrera>(
                            value: carrera,
                            label: _truncateLabel(carrera.nombrecarrera),
                            onFocusChange: (focused) {
                              if (focused) {
                                debugPrint('Focused #${carrera.nombrecarrera} - ');
                              }
                            },
                          ),
                        )
                            .toList(),

                        onSelected: (item) {
                          setState(() {
                            selectedCarrerados = item.value; // Actualizar el valor seleccionado
                          }
                          );
                        },
                        textInputAction: TextInputAction.done,
                        onChanged: (text, reason) {
                          if (text.isEmpty ) {
                            setState(() {
                              print("vacio");
                              selectedCarrerados = null; // Limpiar la selección cuando se borra el texto
                            });
                          }
                        },
                      ),
                    ),
                    Container(
                      height: 30,
                      width: 200,
                      child: AutoSuggestBox<Carrera>(
                        items: carreraList.map<AutoSuggestBoxItem<Carrera>>(
                              (carrera) => AutoSuggestBoxItem<Carrera>(
                            value: carrera,
                            label: _truncateLabel(carrera.nombrecarrera),
                            onFocusChange: (focused) {
                              if (focused) {
                                debugPrint('Focused #${carrera.nombrecarrera} - ');
                              }
                            },
                          ),
                        )
                            .toList(),

                        onSelected: (item) {
                          setState(() {
                            selectedCarreratres = item.value; // Actualizar el valor seleccionado
                          }
                          );
                        },
                        textInputAction: TextInputAction.done,
                        onChanged: (text, reason) {
                          if (text.isEmpty ) {
                            setState(() {
                              print("vacio");
                              selectedCarreratres = null; // Limpiar la selección cuando se borra el texto
                            });
                          }
                        },
                      ),
                    ),
                    Container(
                      height: 30,
                      width: 200,
                      child: AutoSuggestBox<Carrera>(
                        items: carreraList.map<AutoSuggestBoxItem<Carrera>>(
                              (carrera) => AutoSuggestBoxItem<Carrera>(
                            value: carrera,
                            label: _truncateLabel(carrera.nombrecarrera),
                            onFocusChange: (focused) {
                              if (focused) {
                                debugPrint('Focused #${carrera.nombrecarrera} - ');
                              }
                            },
                          ),
                        )
                            .toList(),

                        onSelected: (item) {
                          setState(() {
                            selectedCarreracuatro = item.value; // Actualizar el valor seleccionado
                          }
                          );
                        },
                        textInputAction: TextInputAction.done,
                        onChanged: (text, reason) {
                          if (text.isEmpty ) {
                            setState(() {
                              print("vacio");
                              selectedCarreracuatro = null; // Limpiar la selección cuando se borra el texto
                            });
                          }
                        },
                      ),
                    ),
                    Container(
                      height: 30,
                      width: 200,
                      child: AutoSuggestBox<Carrera>(
                        items: carreraList.map<AutoSuggestBoxItem<Carrera>>(
                              (carrera) => AutoSuggestBoxItem<Carrera>(
                            value: carrera,
                            label: _truncateLabel(carrera.nombrecarrera),
                            onFocusChange: (focused) {
                              if (focused) {
                                debugPrint('Focused #${carrera.nombrecarrera} - ');
                              }
                            },
                          ),
                        )
                            .toList(),

                        onSelected: (item) {
                          setState(() {
                            selectedCarrercinco = item.value; // Actualizar el valor seleccionado
                          }
                          );
                        },
                        textInputAction: TextInputAction.done,
                        onChanged: (text, reason) {
                          if (text.isEmpty ) {
                            setState(() {
                              print("vacio");
                              selectedCarrercinco = null; // Limpiar la selección cuando se borra el texto
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          FilledButton(
            child: const Text('Buscar'),
            onPressed: () {
              String materiaUno = selectedMateria != null ? selectedMateria!.nombremateria : "";
              String materiaDos = selectedMateriados != null ? selectedMateriados!.nombremateria : "";
              String materiaTres = selectedMateriatres != null ? selectedMateriatres!.nombremateria : "";
              String materiaCuatro = selectedMateriacuatro != null ? selectedMateriacuatro!.nombremateria : "";
              String materiaCinco = selectedMateriacinco != null ? selectedMateriacinco!.nombremateria : "";
              String carreraUno = selectedCarrera != null ? selectedCarrera!.nombrecarrera : "";
              String carreraDos = selectedCarrerados != null ? selectedCarrerados!.nombrecarrera : "";
              String carreraTres = selectedCarreratres != null ? selectedCarreratres!.nombrecarrera : "";
              String carreraCuatro = selectedCarreracuatro != null ? selectedCarreracuatro!.nombrecarrera : "";
              String carreraCinco = selectedCarrercinco != null ? selectedCarrercinco!.nombrecarrera : "";

              busquedatutor(materiaUno, materiaDos,materiaTres,materiaCuatro,materiaCinco,carreraUno,carreraDos,carreraTres,carreraCuatro,carreraCinco);
              print(materiaDos);
              loadDataTablasMaterias();

              //cargarlistas

            },
          ),
          if(_cargadotutoresfiltradosmateria==true)
            Column(
              children: [
                Container(
                  height: 600,
                  child: ListView.builder(
                      itemCount: tutoresFiltrados.length,
                      itemBuilder: (context,index){
                        Tutores? tutore = tutoresFiltrados[index];

                        return Container(
                          height: 220,
                          child: Card(
                              child: Row(

                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(child: Text(tutore.nombrewhatsapp)),
                                  Expanded(child: Text(tutore.numerowhatsapp.toString())),
                                  Column(
                                    children: [
                                      Text("# cot global ${tutorEvaluator?.getNumeroCotizacionesGlobal(tutore.nombrewhatsapp).toStringAsFixed(1)}"),
                                      Text("# cot materia ${tutorEvaluator?.getNumeroCotizaciones(tutore.nombrewhatsapp, selectedMateria!.nombremateria).toStringAsFixed(1)}"),
                                      Text("% resp global ${tutorEvaluator?.getPromedioRespuesta(tutore.nombrewhatsapp).toStringAsFixed(1)}"),
                                      Text("% resp materia ${tutorEvaluator?.getPromedioRespuestaMateria(tutore.nombrewhatsapp, selectedMateria!.nombremateria).toStringAsFixed(1)}"),
                                      Text("% precio global ${tutorEvaluator?.getPromedioPrecioTutor(tutore.nombrewhatsapp).toStringAsFixed(1)}"),
                                      Text("% precio materiar ${tutorEvaluator?.getPromedioPrecioTutorMateria(tutore.nombrewhatsapp,selectedMateria!.nombremateria).toStringAsFixed(1)}"),
                                      Text("# agendados ${tutorEvaluator?.getNumeroCotizacionesAgendado(tutore.nombrewhatsapp).toStringAsFixed(1)}"),
                                      Text("# agendados mater ${tutorEvaluator?.getNumeroCotizacionesAgendadoMateria(tutore.nombrewhatsapp,selectedMateria!.nombremateria).toStringAsFixed(1)}"),
                                      Text("% precio age glo  ${tutorEvaluator?.gerpromedioprecioglobalagendado(tutore.nombrewhatsapp).toStringAsFixed(1)}"),
                                      Text("% ganancias glo  ${tutorEvaluator?.getpromediogananciasgeneradas(tutore.nombrewhatsapp).toStringAsFixed(1)}"),

                                    ],
                                  ), //de materia
                                  Column(
                                    children: [
                                      Text("not cot global ${tutorNotas[tutore.nombrewhatsapp]?['num_materiasglobal']?.toStringAsFixed(1)}"),
                                      Text("not cot materia ${tutorNotas[tutore.nombrewhatsapp]?['num_materiaslocal']?.toStringAsFixed(1)}"),
                                      Text("not % resp global ${tutorNotas[tutore.nombrewhatsapp]?['prom_respuestaglobal']?.toStringAsFixed(2)}"),
                                      Text("not % resp materia ${tutorNotas[tutore.nombrewhatsapp]?['prom_respuestalocal']?.toStringAsFixed(1)}"),
                                      Text("not % precio global ${tutorNotas[tutore.nombrewhatsapp]?['prom_precioglobal']?.toStringAsFixed(1)}"),
                                      Text("not % precio materia ${tutorNotas[tutore.nombrewhatsapp]?['prom_precioglobalmateria']?.toStringAsFixed(1)}"),
                                      Text("not # agendados ${tutorNotas[tutore.nombrewhatsapp]?['num_serviciosagedndados']?.toStringAsFixed(1)}"),
                                      Text("not # agendados materia ${tutorNotas[tutore.nombrewhatsapp]?['num_serviciosagedndadosmateria']?.toStringAsFixed(1)}"),
                                      Text("not % precio age glo ${tutorNotas[tutore.nombrewhatsapp]?['prom_precioagendadosglobal']?.toStringAsFixed(1)}"),
                                      Text("not % ganancias glo ${tutorNotas[tutore.nombrewhatsapp]?['prom_preciogananciasglobal']?.toStringAsFixed(1)}"),

                                      Text('calificación ${tutorEvaluator?.retornocalificacion(tutore).toStringAsFixed(1)}'),
                                      Text('ult fecha ${tutorEvaluator?.ultimaFechaCotizacionTutor(tutore.nombrewhatsapp)}'),
                                    ],
                                  )
                                ],
                              )),
                        );
                      }
                  ),
                ),
                FilledButton(
                  child: const Text('Copiar numeros de wsp'),
                  onPressed: () {
                    copiarNumerosWhatsApp();
                  },
                ),
              ],
            ),

        ],
      ),
    );
  }
}

class _CrearTutorNuevo extends StatefulWidget{
  final double currentwidth;

  const _CrearTutorNuevo({Key?key,
    required this.currentwidth,
  }) :super(key: key);

  @override
  _CrearTutorNuevoState createState() => _CrearTutorNuevoState();

}

class _CrearTutorNuevoState extends State<_CrearTutorNuevo> {
  //Variables para crear tutor
  String nombrewsp = "";
  String nombreCompleto = "";
  int numwasa = 0;
  Carrera? selectedCarrera;
  Universidad? selectedUniversidad;
  String correogmail = "";
  String passuno = "";
  String passdos = "";
  final db = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;
  List<Carrera> CarrerasList = [];
  List<Universidad> UniversidadList = [];
  bool _cargadodatos = false;
  CollectionReferencias referencias = CollectionReferencias();

  @override
  void initState() {
    loadDataTablasMaterias(); // Cargar los datos al inicializar el widget
    super.initState();
  }

  Future<void> loadDataTablasMaterias() async {
    CarrerasList = await LoadData().obtenercarreras();
    UniversidadList = await LoadData().obtenerUniversidades();
    setState(() {
      _cargadodatos = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.currentwidth,
      color: Colors.green,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text('Agregar'),
          //Nombre wsp
          TextBox(
            placeholder: 'Nombre Whatsapp',
            onChanged: (value){
              setState(() {
                nombrewsp = value;
              });
            },
            maxLines: null,
          ),
          //Nombre completo
          TextBox(
            placeholder: 'Nombre Completo',
            onChanged: (value){
              setState(() {
                nombreCompleto = value;
              });
            },
            maxLines: null,
          ),
          //num wso
          TextBox(
            placeholder: 'Numero wsp con +57',
            onChanged: (value){
              setState(() {
                numwasa = int.parse(value);
              });
            },
            maxLines: null,
          ),
          //Carrera estudiada
          if(_cargadodatos==true)
            Column(
              children: [
                //carrera
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Carrera'),
                    Container(
                      height: 30,
                      width: 200,
                      child: AutoSuggestBox<Carrera>(
                        items: CarrerasList.map<AutoSuggestBoxItem<Carrera>>(
                              (carrera) => AutoSuggestBoxItem<Carrera>(
                            value: carrera,
                            label: carrera.nombrecarrera,
                            onFocusChange: (focused) {
                              if (focused) {
                                debugPrint('Focused #${carrera.nombrecarrera} - ');
                              }
                            },
                          ),
                        )
                            .toList(),
                        onSelected: (item) {
                          setState(() {
                            print("seleccionado ${item.label}");
                            selectedCarrera = item.value; // Actualizar el valor seleccionado
                          });
                        },
                      ),
                    ),
                  ],
                ),
                //universidad
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Universidad'),
                    SizedBox(
                      height: 30,
                      width: 200,
                      child: AutoSuggestBox<Universidad>(
                        items: UniversidadList.map<AutoSuggestBoxItem<Universidad>>(
                              (universidad) => AutoSuggestBoxItem<Universidad>(
                            value: universidad,
                            label: universidad.nombreuniversidad,
                            onFocusChange: (focused) {
                              if (focused) {
                                debugPrint('Focused #${universidad.nombreuniversidad} - ');
                              }
                            },
                          ),
                        )
                            .toList(),
                        onSelected: (item) {
                          setState(() {
                            selectedUniversidad = item.value; // Actualizar el valor seleccionado
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          //correo gmail
          TextBox(
            placeholder: 'Correo gmail',
            onChanged: (value){
              setState(() {
                correogmail = value;
              });
            },
            maxLines: null,
          ),
          //contraseña
          TextBox(
            placeholder: 'Contraseña',
            onChanged: (value){
              setState(() {
                passuno = value;
              });
            },
            maxLines: null,
          ),
          //id carpeta
          FilledButton(child: const Text('Agregar'), onPressed: ()async{
            print("crear nuevo usuario");
            await createUserWithEmailAndPassword();
          }),
        ],
      ),
    );
  }

  Future<void> createUserWithEmailAndPassword() async {
    await referencias.initCollections();
    try {
      final credential = await referencias.authdireccion!.createUserWithEmailAndPassword(email: correogmail, password: passuno,);
      print("usuario creado");
      await Uploads().addinfotutor(nombrewsp, nombreCompleto, numwasa, selectedCarrera!.nombrecarrera, correogmail, selectedUniversidad!.nombreuniversidad, referencias.authdireccion!.currentUser!.uid);
      referencias.initCollections();
      referencias.authdireccion!.signOut();
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        setState(() {
          print("contraseña mala");
        });
      } else if (e.code == 'email-already-in-use') {
        setState(() {
          print("email ya usado");
        });
      }
    } catch (e) {
      print(e);
      print("error no se creo");
    }
  }

}

class VistaTutoresProvider extends ChangeNotifier {
  List<Tutores> tutorseleccionado = [];
  List<Tutores> todosLosTutores = [];
  List<Tutores> get todosLosTutoresSeleccioando => todosLosTutores;

  String filtro = "";

  void cargarTodosTutores(List<Tutores> tutor){
    todosLosTutores = tutor.toList();
    cargarTutores();
    notifyListeners();
  }

  void setFiltro(String nuevoFiltro) {
    filtro = nuevoFiltro;
    cargarTutores();
    notifyListeners();
  }

  void cargarTutores() {
    tutorseleccionado = todosLosTutores
        .where((tutor) {
      switch (filtro) {
        case 'TutorA':
          return tutor.activo == true && tutor.rol == "TUTOR";
        case 'TutorInac':
          return tutor.rol == 'TUTOR' && tutor.activo == false;
        case 'ADMON':
          return tutor.rol == 'ADMIN';
        default:
          return true; // Sin filtro o filtro desconocido, mostrar todos
      }
    })
        .toList(); // Assign the loaded tutors to todosLosTutores
    notifyListeners();
  }

  void busquedatutor(String texto){
    tutorseleccionado = todosLosTutores
    .where((tutor) =>
        tutor.nombrewhatsapp == texto,
    ).toList();
    notifyListeners();
  }

  void modificarTutor(Tutores tutor) {
    Tutores tutorEnLista = tutorseleccionado.where((tutore) => tutore.uid == tutor.uid).first;

    tutorEnLista.nombrecompleto = tutor.nombrecompleto;
    tutorEnLista.numerowhatsapp = tutor.numerowhatsapp;
    tutorEnLista.carrera = tutor.carrera;
    tutorEnLista.univerisdad = tutor.univerisdad;
    tutorEnLista.activo = tutor.activo;

    notifyListeners();
  }

  void clearTutores() {
    tutorseleccionado.clear(); // Clear the list
    notifyListeners();
  }
}


