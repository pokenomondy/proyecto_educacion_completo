import 'package:dashboard_admin_flutter/Config/theme.dart';
import 'package:dashboard_admin_flutter/Objetos/Configuracion/objeto_configuracion.dart';
import 'package:dashboard_admin_flutter/Objetos/Solicitud.dart';
import 'package:dashboard_admin_flutter/Utils/Drive%20Api/GoogleDrive.dart';
import 'package:dashboard_admin_flutter/Utils/Firebase/Uploads.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' as material;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../Config/Config.dart';
import '../../Objetos/Objetos Auxiliares/Materias.dart';
import '../../Providers/Providers.dart';
import '../../Utils/Disenos.dart';
import '../../Utils/FuncionesMaterial.dart';
import '../../Utils/Utiles/FuncionesUtiles.dart';
import '../../Config/elements.dart';

class DetallesServicio extends StatefulWidget {

  const DetallesServicio({Key?key,
  }) :super(key: key);

  @override
  DetallesServicioState createState() => DetallesServicioState();
}

class DetallesServicioState extends State<DetallesServicio> {

  @override
  Widget build(BuildContext context) {
    //Completo
    final widthCompleto = MediaQuery.of(context).size.width;
    //tamaño para computador y tablet
    final tamanowidthdobleComputador = (widthCompleto/2)-Config.responsivepc/2;
    //currentheight completo
    final heightCompleto = MediaQuery.of(context).size.height-Config.tamanoHeightnormal;

    return Column(
      children: [
        if(widthCompleto >= 1200)
          Row(
            children: [
              PrimaryColumnDetallesSolicitud(currentwith: tamanowidthdobleComputador,currentheight: heightCompleto,editDetalles: true,),
              SecundaryColumnDetallesSolicitud(currentwith: tamanowidthdobleComputador,currentheight: heightCompleto,)
            ],
          ),

        if(widthCompleto < 1200 && widthCompleto > 620)
          Column(
            children: [
              PrimaryColumnDetallesSolicitud(currentwith: widthCompleto,currentheight: 0,editDetalles: true,),
            ],
          ),

        if(widthCompleto <= 620)
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  PrimaryColumnDetallesSolicitud(currentwith: widthCompleto, currentheight: -1,editDetalles: true,),
                  SecundaryColumnDetallesSolicitud(currentwith: widthCompleto, currentheight: -1),
                ],
              ),
            ),
          ),
      ],
    );
  }

}

class PrimaryColumnDetallesSolicitud extends StatefulWidget {
  final double currentwith;
  final double currentheight;
  final bool editDetalles;

  const PrimaryColumnDetallesSolicitud({Key?key,
    required this.currentwith,
    required this.currentheight,
    required this.editDetalles,
  }) :super(key: key);

  @override
  PrimaryColumnDetallesSolicitudState createState() => PrimaryColumnDetallesSolicitudState();

}

class PrimaryColumnDetallesSolicitudState extends State<PrimaryColumnDetallesSolicitud> {
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
            height: widget.currentheight,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 15.0, bottom: 10),
                child: Text("Detalles solicitud", style: themeApp.styleText(20, true, themeApp.primaryColor),),
              ),
              textoymodificable('Tipo de servicio',solicitudSeleccionado.servicio,0,false,),
              if(widget.editDetalles)
                Column(
                  children: [
                    textoymodificable('Id cotización ',solicitudSeleccionado.idcotizacion.toString(),1,true),
                    textoymodificable('Matería  ',solicitudSeleccionado.materia,2,false),
                    textoymodificable('Fecha de entrega  ',solicitudSeleccionado.fechaentrega.toString(),3,false),
                    textoymodificable('Cliente  ',solicitudSeleccionado.cliente.toString(),4,true),
                    textoymodificable('fecha sistema  ',solicitudSeleccionado.fechasistema.toString(),5,true),
                    textoymodificable('Estado  ',solicitudSeleccionado.estado,6,true),

                  ],
                ),
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
                    child: Text("$text : $valor", style: themeApp.styleText(15, false, themeApp.blackColor),)
                ),
                if(!bool && widget.editDetalles)
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

class SecundaryColumnDetallesSolicitud extends StatefulWidget {
  final double currentwith;
  final double currentheight;

  const SecundaryColumnDetallesSolicitud({Key?key,
    required this.currentwith,
    required this.currentheight,

  }) :super(key: key);

  @override
  SecundaryColumnDetallesSolicitudState createState() => SecundaryColumnDetallesSolicitudState();

}

class SecundaryColumnDetallesSolicitudState extends State<SecundaryColumnDetallesSolicitud> {
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
  ConfiguracionPlugins? config;
  Solicitud? solicitud;
  List<ArchivoResultado>? archivoList;


  void actualizarArchivos(int idcotizacion,String carpetaid) async{
    DriveApiUsage().viewarchivosolicitud(idcotizacion, carpetaid,context);
    cargarArchivos = true;
  }



