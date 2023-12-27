import 'package:dashboard_admin_flutter/Config/theme.dart';
import 'package:dashboard_admin_flutter/Objetos/Configuracion/Configuracion_Configuracion.dart';
import 'package:dashboard_admin_flutter/Objetos/Solicitud.dart';
import 'package:dashboard_admin_flutter/Utils/Drive%20Api/GoogleDrive.dart';
import 'package:dashboard_admin_flutter/Utils/Firebase/Load_Data.dart';
import 'package:dashboard_admin_flutter/Utils/Firebase/Uploads.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../Objetos/Objetos Auxiliares/Materias.dart';
import '../../Providers/Providers.dart';
import '../../Utils/Disenos.dart';
import '../../Utils/FuncionesMaterial.dart';
import '../../Utils/Utiles/FuncionesUtiles.dart';

class DetallesServicio extends StatefulWidget {

  const DetallesServicio({Key?key,
  }) :super(key: key);

  @override
  DetallesServicioState createState() => DetallesServicioState();
}

class DetallesServicioState extends State<DetallesServicio> {



  @override
  Widget build(BuildContext context) {
    final currentwidth = MediaQuery.of(context).size.width;
    final tamanowidth = currentwidth/2 -30;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        PrimaryColumn(currentwith: tamanowidth,),
        SecundaryColumn(currentwith: tamanowidth)
      ],
    );
  }

}

class PrimaryColumn extends StatefulWidget {
  final double currentwith;

  const PrimaryColumn({Key?key,
    required this.currentwith,
  }) :super(key: key);

  @override
  PrimaryColumnState createState() => PrimaryColumnState();

}

class PrimaryColumnState extends State<PrimaryColumn> {
  String servicio = "";
  List<bool> editarcasilla = List.generate(10, (index) => false);
  List<String> serviciosList = ['PARCIAL','TALLER','QUIZ','ASESORIAS'];
  Materia? selectedMateria;
  List<Materia> materiaList = [];
  String datoscambiostext = "";
  DateTime cambiarfecha = DateTime.now();
  final ThemeApp themeApp = ThemeApp();
  //id cotización
  int idcotizacionn = 0;
  //Cambios
  String? selectedServicio;
  String? cambio;

  @override
  void initState() {
    loadtablas();
    super.initState();
  }

