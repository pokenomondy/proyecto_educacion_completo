import 'package:dashboard_admin_flutter/Config/theme.dart';
import 'package:dashboard_admin_flutter/Utils/Firebase/Uploads.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import '../../Config/Config.dart';
import '../../Objetos/Clientes.dart';
import '../../Objetos/Objetos Auxiliares/Carreras.dart';
import '../../Objetos/Objetos Auxiliares/Universidad.dart';
import '../../Providers/Providers.dart';
import '../../Utils/Disenos.dart';
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
    final tamanowidth = (currentwidth/2)-Config.responsivepc;
    return Row(
      children: [
        PrimaryColumnEditarClietnes(currentwidth: tamanowidth),
        SecundaryColumnEditarCliente(currentwidth: tamanowidth,),
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
  List<Clientes> clientesList = [];
  Clientes? selectedCliente;

  @override
  Widget build(BuildContext context) {
    return Consumer<ClientesVistaProvider>(
        builder: (context, clienteProviderselect, child) {
          clientesList = clienteProviderselect.todosLosClientes;

          return Container(
            height: 30,
            color: Colors.red,
            width: widget.currentwidth/2,
            child: AutoSuggestBox<Clientes>(
              items: clientesList.map<AutoSuggestBoxItem<Clientes>>(
                    (cliente) => AutoSuggestBoxItem<Clientes>(
                  value: cliente,
                  label: Utiles().truncateLabel(cliente.numero.toString() ),
                ),
              ).toList(),
              decoration: Disenos().decoracionbuscador(),
              onSelected: (item) {
                setState((){
                  //Seleccionar cliente en provider
                  selectedCliente = item.value;
                  final providerCliente = Provider.of<ClientesVistaProvider>(context, listen: false);
                  providerCliente.seleccionarCliente(selectedCliente!.numero);
                });
              },
              onChanged: (text, reason) {
                if (text.isEmpty ) {
                  setState(() {
                    selectedCliente = null;
                    final providerCliente = Provider.of<ClientesVistaProvider>(context, listen: false);
                    providerCliente.deleteClienteSeleccionado();
                  });
                }
              },
            ),
          );
        }
    );
  }


}

class SecundaryColumnEditarCliente extends StatefulWidget {
  final double currentwidth;

  const SecundaryColumnEditarCliente({Key?key,
    required this.currentwidth,
  }) :super(key: key);

  @override
  SecundaryColumnEditarClienteState createState() => SecundaryColumnEditarClienteState();
}

class SecundaryColumnEditarClienteState extends State<SecundaryColumnEditarCliente> {
  List<bool> editarcasilla = List.generate(10, (index) => false);
  List<Clientes> clientesList = [];
  Clientes? selectedCliente;
  List<Carrera> carreraList = [];
  List<Universidad> universidadList = [];
  List<String> estadoLista = [
    'FACEBOOK',
    'WHATSAPP',
    'REFERIDO AMIGO',
    'INSTAGRAM',
    'CAMPAÑA INSTAGRAM',
  ];
  String? selectedEstado;

  String? cambio ;


  @override
  Widget build(BuildContext context) {
    return Consumer3<ClientesVistaProvider,
        UniversidadVistaProvider,
        CarrerasProvider>(
        builder: (context, clienteProviderselect, universidadProviderselect,
            carreraProviderselect, child) {
          clientesList = clienteProviderselect.todosLosClientes;
          selectedCliente = clienteProviderselect.clienteSeleccionado;
          universidadList = universidadProviderselect.todasLasUniversidades;
          carreraList = carreraProviderselect.todosLasCarreras;

          if (selectedCliente!.numero == 0) {
            return Text('Seleccione algun cliente para modificar');
          } else {
            return Column(
              children: [
                textomodificableclientes(
                    0, "carerra", selectedCliente!.carrera, false),
                textomodificableclientes(
                    1, "Universidad", selectedCliente!.universidad, false),
                textomodificableclientes(
                    2, "Nombre cliente", selectedCliente!.nombrecompletoCliente,
                    true),
                textomodificableclientes(
                    3, "Numero Whatsap", selectedCliente!.numero.toString(),
                    true),
                textomodificableclientes(4, "Nombre Completo",
                    selectedCliente!.nombrecompletoCliente, false),
                textomodificableclientes(
                    5, "Procedencia", selectedCliente!.procedencia, true),
                textomodificableclientes(6, "Fecha contacto",
                    selectedCliente!.fechaContacto.toString(), true),
              ],
            );
          }
        }
    );
  }

  Widget textomodificableclientes(int index, String title, String valor, bool bool) {
    const double verticalPadding = 3.0;

    return Row(
      children: [
        if (!editarcasilla[index])
          Padding(
              padding: const EdgeInsets.all(verticalPadding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                      width: widget.currentwidth - 60,
                      padding: const EdgeInsets.only(
                          bottom: 5, right: 5, top: 5),
                      margin: const EdgeInsets.only(left: 15),
                      child: Text("$title : $valor",
                        style: ThemeApp().styleText(
                            15, false, ThemeApp().blackColor),)
                  ),
                  if(!bool)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          editarcasilla[index] =
                          !editarcasilla[index]; // Alterna entre los modos de visualización y edición
                        });
                      },
                      child: const Icon(FluentIcons.edit),
                    )
                ],
              )
          ),

        if (editarcasilla[index])
          Row(
            children: [
              //Carrera
              if(index == 0)
                Container(
                  height: 30,
                  width: 200,
                  child: AutoSuggestBox<Carrera>(
                    items: carreraList.map<AutoSuggestBoxItem<Carrera>>(
                          (carrera) =>
                          AutoSuggestBoxItem<Carrera>(
                            value: carrera,
                            label: carrera.nombrecarrera,
                          ),
                    ).toList(),
                    onSelected: (item) {
                      setState(() {
                        cambio = item.value!.nombrecarrera;
                      });
                    },
                  ),
                ),
              //Universidad
              if(index == 1)
                Container(
                  height: 30,
                  width: 200,
                  child: AutoSuggestBox<Universidad>(
                    items: universidadList.map<AutoSuggestBoxItem<Universidad>>(
                          (universidad) =>
                          AutoSuggestBoxItem<Universidad>(
                            value: universidad,
                            label: universidad.nombreuniversidad,
                          ),
                    )
                        .toList(),
                    onSelected: (item) {
                      setState(() {
                        cambio = item.value!.nombreuniversidad;
                      });
                    },
                  ),
                ),
              //Nombre
              if(index == 4)
                Container(
                  width: 100,
                  child: TextBox(
                    placeholder: valor,
                    onChanged: (value) {
                      setState(() {
                        cambio = value;
                      });
                    },
                    maxLines: null,
                  ),
                ),
              //actualizar variable
              GestureDetector(
                onTap: () async {
                  print("el index es $index y ${selectedCliente!.numero}");
                  verificarModificarCliente(index, selectedCliente!.numero);
                  setState(() {
                    editarcasilla[index] = false;
                  });
                },
                child: const Icon(FluentIcons.check_list),
              ),
              //cancelar
              GestureDetector(
                onTap: () {
                  setState(() {
                    editarcasilla[index] =
                    !editarcasilla[index]; // Alterna entre los modos de visualización y edición
                  });
                },
                child: const Icon(FluentIcons.cancel),
              )
            ],
          ),
      ],
    );
  }

  void verificarModificarCliente(int index, numerocliente) {
    print("el cambio es igual a $cambio");
    if (cambio == "") {
      print("error""");
    } else {
      Uploads().modifyCliente(index, numerocliente, cambio!);
    }
  }
}


