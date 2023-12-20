import 'package:dashboard_admin_flutter/Objetos/Objetos%20Auxiliares/Carreras.dart';
import 'package:dashboard_admin_flutter/Utils/Firebase/Uploads.dart';
import 'package:fluent_ui/fluent_ui.dart';

import '../../Objetos/Objetos Auxiliares/Universidad.dart';
import '../../Utils/Disenos.dart';
import '../../Utils/Firebase/Load_Data.dart';
import '../../Utils/Utiles/FuncionesUtiles.dart';

class AgregarVariables extends StatefulWidget {
  const AgregarVariables({super.key});

  @override
  AgregarVariablesState createState() => AgregarVariablesState();
}

class AgregarVariablesState extends State<AgregarVariables> {

  @override
  Widget build(BuildContext context) {
    final currentwidth = MediaQuery.of(context).size.width;
    final tamanowidth = (currentwidth/1.5)-30;
    return PrimaryColumnVariables(currentwidth: currentwidth);
  }
}

class PrimaryColumnVariables extends StatefulWidget {
  final double currentwidth;

  const PrimaryColumnVariables({Key?key,
    required this.currentwidth,
  }) :super(key: key);

  @override
  PrimaryColumnVariablesState createState() => PrimaryColumnVariablesState();
}

class PrimaryColumnVariablesState extends State<PrimaryColumnVariables> {
  String newMateria = "";
  String newCarrera = "";
  String newUniversidad = "";

  List<Carrera> CarrerasList = [];
  List<Universidad> UniversidadList = [];

  //nuevo prospecto d ecliente
  Carrera? selectedCarreraobject;
  Universidad? selectedUniversidadobject;
  String nombreclientewasa = "";
  int numero = 0;
  String nombrecompletocliente = "";
  DateTime fechaActual = DateTime.now();
  String procedencia = "";
  List<String> EstadoList = ['FACEBOOK','WHATSAPP','REFERIDO AMIGO','INSTAGRAM','CAMPAÑA INSTAGRAM',];
  String? selectedEstado;
  bool carguecompleta = false;

  @override
  void initState() {
    loadtablas();
  }

  Future<void> loadtablas() async {
    //CarrerasList = await LoadData().obtenercarreras();
    //UniversidadList = await LoadData().obtenerUniversidades();
    setState(() {
      carguecompleta = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentwidth = MediaQuery
        .of(context)
        .size
        .width;
    final tamanowidth = (currentwidth / 1.5) - 30;
    return Column(
      children: [
        subirvariable("SUBIR NUEVA MATERIA :", (value) => newMateria = value,"MATERIA"),
        Text("Por aca va una lista de las materias con un buscador"),

        subirvariable("SUBIR NUEVA CARRERA", (value) => newCarrera = value, "CARRERA"),
        Text("Lista de carraras"),

        subirvariable("SUBIR NUEVA UNIVERSIDAD", (value) => newUniversidad = value, "UNIVERSIDAD"),
        Text("Lista de universidad"),

        subirCliente('Prospectos subir'),
      ],
    );
  }

  Widget subirvariable(String titulo, Function(String) onChanged, String motivo) {

    return Row(
      children: [
        Text(titulo),
        Container(
          width: 500,
          child: TextBox(
            onChanged: onChanged,
            maxLines: null,
          ),
        ),
        FilledButton(child: Text("Subir"), onPressed: (){
          if(motivo=="MATERIA"){
            comprobarmateriasubida();
          }else if(motivo == "CARRERA"){
            comprobacioncarrerasubida();
          }else if(motivo == "UNIVERSIDAD"){
            comprobacionuniversidadsubida();
          }
        })
      ],
    );
  }

  Widget subirCliente(String titulo) {

    return Column(
      children: [
        Text("Subir nuevo prospecto"),
        //nombre cliente whatsapp
        Container(
          width: 500,
          child: TextBox(
            placeholder: 'Nombre wsp del cliente',
            maxLines: null,
            onChanged: (value){
              setState(() {
                nombreclientewasa = value;
              });
            },
          ),
        ),
        if(carguecompleta==true)
          Column(
            children: [
              //carrera
              Container(
                height: 30,
                width: 200,
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
                      selectedCarreraobject = item.value; // Actualizar el valor seleccionado
                    });
                  },
                ),
              ),
              //universidad
              Container(
                height: 30,
                width: 200,
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
                      print("seleccionado ${item.label}");
                      selectedUniversidadobject = item.value; // Actualizar el valor seleccionado
                    });
                  },
                ),
              ),
            ],
          ),
        //numero cliente
        Container(
          width: 500,
          child: TextBox(
            placeholder: 'Numero del cliente',
            maxLines: null,
            onChanged: (value){
              setState(() {
                numero = int.parse(value);
              });
            },
          ),
        ),
        //nocmbre completo cliente
        Container(
          width: 500,
          child: TextBox(
            placeholder: 'Nombre completo del cliente',
            maxLines: null,
            onChanged: (value){
              setState(() {
                nombrecompletocliente = value;
              });
            },
          ),
        ),
        //lista de donde viene el cliente
        Container(
          child: AutoSuggestBox<String>(
            items: EstadoList.map((servicio) {
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
              setState(() {
                selectedEstado = item.value;
                procedencia = item.value!;
              });
            },
            decoration: Disenos().decoracionbuscador(),
            placeholder: 'Procedencia',
            onChanged: (text, reason) {
              if (text.isEmpty ) {
                setState(() {
                  selectedEstado = null; // Limpiar la selección cuando se borra el texto
                });
              }
            },
          ),
        ),

        FilledButton(child: Text("Subir cliente"), onPressed: (){
          comprobarclientessubida();
        })
      ],
    );
  }

  void comprobarclientessubida(){
    String? carrerita = "";
    String? universidadcita = "";

    if(selectedCarreraobject==null){
      carrerita = "";
    }else{
      carrerita = selectedCarreraobject!.nombrecarrera;
    }
    if(selectedUniversidadobject==null){
      universidadcita = "";
    }else{
      universidadcita = selectedUniversidadobject!.nombreuniversidad;
    }

    print("a subir cosas");
    if(numero == 0 && selectedEstado == ""){
      print("no dejar subir");
    }else{
      Uploads().addCliente(carrerita, universidadcita, nombreclientewasa, numero, nombrecompletocliente, procedencia);
      print("$carrerita , $universidadcita , $nombreclientewasa , $numero , $nombrecompletocliente , $procedencia");
    }

  }

  void comprobarmateriasubida(){
    if(newMateria!=""){
      Uploads().addnewmateria(newMateria);
      Utiles().notificacion("MATERIA AGREGADA", context, true, "descripcion");

    }else{
      Utiles().notificacion("LLENER LA MATERIA", context, false, "descripcion");
    }
  }

  void comprobacioncarrerasubida(){
    if(newCarrera!=""){
      Uploads().addCarrera(newCarrera);
      Utiles().notificacion("CARRERA AGREGADO", context, true, "descripcion");
    }else{
      Utiles().notificacion("LLENER LA CARRERA", context, false, "descripcion");
    }
  }

  void comprobacionuniversidadsubida(){
    if(newUniversidad!=""){
      Uploads().addUniversidad(newUniversidad);
      Utiles().notificacion("UNIVERSIDAD AGREGADO", context, true, "descripcion");
    }else{
      Utiles().notificacion("LLENER LA UNIVERSIDAD", context, false, "descripcion");
    }
  }
}