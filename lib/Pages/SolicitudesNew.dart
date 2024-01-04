import 'dart:html';
import 'dart:math';
import 'package:dashboard_admin_flutter/Config/theme.dart';
import 'package:dashboard_admin_flutter/Objetos/AgendadoServicio.dart';
import 'package:dashboard_admin_flutter/Utils/Firebase/StreamBuilders.dart';
import 'package:flutter/material.dart' as material;
import 'package:dashboard_admin_flutter/Config/Config.dart';
import 'package:dashboard_admin_flutter/Objetos/Cotizaciones.dart';
import 'package:dashboard_admin_flutter/Pages/ShowDialogs/SolicitudesDialogs.dart';
import 'package:dashboard_admin_flutter/Utils/Drive%20Api/GoogleDrive.dart';
import 'package:dashboard_admin_flutter/Utils/FuncionesMaterial.dart';
import 'package:dashboard_admin_flutter/Utils/Utiles/FuncionesUtiles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dashboard_admin_flutter/Objetos/Clientes.dart';
import 'package:dashboard_admin_flutter/Objetos/Objetos%20Auxiliares/Materias.dart';
import 'package:dashboard_admin_flutter/Objetos/Solicitud.dart';
import 'package:dashboard_admin_flutter/Utils/Firebase/Load_Data.dart';
import 'package:dashboard_admin_flutter/Utils/Firebase/Uploads.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../Config/elements.dart';
import '../Config/strings.dart';
import '../Dashboard.dart';
import '../Objetos/Configuracion/Configuracion_Configuracion.dart';
import '../Objetos/Objetos Auxiliares/Carreras.dart';
import '../Objetos/Objetos Auxiliares/Universidad.dart';
import '../Objetos/Tutores_objet.dart';
import '../Providers/Providers.dart';
import '../Utils/Disenos.dart';

class SolicitudesNew extends StatefulWidget {
  const SolicitudesNew({super.key});

  @override
  _SolicitudesNewState createState() => _SolicitudesNewState();
}

