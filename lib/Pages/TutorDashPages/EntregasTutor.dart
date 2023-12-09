import 'package:dashboard_admin_flutter/Utils/Drive%20Api/GoogleDrive.dart';
import 'package:dashboard_admin_flutter/Utils/Utiles/FuncionesUtiles.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import '../../Objetos/AgendadoServicio.dart';
import '../../Utils/Disenos.dart';
import '../../Utils/EnviarMensajesWhataspp.dart';
import '../../Utils/Firebase/Load_Data.dart';
import '../../Utils/Firebase/StreamBuilders.dart';
import 'package:flutter/material.dart' as material;

class EntregaTutor extends StatefulWidget{

  @override
  _EntregaTutorState createState() => _EntregaTutorState();

}

class _EntregaTutorState extends State<EntregaTutor> {
  String nombretutor = "";
  final currentUser = FirebaseAuth.instance.currentUser;
  String idcarpeta = "";

  @override
  void initState() {
    loaddata().then((_) {
      setState(() {});
    });
    super.initState();
  }

  Future<void> loaddata() async {
    Map<String, dynamic> datos_tutor = await LoadData().getinfotutor(currentUser!);
    nombretutor = datos_tutor['nombre Whatsapp'];
    print("el tutor es $nombretutor");
  }


  @override
  Widget build(BuildContext context) {
    final currentwidth = MediaQuery.of(context).size.width;
    final tamano = currentwidth/2-100;
    return Row(
      children: [
        PrimaryColumn(nombretutor: nombretutor,currentwidth: currentwidth-100,),
      ],
    );
  }

}

class EntregaTutorResponsive extends StatefulWidget{
  final String nombretutor;
  final double currentwidth;

  const EntregaTutorResponsive({Key?key,
    required this.nombretutor,
    required this.currentwidth,
  }) :super(key: key);

  @override
  _PrimaryColumnState createState() => _PrimaryColumnState();

}

class PrimaryColumn extends StatefulWidget{
  final String nombretutor;
  final double currentwidth;

  const PrimaryColumn({Key?key,
    required this.nombretutor,
    required this.currentwidth,
  }) :super(key: key);

  @override
  _PrimaryColumnState createState() => _PrimaryColumnState();

}

class _PrimaryColumnState extends State<PrimaryColumn> {
  List<PlatformFile>? selectedFiles ;
  List<ServicioAgendado>? serviciosListTutor = [];
  ServicioAgendado? selectedServicio;
  bool subiendoentrega = false;
  String textoestado = "";
  bool cargaseleccionarcodigo = false;
  bool cargandoentrega = false;


  @override
  void initState() {
    loaddata();
    super.initState();
  }

  Future<void> loaddata() async{
    serviciosListTutor= await stream_builders().cargaragendatutor();
    print("servicios lista del tutor");
    print(serviciosListTutor);
    DateTime fechaLimite = DateTime(2023, 9, 29);
    serviciosListTutor = serviciosListTutor?.where((servicio) {
      if (servicio.entregadotutor != "ENTREGADO" &&
          servicio.fechasistema != null &&
          servicio.identificadorcodigo !="P" &&
          servicio.identificadorcodigo !="Q" &&
          servicio.identificadorcodigo !="A") {
        DateTime fechasistema = servicio.fechasistema;
        print("servocops cpdogp ${servicio.codigo}");
        return fechasistema.isAfter(fechaLimite);
      }
      return false;
    }).toList();
    print("serivicios $serviciosListTutor");
    setState(() {
      cargaseleccionarcodigo = true;
    });
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
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: SizedBox(
        width: widget.currentwidth,
        height: tamanowidht,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              //Lista de servicios
              if(cargaseleccionarcodigo==true)
                Container(
                  child: AutoSuggestBox<ServicioAgendado>(
                    items: serviciosListTutor!.map((servicio) {
                      return AutoSuggestBoxItem<ServicioAgendado>(
                          value: servicio,
                          label: servicio.codigo,
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
                Column(
                  children: [
                    Text(textoestado)
                  ],
                ),
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
              FilledButton(
                  style: Disenos().boton_estilo(),
                  child: Text('PRUEBA'), onPressed:() async{
                enviarmensajewsp().sendMessageAvisoTrabajoEntregadoAdmin("573006984993", selectedServicio!);
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