  Future loadtablas() async{
    //Cargar materias
    final materiasProvider =  context.read<MateriasVistaProvider>();
    materiaList = materiasProvider.todasLasMaterias;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SolicitudProvider>(
        builder: (context, solicitudprovider, child) {
          Solicitud solicitudSeleccionado = solicitudprovider.solicitudSeleccionado;
          idcotizacionn = solicitudSeleccionado.idcotizacion;

          return ItemsCard(
            alignementColumn: MainAxisAlignment.start,
            shadow: false,
            width: widget.currentwith * 0.98,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 15.0, bottom: 10),
                child: Text("Detalles solicitud", style: themeApp.styleText(20, true, themeApp.primaryColor),),
              ),
              textoymodificable('Tipo de servicio',solicitudSeleccionado.servicio,0,false,),
              textoymodificable('Id cotización ',solicitudSeleccionado.idcotizacion.toString(),1,true),
              textoymodificable('Matería  ',solicitudSeleccionado.materia,2,false),
              textoymodificable('Fecha de entrega  ',solicitudSeleccionado.fechaentrega.toString(),3,false),
              textoymodificable('Cliente  ',solicitudSeleccionado.cliente.toString(),4,true),
              textoymodificable('fecha sistema  ',solicitudSeleccionado.fechasistema.toString(),5,true),
              textoymodificable('Estado  ',solicitudSeleccionado.estado,6,true),
              textoymodificable('Resumen  ',solicitudSeleccionado.resumen,7,false),
              textoymodificable('Info cliente ',solicitudSeleccionado.infocliente,8,false),
              textoymodificable('url archivos ',solicitudSeleccionado.urlArchivos,9,true),
            ],
          );
        }
    );
  }

  Widget textoymodificable(String text,String valor,int index, bool bool){
    const double verticalPadding = 3.0;

    return Row(
      children: [
        if (!editarcasilla[index])
          Padding(
            padding: const EdgeInsets.symmetric(vertical: verticalPadding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                    width: widget.currentwith-60,
                    padding: const EdgeInsets.only(bottom: 5, right: 5, top: 5),
                    margin: const EdgeInsets.only(left: 15),
                    child: Text("$text : $valor", style: themeApp.styleText(15, false, themeApp.blackColor),)),
                if(!bool)
                  GestureDetector(
                    onTap: (){
                      setState(() {
                        editarcasilla[index] = !editarcasilla[index]; // Alterna entre los modos de visualización y edición
                      });
                    },
                    child: const Icon(FluentIcons.edit),
                  )
              ],
            ),
          ),
        if (editarcasilla[index])
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
            child: SizedBox(
              width: widget.currentwith - 42,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if(index == 7 || index == 8)
                    SizedBox(
                      width: widget.currentwith - 120,
                      child: TextBox(
                        placeholder: valor,
                        onChanged: (value){
                          cambio = value;
                        },
                        maxLines: null,
                      ),
                    ),
                  if(index == 0 )
                    SizedBox(
                      width: widget.currentwith - 120,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5.0),
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
                            selectedServicio = item.value;
                            cambio = selectedServicio;
                          },
                          decoration: Disenos().decoracionbuscador(),
                          placeholder: 'Selecciona tu servicio',
                          onChanged: (text, reason) {
                            if (text.isEmpty ) {
                              selectedServicio = null; // Limpiar la selección cuando se borra el texto
                            }
                          },
                        ),
                      ),
                    ),
                  if(index == 2)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
                      child: SizedBox(
                        height: 30,
                        width: widget.currentwith - 120,
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
                          decoration: Disenos().decoracionbuscador(),
                          onSelected: (item) {
                            setState(() {
                              selectedMateria = item.value; // Actualizar el valor seleccionado
                              cambio = item.value?.nombremateria;
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
                    ),
                  if(index == 3)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5.0),
                      child: selectfecha(context),
                    ),
                  //actualizar variable
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3.0),
                        child: GestureDetector(
                          onTap: () async{
                            print("a cambiar $cambio!");
                            await Uploads().modifyServiciosolicitud(index, cambio!, cambiarfecha,idcotizacionn);
                            setState(() {
                              editarcasilla[index] = !editarcasilla[index]; // Alterna entre los modos de visualización y edición
                            });
                          },
                          child: const Icon(FluentIcons.check_list),
                        ),
                      ),
                      //cancelar
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3.0),
                        child: GestureDetector(
                          onTap: (){
                            setState(() {
                              editarcasilla[index] = !editarcasilla[index]; // Alterna entre los modos de visualización y edición
                            });
                          },
                          child: const Icon(FluentIcons.cancel),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
      ],
    );
  }

  String _truncateLabel(String label) {
    const int maxLength = 30; // Define la longitud máxima permitida para la etiqueta
    if (label.length > maxLength) {
      return '${label.substring(0, maxLength - 3)}...'; // Agrega puntos suspensivos
    }
    return label;
  }

  Column selectfecha(BuildContext context){
    return Column(
      children: [
        GestureDetector(
          onTap: () async{
            final date = await FuncionesMaterial().pickDate(context,cambiarfecha);
            if(date == null) return;

            final newDateTime = DateTime(
              date.year,
              date.month,
              date.day,
              cambiarfecha.hour,
              cambiarfecha.minute,
            );

            setState( () =>
            cambiarfecha = newDateTime
            );
          },
          child: Padding(
            padding: const EdgeInsets.only(bottom: 5.0),
            child: Disenos().fecha_y_entrega('${cambiarfecha.day}/${cambiarfecha.month}/${cambiarfecha.year}',widget.currentwith - 60),
          ),
        ),
        GestureDetector(
          onTap: () async {
            final time = await FuncionesMaterial().pickTime(context,cambiarfecha);
            if (time == null) return;

            final newDateTime = DateTime(
              cambiarfecha.year,
              cambiarfecha.month,
              cambiarfecha.day,
              time.hour,
              time.minute,
            );
            setState(() =>
            cambiarfecha = newDateTime
            );
            final formattedTime = DateFormat('hh:mm a').format(cambiarfecha);
            print(formattedTime);
          },
          child: Disenos().fecha_y_entrega(DateFormat('hh:mm  a').format(cambiarfecha), widget.currentwith - 60),
        ),
      ],
    );
  }

  }

class SecundaryColumn extends StatefulWidget {
  final double currentwith;

  const SecundaryColumn({Key?key,
    required this.currentwith,
  }) :super(key: key);

  @override
  SecundaryColumnState createState() => SecundaryColumnState();

}

class SecundaryColumnState extends State<SecundaryColumn> {
  List<ArchivoResultado> archivosresultados = [];
  final ThemeApp themeApp = ThemeApp();
  //comprobar si tenemos licencia
  bool configuracionSolicitudes = false;
  //Documento
  List<PlatformFile>? selectedFiles ;
  String archivoNombre = "";
  String _archivoExtension = "";
  //
  bool cargarArchivos = false;

