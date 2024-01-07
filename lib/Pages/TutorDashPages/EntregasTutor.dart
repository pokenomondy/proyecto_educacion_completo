import 'package:dashboard_admin_flutter/Objetos/Configuracion/objeto_configuracion.dart';
import 'package:dashboard_admin_flutter/Pages/Contabilidad/DashboardContabilidad.dart';
import 'package:dashboard_admin_flutter/Utils/Drive%20Api/GoogleDrive.dart';
import 'package:dashboard_admin_flutter/Utils/Firebase/Uploads.dart';
import 'package:dashboard_admin_flutter/Utils/Utiles/FuncionesUtiles.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:provider/provider.dart';
import '../../Config/theme.dart';
import '../../Objetos/AgendadoServicio.dart';
import '../../Providers/Providers.dart';
import '../../Utils/Disenos.dart';
import 'package:flutter/material.dart' as material;
import '../Servicios/Detalle_Solicitud.dart';

class EntregaTutor extends StatefulWidget{

  @override
  _EntregaTutorState createState() => _EntregaTutorState();

}

class _EntregaTutorState extends State<EntregaTutor> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final currentwidth = MediaQuery.of(context).size.width;
    final currentheight = MediaQuery.of(context).size.height;
    final tamano = currentwidth/3-40;

    return Row(
      children: [
        material.SingleChildScrollView(
          child: Column(
            children: [
              //mosttramos información del servicio
              TercerColumnContaDash(currentwidth: tamano, currentheight: tamano,editDetalles: false,),
              //mostramos información de la solicitud, esta descargandola , 1 documento
              PrimaryColumnDetallesSolicitud(currentwith: tamano, currentheight: -1,editDetalles: false,),
            ],
          ),
        ),
        //mostramos archivos
        SecundaryColumnDetallesSolicitud(currentwith: tamano, currentheight: currentheight,),
        //entregamos trabajo
        Column(
          children: [
            PrimaryColumnEntregaTutor(currentwidth: tamano),
            SecundaryColumnEntregaTutor(currentwidth: tamano,),
          ],
        ),
      ],
    );
  }

}

class PrimaryColumnEntregaTutor extends StatefulWidget{
  final double currentwidth;

  const PrimaryColumnEntregaTutor({Key?key,
    required this.currentwidth,
  }) :super(key: key);

  @override
  _PrimaryColumnEntregaTutorState createState() => _PrimaryColumnEntregaTutorState();

}

class _PrimaryColumnEntregaTutorState extends State<PrimaryColumnEntregaTutor> {
  List<PlatformFile>? selectedFiles ;
  ServicioAgendado? selectedServicio;

  bool subiendoentrega = false;

  String textoestado = "";

  bool cargandoentrega = false;

  ConfiguracionPlugins? config;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final tamanowidht = MediaQuery.of(context).size.height;
    return Stack(
      children: [
        entregasCuadro(tamanowidht),
        if(cargandoentrega==true)
          Positioned.fill(
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

  Widget entregasCuadro(double tamanowidht){
    return Consumer2<ContabilidadProvider,ConfiguracionAplicacion>(
        builder: (context, contabilidadProviderselect,configuracionProviderselet, child) {
          selectedServicio = contabilidadProviderselect.servicioSeleccionado;
          config = configuracionProviderselet.config;

          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              color: Colors.red,
              width: widget.currentwidth,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text('Entregas de trabajo en ${selectedServicio!.codigo}'),
                    //Botón de subir archivos
                    FilledButton(
                        style: Disenos().boton_estilo(),
                        child: Text('seleccionar archivos'), onPressed: (){
                      selectFile();
                    }),
                    if(selectedFiles  != null)
                    //Lista de archivos
                      Wrap(
                        spacing: 8.0,  // Espacio horizontal entre los elementos (ajusta según tus preferencias)
                        runSpacing: 8.0,  // Espacio vertical entre las filas de elementos (ajusta según tus preferencias)
                        children: selectedFiles!.map((file) {
                          return Container(
                            width: 80,
                            height: 80,
                            color: Colors.blue,
                            child: Column(
                              children: [
                                Text(Utiles().truncateLabel(file.name)),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    FilledButton(
                        style: Disenos().boton_estilo(),
                        child: Text('ENTREGAR'), onPressed:() async{
                      entregarTrabajo();
                    }),
                    Disenos().textoentregatrabajoTutor(selectedServicio!.fechaentrega)

                  ],
                ),
              ),
            ),
          );

        }
    );
  }
  
  Future entregarTrabajo() async{
    final result = await DriveApiUsage().subirArchivosDrive(config!.idcarpetaEntregaTutores, selectedFiles, selectedServicio!.codigo, context);
    Uploads().modifyServicioAgendadoEntregado(selectedServicio!.codigo,result.folderUrl);

    setState(() {
      selectedFiles = [];
    });
  }

  Future selectFile() async{
    if(kIsWeb){
      final result = await FilePicker.platform.pickFiles(type: FileType.any, allowMultiple: true);

      if (result != null && result.files.isNotEmpty) {
        final fileName = result.files.first.name;
        final fileextension = result.files.first.extension;
        setState(() {
          selectedFiles  = result.files;
          print(fileName);
          print(fileextension);
        });
        print("extension archivo");
        print("Nombre del archivo");
      }}else{
      print('Aqui no va a pasar');
    }
  }

}

class SecundaryColumnEntregaTutor extends StatefulWidget{
  final double currentwidth;

  const SecundaryColumnEntregaTutor({Key?key,
    required this.currentwidth,
  }) :super(key: key);

  @override
  _SecundaryColumnEntregaTutorState createState() => _SecundaryColumnEntregaTutorState();

}

class _SecundaryColumnEntregaTutorState extends State<SecundaryColumnEntregaTutor> {
  List<ArchivoResultado> archivosDrive = [];
  @override
  Widget build(BuildContext context) {
    return ItemsCard(
      alignementColumn: MainAxisAlignment.start,
      shadow: false,
      width: 300,
      cardColor: ThemeApp().primaryColor,
      children: [
        Text('Aqui vienne archivos de contabilidad'),
        //TarjetaArchivosDrive(archivosList: archivosDrive, numcontenedor: 1)
      ],
    );
  }
}





