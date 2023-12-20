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
import '../Config/theme.dart';
import '../Dashboard.dart';
import '../Objetos/Cotizaciones.dart';
import '../Objetos/Objetos Auxiliares/Carreras.dart';
import '../Objetos/Objetos Auxiliares/Materias.dart';
import '../Objetos/Solicitud.dart';
import '../Utils/Firebase/Uploads.dart';
import 'MainTutores/DetallesTutores.dart';

class TutoresVista extends StatefulWidget {
  const TutoresVista({super.key});

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
  final ThemeApp themeApp = ThemeApp();

  @override
  Widget build(BuildContext context) {
    final double currentHeigth = MediaQuery.of(context).size.height;

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
  late String? selectedTipoCuenta;
  final List<String> tipoCuentaList = ['NEQUI','PAYPAL','BANCOLOMBIA','DAVIPLATA','BINANCE'];
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

  final ThemeApp themeApp = ThemeApp();
  late TextStyle styleText = const TextStyle();
  late TextStyle styleTextSub = const TextStyle();



  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized(); // Asegura que Flutter esté inicializado
    loadtablas(); // Cargar los datos al inicializar el widget
    cargartutores();
    super.initState();

    styleText = themeApp.styleText(14, false, themeApp.grayColor);
    styleTextSub = themeApp.styleText(15, true, themeApp.grayColor);

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
    final double currentHeight = MediaQuery.of(context).size.height;

    return Consumer<VistaTutoresProvider>(
        builder: (context, tutorProvider, child) {
          List<Tutores> tutores = tutorProvider.tutorseleccionado;

          return Column(
            children: [
              contarTutoresRoles(tutoresList),

              SizedBox(
                height: currentHeight * 0.6,
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
                                        Text(tutor.nombrewhatsapp, style: themeApp.styleText(16, true, tutor.activo ? themeApp.greenColor : themeApp.redColor),),
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

                                        GestureDetector(
                                          onTap: (){
                                            material.Navigator.push(context, material.MaterialPageRoute(
                                              builder: (context)  => Dashboard(showSolicitudesNew: false, solicitud: Solicitud.empty(),tutor: tutor,showTutoresDetalles: true,),
                                            ));
                                          },
                                          child: AnimatedContainer(
                                            duration: const Duration(milliseconds: 500),
                                            width: 25,
                                            height: 25,
                                            alignment: Alignment.center,
                                            margin: const EdgeInsets.symmetric(horizontal: 3.0),
                                            decoration: BoxDecoration(
                                              color: themeApp.primaryColor,
                                              borderRadius: BorderRadius.circular(80)
                                            ),
                                            child: Icon(material.Icons.add, color: themeApp.whitecolor,),
                                          ),
                                        ),

                                        GestureDetector(
                                          onTap: (){

                                          },
                                          child: AnimatedContainer(
                                            duration: const Duration(milliseconds: 500),
                                            width: 25,
                                            height: 25,
                                            alignment: Alignment.center,
                                            margin: const EdgeInsets.symmetric(horizontal: 3.0),
                                            decoration: BoxDecoration(
                                                color: themeApp.redColor,
                                                borderRadius: BorderRadius.circular(80)
                                            ),
                                            child: Icon(material.Icons.cancel, color: themeApp.whitecolor,),
                                          ),
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
  }

  Padding _textAndTitle(String title, String text, [Color? color]){
    final TextStyle styleTextColor = color == null? styleText : themeApp.styleText(14, false, color);
    return material.Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 3.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: styleTextSub,),
          Text(text, style: styleTextColor,),
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
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PrimaryStyleButton(
                function: () {
              tutoresProvider.setFiltro('TutorA');
            },
                text: "Tutor Activo"
            ),

            PrimaryStyleButton(
                function: () {
              tutoresProvider.setFiltro('TutorInac');
            },
                text: "Tutor Inactivo"
            ),

            PrimaryStyleButton(
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

    final TextStyle styleText = themeApp.styleText(14, false, themeApp.whitecolor);
    final TextStyle styleTextSub = themeApp.styleText(15, true, themeApp.whitecolor);

    return ItemsCard(
      width: widget.currentwidth+100,
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
                  ],
                ),
              ],
            ),
          ),

        PrimaryStyleButton(
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
              SizedBox(
                height: 600,
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
                                      Text(tutore.nombrewhatsapp, style: themeApp.styleText(18, true, themeApp.primaryColor),),
                                      Text(tutore.numerowhatsapp.toString(), style: themeApp.styleText(18, false, themeApp.grayColor),),
                                    ],
                                  ),
                                ),

                                material.Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
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
                                    ),
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
  late Carrera? selectedCarrera;
  late Universidad? selectedUniversidad;
  final db = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  late List<Carrera> CarrerasList = [];
  late List<Universidad> UniversidadList = [];
  late bool _cargadodatos = false;
  final CollectionReferencias referencias = CollectionReferencias();
  final ThemeApp themeApp = ThemeApp();

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

    final TextStyle styleTextSub = themeApp.styleText(15, true, themeApp.grayColor);

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

        //Carrera estudiada
        if(_cargadodatos==true)
          material.Padding(
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
                ),
              ],
            ),
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

        //id carpeta
        PrimaryStyleButton(
            width: 120,
            function: ()async{
          print("crear nuevo usuario");
          await createUserWithEmailAndPassword();
        },
            text: "Agregar")
      ],
    );
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


