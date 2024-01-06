import 'package:dashboard_admin_flutter/Pages/Contabilidad/DashboardContabilidad.dart';
import 'package:dashboard_admin_flutter/Utils/Drive%20Api/GoogleDrive.dart';
import 'package:dashboard_admin_flutter/Utils/Utiles/FuncionesUtiles.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../../Objetos/AgendadoServicio.dart';
import '../../Providers/Providers.dart';
import '../../Utils/Disenos.dart';
import '../../Utils/EnviarMensajesWhataspp.dart';
import '../../Utils/Firebase/Load_Data.dart';
import '../../Utils/Firebase/StreamBuilders.dart';
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
        PrimaryColumnEntregaTutor(nombretutor: "",currentwidth: tamano,),
      ],
    );
  }

}

class PrimaryColumnEntregaTutor extends StatefulWidget{
  final String nombretutor;
  final double currentwidth;

  const PrimaryColumnEntregaTutor({Key?key,
    required this.nombretutor,
    required this.currentwidth,
  }) :super(key: key);

  @override
  _PrimaryColumnEntregaTutorState createState() => _PrimaryColumnEntregaTutorState();

}

class _PrimaryColumnEntregaTutorState extends State<PrimaryColumnEntregaTutor> {
  List<PlatformFile>? selectedFiles ;
  List<ServicioAgendado>? serviciosListTutor = [];
  ServicioAgendado? selectedServicio;

  bool subiendoentrega = false;

  String textoestado = "";

  bool cargaseleccionarcodigo = false;

  bool cargandoentrega = false;

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
    return Consumer<ContabilidadProvider>(
        builder: (context, contabilidadProviderselect, child) {

          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: SizedBox(
              width: widget.currentwidth,
              height: tamanowidht,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [

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
                    if(subiendoentrega == true)
                    //Archivos ya subidos
                      FilledButton(
                          style: Disenos().boton_estilo(),
                          child: Text('seleccionar archivos'), onPressed: (){
                        selectFile();
                      }),
                    FilledButton(
                        style: Disenos().boton_estilo(),
                        child: Text('ENTREGAR'), onPressed:() async{
                      setState(() {
                        textoestado = "Archivos subiendose ..., espere mensaje de confirmación";
                        subiendoentrega = true;
                        cargandoentrega = true;
                      });
                      await DriveApiUsage().entregartrabajo(selectedServicio!.codigo, selectedFiles, "1I2RvuF9pOVgN5laPkahMdBoYaAY9Ma_1", context,selectedServicio!);

                      setState(() {
                        selectedFiles = [];
                        selectedServicio = null;
                        textoestado = "SUBIDO COMPLETO";
                        cargandoentrega = false;
                      });
                    }),

                    //Tiempo restante de entrega
                    if(selectedServicio != null)
                      Column(
                        children: [
                          Disenos().textoentregatrabajoTutor(selectedServicio!.fechaentrega)
                        ],
                      )
                  ],
                ),
              ),
            ),
          );

        }
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


