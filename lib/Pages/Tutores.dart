import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dashboard_admin_flutter/Config/elements.dart';
import 'package:dashboard_admin_flutter/Objetos/AgendadoServicio.dart';
import 'package:dashboard_admin_flutter/Objetos/Objetos%20Auxiliares/Universidad.dart';
import 'package:dashboard_admin_flutter/Objetos/Tutores_objet.dart';
import 'package:dashboard_admin_flutter/Utils/Firebase/CollectionReferences.dart';
import 'package:flutter/material.dart' as material;
import 'package:dashboard_admin_flutter/Utils/Firebase/StreamBuilders.dart';
import 'package:dashboard_admin_flutter/Pages/MainTutores/NotaTutores.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';
import '../Config/Config.dart';
import 'package:intl/intl.dart';
import '../Config/strings.dart';
import '../Config/theme.dart';
import '../Dashboard.dart';
import '../Objetos/Cotizaciones.dart';
import '../Objetos/Objetos Auxiliares/Carreras.dart';
import '../Objetos/Objetos Auxiliares/Materias.dart';
import '../Objetos/Solicitud.dart';
import '../Providers/Providers.dart';
import '../Utils/Firebase/Uploads.dart';
import 'MainTutores/DetallesTutores.dart';

class TutoresVista extends StatefulWidget {
  const TutoresVista({super.key});

  @override
  TutoresVistaVistaState createState() => TutoresVistaVistaState();
}

class TutoresVistaVistaState extends State<TutoresVista> {
  Config configuracion = Config();
  List<Tutores> tutoresList = [];
  bool cargadodata = false;

  @override
  void initState() {
    loadtablas();
    super.initState();
  }

