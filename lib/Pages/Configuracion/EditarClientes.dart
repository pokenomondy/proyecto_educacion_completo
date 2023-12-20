import 'package:dashboard_admin_flutter/Utils/Firebase/Load_Data.dart';
import 'package:fluent_ui/fluent_ui.dart';

import '../../Objetos/Clientes.dart';
import '../../Objetos/Objetos Auxiliares/Carreras.dart';
import '../../Objetos/Objetos Auxiliares/Universidad.dart';
import '../../Utils/Disenos.dart';
import '../../Utils/Firebase/Uploads.dart';
import '../../Utils/Utiles/FuncionesUtiles.dart';

class EditarClientes extends StatefulWidget {
  const EditarClientes({super.key});

  @override
  EditarClientesState createState() => EditarClientesState();
}

class EditarClientesState extends State<EditarClientes> {

  @override
  Widget build(BuildContext context) {
    final currentwidth = MediaQuery.of(context).size.width;
    final tamanowidth = (currentwidth/1.5)-30;
    return Row(
      children: [
        PrimaryColumnEditarClietnes(currentwidth: currentwidth),
      ],
    );
  }
}

class PrimaryColumnEditarClietnes extends StatefulWidget {
  final double currentwidth;

  const PrimaryColumnEditarClietnes({Key?key,
    required this.currentwidth,
  }) :super(key: key);

  @override
  PrimaryColumnEditarClietnesState createState() => PrimaryColumnEditarClietnesState();
}

class PrimaryColumnEditarClietnesState extends State<PrimaryColumnEditarClietnes> {
  List<bool> editarcasilla = [false,false,false,false,false,false,false];
  bool carguecompleta = false;
  List<Clientes> clientesList = [];
  Clientes? selectedCliente;
  List<String> valores = [];
  bool dataSearch = false;
  Carrera? selectedCarreraobject;
  List<Carrera> CarrerasList = [];
  List<Universidad> UniversidadList = [];
  Universidad? selectedUniversidadobject;
  List<String> EstadoList = ['FACEBOOK','WHATSAPP','REFERIDO AMIGO','INSTAGRAM','CAMPAÑA INSTAGRAM',];
  String? selectedEstado;

  String cambioanter = "";

  @override
  void initState() {
    loadtablas();
  }

  Future<void> loadtablas() async {
    //CarrerasList = await LoadData().obtenercarreras();
    //clientesList = await LoadData().obtenerclientes();
    //UniversidadList = await LoadData().obtenerUniversidades();

    setState(() {
      carguecompleta = true;
    });
  }

  void actualizarvalores(){
    valores.clear();
    valores.add(selectedCliente!.carrera);
    valores.add(selectedCliente!.universidad);
    valores.add(selectedCliente!.nombreCliente);
    valores.add(selectedCliente!.numero.toString());
    valores.add(selectedCliente!.nombrecompletoCliente);
    valores.add(selectedCliente!.procedencia);
    valores.add(selectedCliente!.fechaContacto.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 30,
          color: Colors.red,
          width: widget.currentwidth/2,
          child: AutoSuggestBox<Clientes>(
            items: clientesList.map<AutoSuggestBoxItem<Clientes>>(
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
                actualizarvalores();
                dataSearch = true;
              });
            },
            onChanged: (text, reason) {
              if (text.isEmpty ) {
                setState(() {
                  selectedCliente = null; // Limpiar la selección cuando se borra el texto
                  dataSearch = false;
                  valores.clear();
                });
              }
            },
          ),
        ),
        if(dataSearch==true)
          Column(
            children: [
              textomodificableclientes(0, 'carerra', false),
              textomodificableclientes(1, 'Universidad', false),
              textomodificableclientes(2, 'Nombre cliente', true),
              textomodificableclientes(3, 'Numero Whatsapp', true), //No se puede cambiar, esto esta ligado a solicitudes, se pierde eso
              textomodificableclientes(4, 'Nombre Completo', false),
              textomodificableclientes(5, 'Procedencia', true),
              textomodificableclientes(6, 'Fecha contacto', true),
            ],
          )
      ],
    );
  }

  Widget textomodificableclientes(int index,String text,bool bool){
    String? cambio = "";
    String valor = valores[index];

    if(index==0){
      cambio = selectedCarreraobject?.nombrecarrera;
    }else if(index==1){
      cambio = selectedUniversidadobject?.nombreuniversidad;
    }else if(index==5){
      cambio = selectedEstado;
    }else if(index==4){
      cambio = cambioanter.toString();
    }

    return Row(
      children: [
        if (!editarcasilla[index])
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Text("$text : $valor"),
                if(!bool)
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
          ),
        if (editarcasilla[index])
          Row(
            children: [
              if(index==0)
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
              if(index==1)
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
              if(index==4)
                Container(
                  width: 100,
                  child: TextBox(
                    placeholder: valor,
                    onChanged: (value){
                      setState(() {
                        cambioanter = value;
                        cambio = cambioanter;
                        print(value);
                      });
                    },
                    maxLines: null,
                  ),
                ),
              if(index==5)
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
              //actualizar variable
              GestureDetector(
                onTap: () async{
                  print("a cabmair $cambio");
                  await Uploads().modifyCliente(index, selectedCliente!.numero.toString(), cambio!);
                  setState(() {
                    valores[index] = cambio!;
                    editarcasilla[index] = false;  // Desactiva el modo de edición
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
          ),
      ],
    );
  }

}