  @override
  Widget build(BuildContext context) {
    return Consumer3<ConfiguracionAplicacion, SolicitudProvider,ArchivoVistaDrive>(
      builder: (context, configuracionProviderselect, solicitudProviderselect,archivoDriveProvider , child) {
        config = configuracionProviderselect.config;
        solicitud = solicitudProviderselect.solicitudSeleccionado;
        archivoList = archivoDriveProvider.todosLosArchivos;
        configuracionSolicitudes = Utiles().obtenerBool(config!.solicitudesDriveApiFecha);

        if(!cargarArchivos && configuracionSolicitudes){
          print("cargando archivos");
          actualizarArchivos(solicitud!.idcotizacion,config!.idcarpetaSolicitudes);
        }

        if(configuracionSolicitudes){
          return ItemsCard(
            alignementColumn: MainAxisAlignment.start,
            shadow: false,
            width: widget.currentwith,
            height: widget.currentheight,
            cardColor: themeApp.primaryColor,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20.0, bottom: 12.0),
                child: Text("Seleccionar archivos", style: themeApp.styleText(24, true, themeApp.whitecolor),),
              ),
              PrimaryStyleButton(
                  buttonColor: themeApp.grayColor,
                  tapColor: themeApp.blackColor,
                  invert: true,
                  function: (){
                    selectFile();
                  }, text: "Seleccionar archivos"),

              //Archivos nombre que se van a subir
              if(selectedFiles  != null)
                Column(
                  children: selectedFiles!.map((file) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
                      color: themeApp.primaryColor,
                      child: Text(file.name, style: themeApp.styleText(14, false, themeApp.whitecolor),),
                    );
                  }).toList(),
                ),

              PrimaryStyleButton(
                  invert: true,
                  function: (){
                    subirarchivos(config!.idcarpetaSolicitudes,solicitud!.idcotizacion.toString());
                  }, text: "Subir mas archivos"),

              Padding(
                padding: const EdgeInsets.only(top: 20.0, bottom: 10.0),
                child: Text("Archivos en Solicitud", style: themeApp.styleText(22, true, themeApp.whitecolor),),
              ),

              _TarjetaArchivos(archivosList: archivoList,numcontenedor: widget.currentheight == -1 ? 1 : 4,),

            ],
          );
        }else{
          return Text('Vos no tenes este plugin para ver los archivos');
        }
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
  final int numcontenedor;

  const _TarjetaArchivos({Key?key,
    required this.archivosList,
    required this.numcontenedor,
  }) :super(key: key);

  @override
  _TarjetaArchivosState createState() => _TarjetaArchivosState();

}

class _TarjetaArchivosState extends State<_TarjetaArchivos> {

  final ThemeApp themeApp = ThemeApp();

  @override
  Widget build(BuildContext context) {
    TextStyle styleText([Color? color]) => themeApp.styleText(14, false, color?? themeApp.whitecolor);


    Expanded containWidgets(List<Widget> children) => Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: children,
        ),
      ),
    );

    List<Widget> contenedores = List.generate(widget.numcontenedor, (index){
      return containWidgets([
        for (int i = 0; i < widget.archivosList!.length; i++)
          if ((i + 1) % widget.numcontenedor == (index + 1) % widget.numcontenedor)
            _TarjetaArchivo(archivo: widget.archivosList![i]),
      ]);
    });

    return ItemsCard(
      alignementColumn: MainAxisAlignment.start,
      shadow: false,
      cardColor: themeApp.primaryColor,
      children: [
        Text("hay ${widget.archivosList?.length.toString()} archivos", style: styleText(),),

        material.Card(
          color: themeApp.whitecolor.withOpacity(0),
          shadowColor: themeApp.whitecolor.withOpacity(0),
          child: SingleChildScrollView(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: contenedores,
            ),
          ),
        ),


      ],
    );
  }

}

class _TarjetaArchivo extends StatelessWidget{

  final ArchivoResultado archivo;

  const _TarjetaArchivo({
    Key?key,
    required this.archivo,
  }):super(key: key);

  @override
  Widget build(BuildContext context){
    const double imageTamanio = 40;
    const double radioButton = 22;
    final ThemeApp themeApp = ThemeApp();

    TextStyle styleText([double? tamanio]) => themeApp.styleText(tamanio?? 14, false, themeApp.blackColor);
    material.SizedBox textResponsive(String text, TextStyle styleText) => material.SizedBox(
      width: double.infinity,
      child: Text(text, style: styleText, textAlign: TextAlign.center,),
    );

    return Card(
        margin: const EdgeInsets.symmetric(vertical: 5.0),
        backgroundColor: themeApp.whitecolor,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 7.0, horizontal: 5.0),
          child: material.SizedBox(
            width: double.infinity,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onDoubleTap: (){
                        _abrirEnlace(archivo.linkVistaArchivo);
                      },
                      child: Image.network(
                        archivo.iconLink,
                        width: imageTamanio,
                        height: imageTamanio,
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.high,
                      ),
                    ),
                  ),
                ),

                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                      child: textResponsive(archivo.nombrearchivo, styleText()),
                    onDoubleTap: (){
                        _abrirEnlace(archivo.linkVistaArchivo);
                    },
                  ),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text("${archivo.size} mb", style: styleText(9), textAlign: TextAlign.start,)),
                    Expanded(child: Text(archivo.horaCracion, style: styleText(9), textAlign: TextAlign.end,)),
                  ],
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CircularButton(
                        radio: radioButton,
                        iconData: material.Icons.download,
                        function: (){
                          _abrirEnlace(archivo.linkDescargaArchivo);
                        }
                    ),
                    CircularButton(
                        radio: radioButton,
                        buttonColor: themeApp.redColor,
                        iconData: material.Icons.clear,
                        function: (){
                          DriveApiUsage().eliminarArchivo(archivo.id,context);
                        }
                    ),
                  ],
                )

              ],
            ),
          ),
        )
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