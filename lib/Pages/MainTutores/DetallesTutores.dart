import 'package:dashboard_admin_flutter/Objetos/Tutores_objet.dart';
import 'package:dashboard_admin_flutter/Utils/Firebase/Load_Data.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart' as notify;
import 'package:provider/provider.dart';
import '../../Objetos/CuentasBancaraias.dart';
import '../../Objetos/Objetos Auxiliares/Carreras.dart';
import '../../Objetos/Objetos Auxiliares/Materias.dart';
import '../../Objetos/Objetos Auxiliares/Universidad.dart';
import '../../Utils/Disenos.dart';
import '../../Utils/Firebase/Uploads.dart';
import '../../Utils/Utiles/FuncionesUtiles.dart';
import '../Tutores.dart';

class DetallesTutores extends StatefulWidget {
  final Tutores tutor;

  const DetallesTutores({Key?key,
    required this.tutor,
  }) :super(key: key);

  @override
  DetallesTutoresState createState() => DetallesTutoresState();
}

class DetallesTutoresState extends State<DetallesTutores> {

  @override
  Widget build(BuildContext context) {
    final currentwidth = MediaQuery.of(context).size.width;
    final tamanowidth = currentwidth/3 -30;
    return Row(
      children: [
        PrimaryColumnTutores(tutor: widget.tutor, currentwith: tamanowidth),
        SecundaryColumnTutores(tutor: widget.tutor,currentwith: tamanowidth,),
        TercerColumnTutores(tutor: widget.tutor,currentwith: tamanowidth,)
      ],
    );
  }
}

class PrimaryColumnTutores extends StatefulWidget {
  final Tutores tutor;
  final double currentwith;

  const PrimaryColumnTutores({Key?key,
    required this.tutor,
    required this.currentwith,
  }) :super(key: key);

  @override
  PrimaryColumnTutoresState createState() => PrimaryColumnTutoresState();

}

class PrimaryColumnTutoresState extends State<PrimaryColumnTutores> {
  final GlobalKey<TutoresVistaVistaState> tutoresVistaState = GlobalKey<TutoresVistaVistaState>();
  List<String> valores = [];
  List<bool> editarcasilla = [false, false, false, false, false, false, false];
  String datoscambiostext = "";
  int numcelint = 0;
  List<Materia> materiasList = [];
  Materia? selectedMateria ;
  bool cargadotablamaterias = false;

  //Cuentas bancarias
  List<CuentasBancarias> cuentas = [];
  String? selectedTipoCuenta;
  List<String> tipoCuentaList = ['NEQUI','PAYPAL','BANCOLOMBIA','DAVIPLATA','BINANCE'];
  String numeroCuenta = "";
  String cedula = "";
  String nombreCedula = "";

  List<Carrera> CarrerasList = [];
  Carrera? selectedCarreraobject;

  List<Universidad> UniversidadList = [];
  Universidad? selectedUniversidadobject;


  @override
  void initState() {
    valores.add(widget.tutor.nombrewhatsapp);
    valores.add(widget.tutor.nombrecompleto);
    valores.add(widget.tutor.numerowhatsapp.toString());
    valores.add(widget.tutor.carrera);
    valores.add(widget.tutor.correogmail);
    valores.add(widget.tutor.univerisdad);
    valores.add(widget.tutor.activo.toString());
    loaddata();
    super.initState();
  }

