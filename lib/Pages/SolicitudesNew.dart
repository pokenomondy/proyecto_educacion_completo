import 'dart:convert';
import 'dart:html';
import 'dart:math';
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
import 'package:shared_preferences/shared_preferences.dart';
import '../Dashboard.dart';
import '../Objetos/Objetos Auxiliares/Carreras.dart';
import '../Objetos/Objetos Auxiliares/HistorialEstado.dart';
import '../Objetos/Objetos Auxiliares/Universidad.dart';
import '../Objetos/Tutores_objet.dart';
import '../Utils/Disenos.dart';

class SolicitudesNew extends StatefulWidget {
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
  final GlobalKey<_CuadroSolicitudesState> actualizartablas = GlobalKey<_CuadroSolicitudesState>();
  final GlobalKey<_subirsolicitudesState> subirsolicitudes = GlobalKey<_subirsolicitudesState>();
  final GlobalKey<_CuadroSolicitudesState> dialogKey = GlobalKey<_CuadroSolicitudesState>();
  Config configuracion = Config();
  bool configloaded = false;

  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized(); // Asegura que Flutter esté inicializado
    configuracion.initConfig().then((_) {
      setState(() {
        configloaded = true;
      }); // Actualiza el estado para reconstruir el widget
    });
    loadtablas(); // Cargar los datos al inicializar el widget
    super.initState();
  }

  Future<void> loadtablas() async {
    CarrerasList = await LoadData().obtenercarreras();
    UniversidadList = await LoadData().obtenerUniversidades();
    materiaList = await LoadData().tablasmateria();
    clienteList = await LoadData().obtenerclientes();
    tutoresList = await LoadData().obtenertutores();
    print("load tablas ejecutandose");
    Future.delayed(Duration(milliseconds: 400), () {
      actualizartablas.currentState?.update();
      print("enviar señal");
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
            body:  _subirsolicitudes(currentwidth: currentwidth,onUpdateListaClientes: widget.onUpdateListaClientes,materiaList: widget.materiaList,clienteList: widget.clienteList,carreraList:widget.carreraList ,universidadList: widget.universidadList,primarycolor: Color(0xFFFFFFFF),),
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
  int numsolicitud = 0;
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
  Config configuracion = Config();
  String carpetaurl = "";

  //Reusltados Google Drive

  void main() async {
    WidgetsFlutterBinding.ensureInitialized(); // Asegura que Flutter esté inicializado
    await configuracion.initConfig(); // Espera a que initConfig() se complete
  }

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
    numcotizacionstream = LoadData().cargarnumerodesolicitudes();
    super.initState();
  }

  String _truncateLabel(String label) {
    const int maxLength = 30; // Define la longitud máxima permitida para la etiqueta
    if (label.length > maxLength) {
      return label.substring(0, maxLength - 3) + '...'; // Agrega puntos suspensivos
    }
    return label;
  }

  @override
  Widget build(BuildContext context) {
    final tamanowidht = MediaQuery.of(context).size.height;
    return Container(
      width: widget.currentwidth,
      height: tamanowidht,
      decoration: BoxDecoration(
        color: widget.primarycolor,
        borderRadius: BorderRadius.only(
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
              Text("Nueva solicitud",style: Disenos().aplicarEstilo(Config.secundaryColor, 30,true),),
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
                    //Numero de cotización
                    StreamBuilder(
                      stream: numcotizacionstream,
                      builder: (context, snapshot){
                        if (snapshot.hasError) {
                          return Center(child: Text('Error al cargar las solicitudes'));
                        }

                        if (!snapshot.hasData) {
                          return Center(child: Text('cargando'));
                        }
                        int? num_solicitud = snapshot.data;
                        numsolicitud = num_solicitud!;
                        return Disenos().textonuevasolicitudblanco(num_solicitud.toString());
                      },
                    ),
                  ],
                ),
              ),
              if(selectedServicio!=null)
              //Variables despues de seleccionar servicio
                Column(
                  children: [
                    //Materia
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
                                  label: _truncateLabel(materia.nombremateria),
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
                    Container(
                      margin: EdgeInsets.only(top: margen_solicitud),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Disenos().textonuevasolicitudblanco("Cliente"),
                          //Aqui voy a poder agregar clientes, vamos a ver.
                          Container(
                            height: 30,
                            width: widget.currentwidth-200,
                            child: AutoSuggestBox<Clientes>(
                              items: widget.clienteList.map<AutoSuggestBoxItem<Clientes>>(
                                    (cliente) => AutoSuggestBoxItem<Clientes>(
                                  value: cliente,
                                  label: _truncateLabel(cliente.numero.toString() ),
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
                          SolicitudesDialog(carreraList: widget.carreraList,universidadList: widget.universidadList,onUpdateListaClientes: widget.onUpdateListaClientes,),

                        ],
                      ),
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
                    //cuadrar la subida de archivos, como llevar a cabo ?
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        FilledButton(
                            style: Disenos().boton_estilo(),
                            child: Text('seleccionar archivos'), onPressed: (){
                          selectFile();
                        }),
                        FilledButton(
                            style: Disenos().boton_estilo(),
                            child: Text('Subir archivos'), onPressed: () async{
                          final result = await DriveApi().subirSolicitudes("1UhZBywK1XjkIJDQH0xpaAzzqVRevG3iD", selectedFiles,numsolicitud.toString());
                          print("Número de archivos subidos: ${result.numberfilesUploaded}");
                          print("URL de la carpeta: ${result.folderUrl}");
                          //Ahora avisar numero de archivos subidos y url
                          setState(() {
                            uploadedCount = result.numberfilesUploaded;
                            carpetaurl = result.folderUrl;
                          });
                        }),
                      ],
                    ),
                    //Botón para añadir servicio
                    FilledButton(
                      style: Disenos().boton_estilo(),
                      child: const Text('Subir servicio'),
                      onPressed: () {
                        validar_antesde_solicitar();
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

  /*
  void uploadfile() async {
    if (kIsWeb) {
      for (final file in selectedFiles!) {
        TaskSnapshot taskSnapshot = await FirebaseStorage.instance
            .ref('SOLICITUDES/$numsolicitud/${file.name}')
            .putData(file.bytes!);

        String downloadUrl = await taskSnapshot.ref.getDownloadURL();

        print('Enlace de descarga: $downloadUrl');

        setState(() {
          uploadedCount++;
        });
        if(uploadedCount == selectedFiles!.length){
          Utiles().notificacion("Se han subido los elementos, subieron $uploadedCount archivos", context, true, "Subido");
        }
      }
    } else {
      print("Esta parte no se ejecutará en dispositivos no web");
    }
  }

   */

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

  void validar_antesde_solicitar(){
    //Validación de fecha, que no sea fecha pasada
    if (fechaentrega.isBefore(DateTime.now())) {
      Utiles().notificacion("La fecha de entrega no puede ser menor a hoy", context, false,"Cambien la fecha");
    }else if(selectedMateria == null || selectedCliente == null){
      Utiles().notificacion("Materia o cliente no seleccionado", context, false,"Seleccione cliente o matería");
    } else{
      setState(() {
        numcotizacionstream = LoadData().cargarnumerodesolicitudes();
        selectedFiles = [];
        uploadedCount = 0;
      });
      DateTime fecha = DateTime(fechaentrega.year,fechaentrega.month,fechaentrega.day,fechaentrega.hour,fechaentrega.minute);
      String? materia = selectedMateria?.nombremateria.toString();
      print(fecha);
      Uploads().addServicio(selectedServicio!, "NADA", numsolicitud, materia!, selectedCliente!.universidad.toString(), fecha , resumen, infocliente, selectedCliente!.numero,carpetaurl);
      Utiles().notificacion("Servicio solicitado con exito",context,true,"Bien rey");
      eliminar_Datos();
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
    });
  }

  Column showservicios(String primer_recuadro,String segundo_recuadro){
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
                  placeholder: primer_recuadro,
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
                  placeholder: segundo_recuadro,
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
            StreamBuilder(
                stream: LoadData().getsolicitudstream(widget.estado),
              builder: (context, snapshot){
                if (snapshot.hasError) {
                  return Center(child: Text('Error al cargar las solicitudes'));
                }

                if (!snapshot.hasData) {
                  return Center(child: Text('cargando'));
                }
                    List<Solicitud>? solicitudesList = snapshot.data;
                    return _CuadroSolicitudes(solicitudesList: solicitudesList,height: widget.height,clienteList: widget.clienteList,tutoresList: widget.tutoresList,onUpdateListaClientes: forzarupdatedata,primarycolor: widget.primarycolor,);
                },
            ),
          ],
        ),
      ),
    );
  }
}

class _CuadroSolicitudes extends StatefulWidget{
  final List<Solicitud>? solicitudesList;
  final double height;
  final List<Clientes> clienteList;
  final List<Tutores> tutoresList;
  final Function() onUpdateListaClientes; // Agrega esta variable
  final Color primarycolor;

  const _CuadroSolicitudes({Key?key,
    required this.solicitudesList,
    required this.height,
    required this.clienteList,
    required this.tutoresList,
    required this.onUpdateListaClientes,
    required this.primarycolor,
  }) :super(key: key);

  @override
  _CuadroSolicitudesState createState() => _CuadroSolicitudesState();


}

class _CuadroSolicitudesState extends State<_CuadroSolicitudes> {

  Stream<Duration> _tick(DateTime fechasistema) {
    return Stream<Duration>.periodic(Duration(seconds: 1), (count) {
      DateTime now = DateTime.now();
      DateTime endTime = fechasistema;
      return endTime.difference(now);
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.abs().toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  final TextStyle textStyle = TextStyle(
      fontSize: 15.0, color: Config().primaryColor);
  Tutores? selectedTutor;
  int precio = 0;
  String comentario = "";
  DateTime fechaconfirmacion = DateTime.now();
  List<String> EstadoList = [
    'DISPONIBLE',
    'EXPIRADO',
    'ESPERANDO',
    'AGENDADO',
    'NO PODEMOS'
  ];
  String? selectedEstado = "";
  final db = FirebaseFirestore.instance;
  String? selectedSistema;
  int preciocobrado = 0;
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
  final GlobalKey<_CuadroSolicitudesState> statefulBuilderKey = GlobalKey<_CuadroSolicitudesState>();
  String codigo = "";



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
                                            margin: EdgeInsets.only(
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
                                                  return Text('Cargando');
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
                                        padding: EdgeInsets.only(
                                            bottom: 15, right: 25, top: 5),
                                        margin: EdgeInsets.only(left: 25),
                                        child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(solicitud.resumen,
                                              textAlign: TextAlign.justify,))),
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
                              escucharnumcotizaciones(solicitud.idcotizacion),
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
                              FilledButton(
                                  child: Text('Copiar'), onPressed: () {
                                copiarSolicitud(
                                    solicitud.servicio,
                                    solicitud.idcotizacion,
                                    solicitud.materia,
                                    solicitud.fechaentrega,
                                    solicitud.resumen,
                                    solicitud.infocliente,
                                    solicitud.urlArchivos
                                );
                              }),
                              Row(
                                children: [
                                  //Ver detalles de cotización
                                  GestureDetector(
                                    onTap: () {
                                      print("Ver detalles");
                                      material.Navigator.push(context, material.MaterialPageRoute(
                                        builder: (context)  => Dashboard(showSolicitudesNew: true, solicitud: solicitud,),
                                      ));
                                    },
                                    child: Icon(FluentIcons.a_a_d_logo),
                                  ),
                                  //Cotizar por tutor
                                  GestureDetector(
                                    onTap: () {
                                      print("Cotizar por otro tutor");
                                      cotizarporotrotutordialog(
                                          context, solicitud.idcotizacion,
                                          solicitud.fechasistema);
                                    },
                                    child: Icon(FluentIcons.a_a_d_logo),
                                  ),
                                  //Ver cotizaciones
                                  GestureDetector(
                                    onTap: () {
                                      print("Ver cotizaciones");
                                      vistacotizaciones(context, solicitud);
                                    },
                                    child: Icon(FluentIcons.access_logo),
                                  ),
                                  //Cambiar estado de servicio
                                  GestureDetector(
                                    onTap: () {
                                      print("Cambiar de estado del servicio");
                                      cambiarestadoDialog(
                                          context, solicitud.idcotizacion,
                                          solicitud.fechasistema);
                                    },
                                    child: Icon(FluentIcons.activate_orders),
                                  ),
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

  void detallessolicitud() {

  }

  StreamBuilder<QuerySnapshot<Map<String, dynamic>>> escucharnumcotizaciones(int idsolicitud){
    return StreamBuilder(
      stream: db.collection("SOLICITUDES").doc(idsolicitud.toString()).collection("COTIZACIONES").snapshots(),
        builder: (context,snapshot){
          if(!snapshot.hasData) return Text('CARGANDO NO HAY NADA');
          List<Cotizacion> cotizaciones = [];
          for(var doc in snapshot.data!.docs){
            final data = doc.data() as Map<String,dynamic>;
            Cotizacion cotizacion = Cotizacion(
              data['Cotizacion'],
              data['uidtutor'],
              data['nombretutor'],
              data['Tiempo confirmacion'],
              data['Comentario Cotización']?.toString(),
              data['Agenda'],
              data.containsKey('fechaconfirmacion') ? data['fechaconfirmacion'].toDate() : DateTime.now(), // Maneja el caso en que no existe fechaconfirmacion
            );
            numerocotizaciones = snapshot.data!.size;
            cotizaciones.add(cotizacion);
          }
          return Disenos().textocardsolicitudesnobold("${snapshot.data?.size} cotizaciones");
        }
    );
  }

  void copiarSolicitud(String servicio, int idcotizacion, String materia, DateTime fechaentrega, String resumen, String infocliente, String urlArchivos) {
    String horaRealizada = "";
    if(servicio=="TALLER"){
      horaRealizada = 'ANTES DE LAS ${DateFormat('hh:mma').format(fechaentrega)}';
    }else{
      horaRealizada = '${DateFormat('hh:mma').format(fechaentrega)}';
    }

    String solicitud = '🔴TIPO SERVICIO = $servicio \n🔴SOLICITUD = ${idcotizacion.toString()}'
        '\n🔴MATERIA = $materia'
        '\n🔴FECHA ENTREGA = ${DateFormat('dd/MM/yyyy').format(fechaentrega)}'
        '\n🔴HORA ENTREGA =  $horaRealizada'
        '\n🔴RESUMEN = $resumen'
        '\n🔴INFORMACIÓN CLIENTE = $infocliente'
        '\n '
        '\n🔴ARCHIVOS = $urlArchivos';


    Clipboard.setData(ClipboardData(text: solicitud));
    print("se copio");
  }

  void cotizarporotrotutordialog(BuildContext context, int idcotizacion, DateTime fechasistema) async {
    showDialog(
      context: context,
      builder: (context) => ContentDialog(
        title: const Text('Cotizar por tutor'),
        content: Column(
          children: [
            //tutor
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Seleccionar tutor'),
                Container(
                  height: 30,
                  width: 200,
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
            //Precio del tutor
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Precio de tutor'),
                Container(
                  width: 200,
                  child: TextBox(
                    placeholder: 'Precio de cotización',
                    onChanged: (value){
                      setState(() {
                        precio = int.parse(value);
                      });
                    },
                    maxLines: null,
                  ),
                ),
              ],
            ),
            //Fecha maxima de confirmación
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                selectfecha(),
              ],
            ),
            //Comentario
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Comentario'),
                Container(
                  width: 200,
                  child: TextBox(
                    placeholder: 'Comentario',
                    onChanged: (value){
                      setState(() {
                        comentario = value ;
                      });
                    },
                    maxLines: null,
                  ),
                ),
              ],
            )
          ],
        ),
        actions: [
          Button(
            child: const Text('Subir precio'),
            onPressed: () {
              final DateTime ahora = DateTime.now();
              final Duration duration = ahora.difference(fechasistema);
              Uploads().addCotizacion(idcotizacion, precio, selectedTutor!.uid, selectedTutor!.nombrewhatsapp, duration.inMinutes, 'Comentario', '', fechaconfirmacion);
              Navigator.pop(context, 'User deleted file');},
          ),
          FilledButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context, 'User canceled dialog'),
          ),
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

  void vistacotizaciones(BuildContext context, Solicitud solicitud) async {
    print("id solicitud ${solicitud.idcotizacion}");
    showDialog(
      context: context,
      builder: (context) => ContentDialog(
        title: const Text('Cotizaciones de servicio'),
        content:
        Column(
          children: [
            StreamBuilder(
                stream: db.collection("SOLICITUDES").doc(solicitud.idcotizacion.toString()).collection("COTIZACIONES").snapshots(),
                builder: (context,snapshot){
                  if(!snapshot.hasData) return Text('CARGANDO NO HAY NADA');
                  List<Cotizacion> cotizaciones = [];
                  for(var doc in snapshot.data!.docs){
                    final data = doc.data() as Map<String,dynamic>;
                    Cotizacion cotizacion = Cotizacion(
                      data['Cotizacion'],
                      data['uidtutor'],
                      data['nombretutor'],
                      data['Tiempo confirmacion'],
                      data['Comentario Cotización']?.toString(),
                      data['Agenda'],
                      data.containsKey('fechaconfirmacion') ? data['fechaconfirmacion'].toDate() : DateTime.now(), // Maneja el caso en que no existe fechaconfirmacion
                    );
                    numerocotizaciones = snapshot.data!.size;
                    cotizaciones.add(cotizacion);
                  }
                  return Container(
                    height: 350,
                    child: ListView.builder(
                        itemCount: cotizaciones.length,
                        itemBuilder: (context,subIndex){
                          Cotizacion cotizacion = cotizaciones[subIndex];

                          return Container(
                            height: 120,
                            child: Card(
                              child:
                              Column(
                                children: [
                                  //Nombre de tutor y precio cobrado
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(child: Text(cotizacion.nombretutor)),
                                      Expanded(child: Text(cotizacion.cotizacion.toString()))
                                    ],
                                  ),
                                  //Tiempo en dar respuesta
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(child: Text("${cotizacion.tiempoconfirmacion.toString()} minutos")),
                                      Expanded(child: Text('Fecha max confirmación')),
                                      GestureDetector(child: Icon(FluentIcons.add),
                                        onTap: () async {
                                          print("Vamos a agendar con el tutor");
                                          //caragamos el dialog y despues de cargar el Dialog vamos  a confuirmar la solicitud
                                          identificadorcodigo(solicitud.servicio);
                                          codigocontabilidad(solicitud);
                                          agendartrabajo(context,solicitud,cotizacion);
                                        },
                                      )
                                    ],
                                  )
                                ],
                              ),

                            ),
                          );
                        }
                    ),
                  );
                }
            ),
          ],
        ),
        actions: [
          Button(
            child: const Text('Subir precio'),
            onPressed: () {
            }
          ),
          FilledButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context, 'User canceled dialog'),
          ),
        ],
      ),
    );
  }

  void cambiarestadoDialog(BuildContext context, int idcotizacion, DateTime fechasistema) async {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return ContentDialog(
              title: const Text('Cotizaciones de servicio'),
              content: Column(
                children: [
                  //seleccionar estado
                  ComboBox<String>(
                    value: selectedEstado,
                    items: EstadoList.map<ComboBoxItem<String>>((e) {
                      return ComboBoxItem<String>(
                        child: Text(e),
                        value: e,
                      );
                    }).toList(),
                    onChanged: (text) {
                      setState(() {
                        selectedEstado = text; // Update the local variable
                      });
                      print("materia seleccionado $selectedEstado");
                    },
                    placeholder: const Text('Seleccionar tipo servicio'),
                  ),
                ],
              ),
              actions: [
                Button(
                  child: const Text('Actualizar Estado'),
                  onPressed: () async {
                    print("Enviar estado de servicio");
                    DocumentReference estadomateria = db.collection("SOLICITUDES").doc(idcotizacion.toString());
                    estadomateria.update({'Estado': selectedEstado});
                    Navigator.pop(context);
                    //Registrar el historial cada vez que se coloque
                    final ahora = DateTime.now();
                    final Duration duration = ahora.difference(fechasistema);
                    CollectionReference historialmateria = db.collection("SOLICITUDES").doc(idcotizacion.toString()).collection("HISTORIAL");
                    HistorialEstado hisotrialnuevo = HistorialEstado(selectedEstado!, duration.inMinutes, DateTime.now());
                    historialmateria.doc(selectedEstado!).set(hisotrialnuevo.toMap());
                    //Ahora de forma local, cambiemos el estado a ver
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    String solicitudesJson = prefs.getString('solicitudes_list') ?? '';
                    List<dynamic> CarreraData = jsonDecode(solicitudesJson);
                    List solicitudList = CarreraData.map((tutorData) =>
                        Solicitud.fromJson(tutorData as Map<String, dynamic>)).toList();
                    // Actualizar la lista de clientes local con el cliente actualizado
                    int indexToUpdate = solicitudList.indexWhere((solicitud) => solicitud.idcotizacion == idcotizacion);
                    if (indexToUpdate != -1) {
                      solicitudList[indexToUpdate].estado = selectedEstado;
                    }
                    String solicitudListdos = jsonEncode(solicitudList);
                    await prefs.setString('solicitudes_list', solicitudListdos);
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

  void agendartrabajo(BuildContext context, Solicitud solicitud, Cotizacion cotizacion) async {
    final currentwidth = MediaQuery.of(context).size.width;
    print("se dibja show diaglog");
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          key: statefulBuilderKey,
          builder: (BuildContext context, StateSetter setState) {
            return ContentDialog(
              title: const Text('Agendar trabajo'),
              content: Column(
                children: [
                  //Numero de servicio agendado
                  StreamBuilder(
                    stream: LoadData().cargarnumerocontabilidad(),
                    builder: (context, snapshot){
                      if (snapshot.hasError) {
                        return Center(child: Text('Error al cargar las solicitudes'));
                      }
                      if (!snapshot.hasData) {
                        return Center(child: Text('cargando'));
                      }
                      int? num_solicitud = snapshot.data;
                      numerocontabilidadagenda = num_solicitud!;
                      return Text("id contabilidad $num_solicitud");
                    },
                  ),
                  //ssitema
                  ComboBox<String>(
                    value: selectedSistema,
                    items: SistemaList.map<ComboBoxItem<String>>((e) {
                      return ComboBoxItem<String>(
                        child: Text(e),
                        value: e,
                      );
                    }).toList(),
                    onChanged: (text) {
                      setState(() {
                        selectedSistema = text; // Update the local variable
                      });
                    },
                    placeholder: const Text('Seleccionar sistema de servicio'),
                  ),
                  //Precio del tutor
                  Container(
                    width: currentwidth-80,
                    child: Text("Precio tutor: ${cotizacion.cotizacion}"),
                  ),
                  //precio cobrado
                  Container(
                    width: currentwidth-80,
                    child: TextBox(
                      placeholder: 'Precio cobrado',
                      onChanged: (value){
                        setState(() {
                          preciocobrado = int.parse(value);
                        });
                      },
                      maxLines: null,
                    ),
                  ),
                  //identificador de codigo
                  identificadorcodigo(solicitud.servicio),
                  //Prospecto cliente o no?, para ver si hay que actualizarle información
                  prospectocliente(solicitud),
                  Text(stringnombrecliente),
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
                    FilledButton(child: Text('Copiar confirmación'),
                      onPressed: (){
                      copiarConfirmacion(solicitud,true,cotizacion);
                      }
                  ),
                  FilledButton(child: Text('Copiar confirmación tutor'),
                      onPressed: (){
                        copiarConfirmacion(solicitud,false,cotizacion);
                      }
                  ),
                ],
              ),
              actions: [
                Button(
                  child: const Text('Actualizar Estado'),
                  onPressed: () {
                    comprobacionagendartrabajo(cotizacion,solicitud,context);
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

  Future<void> comprobacionagendartrabajo(Cotizacion cotizacion, Solicitud solicitud, BuildContext context) async {
    if(selectedSistema==null){
      Utiles().notificacion("Selecciona un sistema", context, false,"ya sea nacional o internacional");
    }else if(preciocobrado<cotizacion.cotizacion){
      print("precio cobrado es < al precio del tutor");
      Utiles().notificacion("Precio cobrado es < precio tutor", context, false,"cambia el precio");
    } else{
      CollectionReference agendatutor = db.collection("SOLICITUDES").doc(solicitud.idcotizacion.toString()).collection("COTIZACIONES");
      Map<String, dynamic> data = {'Agenda': "AGENDADO"};
      agendatutor.doc(cotizacion.uidtutor).update(data);
      CollectionReference expiradoglobal = db.collection("SOLICITUDES");
      Map<String, dynamic> dataexpirado = {'Estado': "AGENDADO"};
      expiradoglobal.doc(solicitud.idcotizacion.toString()).update(dataexpirado);
      //Aqui vamos a tener el servicio agendado, agendado realmente
      Uploads().addServicioAgendado(codigo,selectedSistema!, solicitud.materia, solicitud.cliente.toString(), preciocobrado, solicitud.fechaentrega, cotizacion.nombretutor, cotizacion.cotizacion, selectedIdentificador, solicitud.idcotizacion,numerocontabilidadagenda,"NO ENTREGADO");
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

  Text identificadorcodigo(String servicio){
    if(servicio == "TALLER"){
      selectedIdentificador = "T";
    }else if(servicio == "PARCIAL"){
      selectedIdentificador = "P";
    }else if(servicio == "QUIZ"){
      selectedIdentificador = "Q";
    } else{
      selectedIdentificador = "NO PROGRAMADO";
    }
    return Text(selectedIdentificador);
  }

  Text prospectocliente(Solicitud solicitud){
// Filtra la lista de clientes para encontrar el cliente correspondiente al número de cliente en la solicitud
    final clienteEncontrado = widget.clienteList.firstWhere(
          (cliente) => cliente.numero == solicitud.cliente, // Manejo de caso en el que no se encuentra el cliente
    );

// Verifica si se encontró el cliente y obtén el valor del nombre del cliente
    if (clienteEncontrado != null) {
      stringpropsectocliente = clienteEncontrado.nombreCliente;
      stringnombrecliente = clienteEncontrado.nombrecompletoCliente;
    } else {
      // Manejo de caso en el que no se encuentra el cliente
      stringpropsectocliente = 'Cliente no encontrado';
      stringnombrecliente = 'CLIENTE SIN NOMBRE';
    }
    return Text(stringpropsectocliente);
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
    int preciousuario = istutor? preciocobrado : cotizacion.cotizacion;
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
    }

    String confirmacion = '*CONFIRMACIÓN DE $servicio DUFY ASESORÍAS*'
        '\n'
        '\n${solicitud.servicio} CONFIRMADO'
        '\n'
        '\nMatería: ${solicitud.materia}'
        '\n$tutorcliente: ${nombreusuario}'
        '\nPrecio: ${NumberFormat("#,###", "es_ES").format(preciousuario)}'
        '\nFecha de entrega: $fechita'
        '\nCódigo de confirmación: $codigo'
        '\nID solicitud confirmada: ${solicitud.idcotizacion}';
        '\nCualquier duda o inconveniente, comunícate con nosotros!! 📝';

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
    widget.onUpdateListaClientes();
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