class _SolicitudesNewState extends State<SolicitudesNew> {
  List<Tutores> tutoresList = [];
  List<Clientes> clienteList = [];
  List<Carrera> CarrerasList = [];
  List<Universidad> UniversidadList = [];
  List<Materia> materiaList = [];
  bool dataLoaded = false;
  final GlobalKey<CuadroSolicitudesState> actualizartablas = GlobalKey<CuadroSolicitudesState>();
  final GlobalKey<_subirsolicitudesState> subirsolicitudes = GlobalKey<_subirsolicitudesState>();
  final GlobalKey<CuadroSolicitudesState> dialogKey = GlobalKey<CuadroSolicitudesState>();
  Config configuracion = Config();
  bool configloaded = false;

  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized(); // Asegura que Flutter esté inicializado
    configuracion.initConfig().then((_) {
      setState(() {
        configloaded = true;
      });
    });
    loadtablas();
    super.initState();
  }

  Future<void> loadtablas() async {
    //Cargar Tutores
    final tutoresProvider =  context.read<VistaTutoresProvider>();
    tutoresList = tutoresProvider.tutoresactivos;
    //Cargar materias
    final materiasProvider =  context.read<MateriasVistaProvider>();
    materiaList = materiasProvider.todasLasMaterias;
    //Cargar clientes
    final clientesProvider =  context.read<ClientesVistaProvider>();
    clienteList = clientesProvider.todosLosClientes;
    //Cargar Univerisdades
    final universidadProvider =  context.read<UniversidadVistaProvider>();
    UniversidadList = universidadProvider.todasLasUniversidades;
    //Cargar carreras
    final carrerasProvider =  context.read<CarrerasProvider>();
    CarrerasList = carrerasProvider.todosLasCarreras;

    Future.delayed(Duration(milliseconds: 400), () {
      actualizartablas.currentState?.update();
    });
    setState(() {
      Future.delayed(Duration(milliseconds: 400), () {
        subirsolicitudes.currentState?.updatedata();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentwidth = MediaQuery.of(context).size.width;
    final currentheight = MediaQuery.of(context).size.height-140;
    final tamanowidth = (currentwidth/3)-30;
    if (!configloaded) {
      print("carngado cosas de solicitudes");
      return Text('cargando cosas');
    }else{
      return NavigationView(
        content: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 12),
          child: Row(
            children: [
              if(currentwidth >= 1200)
                Row(
                  children: [
                    _subirsolicitudes(currentwidth: tamanowidth,onUpdateListaClientes: loadtablas,materiaList: materiaList,clienteList: clienteList,carreraList: CarrerasList,universidadList: UniversidadList,primarycolor: configuracion.primaryColor,),
                    _CrearContainer(currentwidth: tamanowidth, title: "Disponible",descargadatos: true,estado: "DISPONIBLE",height: currentheight,clienteList: clienteList,tutoresList: tutoresList,onUpdateListaClientes: loadtablas,primarycolor: configuracion.primaryColor,),
                    _CrearContainer(currentwidth: tamanowidth, title: "Esperando",descargadatos: false,estado: "ESPERANDO",height: currentheight,clienteList: clienteList,tutoresList: tutoresList,onUpdateListaClientes: loadtablas,primarycolor: configuracion.primaryColor,),
                  ],
                ),
              if(currentwidth < 1200 && currentwidth > 620)
                Container(
                    width: currentwidth-80,
                    child: SolicitudesResponsiveCelular(clienteList: clienteList,onUpdateListaClientes: loadtablas,materiaList: materiaList,tutoresList: tutoresList,carreraList: CarrerasList,universidadList: UniversidadList,primarycolor: configuracion.primaryColor,)),
              if(currentwidth <= 620)
                Container(
                    width: currentwidth-20,
                    child: SolicitudesResponsiveCelular(clienteList: clienteList,onUpdateListaClientes: loadtablas,materiaList: materiaList,tutoresList: tutoresList,carreraList: CarrerasList,universidadList: UniversidadList,primarycolor: configuracion.primaryColor,))
            ],
          ),
        ),
      );
    }

  }
}

class SolicitudesResponsiveCelular extends StatefulWidget {
  final List<Clientes> clienteList;
  final Function() onUpdateListaClientes; // Agrega esta variable
  final List<Materia> materiaList;
  final List<Tutores> tutoresList;
  final List<Carrera> carreraList;
  final List<Universidad> universidadList;
  final Color primarycolor;

  const SolicitudesResponsiveCelular({Key?key,
    required this.clienteList,
    required this.onUpdateListaClientes,
    required this.materiaList,
    required this.tutoresList,
    required this.carreraList,
    required this.universidadList,
    required this.primarycolor,
  }) :super(key: key);

  @override
  _SolicitudesResponsiveCelularState createState() => _SolicitudesResponsiveCelularState();
}

class _SolicitudesResponsiveCelularState extends State<SolicitudesResponsiveCelular> {
  int _selectedpage = 0;

  @override
  Widget build(BuildContext context) {
    final currentwidth = MediaQuery.of(context).size.width;
    final currentheight = MediaQuery.of(context).size.height;
    return NavigationView(
      pane: NavigationPane(
        selected: _selectedpage,
        onChanged: (index) => setState(() {
          _selectedpage = index;
        }),
        displayMode: PaneDisplayMode.top,
        items: <NavigationPaneItem>[
          PaneItem(
            icon:  const Icon(FluentIcons.home),
            title: const Text('New solicitud'),
            body:  _subirsolicitudes(currentwidth: currentwidth,onUpdateListaClientes: widget.onUpdateListaClientes,materiaList: widget.materiaList,clienteList: widget.clienteList,carreraList:widget.carreraList ,universidadList: widget.universidadList,primarycolor: widget.primarycolor,),
          ),
          PaneItem(
            icon:  const Icon(FluentIcons.home),
            title: const Text('Disponible'),
            body:  _CrearContainer(currentwidth: currentwidth, title: "Disponible",descargadatos: true,estado: "DISPONIBLE",height: currentheight-180,clienteList: widget.clienteList,tutoresList: widget.tutoresList,onUpdateListaClientes:widget.onUpdateListaClientes ,primarycolor: widget.primarycolor,),
          ),
          PaneItem(
            icon:  const Icon(FluentIcons.home),
            title: const Text('Esperando'),
            body:  _CrearContainer(currentwidth: currentwidth, title: "Esperando",descargadatos: false,estado: "ESPERANDO",height: currentheight-180,clienteList: widget.clienteList,tutoresList: widget.tutoresList,onUpdateListaClientes:widget.onUpdateListaClientes ,primarycolor: widget.primarycolor,),
          ),
        ],
      ),
    );
  }

}

class _subirsolicitudes extends StatefulWidget{
  final double currentwidth;
  final Function() onUpdateListaClientes; // Agrega esta variable
  final List<Materia> materiaList;
  final List<Clientes> clienteList;
  final List<Carrera> carreraList;
  final List<Universidad> universidadList;
  final Color primarycolor;


  const _subirsolicitudes({Key?key,
    required this.currentwidth,
    required this.onUpdateListaClientes,
    required this.materiaList,
    required this.clienteList,
    required this.carreraList,
    required this.universidadList,
    required this.primarycolor,
  }) :super(key: key);

  @override
  _subirsolicitudesState createState() => _subirsolicitudesState();

}

class _subirsolicitudesState extends State<_subirsolicitudes> {
  List<String> serviciosList = ['PARCIAL','TALLER','QUIZ','ASESORIAS'];
  String? selectedServicio = "";
  String? selectedTipoTesis = "";
  List<String> tipoTesisList = ['PREGRADO','POSGRADO','DOCTORADO'];
  Materia? selectedMateria;
  Clientes? selectedCliente;
  String selectedCarrera = "";
  String selectedUniversidad = "";
  bool dataLoaded = false; // Variable para rastrear si los datos ya se han cargado
  List<Materia> materiaList = [];
  List<Clientes> clienteList = [];
  List<Tutores> tutoresList = [];
  DateTime fechaentrega = DateTime.now();
  String resumen = "";
  String infocliente = "";
  bool anteproyecto = false;
  bool nombretesisbool = false;
  bool cronogramaAvances = false;
  Future<int>? numcotizacionFuture;
  Stream<int>? numcotizacionstream;
  List<PlatformFile>? selectedFiles ;
  String archivoNombre = "";
  String _archivoExtension = "";
  //Inicializar base de datos
  final db = FirebaseFirestore.instance;
  UploadTask? uploadTask;
  List<Carrera> CarrerasList = [];
  List<Universidad> UniversidadList = [];

  //Conteo de archivos
  int uploadedCount = 0;

  //info
  String nombrewasacliente = "PROSPECTO CLIENTE";
  String nombreCompleto = "";
  int numwasaCliente = 0;
  Carrera? selectedCarreraobject;
  Universidad? selectedUniversidadobject;
  double margen_solicitud = 10;
  List<File> files = [];
  String carpetaurl = "";

  //Modo de carga
  bool cargandoservicio = false;

  //apoyo para configuiración
  bool configuracionSolicitudes = false;
  String idcarpetasolicitudesDrive = "";

  int numSolicitud = 0;

  void updatedata(){
    setState(() {
      widget.clienteList;
    });
  }

  @override
  void initState() {
    selectedServicio = null;
    selectedCliente = null;
    selectedMateria = null;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final tamanowidht = MediaQuery.of(context).size.height;
    return Stack(
      children: [
        solicitudescuadro(tamanowidht),
        if(cargandoservicio==true)
          const Positioned.fill(
            child: AbsorbPointer(
              absorbing: true, // Evita todas las interacciones del usuario
              child: Center(
                child: material.CircularProgressIndicator(), // Puedes personalizar el indicador de carga
              ),
            ),
          ),
      ],
    );
  }

  Widget solicitudescuadro(double tamanowidht){
    return Container(
      width: widget.currentwidth,
      height: tamanowidht,
      decoration: BoxDecoration(
        color: widget.primarycolor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          bottomLeft: Radius.circular(30),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 50,vertical: 30),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("Nueva solicitud ",style: Disenos().aplicarEstilo(Config.secundaryColor, 30,true),),
              //Tipo de servicio
              Container(
                margin: EdgeInsets.only(top: margen_solicitud),
                child: AutoSuggestBox<String>(
                  items: serviciosList.map((servicio) {
                    return AutoSuggestBoxItem<String>(
                        value: servicio,
                        label: servicio,
                        onFocusChange: (focused) {
                          if (focused) {
                            debugPrint('Focused $servicio');
                          }
                        }
                    );
                  }).toList(),
                  onSelected: (item) {
                    setState(() => selectedServicio = item.value);
                  },
                  decoration: Disenos().decoracionbuscador(),
                  placeholder: 'Selecciona tu servicio',
                  onChanged: (text, reason) {
                    if (text.isEmpty ) {
                      setState(() {
                        selectedServicio = null; // Limpiar la selección cuando se borra el texto
                      });
                    }
                  },
                ),
              ),
              //Id de cotización
              Container(
                margin: EdgeInsets.only(top: margen_solicitud),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Disenos().textonuevasolicitudblanco("ID cotización"),
                    //Numero de cotización - obtenemos con Consumer
                    Consumer<SolicitudProvider>
                      (builder: (context, numcotizacion, child) {

                      if(!Config.dufyadmon){
                        numSolicitud =  numcotizacion.todaslasSolicitudes.length + 1;
                      }else{
                        numSolicitud = numcotizacion.todaslasSolicitudes.length + 473;
                      }

                      return Disenos().textonuevasolicitudblanco(numSolicitud.toString());
                    }
                    ),
                  ],
                ),
              ),
              if(selectedServicio!=null)
              //Variables despues de seleccionar servicio
                Column(
                  children: [
                    //Materia - Agregar materia aca mismo
                    Container(
                      margin: EdgeInsets.only(top: margen_solicitud),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Disenos().textonuevasolicitudblanco("Matería"),
                          Container(
                            height: 30,
                            width: widget.currentwidth-200,
                            child: AutoSuggestBox<Materia>(
                              items: widget.materiaList.map<AutoSuggestBoxItem<Materia>>(
                                    (materia) => AutoSuggestBoxItem<Materia>(
                                  value: materia,
                                  label: Utiles().truncateLabel(materia.nombremateria),
                                  onFocusChange: (focused) {
                                    if (focused) {
                                      debugPrint('Focused #${materia.nombremateria} - ');
                                    }
                                  },
                                ),
                              )
                                  .toList(),
                              decoration: Disenos().decoracionbuscador(),
                              onSelected: (item) {
                                setState(() {
                                  print("seleccionado ${item.label}");
                                  selectedMateria = item.value; // Actualizar el valor seleccionado
                                });
                              },
                              onChanged: (text, reason) {
                                if (text.isEmpty ) {
                                  setState(() {
                                    selectedMateria = null; // Limpiar la selección cuando se borra el texto
                                  });
                                }
                              },
                            ),
                          ),


                        ],
                      ),
                    ),
                    //Cliente
                    Consumer<ClientesVistaProvider>(
                      builder: (context, clienteProviderSelect, child) {
                        List<Clientes> clienteList = clienteProviderSelect.todosLosClientes;

                        return Container(
                          margin: EdgeInsets.only(top: margen_solicitud),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Disenos().textonuevasolicitudblanco("Cliente"),
                              //Aqui voy a poder agregar clientes, vamos a ver.
                              SizedBox(
                                height: 30,
                                width: widget.currentwidth-200,
                                child: AutoSuggestBox<Clientes>(
                                  items: clienteList.map<AutoSuggestBoxItem<Clientes>>(
                                        (cliente) => AutoSuggestBoxItem<Clientes>(
                                      value: cliente,
                                      label: Utiles().truncateLabel(cliente.numero.toString() ),
                                      onFocusChange: (focused) {
                                        if (focused) {
                                          debugPrint('Focused #${cliente.numero} - ');
                                        }
                                      },
                                    ),
                                  )
                                      .toList(),
                                  decoration: Disenos().decoracionbuscador(),
                                  onSelected: (item) {
                                    setState(() {
                                      print("seleccionado ${item.label} con numero ${item.value?.numero.toString()}");
                                      selectedCliente = item.value;
                                      //Ahora sacamos , carrera y universidad

                                    });
                                  },
                                  onChanged: (text, reason) {
                                    if (text.isEmpty ) {
                                      setState(() {
                                        selectedCliente = null; // Limpiar la selección cuando se borra el texto
                                      });
                                    }
                                  },
                                ),
                              ),
                              SolicitudesDialog(),

                            ],
                          ),
                        );

                      }
                    ),
                    //Nombre de cliente
                    Container(
                      margin: EdgeInsets.only(top: margen_solicitud),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Disenos().textonuevasolicitudblanco("Nombre Cliente"),
                          Flexible(child: Disenos().textonuevasolicitudblanco(selectedCliente?.nombreCliente.toString() ?? 'NO REGISTRADA')),
                        ],
                      ),
                    ),
                    //Carrera
                    Container(
                      margin: EdgeInsets.only(top: margen_solicitud),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Disenos().textonuevasolicitudblanco("Carrera"),
                          Disenos().textonuevasolicitudblanco(selectedCliente?.carrera.toString() ?? 'NO REGISTRADA'),
                        ],
                      ),
                    ),
                    //Universidad
                    Container(
                      margin: EdgeInsets.only(top: margen_solicitud),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Disenos().textonuevasolicitudblanco("Universidad"),
                          Flexible(child: Disenos().textonuevasolicitudblanco(selectedCliente?.universidad.toString() ?? 'NO REGISTRADA')),
                        ],
                      ),
                    ),
                    if(selectedServicio=="PARCIAL")
                      showservicios("Temas a evaluar", "Duración del examen"),
                    if(selectedServicio=="TALLER")
                      showservicios("Resumen", "Info de cliente"),
                    if(selectedServicio=="ASESORIAS")
                      showservicios("Temas de asesoría", "NA"),
                    if(selectedServicio=="QUIZ")
                      showservicios("Temas a evaluar", "Duración del quiz"),

                    //Archivos nombre que se van a subir
                    if(selectedFiles  != null)
                      Column(
                        children: selectedFiles!.map((file) {
                          return Container(
                            color: Colors.blue,
                            child: Text(file.name),
                          );
                        }).toList(),
                      ),
                    if(uploadedCount != 0)
                      Column(
                        children: [
                          Text('$uploadedCount archivos de ${selectedFiles?.length}')
                        ],
                      ),
                    //Consumer de seleccionar archivos Drive Api
                    Consumer<ConfiguracionAplicacion>(
                      builder: (context, condifuracionProvider, child) {
                        ConfiguracionPlugins? config = condifuracionProvider.config;
                        configuracionSolicitudes = Utiles().obtenerBool(config!.SolicitudesDriveApiFecha);
                        idcarpetasolicitudesDrive = config.idcarpetaSolicitudes;
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children:[
                            if(configuracionSolicitudes)
                              FilledButton(
                                  style: Disenos().boton_estilo(),
                                  child: Text('seleccionar archivos'), onPressed: (){
                                selectFile();
                              }),
                          ],
                        );
                      }
                    ),
                    //Botón para añadir servicio
                    FilledButton(
                      style: Disenos().boton_estilo(),
                      child: const Text('Subir servicio'),
                      onPressed: () {
                        validar_antesde_solicitar(context);
                      },
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future selectFile() async{
    if(kIsWeb){
      final result = await FilePicker.platform.pickFiles(type: FileType.any, allowMultiple: true);

      if (result != null && result.files.isNotEmpty) {
        final fileName = result.files.first.name;
        final fileextension = result.files.first.extension;
        setState(() {
          selectedFiles  = result.files;
          archivoNombre = fileName;
          _archivoExtension = fileextension!;
          print(fileName);
          print(fileextension);
        });
        print("extension archivo");
        print(_archivoExtension);
        print("Nombre del archivo");
      }}else{
      print('Aqui no va a pasar');
    }
  }

  void validar_antesde_solicitar(BuildContext context) async{
    UtilDialogs dialogs = UtilDialogs(context : context);
    if (fechaentrega.isBefore(DateTime.now())) {
      dialogs.error(Strings().errorfechanovalidadDescripcion, Strings().errorglobalText);
    }else if(selectedMateria == null || selectedCliente == null){
      dialogs.error(Strings().errorMateriaoCliente, Strings().errorglobalText);
    } else{
      setState(() {
        cargandoservicio = true;
      });
      await uploadarchivosDrive();
      setState(() {
        selectedFiles = [];
        uploadedCount = 0;
      });
      DateTime fecha = DateTime(fechaentrega.year,fechaentrega.month,fechaentrega.day,fechaentrega.hour,fechaentrega.minute);
      String? materia = selectedMateria?.nombremateria.toString();
      print(fecha);
      Uploads().addServicio(selectedServicio!, "NADA", numSolicitud, materia!, selectedCliente!.universidad.toString(), fecha , resumen, infocliente, selectedCliente!.numero,carpetaurl);
      Utiles().notificacion("Servicio solicitado con exito",context,true,"Bien rey");
      eliminar_Datos();
    }
  }

  Future<void> uploadarchivosDrive() async{
    if(configuracionSolicitudes){
      final result = await DriveApiUsage().subirSolicitudes(idcarpetasolicitudesDrive, selectedFiles,numSolicitud.toString(),context);
      print("Número de archivos subidos: ${result.numberfilesUploaded}");
      print("URL de la carpeta: ${result.folderUrl}");
      //Ahora avisar numero de archivos subidos y url
      setState(() {
        uploadedCount = result.numberfilesUploaded;
        carpetaurl = result.folderUrl;
      });
    }else{
      print("no tenes credenciales para esto");
    }
  }

  void eliminar_Datos(){
    setState(() {
      selectedServicio = "";
      resumen = "";
      infocliente = "";
      fechaentrega = DateTime.now();
      selectedMateria = null;
      selectedCliente = null;
      selectedServicio = null;
      carpetaurl = "";
      cargandoservicio = false;
    });
  }

  Column showservicios(String primerRecuadro,String segundoRecuadro){
    return Column(
      children: [
        //fechas
        Container(
            margin: EdgeInsets.only(top: margen_solicitud),
            child: selectfecha()),
        //Temas a evaluar // temas de asesoría // Resumen taller
        Container(
          margin: EdgeInsets.only(top: margen_solicitud),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: widget.currentwidth-120,
                child: TextBox(
                  decoration: BoxDecoration(
                    color: Config.secundaryColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  placeholder: primerRecuadro,
                  onChanged: (value){
                    setState(() {
                      resumen = value;
                    });
                  },
                  maxLines: null,
                ),
              ),
            ],
          ),
        ),
        //Duración del examen // xx // Información de cliente
        Container(
          margin: EdgeInsets.only(top: margen_solicitud),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: widget.currentwidth-120,
                child: TextBox(
                  decoration: BoxDecoration(
                    color: Config.secundaryColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  placeholder: segundoRecuadro,
                  onChanged: (value){
                    setState(() {
                      infocliente = value;
                    });
                  },
                  maxLines: null,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Column selectfecha(){
    return Column(
      children: [
        Container(
          margin: EdgeInsets.only(top: margen_solicitud),
          child: GestureDetector(
            onTap: () async{
              final date = await FuncionesMaterial().pickDate(context,fechaentrega);
              if(date == null) return;

              final newDateTime = DateTime(
                date.year,
                date.month,
                date.day,
                fechaentrega.hour,
                fechaentrega.minute,
              );

              setState( () =>
              fechaentrega = newDateTime
              );
            },
            child: Disenos().fecha_y_entrega('${fechaentrega.day}/${fechaentrega.month}/${fechaentrega.year}',widget.currentwidth),
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: margen_solicitud),
          child: GestureDetector(
            onTap: () async {
              final time = await FuncionesMaterial().pickTime(context,fechaentrega);
              if (time == null) return;

              final newDateTime = DateTime(
                fechaentrega.year,
                fechaentrega.month,
                fechaentrega.day,
                time.hour,
                time.minute,
              );
              setState(() =>
              fechaentrega = newDateTime
              );
              final formattedTime = DateFormat('hh:mm a').format(fechaentrega);
              print(formattedTime);
            },
            child: Disenos().fecha_y_entrega(DateFormat('hh:mm  a').format(fechaentrega), widget.currentwidth),
          ),
        ),
      ],
    );
  }

}

class _CrearContainer extends StatefulWidget{
  final double currentwidth;
  final String title;
  final bool descargadatos;
  final String estado;
  final double height;
  final List<Clientes> clienteList;
  final List<Tutores> tutoresList;
  final Function() onUpdateListaClientes; // Agrega esta variable
  final Color primarycolor;


  const _CrearContainer({Key?key,
    required this.currentwidth,
    required this.title,
    required this.descargadatos,
    required this.estado,
    required this.height,
    required this.clienteList,
    required this.tutoresList,
    required this.onUpdateListaClientes,
    required this.primarycolor,
  }) :super(key: key);

  @override
  _CrearContainerState createState() => _CrearContainerState();

}

class _CrearContainerState extends State<_CrearContainer> {


  void forzarupdatedata(){
    widget.onUpdateListaClientes();
    print("forzando update de datas;");
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: widget.primarycolor,
          width: 5,
        ),
        borderRadius: BorderRadius.circular(0), // Ajusta el valor según tus preferencias
      ),
      width: widget.currentwidth,
      child:Padding(
        padding: const EdgeInsets.symmetric(vertical: 5,horizontal: 8),
        child: Column(
          children: [
            Text(widget.title,style: Disenos().aplicarEstilo(Config().primaryColor, 30, true),),
            Consumer<SolicitudProvider>(
                builder: (context, solicitudProvider, child) {
                  List<Solicitud> solicitudesList = [];
                  if(widget.estado=="DISPONIBLE"){
                    solicitudesList = solicitudProvider.solicitudesDISPONIBLES;
                  }else if(widget.estado =="ESPERANDO"){
                    solicitudesList = solicitudProvider.solicitudesESPERANDO;
                  }

                  return CuadroSolicitudes(solicitudesList: solicitudesList,height: widget.height,clienteList: widget.clienteList,tutoresList: widget.tutoresList,primarycolor: widget.primarycolor,);

                }
            ),
          ],
        ),
      ),
    );
  }
}

class CuadroSolicitudes extends StatefulWidget{
  final List<Solicitud>? solicitudesList;
  final double height;
  final List<Clientes> clienteList;
  final List<Tutores> tutoresList;
  final Color primarycolor;

  const CuadroSolicitudes({Key?key,
    required this.solicitudesList,
    required this.height,
    required this.clienteList,
    required this.tutoresList,
    required this.primarycolor,
  }) :super(key: key);

  @override
  CuadroSolicitudesState createState() => CuadroSolicitudesState();


}

class CuadroSolicitudesState extends State<CuadroSolicitudes> {

  Stream<Duration> _tick(DateTime fechasistema) {
    return Stream<Duration>.periodic(Duration(seconds: 1), (count) {
      DateTime now = DateTime.now();
      DateTime endTime = fechasistema;
      return endTime.difference(now);
    });
  }

  final ThemeApp themeApp = ThemeApp();
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.abs().toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  final TextStyle textStyle = TextStyle(
      fontSize: 15.0, color: Config().primaryColor);
  Tutores? selectedTutor;
  final TextEditingController precioTutor = TextEditingController();
  final TextEditingController comentarioTutor = TextEditingController();
  DateTime fechaconfirmacion = DateTime.now();

  final db = FirebaseFirestore.instance;
  String? selectedSistema;
  final TextEditingController precioCobrado = TextEditingController();
  String selectedIdentificador = "";
  List<String> SistemaList = ['NACIONAL', 'INTERNACIONAL'];
  List<String> IdentificadorList = ['T', 'P', 'Q', 'A'];
  int numerocontabilidadagenda = 0;

  List<Cotizacion> cotizacionesstream = [];
  int numerocotizaciones = 0;
  double margen_card = 5;
  String stringpropsectocliente = "";
  String stringnombrecliente = "";
  String nombrewspclientenuevo = "";

  String editnombrecliente = "";
  String editnombrewspcliente = "";
  final GlobalKey<CuadroSolicitudesState> statefulBuilderKey = GlobalKey<CuadroSolicitudesState>();
  String codigo = "";
  bool configloaded = false;
  Tutores tutoresVacia = Tutores.empty();
  ConfiguracionPlugins configuracionapp = ConfiguracionPlugins.empty();

  int numCotizacionAgenda = 0;

  //stream
  Clientes? selectedCliente;

  @override
  void initState() {
    super.initState();
    loadtabla();
  }

  Future loadtabla() async{
    configuracionapp = (await stream_builders().cargarconfiguracion()) as ConfiguracionPlugins;
  }

  void update(){
    setState(() {
      widget.clienteList ;
      print("fin del ciclo, correcto");
      statefulBuilderKey.currentState?.setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      child: ListView.builder(
          itemCount: widget.solicitudesList?.length,
          itemBuilder: (context, index) {
            Solicitud? solicitud = widget.solicitudesList?[index];

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
              child: Card(
                  backgroundColor: widget.primarycolor,
                  borderRadius: BorderRadius.circular(30),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 9, vertical: 6),
                    child: Column(
                      children: [
                        //Tipo de servicio y fecha de entrega
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Disenos().textocardsolicitudes("${solicitud!
                                .servicio}#${solicitud.idcotizacion}"),
                            Disenos().textocardsolicitudes(DateFormat('dd/MM/yyyy').format(solicitud.fechaentrega)),
                          ],
                        ),
                        //Matería y hora de entrega
                        Container(
                          margin: EdgeInsets.only(top: margen_card),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Disenos().textocardsolicitudesnobold(
                                  solicitud.materia),
                              Disenos().textocardsolicitudesnobold(
                                  DateFormat('hh:mm a').format(
                                      solicitud.fechaentrega)),
                            ],
                          ),
                        ),
                        //Resumen nada mas
                        Container(
                          margin: EdgeInsets.only(top: margen_card),
                          child: Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  color: Config.primarycikirbackground,
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment
                                          .spaceBetween,
                                      children: [
                                        Container(
                                            margin: const EdgeInsets.only(
                                                left: 25, top: 15),
                                            child: Disenos()
                                                .textocardsolicitudesnobold(
                                                'Resumen del servicio')),
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Config.secundaryColor,
                                            borderRadius: BorderRadius.circular(
                                                30),
                                          ),
                                          height: 20,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 2),
                                            child: StreamBuilder<Duration>(
                                              stream: _tick(
                                                  solicitud.fechasistema),
                                              builder: (context, snapshot) {
                                                if (!snapshot.hasData)
                                                  return const Text('Cargando');
                                                Duration duration = snapshot
                                                    .data!;
                                                return Text(
                                                  _formatDuration(duration),
                                                  style: textStyle,
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                        padding: const EdgeInsets.only(
                                            bottom: 15, right: 25, top: 5),
                                        margin: EdgeInsets.only(left: 25),
                                        child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(solicitud.resumen,
                                              textAlign: TextAlign.justify, style: themeApp.styleText(13, false, themeApp.whitecolor),))),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        //Numero de cotizaciones y estado
                        Container(
                          margin: EdgeInsets.only(top: margen_card),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              //metemos un streambuilder para escuchar numero de cotizaciones
                              Text("${solicitud.cotizaciones.length} cotizaciones", style: themeApp.styleText(14, false, themeApp.whitecolor),),
                              Disenos().textocardsolicitudesnobold(
                                  solicitud.estado),
                            ],
                          ),
                        ),
                        //cliente numero, botón copiar y boton de opciones
                        Container(
                          margin: EdgeInsets.only(top: margen_card),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              //Numero de celular
                              GestureDetector(
                                onTap: () {
                                  final textToCopy = solicitud.cliente
                                      .toString();
                                  Clipboard.setData(
                                      ClipboardData(text: textToCopy));
                                },
                                child: Disenos().textocardsolicitudesnobold(
                                    solicitud.cliente.toString()),
                              ),
                              //Copiar solicitud
                              PrimaryStyleButton(
                                  width: 100,
                                  function: (){
                                    copiarSolicitud(
                                        solicitud.servicio,
                                        solicitud.idcotizacion,
                                        solicitud.materia,
                                        solicitud.fechaentrega,
                                        solicitud.resumen,
                                        solicitud.infocliente,
                                        solicitud.urlArchivos
                                    );
                                  },
                                  text: "Copiar"
                              ),
                              Row(
                                children: [
                                  //Ver detalles de cotización
                                  GestureDetector(
                                    onTap: () {
                                      print("Ver detalles");
                                      material.Navigator.push(context, material.MaterialPageRoute(
                                        builder: (context)  => Dashboard(showSolicitudesNew: true, showTutoresDetalles: false,),
                                      ));
                                      //Vamos a seleccionar el servicio
                                      final solicitudProvider = Provider.of<SolicitudProvider>(context, listen: false);
                                      solicitudProvider.seleccionarSolicitud(solicitud);
                                    },
                                    child: material.Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 2),
                                      child: Icon(material.Icons.info_outline_rounded, color: themeApp.whitecolor,),
                                    ),
                                  ),
                                  //Cotizar por tutor
                                  GestureDetector(
                                    onTap: () {
                                      print("Cotizar por otro tutor");
                                      cotizarPorOtroTutorDialog(context, solicitud.idcotizacion, solicitud.fechasistema);

                                    },
                                    child: material.Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 2),
                                      child: Icon(material.Icons.accessibility, color: themeApp.whitecolor,),
                                    ),
                                  ),
                                  //Ver cotizaciones
                                  GestureDetector(
                                    onTap: () {
                                      print("Ver cotizaciones");
                                      vistaCotizaciones(context, solicitud);
                                    },
                                    child: material.Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 2),
                                      child: Icon(material.Icons.note_rounded, color: themeApp.whitecolor,),
                                    ),
                                  ),
                                  //Cambiar estado de servicio
                                  EstadoServicioDialog(solicitud: solicitud,),
                                ],
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
              ),
            );
          }
      ),
    );
  }

  void copiarSolicitud(String servicio, int idcotizacion, String materia, DateTime fechaentrega, String resumen, String infocliente, String urlArchivos) {
    String horaRealizada = "";
    String fechaDeRealizacion = "";
    fechaDeRealizacion = "${DateFormat('dd/MM/yyyy').format(fechaentrega)}";
    if(servicio=="TALLER"){
      horaRealizada = 'ANTES DE LAS ${DateFormat('hh:mma').format(fechaentrega)}';
    }else{
      horaRealizada = '${DateFormat('hh:mma').format(fechaentrega)}';
    }

    String solicitud = configuracionapp.SOLICITUD;

    solicitud = solicitud.replaceAll("/servicio/", servicio);
    solicitud = solicitud.replaceAll("/idcotizacion/", idcotizacion.toString());
    solicitud = solicitud.replaceAll("/materia/", materia);
    solicitud = solicitud.replaceAll("/fechaentrega/", fechaDeRealizacion);
    solicitud = solicitud.replaceAll("/horaentrega/", horaRealizada);
    solicitud = solicitud.replaceAll("/resumen/", resumen);
    solicitud = solicitud.replaceAll("/infocliente/", infocliente);
    solicitud = solicitud.replaceAll("/urlarchivos/", urlArchivos);

    Clipboard.setData(ClipboardData(text: solicitud));
    print("se copio");
  }
  void cotizarPorOtroTutorDialog(BuildContext context, int idCotizacion, DateTime fechaSistema) => showDialog(
      context: context,
      builder: (BuildContext context) => _cotizarPorOtroTutorDialog(context, idCotizacion, fechaSistema)
  );

  material.Dialog _cotizarPorOtroTutorDialog(BuildContext context, int idCotizacion, DateTime fechaSistema){
    final ThemeApp themeApp = ThemeApp();
    const double width = 420;
    const double height = 400;
    const double multiplier = 0.8;
    const double verticalPadding = 5;
    return material.Dialog(
      backgroundColor: themeApp.blackColor.withOpacity(0),
      child: ItemsCard(
        width: width,
        height: height,
        children: [
          material.Padding(
            padding: const EdgeInsets.symmetric(vertical: verticalPadding + 5),
            child: Text("Cotizar por tutor", style: themeApp.styleText(22, true, themeApp.primaryColor),),
          ),
          material.Padding(
            padding: const EdgeInsets.symmetric(vertical: verticalPadding),
            child: material.SizedBox(
              width: width * multiplier,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Seleccionar tutor:", style: themeApp.styleText(12, false, themeApp.blackColor),),
                  SizedBox(
                    width: width * (multiplier * 0.65),
                    child: AutoSuggestBox<Tutores>(
                      items: widget.tutoresList.map<AutoSuggestBoxItem<Tutores>>(
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
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          material.Padding(
            padding: const EdgeInsets.symmetric(vertical: verticalPadding),
            child: material.SizedBox(
              width: width * multiplier,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Precio tutor:", style: themeApp.styleText(12, false, themeApp.blackColor),),
                  RoundedTextField(
                      width: width * multiplier * 0.65,
                      controller: precioTutor,
                      placeholder: "Precio de cotizacion"
                  ),
                ],
              ),
            ),
          ),

          material.Padding(
            padding: const EdgeInsets.symmetric(vertical: verticalPadding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                selectfecha()
              ],
            ),
          ),

          material.Padding(
            padding: const EdgeInsets.symmetric(vertical: verticalPadding),
            child: material.SizedBox(
              width: width * multiplier,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Comentarios:", style: themeApp.styleText(12, false, themeApp.blackColor),),
                  RoundedTextField(
                      width: width * multiplier * 0.65,
                      controller: comentarioTutor,
                      placeholder: "Comentario"
                  ),
                ],
              ),
            ),
          ),


          material.Padding(
            padding: const EdgeInsets.symmetric(vertical: verticalPadding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                PrimaryStyleButton(
                    function: (){
                      final DateTime ahora = DateTime.now();
                      final Duration duration = ahora.difference(fechaSistema);
                      Uploads().addCotizacion(idCotizacion, int.parse(precioTutor.text), selectedTutor!.uid, selectedTutor!.nombrewhatsapp, duration.inMinutes, comentarioTutor.text, '', fechaconfirmacion);
                      Navigator.pop(context, 'User deleted file');
                    },
                    text: "Subir precio"
                ),
                PrimaryStyleButton(
                    function: (){
                      Navigator.pop(context, 'User canceled dialog');
                    },
                    text: "Cancelar"
                ),
              ],
            ),
          )



        ],
      ),
    );
  }

  Column selectfecha(){
    return Column(
      children: [
        //Fecha de entrega
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            DatePicker(
              selected: fechaconfirmacion,
              showYear: true,
              onChanged: (time){
                setState((){
                  fechaconfirmacion = time.toUtc();
                },
                );
              },
            ),
          ],
        ),
        //hora de realizacion
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TimePicker(
              selected: fechaconfirmacion,
              header: 'Seleccione hora de realización',
              minuteIncrement: 1,
              onChanged: (time){
                setState((){
                  fechaconfirmacion = time.toUtc();
                });
              },
            ),
          ],
        ),
      ],
    );
  }

  void vistaCotizaciones(BuildContext context, Solicitud solicitud) => showDialog(
      context: context,
      builder: (BuildContext context) => _vistaCotizaciones(context, solicitud)
  );

  material.Dialog _vistaCotizaciones(BuildContext context, Solicitud solicitud){
    const double horizontalPadding = 20;

    return material.Dialog(
      backgroundColor: themeApp.blackColor.withOpacity(0),
      child: ItemsCard(
        width: 400,
        height: 450,
        children: [
          material.Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: Text("Cotizaciones de servicio", style: themeApp.styleText(20, true, themeApp.primaryColor),),
          ),

          Expanded(
            child: ListView.builder(
                itemCount: solicitud.cotizaciones.length,
                itemBuilder: (context, index){
                  Cotizacion cotizacion = solicitud.cotizaciones[index];

                  return material.Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                    child: ItemsCard(
                        shadow: false,
                        cardColor: themeApp.grayColor.withOpacity(0.05),
                        width: 380,
                        height: 100,
                        children: [
                          material.Padding(
                            padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(child: Text(cotizacion.nombretutor, style: themeApp.styleText(14, false, themeApp.blackColor),)),
                                Expanded(child: Text(cotizacion.cotizacion.toString(), style: themeApp.styleText(14, false, themeApp.blackColor),))
                              ],
                            ),
                          ),

                          material.Padding(
                            padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(child: Text("${cotizacion.tiempoconfirmacion.toString()} minutos", style: themeApp.styleText(14, false, themeApp.blackColor),)),
                                Expanded(child: Text('Fecha max confirmación', style: themeApp.styleText(14, false, themeApp.blackColor),)),
                                GestureDetector(
                                  child: Container(
                                      decoration: BoxDecoration(
                                          color: themeApp.primaryColor,
                                          borderRadius: BorderRadius.circular(80)
                                      ),
                                      height: 25,
                                      width: 25,
                                      child: Icon(FluentIcons.add, color: themeApp.whitecolor, size: 12,)
                                  ),
                                  onTap: () async {
                                    codigocontabilidad(solicitud);
                                    
                                    agendarTrabajo(context,solicitud,cotizacion);
                                  },
                                )
                              ],
                            ),
                          ),

                          material.Padding(
                            padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
                            child: Text(cotizacion.comentariocotizacion!, style: themeApp.styleText(14, false, themeApp.blackColor),),
                          ),

                        ]
                    ),
                  );
                }
            ),
          ),

          material.Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              material.Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 20.0),
                child: PrimaryStyleButton(
                    function: (){

                    },
                    text: "Subir precio"
                ),
              ),

              material.Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 8.0),
                child: PrimaryStyleButton(
                    width: 120,
                    function: (){
                      Navigator.pop(context);
                    }, text: "Cancelar"
                ),
              )
            ],
          ),


        ],
      ),
    );
  }


  void agendarTrabajo(BuildContext context, Solicitud solicitud, Cotizacion cotizacion) => showDialog(
      context: context,
      builder: (BuildContext context) => agendarTrabajoDialog(context, solicitud, cotizacion)
  );

  StatefulBuilder agendarTrabajoDialog(BuildContext context, Solicitud solicitud, Cotizacion cotizacion){

    const double currentwidth = 450;
    final TextStyle styleText = themeApp.styleText(15, false, themeApp.blackColor);
    final TextStyle styleSubText = themeApp.styleText(16, true, themeApp.blackColor);

    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState){
          return material.Dialog(
            backgroundColor: themeApp.blackColor.withOpacity(0),
            child: ItemsCard(
              alignementColumn: MainAxisAlignment.center,
              width: currentwidth,
              height: 450,
              children: [
                material.Padding(
                  padding: const EdgeInsets.only(bottom: 18.0),
                  child: Text("Agendar trabajo", style: themeApp.styleText(24, true, themeApp.primaryColor),),
                ),

                Consumer<ContabilidadProvider>(
                  builder: (context, pagosProvider, child) {
                    if(!Config.dufyadmon){
                      numCotizacionAgenda =  pagosProvider.todoslosServiciosAgendados.length + 1;
                    }else{
                      numCotizacionAgenda =  pagosProvider.todoslosServiciosAgendados.length + 922;
                    }
                    return Text("id contabilidad $numCotizacionAgenda", style: styleText,);

                  }
                ),

                material.Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: ComboBox<String>(
                    value: selectedSistema,
                    items: SistemaList.map<ComboBoxItem<String>>((e) {
                      return ComboBoxItem<String>(
                        value: e,
                        child: Text(e, style: styleText,),
                      );
                    }).toList(),
                    onChanged: (text) {
                      setState(() {
                        selectedSistema = text; // Update the local variable
                      });
                    },
                    placeholder: Text('Seleccionar sistema de servicio', style: styleText,),
                  ),
                ),

                material.Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: SizedBox(
                    width: currentwidth-80,
                    child: material.Row(
                      children: [
                        Text("Precio tutor: ", style: styleSubText,),
                        Text(cotizacion.cotizacion.toString(), style: styleText,)
                      ],
                    ),
                  ),
                ),

                material.Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: SizedBox(
                      width: currentwidth-80,
                      child: RoundedTextField(
                        placeholder: "Precio cobrado",
                        controller: precioCobrado,
                      )
                  ),
                ),

                //identificador de codigo
                material.Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: identificadorcodigo(solicitud.servicio, styleText),
                ),

                //Información del cliente a agendar

                Consumer<ClientesVistaProvider>(
                  builder: (context, clienteProviderselect, child) {
                    selectedCliente = clienteProviderselect.clienteSeleccionado;

                    return Column(
                      children: [

                        //
                        material.Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5.0),
                          child: prospectocliente(solicitud, styleText),
                        ),

                        material.Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5.0),
                          child: Text(stringnombrecliente, style: styleText,),
                        ),

                      ],
                    );
                  }
                ),



                if(stringpropsectocliente == "PROSPECTO CLIENTE" || stringnombrecliente == "NO REGISTRADO")
                  GestureDetector(
                    child: Container(
                        height: 30,
                        width: 30,
                        decoration: BoxDecoration(
                          color: Config.secundaryColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(FluentIcons.add,
                          color: Config().primaryColor,
                          weight: 30,)),
                    onTap: (){
                      print("agregar nuevo prospecto de cliente");
                      addInfoFaltanteCliente(context,solicitud);
                    },
                  ),

                //Mensaje de confirmación
                if(stringpropsectocliente != 'PROSPECTO CLIENTE' || stringnombrecliente == "NO REGISTRADO")
                  PrimaryStyleButton(
                      function: (){
                        copiarConfirmacion(solicitud,true,cotizacion);
                      },
                      text: "Copiar confirmacion"),
                PrimaryStyleButton(
                    function: (){
                      copiarConfirmacion(solicitud,false,cotizacion);
                    },
                    text: "Copiar confirmacion tutor"),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    material.Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: PrimaryStyleButton(
                          function: (){
                            comprobacionagendartrabajo(cotizacion,solicitud,context);
                          },
                          text: "Subir Servicio"
                      ),
                    ),

                    material.Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: PrimaryStyleButton(
                          width: 100,
                          function: (){
                            Navigator.pop(context);
                          },
                          text: "Cerrar"
                      ),
                    ),

                  ],
                )
              ],
            ),
          );
        }
    );
  }

  Future<void> comprobacionagendartrabajo(Cotizacion cotizacion, Solicitud solicitud, BuildContext context) async {
    if(selectedSistema==null){
      Utiles().notificacion("Selecciona un sistema", context, false,"ya sea nacional o internacional");
    }else if(int.parse(precioCobrado.text)<cotizacion.cotizacion){
      print("precio cobrado es < al precio del tutor");
      Utiles().notificacion("Precio cobrado es < precio tutor", context, false,"cambia el precio");
    }else if(solicitud.fechaentrega.isBefore(DateTime.now())){
      Utiles().notificacion("fecha de entrega es < a hoy", context, false,"cambia la fehca de entrega");
    }else{
      //Aqui vamos a tener el servicio agendado, agendado realmente
      await Uploads().addServicioAgendado(codigo,selectedSistema!, solicitud.materia, solicitud.cliente.toString(), int.parse(precioCobrado.text), solicitud.fechaentrega, cotizacion.nombretutor, cotizacion.cotizacion, selectedIdentificador, solicitud.idcotizacion,numerocontabilidadagenda,"NO ENTREGADO");
      Navigator.pop(context, 'User deleted file');
      Navigator.pop(context, 'User deleted file');
      Utiles().notificacion("Servicio subido con exito", context, true,"bien rey");
    }

  }

  String generarCodigoAleatorio() {
    const caracteres = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    final codeUnits = List.generate(5, (index) {
      final randomIndex = random.nextInt(caracteres.length);
      return caracteres.codeUnitAt(randomIndex);
    });
    return String.fromCharCodes(codeUnits);
  }

  Text identificadorcodigo(String servicio, TextStyle style){
    if(servicio == "TALLER"){
      selectedIdentificador = "T";
    }else if(servicio == "PARCIAL"){
      selectedIdentificador = "P";
    }else if(servicio == "QUIZ"){
      selectedIdentificador = "Q";
    }else if(servicio == "ASESORIAS"){
      selectedIdentificador = "A";
    }else{
      selectedIdentificador = "NO PROGRAMADO";
    }
    return Text(selectedIdentificador, style: style);
  }

  Text prospectocliente(Solicitud solicitud, TextStyle style){
    final clienteEncontrado = widget.clienteList.firstWhere(
          (cliente) => cliente.numero == solicitud.cliente,
    );

    if (clienteEncontrado != null) {
      stringpropsectocliente = clienteEncontrado.nombreCliente;
      stringnombrecliente = clienteEncontrado.nombrecompletoCliente;
    } else {
      stringpropsectocliente = 'Cliente no encontrado';
      stringnombrecliente = 'CLIENTE SIN NOMBRE';
    }
    return Text(stringpropsectocliente, style: style);
  }

  Container addinfoclienteprospecto(){
    return Container(
      child: Column(
        children: [
          TextBox(
            placeholder: 'NOMBRE WSP CLIENTE',
            onChanged: (value){
              setState(() {
                nombrewspclientenuevo = value;
              });
            },
            maxLines: null,
          ),
        ],
      ),
    );
  }

  void copiarConfirmacion(Solicitud solicitud, bool istutor, Cotizacion cotizacion){
    int preciousuario = istutor? int.parse(precioCobrado.text) : cotizacion.cotizacion;
    String nombreusuario = istutor? stringnombrecliente : cotizacion.nombretutor; //aqui tengo que entrar a buscar el nombre completo del tutor para ponerlo
    String servicio = "";
    String fechita = "";
    String tutorcliente = istutor? "Cliente": "Tutor";
    if(solicitud.servicio == "TALLER"){
      servicio = "TALLERES";
      fechita = "${DateFormat("dd/MM").format(solicitud.fechaentrega)} ANTES DE ${DateFormat('hh:mma').format(solicitud.fechaentrega)}";
    }else if(solicitud.servicio == "PARCIAL"){
      fechita = "${DateFormat("dd/MM").format(solicitud.fechaentrega)} ${DateFormat('hh:mma').format(solicitud.fechaentrega)}";
      servicio = "PARCIALES";
    }else if(solicitud.servicio == "QUIZ"){
      servicio = "QUICES";
      fechita = "${DateFormat("dd/MM").format(solicitud.fechaentrega)} ${DateFormat('hh:mma').format(solicitud.fechaentrega)}";
    }else if(solicitud.servicio == "ASESORIAS"){
      servicio = "ASESORIAS";
      fechita = "${DateFormat("dd/MM").format(solicitud.fechaentrega)} ${DateFormat('hh:mma').format(solicitud.fechaentrega)}";
    }

    String confirmacion = configuracionapp.CONFIRMACION_CLIENTE;

    confirmacion = confirmacion.replaceAll("/servicioplural/", servicio);
    confirmacion = confirmacion.replaceAll("/servicio/", solicitud.servicio);
    confirmacion = confirmacion.replaceAll("/materia/", solicitud.materia);
    confirmacion = confirmacion.replaceAll("/rolusuario/", tutorcliente);
    confirmacion = confirmacion.replaceAll("/nombreusuario/", nombreusuario);
    confirmacion = confirmacion.replaceAll("/preciousuario/", preciousuario.toString());
    confirmacion = confirmacion.replaceAll("/fecha de entrega/", fechita);
    confirmacion = confirmacion.replaceAll("/codigo/", codigo);
    confirmacion = confirmacion.replaceAll("/idsolicitud/", solicitud.idcotizacion.toString());

    Clipboard.setData(ClipboardData(text: confirmacion));
  }

  void addInfoFaltanteCliente(BuildContext context, Solicitud solicitud) async {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return ContentDialog(
              title: const Text('Agregar info cliente'),
              content: Column(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      //NOMBRE WSP CLIENTE
                      Text("Nombre wsp cliente ${stringpropsectocliente}"),
                      Text('Nombre cliente ${stringnombrecliente}'),
                      TextBox(
                        placeholder: 'Nombre wsp cliente',
                        onChanged: (value){
                          setState(() {
                            editnombrewspcliente = value;
                          });
                        },
                        maxLines: null,
                      ),
                      TextBox(
                        placeholder: 'Nombre completo Cliente',
                        onChanged: (value){
                          setState(() {
                            editnombrecliente = value;
                          });
                        },
                        maxLines: null,
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                Button(
                  child: const Text('Agregar Cliente'),
                  onPressed: () async{
                    validarantesdeactualizarprospecto(solicitud,context);
                  },
                ),
                FilledButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.pop(context, 'User canceled dialog'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void validarantesdeactualizarprospecto(Solicitud solicitud, BuildContext context) async {
    await Uploads().prospectoacliente(
        editnombrewspcliente, editnombrecliente, solicitud.cliente);
    //Función
    print("registrando nuevo usuarido editado, porque no cambia");
    setState(() {
      stringnombrecliente = editnombrecliente;
      stringpropsectocliente = editnombrewspcliente;
      print("mandar a actualizar?");
    });
    Future.delayed(Duration(milliseconds: 2000), () {
      Utiles().notificacion("REGISTRADO CON EXITO", context, true, "exito");
      Navigator.pop(context, 'User canceled dialog');
      Navigator.pop(context, 'User canceled dialog');
      print("nos devolvemos");
    });
  }

  Future<void> codigocontabilidad(Solicitud solicitud) async {
    String primerasTresLetras = solicitud.materia.substring(0, 3); // Obtener las primeras tres letras
    codigo = "$selectedIdentificador$primerasTresLetras${DateFormat('ddMMyy').format(solicitud.fechaentrega)}-AN${DateFormat('hh').format(solicitud.fechaentrega)}";
    //codigo modificar y crear
    try {
      DocumentSnapshot getCodigo = await FirebaseFirestore.instance.collection("CONTABILIDAD").doc(codigo).get();

      if (getCodigo.exists) {
        String codigoAleatorio = generarCodigoAleatorio();
        print("El documento existe");
        codigo = codigo+codigoAleatorio;
      } else {
        print("no existe documetno");
      }
    } catch (e) {
      // Maneja cualquier error que pueda ocurrir durante la obtención del documento
      print("Error: $e");
    }
    print(codigo);
  }

}