  Future <void> loaddata()async{
    materiasList = await LoadData().tablasmateria();
    CarrerasList = await LoadData().obtenercarreras();
    UniversidadList = await LoadData().obtenerUniversidades();
    setState(() {
      cargadotablamaterias = true;
    });
    //materias provider
    final materiasProvider = Provider.of<MateriasProvider>(context, listen: false);
    // Eliminar todas las materias
    materiasProvider.clearMaterias();
    for (Materia materia in widget.tutor.materias) {
      materiasProvider.addMateria(materia);
    }
    //Cuentas provider
    final cuentasProvider = Provider.of<CuentasProvider>(context, listen: false);
    //eliminar primero
    cuentasProvider.clearCuentas();
    for (CuentasBancarias cuentita in widget.tutor.cuentas) {
      cuentasProvider.addCuenta(cuentita);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.red,
      width: widget.currentwith,
      child: Column(
        children: [
          textoymodificable("Nombre Whatsap", 0 , true),
          textoymodificable("Nombre Completo", 1, false),
          textoymodificable("Numero de Whatsapp", 2, false),
          textoymodificable("Carrera", 3, false),
          textoymodificable("Correo gmail", 4, true),
          textoymodificable("Universidad", 5, false),
          textoymodificable("Activo?", 6, false),
          //Agregar nueva matería
          if(cargadotablamaterias=true)
            Column(
              children: [
                Container(
                  height: 30,
                  width: widget.currentwith-50,
                  child: AutoSuggestBox<Materia>(
                    items: materiasList.map<AutoSuggestBoxItem<Materia>>(
                          (materia) => AutoSuggestBoxItem<Materia>(
                        value: materia,
                        label: materia.nombremateria,
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
                FilledButton(
                    child: const Text('Subir Matería'),
                    onPressed: () async{
                      Uploads().addMateriaTutor(widget.tutor.uid, selectedMateria!.nombremateria);
                      final materiasProvider = Provider.of<MateriasProvider>(context, listen: false);
                      materiasProvider.addMateria(selectedMateria!);
                    }),
                Text('Cuentas Bancarias'),
                ComboBox<String>(
                  value: selectedTipoCuenta,
                  items: tipoCuentaList.map<ComboBoxItem<String>>((e) {
                    return ComboBoxItem<String>(
                      value: e,
                      child: Text(e),
                    );
                  }).toList(),
                  onChanged: (text) {
                    setState(() {
                      selectedTipoCuenta = text; // Update the local variable
                    });
                  },
                  placeholder: const Text('Tipo de cuenta'),
                ),
                TextBox(
                  placeholder: 'Numero de cuenta',
                  onChanged: (value){
                    setState(() {
                      numeroCuenta = value;
                    });
                  },
                  maxLines: null,
                ),
                TextBox(
                  placeholder: 'Cedula',
                  onChanged: (value){
                    setState(() {
                      cedula = value;
                    });
                  },
                  maxLines: null,
                ),
                TextBox (
                  placeholder: 'Nombre de cedula',
                  onChanged: (value){
                    setState(() {
                      nombreCedula=value;
                    });
                  },
                  maxLines: null,
                ),
                FilledButton(
                    child: const Text('Subir cuenta'),
                    onPressed: (){
                      Uploads().addCuentaBancaria(widget.tutor.uid, selectedTipoCuenta!, numeroCuenta, cedula, nombreCedula);
                      final cuentasProvider = Provider.of<CuentasProvider>(context, listen: false);
                      cuentasProvider.addCuenta(CuentasBancarias(selectedTipoCuenta!, numeroCuenta, cedula, nombreCedula));
                    }),
              ],
            ),
        ],
      ),
    );
  }

  Widget textoymodificable(String text,int index, bool active){
    String ? cambio = "";
    int ? cambionum = 0;

    if (index == 1) {
      cambio = datoscambiostext;
    }else if(index == 2){
      cambionum = numcelint;
    }else if(index == 3){
      cambio = selectedCarreraobject?.nombrecarrera;
    }else if(index == 5) {
      cambio = selectedUniversidadobject?.nombreuniversidad;
    } else if(index == 6){
      cambio = valores[index];
    }

    return Row(
      children: [
        if (!editarcasilla[index])
          Row(
          children: [
            Container(
                width: widget.currentwith-60,
                padding: EdgeInsets.only(
                    bottom: 15, right: 10, top: 5),
                margin: EdgeInsets.only(left: 10),
                child: Text("$text : ${valores[index]}",)),
            if(!active)
              GestureDetector(
                onTap: (){
                  setState(() {
                    editarcasilla[index] = !editarcasilla[index]; // Alterna entre los modos de visualización y edición
                    if (!editarcasilla[index]) {
                      // Si se desactiva la edición, actualiza el texto original con el texto editado
                      editarcasilla[index] = editarcasilla[index]; // Alterna entre los modos de visualización y edición
                    }
                  });
                  print("oprimido para cambiar");
                },
                child: Icon(FluentIcons.edit),
              )
          ],
        ),
        if (editarcasilla[index])
          Row(
            children: [
              if(index == 1)
                Container(
                  width: 100,
                  child: TextBox(
                    placeholder: valores[index],
                    onChanged: (value){
                      setState(() {
                        datoscambiostext = value;
                      });
                    },
                    maxLines: null,
                  ),
                ),
              if(index == 2)
                Container(
                  width: 100,
                  child: TextBox(
                    placeholder: valores[index],
                    onChanged: (value){
                      setState(() {
                        numcelint = int.parse(value);
                      });
                    },
                    maxLines: null,
                  ),
                ),
              if(index == 3)
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
              if(index == 5)
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
              if(index==6)
                ToggleSwitch(
                    checked: Utiles().textoToBool(valores[index]),
                  onChanged: (bool value) {
                    setState(() {
                      valores[index] = value.toString();
                      cambio = value.toString();
                      print(cambio);
                    });
                  },),
              //actualizar variable
              GestureDetector(
                onTap: () async{
                  await Uploads().modifyinfotutor(index, cambio!, widget.tutor,cambionum!,context);
                  if(index == 2){
                    valores[index] = cambionum!.toString();
                  }else{
                    valores[index] = cambio!;
                  }
                  setState(() {
                    editarcasilla[index] = !editarcasilla[index]; // Alterna entre los modos de visualización y edición
                    if (!editarcasilla[index]) {
                      editarcasilla[index] = editarcasilla[index]; // Alterna entre los modos de visualización y edición
                    }
                  });
                },
                child: Icon(FluentIcons.check_list),
              ),
              //cancelar
              GestureDetector(
                onTap: (){
                  setState(() {
                    editarcasilla[index] = !editarcasilla[index]; // Alterna entre los modos de visualización y edición
                    if (!editarcasilla[index]) {
                      // Si se desactiva la edición, actualiza el texto original con el texto editado
                      editarcasilla[index] = editarcasilla[index]; // Alterna entre los modos de visualización y edición
                    }
                  });
                  print("oprimido para cambiar");
                },
                child: Icon(FluentIcons.cancel),
              )
            ],
          )
      ],
    );
  }


}

class SecundaryColumnTutores extends StatefulWidget {
  final Tutores tutor;
  final double currentwith;

  const SecundaryColumnTutores({Key?key,
    required this.tutor,
    required this.currentwith,
  }) :super(key: key);

  @override
  SecundaryColumnTutoresState createState() => SecundaryColumnTutoresState();

}

class SecundaryColumnTutoresState extends State<SecundaryColumnTutores> {

  void updateData() {
    setState(() {
      widget.tutor;
      widget.tutor.materias;
      print("actualizando tutor y materias, o eso se cree");
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentheight = MediaQuery.of(context).size.height-100;
    return Consumer<MateriasProvider>(
      builder: (context, materiasProvider, child) {
        return Container(
          width: widget.currentwith,
          child: ListView.builder(
            itemCount: materiasProvider.materias.length,
            itemBuilder: (context, subindex) {
              Materia materia = materiasProvider.materias[subindex];
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(materia.nombremateria),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class TercerColumnTutores extends StatefulWidget {
  final Tutores tutor;
  final double currentwith;

  const TercerColumnTutores({Key?key,
    required this.tutor,
    required this.currentwith,
  }) :super(key: key);

  @override
  TercerColumnTutoresState createState() => TercerColumnTutoresState();

}

class TercerColumnTutoresState extends State<TercerColumnTutores> {
  @override
  Widget build(BuildContext context) {
    final currentheight = MediaQuery.of(context).size.height-100;
    return Consumer<CuentasProvider>(
      builder: (context, cuentasprovider, child) {
        return Container(
          width: widget.currentwith,
          child: ListView.builder(
            itemCount: cuentasprovider.cuentas.length,
            itemBuilder: (context, subindex) {
              CuentasBancarias cuenta = cuentasprovider.cuentas[subindex];
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        Text(cuenta.nombreCuenta),
                        Text(cuenta.numeroCedula),
                        Text(cuenta.numeroCuenta),
                        Text(cuenta.tipoCuenta),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class MateriasProvider extends ChangeNotifier {
  List<Materia> materias = [];

  // Método para eliminar todas las materias
  void clearMaterias() {
    materias.clear();
    notifyListeners();
  }

  void addMateria(Materia materia) {
    materias.add(materia);
    notifyListeners(); // Notificar a los oyentes que la lista de materias ha cambiado
  }
}

class CuentasProvider extends ChangeNotifier {
  List<CuentasBancarias> cuentas = [];

  // Método para eliminar todas las materias
  void clearCuentas() {
    cuentas.clear();
    notifyListeners();
  }

  void addCuenta(CuentasBancarias cuentita) {
    cuentas.add(cuentita);
    notifyListeners(); // Notificar a los oyentes que la lista de materias ha cambiado
  }
}

