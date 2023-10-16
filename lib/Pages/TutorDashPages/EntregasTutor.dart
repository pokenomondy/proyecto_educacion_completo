import 'package:dashboard_admin_flutter/Utils/Drive%20Api/GoogleDrive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import '../../Objetos/AgendadoServicio.dart';
import '../../Utils/Disenos.dart';
import '../../Utils/Firebase/Load_Data.dart';
import '../../Utils/Firebase/StreamBuilders.dart';

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
    nombretutor = datos_tutor['nametutor'];
    idcarpeta = datos_tutor['idcarpeta'];
    print("agenda tutores la verga");
    print(nombretutor);
  }


  @override
  Widget build(BuildContext context) {
    final currentwidth = MediaQuery.of(context).size.width;
    final tamano = currentwidth/2-100;
    return Row(
      children: [
        PrimaryColumn(nombretutor: nombretutor,idcarpeta: idcarpeta,currentwidth: tamano,),
      ],
    );
  }

}

class PrimaryColumn extends StatefulWidget{
  final String nombretutor;
  final String idcarpeta;
  final double currentwidth;

  const PrimaryColumn({Key?key,
    required this.nombretutor,
    required this.idcarpeta,
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


  @override
  void initState() {
    loaddata();
    super.initState();
  }

  Future<void> loaddata() async{
    serviciosListTutor= await stream_builders().cargaragendatutor();
    DateTime fechaLimite = DateTime(2023, 9, 29);
    serviciosListTutor = serviciosListTutor?.where((servicio) {
      if (servicio.entregadotutor != "ENTREGADO" && servicio.fechasistema != null) {
        DateTime fechasistema = servicio.fechasistema;
        return fechasistema.isAfter(fechaLimite);
      }
      return false;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.currentwidth,
      child: Column(
        children: [
          Text('Entrega tutores'),
          //Autosuggest
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
            Column(
              children: selectedFiles!.map((file) {
                return Container(
                  width: widget.currentwidth,
                  height: 70,
                  color: Colors.blue,
                  child: Text(file.name),
                );
              }).toList(),
            ),
          if(subiendoentrega == true)
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
              child: Text('Subir archivos'), onPressed:() async{
            setState(() {
              textoestado = "Archivos subiendose ..., espere mensaje de confirmación";
              subiendoentrega = true;
            });
            await DriveApi().entrega_tutor(widget.idcarpeta, widget.nombretutor,selectedServicio!.codigo,selectedFiles,context);
            setState(() {
              selectedFiles = [];
              selectedServicio = null;
              textoestado = "SUBIDO COMPLETO";
            });
          }),
          Text("Aqui solo sale lo que no has entregado"),
        ],
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