  Future<void> loadtablas() async {
    //tutoresList = await LoadData().obtenertutores();
    setState(() {
      cargadodata=true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentwidth = MediaQuery.of(context).size.width;
    final tamanowidth = (currentwidth/3)-Config.responsivepc/3;
    return NavigationView(
      content: Row(
        children: [
          if(currentwidth>=configuracion.computador)
            if(cargadodata==true)
              Row(children: [
                _Creartutores(currentwidth: tamanowidth-30,tutoresList: tutoresList,),
                _BusquedaTutor(currentwidth: tamanowidth+60,),
                _CrearTutorNuevo(currentwidth: tamanowidth-30),
              ],),
          if(currentwidth < 1200 && currentwidth > 620)
            Container(
                width: currentwidth-Config.responsivetablet,
                child: TutoresResponsiveVista(tutoresList: tutoresList,)),
          if(currentwidth <= 620)
            Container(
                width: currentwidth-Config.responsivecelular,
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
  final ThemeApp themeApp = ThemeApp();
  late bool construct = false;

  @override
  void initState(){
    super.initState();
    WidgetsFlutterBinding.ensureInitialized(); // Asegura que Flutter esté inicializado
    themeApp.initTheme().then((_) {
      setState(()=>construct = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final double currentHeigth = MediaQuery.of(context).size.height;

    if(construct){
      return SizedBox(
        width: widget.currentwidth,
        height: currentHeigth,
        child: ItemsCard(
          alignementColumn: MainAxisAlignment.start,
          shadow: false,
          children: [
            material.Padding(
              padding: const EdgeInsets.only(top: 22.0, bottom: 15.0),
              child: Text('Tutores', style: themeApp.styleText(24, true, themeApp.primaryColor),),
            ),
            _TarjetaTutores(tutoresList: widget.tutoresList),
          ],
        ),
      );
    }else{
      return const Center(child: material.CircularProgressIndicator());
    }
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
  late String? selectedTipCuenta;
  final List<String> tipoCuentaList = ['NEQUI','PAYPAL','BANCOLOMBIA','DAVIPLATA','BINANCE'];
  String numeroCuenta = "";
  String cedula = "";
  String nombreCedula = "";
  List<Materia> materiaList = [];
  Materia? selectedMateria;
  List<Solicitud> solicitudesList = [];
  bool dataLoaded = false;

  String Busqueda = "";
  Tutores? selectedTutor;

  final ThemeApp themeApp = ThemeApp();
  late TextStyle styleText = const TextStyle();
  late TextStyle styleTextSub = const TextStyle();
  late bool construct = false;

  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized(); // Asegura que Flutter esté inicializado
    loadtablas(); // Cargar los datos al inicializar el widget
    super.initState();
    themeApp.initTheme().then((_) {
      setState(()=>construct = true);
    });
    styleText = themeApp.styleText(14, false, themeApp.grayColor);
    styleTextSub = themeApp.styleText(15, true, themeApp.grayColor);
  }


  Future<void> loadtablas() async {
    //materiaList = await LoadData().tablasmateria();
    //solicitudesList = await LoadData().obtenerSolicitudes();
    setState(() {
      dataLoaded=true;
    });
    print("load tablas ejecutandose");
  }

  @override
  Widget build(BuildContext context) {
    final double currentHeight = MediaQuery.of(context).size.height;

    if(construct){
      return Consumer<VistaTutoresProvider>(
          builder: (context, tutorProvider, child) {
            List<Tutores> tutores = tutorProvider.tutorseleccionado;
            List<Tutores> tutoresList = tutorProvider.todosLosTutores;

            return Column(
              children: [
                contarTutoresRoles(tutoresList),

                SizedBox(
                    height: currentHeight * 0.55,
                    child: ListView.builder(
                        itemCount: tutores.length,
                        itemBuilder: (context,index) {
                          Tutores? tutor = tutores[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5,horizontal: 8),
                            child: material.Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: (tutor.activo) ? themeApp.greenColor : themeApp.redColor,
                                    width: 2.0,
                                  )
                              ),
                              child: Card(
                                backgroundColor: themeApp.blackColor.withOpacity(0),
                                borderRadius: BorderRadius.circular(20),
                                child:Column(
                                  children: [
                                    //nombre y numero de wasap
                                    material.Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(child: Text(tutor.nombrewhatsapp, style: themeApp.styleText(16, true, tutor.activo ? themeApp.greenColor : themeApp.redColor),)),
                                          GestureDetector(
                                            onTap: () {
                                              final textToCopy = tutor.numerowhatsapp.toString();
                                              Clipboard.setData(ClipboardData(text: textToCopy));
                                            },
                                            child:Text(tutor.numerowhatsapp.toString(), style: themeApp.styleText(16, false, themeApp.grayColor),),

                                          ),
                                        ],
                                      ),
                                    ),

                                    //# de materias manejadas
                                    _textAndTitle("Materias: ", "${tutor.materias.length.toString()} materias registradas"),

                                    //# de cuentas bancarias registradas
                                    _textAndTitle("Cuentas: ", "${tutor.cuentas.length.toString()} cuentas registradas"),

                                    //nombre del tutor
                                    _textAndTitle("Nombre Completo: ", tutor.nombrecompleto),

                                    _textAndTitle("Universidad: ", tutor.univerisdad),

                                    _textAndTitle("Carrera: ", tutor.carrera),

                                    _textAndTitle("Tutor Activo: ", tutor.activo ? "Tutor Activo" : "Tutor Inactivo", tutor.activo ? themeApp.greenColor : themeApp.redColor),

                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 3.0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          CircularButton(
                                              buttonColor: themeApp.primaryColor,
                                              radio: 28,
                                              iconData: material.Icons.add,
                                              function: (){
                                                final tutorProvider = Provider.of<VistaTutoresProvider>(context, listen: false);
                                                material.Navigator.push(context, material.MaterialPageRoute(
                                                  builder: (context)  => const Dashboard(showSolicitudesNew: false,showTutoresDetalles: true,),
                                                ));
                                                tutorProvider.seleccionarTutor(tutor);
                                              }
                                          ),

                                          CircularButton(
                                              radio: 28,
                                              buttonColor: themeApp.redColor,
                                              iconData: material.Icons.clear,
                                              function: (){

                                              }
                                          ),
                                        ],
                                      ),
                                    ),

                                    if(dataLoaded==true)
                                      Text('ult fecha ${DateFormat('dd/MM/yy').format(ultimaFechaCotizacionTutor(tutor.nombrewhatsapp))}', style: themeApp.styleText(11, false, themeApp.grayColor),)
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
    }else{
      return const Center(child: material.CircularProgressIndicator());
    }
  }

  Padding _textAndTitle(String title, String text, [Color? color]){
    final TextStyle styleTextColor = color == null? styleText : themeApp.styleText(14, false, color);
    return material.Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 3.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(title, style: styleTextSub, textAlign: TextAlign.start,)),
          Expanded(child: Text(text, style: styleTextColor, textAlign: TextAlign.end,)),
        ],
      ),
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
        Text('$tutoresActivos tutores activos, $tutoreInactivos tutores inactivos', style: styleText,),
        Text('$administradores administradores activos', style: styleText,),
        Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                PrimaryStyleButton(
                  buttonColor: themeApp.primaryColor,
                    function: () {
                      tutoresProvider.setFiltro('TutorA');
                    },
                    text: "Tutor Activo"
                ),

                PrimaryStyleButton(
                    buttonColor: themeApp.primaryColor,
                    function: () {
                      tutoresProvider.setFiltro('TutorInac');
                    },
                    text: "Tutor Inactivo"
                ),
              ],
            ),

            PrimaryStyleButton(
                buttonColor: themeApp.primaryColor,
                function: () {
                  tutoresProvider.setFiltro('ADMON');
                },
                text: "Administradores"
            ),

          ],
        ),
        material.Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: material.Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              material.Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                child: Icon(material.Icons.search, color: themeApp.grayColor, size: 14,),
              ),

              Container(
                height: 30,
                width: 350,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(80)
                ),
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
  final ThemeApp themeApp = ThemeApp();
  late bool construct = false;

  @override
  void initState(){
    super.initState();
    loadDataTablasMaterias();
    WidgetsFlutterBinding.ensureInitialized(); // Asegura que Flutter esté inicializado
    themeApp.initTheme().then((_) {
      setState(()=>construct = true);
    });
  }

  Future<void> loadDataTablasMaterias() async {
    materiaList = await stream_builders().cargarMaterias();
    carreraList = await stream_builders().cargarCarreras();
    solicitudesList = (await stream_builders().cargarsolicitudes())!;
    serviciosagendadosList = (await stream_builders().cargarserviciosagendados())!;
    final tutoresProvider =  context.read<VistaTutoresProvider>();
    tutoresList = tutoresProvider.todosLosTutores;
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

      tutoresFiltrados = tutoresList.where((tutor) {
        print("el tutor ${tutor.nombrewhatsapp} tiene ${tutor.materias.length}");
        return tutor.activo;
      }).where((tutor) {
        print("tutor entrando");
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
      return '${label.substring(0, maxLength - 3)}...'; // Agrega puntos suspensivos
    }
    return label;
  }

  @override
  Widget build(BuildContext context) {
    if(construct){
      return ItemsCard(
        width: widget.currentwidth,
        cardColor: themeApp.primaryColor,
        shadow: false,
        alignementColumn: MainAxisAlignment.start,
        children: [
          material.Padding(
            padding: const EdgeInsets.only(top: 20.0, bottom: 12.0),
            child: Text('Busqueda', style: themeApp.styleText(24, true, themeApp.whitecolor),),
          ),
          if(_materiacargarauto)
            material.Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [

                      material.Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: Text("Materias", style: themeApp.styleText(18, true, themeApp.whitecolor)),
                      ),

                      material.Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5.0),
                        child: SizedBox(
                          height: 30,
                          width: 200,
                          child: AutoSuggestBox<Materia>(
                            items: materiaList.map<AutoSuggestBoxItem<Materia>>(
                                  (materia) => AutoSuggestBoxItem<Materia>(
                                value: materia,

                                label: _truncateLabel(materia.nombremateria),
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
                      ),

                      /*
                    material.Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5.0),
                      child: SizedBox(
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
                    ),

                    material.Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5.0),
                      child: SizedBox(
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
                    ),

                    material.Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5.0),
                      child: SizedBox(
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
                    ),

                    material.Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5.0),
                      child: SizedBox(
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
                    ),

                     */
                    ],
                  ),

                  Column(
                    children: [

                      material.Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: Text("Carreras", style: themeApp.styleText(18, true, themeApp.whitecolor)),
                      ),

                      material.Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5.0),
                        child: SizedBox(
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
                      ),
                      /*
                    material.Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5.0),
                      child: SizedBox(
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
                    ),


                    material.Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5.0),
                      child: SizedBox(
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
                    ),

                    material.Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5.0),
                      child: SizedBox(
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
                    ),

                    material.Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5.0),
                      child: SizedBox(
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
                    ),

                     */
                    ],
                  ),
                ],
              ),
            ),

          PrimaryStyleButton(
            buttonColor: themeApp.primaryColor,
              invert: true,
              width: 120,
              function: () {
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
              text: "Buscar"),
          if(_cargadotutoresfiltradosmateria==true)
            Column(
              children: [
                material.SizedBox(
                  height: 400,
                  child: ListView.builder(
                      itemCount: tutoresFiltrados.length,
                      itemBuilder: (context,index){
                        Tutores? tutore = tutoresFiltrados[index];

                        return material.Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                          child: Card(
                              padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 30.0),
                              borderRadius: BorderRadius.circular(20),
                              backgroundColor: themeApp.whitecolor,
                              child: Column(
                                children: [

                                  material.Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(child: Text(tutore.nombrewhatsapp, style: themeApp.styleText(18, true, themeApp.primaryColor), textAlign: TextAlign.start,)),
                                        Expanded(child: Text(tutore.numerowhatsapp.toString(), style: themeApp.styleText(18, false, themeApp.grayColor), textAlign: TextAlign.end,)),
                                      ],
                                    ),
                                  ),

                                  material.Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [

                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [

                                            _textAndTitle("Calificacion obtenida: ", tutorEvaluator!.retornocalificacion(tutore).toStringAsFixed(1)),
                                            _nivelTutor("Nivel: ", tutorEvaluator!.retornocalificacion(tutore)),

                                            material.Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: [
                                                  CircularButton(
                                                    buttonColor: themeApp.primaryColor,
                                                    iconData: material.Icons.format_list_bulleted,
                                                    function: (){
                                                      _mostrarDetalles(context, tutore, tutorEvaluator!);
                                                    },
                                                  ),
                                                ],
                                              ),
                                            )

                                          ],
                                        ),
                                      ),

                                      _pieChart(tutorEvaluator!.retornocalificacion(tutore), 90),

                                    ],
                                  )
                                ],
                              )),
                        );
                      }
                  ),
                ),
                PrimaryStyleButton(
                  buttonColor: themeApp.primaryColor,
                    invert: true,
                    function: () => copiarNumerosWhatsApp(),
                    text: "Copiar numeros de WhatsApp"
                ),
              ],
            ),

        ],
      );
    }else{
      return const Center(child: material.CircularProgressIndicator(),);
    }
  }

  void _mostrarDetalles(BuildContext context, Tutores tutores, TutorEvaluator tutorEvaluator) => showDialog(
    context: context,
    builder: (BuildContext context) => _detallesBusqueda(context, tutores, tutorEvaluator),
  );

  material.Dialog _detallesBusqueda(BuildContext context, Tutores tutor, TutorEvaluator tutorEvaluator){
    TextStyle styleText([double? tamanio]) => themeApp.styleText(tamanio ?? 14, false, themeApp.grayColor);
    return material.Dialog(
      backgroundColor: themeApp.whitecolor.withOpacity(0),
      child: ItemsCard(
        width: 400,
        height: 340,
        horizontalPadding: 20.0,
        children: [
          Text("Detalles ${tutor.nombrewhatsapp}", style: themeApp.styleText(20, true, themeApp.primaryColor),),
          material.Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(tutor.nombrecompleto, style: styleText(12),),
          ),

          _textAndTitle("Materia:", tutorEvaluator.selectedMateria!.nombremateria),
          _textAndTitle("Servicios:", "${tutorEvaluator.serviciosagendadosList.length.toString()} agendados"),
          _textAndTitle("Solicitudes:", "${tutorEvaluator.solicitudesList.length.toString()} solicitudes"),
          _textAndTitle("WhatsApp:", tutor.numerowhatsapp.toString()),

          material.Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0),
            child: PrimaryStyleButton(
              buttonColor: themeApp.primaryColor,
              function: () => Navigator.pop(context),
              text: " Cancelar "
            ),
          ),

        ],
      ),
    );
  }

  Padding _textAndTitle(String title, String text){
    return Padding(
      padding: const EdgeInsets.only(left: 5.0, top: 2.0, bottom: 2.0, right: 30.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(title, style: themeApp.styleText(15, true, themeApp.grayColor), textAlign: TextAlign.start,)),
          Expanded(child: Text(text, style: themeApp.styleText(14, false, themeApp.grayColor), textAlign: TextAlign.end,)),
        ],
      ),
    );
  }

  Padding _nivelTutor(String title, double calificacion){
    return Padding(
      padding: const EdgeInsets.only(left: 5.0, top: 2.0, bottom: 2.0, right: 30.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: themeApp.styleText(15, true, themeApp.grayColor),),
          Text(calificacion > 4 ? "Excelente" : calificacion >= 3 ? "Intermedio" : "Regular", style: themeApp.styleText(14, true, calificacion > 4 ? themeApp.greenColor : calificacion >= 3 ? themeApp.primaryColor : themeApp.redColor),),
        ],
      ),
    );
  }

  CircularPercentIndicator _pieChart(double calificacion, double tamanio){
    return CircularPercentIndicator(
      radius: tamanio,
      lineWidth: 5.0,
      percent: calificacion / 5.0,
      center: material.Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(calificacion.toString().length < 2 ? "$calificacion.0" : calificacion.toStringAsFixed(1), style: themeApp.styleText(tamanio * 0.3, true, themeApp.primaryColor),),
          Text("/5.0", style: themeApp.styleText(tamanio * 0.2, true, themeApp.primaryColor),)
        ],
      ),
      circularStrokeCap: CircularStrokeCap.round,
      progressColor: themeApp.primaryColor,
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
  final TextEditingController nombreWsp = TextEditingController();
  final TextEditingController nombrecompleto = TextEditingController();
  final TextEditingController numWsp = TextEditingController();
  final TextEditingController correoGmail = TextEditingController();
  final TextEditingController password = TextEditingController();
  Carrera? selectedCarrera;
  Universidad? selectedUniversidad;
  final db = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  List<Carrera> carreraList = [];
  List<Universidad> universidadList = [];
  final CollectionReferencias referencias = CollectionReferencias();
  final ThemeApp themeApp = ThemeApp();
  late bool construct = false;

  @override
  void initState(){
    super.initState();
    WidgetsFlutterBinding.ensureInitialized(); // Asegura que Flutter esté inicializado
    themeApp.initTheme().then((_) {
      setState(()=>construct = true);
    });
  }

  @override
  Widget build(BuildContext context) {

    final TextStyle styleTextSub = themeApp.styleText(15, true, themeApp.grayColor);

    if(construct){
      return ItemsCard(
        alignementColumn: MainAxisAlignment.start,
        width: widget.currentwidth,
        shadow: false,
        horizontalPadding: 20.0,
        children: [
          material.Padding(
            padding: const EdgeInsets.only(top: 20.0, bottom: 12.0),
            child: Text('Agregar', style: themeApp.styleText(24, true, themeApp.primaryColor)),
          ),
          //Nombre wsp
          RoundedTextField(
              controller: nombreWsp,
              placeholder: "Nombre WhatsApp"
          ),

          //Nombre completo
          RoundedTextField(
              controller: nombrecompleto,
              placeholder: "Nombre Completo"
          ),

          //num wso
          RoundedTextField(
              controller: numWsp,
              placeholder: "Numero WhatsApp con +57"
          ),

          //Carrera y universidad estudiadas
          Consumer2<CarrerasProvider,UniversidadVistaProvider>(
            builder: (context, carreraProviderselect, universidadProviderselect, child) {
              carreraList = carreraProviderselect.todosLasCarreras;
              universidadList = universidadProviderselect.todasLasUniversidades;

              return material.Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  children: [
                    //carrera
                    material.Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Carrera', style: styleTextSub,),
                          SizedBox(
                            height: 30,
                            width: 240,
                            child: AutoSuggestBox<Carrera>(
                              items: carreraList.map<AutoSuggestBoxItem<Carrera>>(
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
                    ),
                    //universidad
                    material.Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Universidad', style: styleTextSub,),
                          SizedBox(
                            height: 30,
                            width: 240,
                            child: AutoSuggestBox<Universidad>(
                              items: universidadList.map<AutoSuggestBoxItem<Universidad>>(
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
                    ),
                  ],
                ),
              );

            },
          ),

          //correo gmail
          RoundedTextField(
              controller: correoGmail,
              placeholder: "Correo Gmail"
          ),

          //contraseña
          RoundedTextField(
              controller: password,
              placeholder: "Contraseña"
          ),

          //Botón
          PrimaryStyleButton(
            buttonColor: themeApp.primaryColor,
              width: 120,
              function: ()async{
                validarAntesDeCrearTutor();
              },
              text: "Agregar")
        ],
      );
    }else{
      return const Center(child: material.CircularProgressIndicator(),);
    }
  }

  Future validarAntesDeCrearTutor() async{
    UtilDialogs dialogs = UtilDialogs(context : context);
    if(nombreWsp.text.isEmpty || nombrecompleto.text.isEmpty || numWsp.text.isEmpty || selectedCarrera!.nombrecarrera == "" ||selectedUniversidad!.nombreuniversidad == "" || correoGmail.text.isEmpty || password.text.isEmpty){
      dialogs.error(Strings().errroDebeLLenarTodo, Strings().errorglobalText);
    }else{
      await createUserWithEmailAndPassword();
      dialogs.exito(Strings().exitoglobal, Strings().exitoglobaltitulo);
    }
  }

  Future<void> createUserWithEmailAndPassword() async {
    await referencias.initCollections();
    try {
      final credential = await referencias.authdireccion!.createUserWithEmailAndPassword(email: correoGmail.text, password: password.text,);
      print("usuario creado");
      await Uploads().addinfotutor(nombreWsp.text, nombrecompleto.text, int.parse(numWsp.text), selectedCarrera!.nombrecarrera, correoGmail.text, selectedUniversidad!.nombreuniversidad, referencias.authdireccion!.currentUser!.uid);
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