  void actualizarArchivos(int idcotizacion,String carpetaid) async{
    await DriveApiUsage().viewarchivosolicitud(idcotizacion, carpetaid,context);
    setState(() {
      cargarArchivos = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentheight = MediaQuery.of(context).size.height;
    return Consumer3<ConfiguracionAplicacion, SolicitudProvider,ArchivoVistaDrive>(
      builder: (context, configuracionProviderselect, solicitudProviderselect,archivoDriveProvider , child) {
        ConfiguracionPlugins? config = configuracionProviderselect.config;
        Solicitud solicitud = solicitudProviderselect.solicitudSeleccionado;
        List<ArchivoResultado> archivoList = archivoDriveProvider.todosLosArchivos;
          configuracionSolicitudes = Utiles().obtenerBool(config!.SolicitudesDriveApiFecha);

          if(!cargarArchivos){
            print("cargando archivos");
            actualizarArchivos(solicitud.idcotizacion,config.idcarpetaSolicitudes);
          }

        return ItemsCard(
          shadow: false,
          cardColor: themeApp.primaryColor,
          width: widget.currentwith * 0.98,
          height: currentheight,

          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children:[
                if(configuracionSolicitudes)
                  FilledButton(
                      style: Disenos().boton_estilo(),
                      child: Text('seleccionar archivos'), onPressed: (){
                    selectFile();
                  }),
              ],
            ),
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
            FilledButton(
                child: Text('Subir mas archivos'),
                onPressed: (){
                  subirarchivos(config.idcarpetaSolicitudes,solicitud.idcotizacion.toString());
                }
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20.0, bottom: 10.0),
              child: Text("Archivos en Solicitud", style: themeApp.styleText(22, true, themeApp.whitecolor),),
            ),
            Expanded(
              child: _TarjetaArchivos(archivosList: archivoList),
            ),

          ],
        );
      },
    );
  }

  Future subirarchivos(String idcarpetasolicitudesDrive, String idsolicitud) async{
    final result = await DriveApiUsage().subirSolicitudes(idcarpetasolicitudesDrive, selectedFiles,idsolicitud,context);
    print("Número de archivos subidos: ${result.numberfilesUploaded}");
    print("URL de la carpeta: ${result.folderUrl}");
    //Ahora avisar numero de archivos subidos y url
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

}

class _TarjetaArchivos extends StatefulWidget{
  final List<ArchivoResultado>? archivosList;

  const _TarjetaArchivos({Key?key,
    required this.archivosList,
  }) :super(key: key);

  @override
  _TarjetaArchivosState createState() => _TarjetaArchivosState();

}

class _TarjetaArchivosState extends State<_TarjetaArchivos> {

  final ThemeApp themeApp = ThemeApp();

  @override
  Widget build(BuildContext context) {
    final currentheight = MediaQuery.of(context).size.height;
    const double multiplier = 0.7;
    return ItemsCard(
      shadow: false,
      cardColor: themeApp.primaryColor,
      height: currentheight * multiplier,
      children: [
        Text("hay ${widget.archivosList?.length.toString()} archivos"),
        SizedBox(
            height: currentheight * multiplier,
            child: ListView.builder(
                itemCount: widget.archivosList?.length,
                itemBuilder: (context,index) {
                  ArchivoResultado? archivo = widget.archivosList?[index];

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5,horizontal: 8),
                    child: Card(
                      child:Column(
                        children: [
                          //nombre del archivo
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(archivo!.nombrearchivo),
                            ],
                          ),
                          //id de archivo
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(archivo.id),
                            ],
                          ),
                          //Url del archivo
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                  child: Text(archivo.linkVistaArchivo),
                              onTap: (){
                                _abrirEnlace(archivo.linkVistaArchivo);
                              },),
                            ],
                          ),
                          //acciones
                          Row(
                            children: [
                              //ver archivo -- LOGRADO

                              //Descargar archvio -- LOGRADO

                              //eliminar archivo --
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  GestureDetector(
                                    child: Text('Eliminar archivo'),
                                    onTap: (){
                                      DriveApiUsage().eliminarArchivo(archivo.id,context);
                                    },),
                                ],
                              ),

                              //cambiar nombre -- TOCA VER

                              //informacón de archivo -- LOGRADO

                              //Actividad de archivo -- TOCA VER
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                }
            )
        ),
      ],
    );
  }

  void _abrirEnlace(String enlace) async {
    if (await canLaunch(enlace)) {
      await launch(enlace);
    } else {
      throw 'No se pudo abrir el enlace $enlace';
    }
  }
}

