import 'package:dashboard_admin_flutter/Config/strings.dart';
import 'package:dashboard_admin_flutter/Config/theme.dart';
import 'package:dashboard_admin_flutter/Objetos/Clientes.dart';
import 'package:dashboard_admin_flutter/Providers/Providers.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import '../../Config/Config.dart';
import '../../Config/elements.dart';
import '../../Objetos/Objetos Auxiliares/Carreras.dart';
import '../../Objetos/Objetos Auxiliares/Materias.dart';
import '../../Objetos/Objetos Auxiliares/Universidad.dart';
import '../../Objetos/Solicitud.dart';
import '../../Objetos/Tutores_objet.dart';
import '../../Utils/Disenos.dart';
import '../../Utils/Firebase/Uploads.dart';
import 'package:flutter/material.dart' as dialog;

//DIALOGOS AGREGAR NUEVO PROSPECTO CLIENTE

class SolicitudesDialog extends StatefulWidget {

  const SolicitudesDialog({Key?key,
  }) :super(key: key);

  @override
  _SolicitudesDialogState createState() => _SolicitudesDialogState();
}

class _SolicitudesDialogState extends State<SolicitudesDialog> {
  String nombrewasacliente = "PROSPECTO CLIENTE";
  String nombreCompleto = "";
  int numwasaCliente = 0;
  Carrera? selectedCarreraobject;
  Universidad? selectedUniversidadobject;
  List<String> EstadoList = ['FACEBOOK','WHATSAPP','REFERIDO AMIGO','INSTAGRAM','CAMPAÑA INSTAGRAM',];
  String? selectedProcedencia;
  List<Clientes> clienteList = [];

  @override
  Widget build(BuildContext context) {
    return Container(
      child: GestureDetector(
      child: Container(
          height: 30,
          width: 30,
          decoration: BoxDecoration(
            color: Config.secundaryColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(FluentIcons.add,
            color: Config().primaryColor,
            weight: 30,)),
      onTap: (){
        _showDialog(context);
      },
    ),);
  }

  void _showDialog(BuildContext context)  {
    showDialog(
      context: context,
      builder: (context) {
        return Consumer3<CarrerasProvider, UniversidadVistaProvider,ClientesVistaProvider>(
          builder: (context, carreraProviderselect, universidadProviderselect,clienteProviderselect ,child) {
            List<Carrera> carreraList = carreraProviderselect.todosLasCarreras;
            List<Universidad> universidadList = universidadProviderselect.todasLasUniversidades;
            clienteList = clienteProviderselect.todosLosClientes;

            return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return ContentDialog(
                  title: const Text('Agregar Prospecto'),
                  content: Column(
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          //NOMBRE WSP CLIENTE
                          Text('PROSPECTO CLIENTE'),
                          //Nombre Completo
                          Container(
                            width: 200,
                            child: TextBox(
                              placeholder: 'Nombre Completo',
                              onChanged: (value){
                                setState(() {
                                  nombreCompleto = value;
                                });
                              },
                              maxLines: null,
                            ),
                          ),
                          //Num de cliente
                          Container(
                            width: 200,
                            child: TextBox(
                              placeholder: 'Num de cliente',
                              onChanged: (value){
                                setState(() {
                                  numwasaCliente = int.parse(value);
                                });
                              },
                              maxLines: null,
                            ),
                          ),
                          //Carrera
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Carrera'),
                              Container(
                                height: 30,
                                width: 200,
                                child: AutoSuggestBox<Carrera>(
                                  items: carreraList.map<AutoSuggestBoxItem<Carrera>>(
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
                              AgregarCarreraDialog(carreraList: carreraList, universidadList: universidadList,CarreUniver: "CARRERA"),
                            ],
                          ),
                          //Universidad
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Universidad'),
                              Container(
                                height: 30,
                                width: 200,
                                child: AutoSuggestBox<Universidad>(
                                  items: universidadList.map<AutoSuggestBoxItem<Universidad>>(
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
                              AgregarCarreraDialog(carreraList: carreraList, universidadList: universidadList,CarreUniver: "UNIVERSIDAD"),
                            ],
                          ),
                          //Lista de procedencia del cliente
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
                                  selectedProcedencia = item.value;
                                });
                              },
                              decoration: Disenos().decoracionbuscador(),
                              placeholder: 'Procedencia',
                              onChanged: (text, reason) {
                                if (text.isEmpty ) {
                                  setState(() {
                                    selectedProcedencia = null; // Limpiar la selección cuando se borra el texto
                                  });
                                }
                              },
                            ),
                          ),

                        ],
                      ),
                    ],
                  ),
                  actions: [
                    Button(
                      child: const Text('Agregar Cliente'),
                      onPressed: () async{
                        validar_antes_de_subir_cliente(context);
                      },
                    ),
                    FilledButton(
                      child: const Text('Cancel'),
                      onPressed: () => Navigator.pop(context, 'User canceled dialog'),
                    ),
                  ],
                );
              },
            );

          },
        );
      },
    );
  }

  Future<void> validar_antes_de_subir_cliente(BuildContext context) async {
    String universidad = selectedUniversidadobject?.nombreuniversidad ?? "NO REGISTRADO";
    String carrera = selectedCarreraobject?.nombrecarrera ?? "NO REGISTRADO";
    String procedencia = selectedProcedencia ?? "";

    UtilDialogs dialogs = UtilDialogs(context : context);

    if(nombreCompleto == "" || numwasaCliente == "" || carrera == "" || universidad == "" || procedencia == ""){
      dialogs.error(Strings().errroDebeLLenarTodo,Strings().errorglobalText);
    }else if(clienteList.any((cliente) => cliente.numero.toString() == numwasaCliente.toString())){
      dialogs.error(Strings().errorClienteIgual,Strings().errorglobalText);
    }else{
      await Uploads().addCliente(carrera, universidad, nombrewasacliente, numwasaCliente,nombreCompleto,procedencia);
      Navigator.pop(context);
    }
  }
}

//AGREGAR CARRERAS DIALOGOS

class AgregarCarreraDialog extends StatefulWidget {
  final List<Carrera> carreraList;
  final List<Universidad> universidadList;
  final String CarreUniver;

  const AgregarCarreraDialog({Key?key,
    required this.carreraList,
    required this.universidadList,
    required this.CarreUniver,
  }) :super(key: key);

  @override
  _AgregarCarreraDialogState createState() => _AgregarCarreraDialogState();
}

class _AgregarCarreraDialogState extends State<AgregarCarreraDialog> {
  String agregarcarrera = "";
  String agregaruniversidad = "";

  @override
  Widget build(BuildContext context) {
    return Container(child: GestureDetector(
      child: Container(
          height: 30,
          width: 30,
          decoration: BoxDecoration(
            color: Config.secundaryColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(FluentIcons.add,
            color: Config().primaryColor,
            weight: 30,)),
      onTap: (){
        _showDialog(context);
      },
    ),);
  }

  void _showDialog(BuildContext context)  {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return ContentDialog(
              title: const Text('Agregar Prospecto'),
              content: Column(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      //UNIVERSIDAD
                      if(widget.CarreUniver=="UNIVERSIDAD")
                      Column(
                        children: [
                          Text('Agregar universidad'),
                          //Agregar universidad
                          Container(
                            width: 200,
                            child: TextBox(
                              placeholder: 'Agregar universidad',
                              onChanged: (value){
                                setState(() {
                                  agregaruniversidad = value;
                                });
                              },
                              maxLines: null,
                            ),
                          ),
                        ],
                      ),
                      if(widget.CarreUniver=="CARRERA")
                      //CARRERA
                      Column(
                        children: [
                          Text('Agregar carrera'),
                          //Agregar carrera
                          Container(
                            width: 200,
                            child: TextBox(
                              placeholder: 'Agregar agregarcarrera',
                              onChanged: (value){
                                setState(() {
                                  agregarcarrera = value;
                                });
                              },
                              maxLines: null,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                Button(
                  child: const Text('Agregar Cliente'),
                  onPressed: () async{
                    validar_antes_de_subir();
                  },
                ),
                FilledButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.pop(context, 'User canceled dialog'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> validar_antes_de_subir() async {
    if(widget.CarreUniver == "UNIVERSIDAD"){
      await Uploads().addUniversidad(agregaruniversidad);
    }else{
      await Uploads().addCarrera(agregarcarrera);
    }
    Navigator.pop(context, 'User deleted file');
  }
}

//DIALOGO DE TUTORES

class TutoresDialog extends StatefulWidget {
  final Tutores tutor;
  final List<Materia> materiasList;

  const TutoresDialog({Key?key,
    required this.tutor,
    required this.materiasList,
  }) :super(key: key);

  @override
  _TutoresDialogState createState() => _TutoresDialogState();
}

class _TutoresDialogState extends State<TutoresDialog> {
  String? selectedTipoCuenta;
  List<String> tipoCuentaList = ['NEQUI','PAYPAL','BANCOLOMBIA','DAVIPLATA','BINANCE'];
  String numeroCuenta = "";
  String cedula = "";
  String nombreCedula = "";
  List<Materia> materiaList = [];
  Materia? selectedMateria;

  @override
  Widget build(BuildContext context) {
    return Container(child: GestureDetector(
      child: Container(
          height: 30,
          width: 30,
          decoration: BoxDecoration(
            color: Config.secundaryColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(FluentIcons.add,
            color: Config().primaryColor,
            weight: 30,)),
      onTap: (){
        _showDialog(context);
      },
    ),);
  }

  void _showDialog(BuildContext context)  {
    final currentwidth = MediaQuery.of(context).size.width;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return ContentDialog(
              title: const Text('INFO DEL TUTOR'),
              content: Column(
                children: [
                  Text('Nombre de tutor ${widget.tutor.nombrewhatsapp}'),
                  const Text('Materias manejadas'),
                  SizedBox(
                    height: 200,
                    child: ListView.builder(
                        itemCount: widget.tutor.materias.length,
                        itemBuilder: (context, subindex){
                          Materia materia = widget.tutor.materias[subindex];

                          return Column(
                            children: [
                              Text(materia.nombremateria),
                            ],
                          );
                        }

                    ),
                  ),
                  const Text('Registro de cuentas'),
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
                        Navigator.pop(context);
                      }),

                  //Agregar nueva matería
                  Container(
                    height: 30,
                    width: currentwidth-200,
                    child: AutoSuggestBox<Materia>(
                      items: widget.materiasList.map<AutoSuggestBoxItem<Materia>>(
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
                      onPressed: (){
                        Uploads().addMateriaTutor(widget.tutor.uid, selectedMateria!.nombremateria);
                        Navigator.pop(context);
                      }),
                ],
              ),
              actions: [
                Button(
                  child: const Text('Agregar Cliente'),
                  onPressed: () async{
                  },
                ),
                FilledButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.pop(context, 'User canceled dialog'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _truncateLabel(String label) {
    const int maxLength = 30; // Define la longitud máxima permitida para la etiqueta
    if (label.length > maxLength) {
      return label.substring(0, maxLength - 3) + '...'; // Agrega puntos suspensivos
    }
    return label;
  }

}

//Dialogo de estado de servicio

class EstadoServicioDialog extends StatefulWidget {
  final Solicitud solicitud;

  const EstadoServicioDialog({Key?key,
    required this.solicitud,
  }) :super(key: key);

  @override
  EstadoServicioDialogState createState() => EstadoServicioDialogState();
}

class EstadoServicioDialogState extends State<EstadoServicioDialog> {

  final ThemeApp themeApp = ThemeApp();
  late bool construct = false;

  @override
  void initState(){
    super.initState();
    WidgetsFlutterBinding.ensureInitialized(); // Asegura que Flutter esté inicializado
    themeApp.initTheme().then((_) {
      setState(()=>construct = true);
    });
  }

  final List<String> EstadoList = [
    'DISPONIBLE',
    'EXPIRADO',
    'ESPERANDO',
    'NO PODEMOS'
  ];
  late String? selectedEstado = "";

  @override
  Widget build(BuildContext context) {
    if(construct){
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: Container(
                height: 23,
                width: 23,
                decoration: BoxDecoration(
                  color: themeApp.whitecolor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(FluentIcons.add,
                  color: themeApp.primaryColor,
                  size: 12,
                )),
          ),
          onTap: () => _solicitud(widget.solicitud.idcotizacion, context),
        ),
      );
    }else{
      return const Center(child: dialog.CircularProgressIndicator(),);
    }
  }

  void _solicitud(int idSolicitud, BuildContext context) => showDialog(
      context: context,
      builder: (BuildContext context) => _dialogSolicitud(idSolicitud, context)
  );

  dialog.StatefulBuilder _dialogSolicitud(int idSolicitud, BuildContext context){
    return dialog.StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
      return dialog.Dialog(
        backgroundColor: themeApp.blackColor.withOpacity(0),
        child: ItemsCard(
          width: 350,
          height: 220,
          children: [
            Text("Cambiar Estado Solicitud", style: themeApp.styleText(22, true, themeApp.primaryColor),),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: ComboBox<String>(
                value: selectedEstado,
                items: EstadoList.map((String item) {
                  return ComboBoxItem<String>(
                    value: item,
                    child: Text(item),
                  );
                  }).toList(),
                onChanged: (text) => setState((){
                  selectedEstado = text;
                  print("Estado cambiado a $selectedEstado");
                }),
                placeholder: const Text('Seleccionar tipo servicio'),
              ),
            ),
            Row(
              mainAxisAlignment:  MainAxisAlignment.center,
              children: [
                PrimaryStyleButton(
                  buttonColor: themeApp.primaryColor,
                  text: 'Actualizar Estado',
                  function: () async {
                    print("actualizar estado $idSolicitud");
                    await Uploads().cambiarEstadoSolicitud(idSolicitud, selectedEstado!);
                    Navigator.pop(context, 'User canceled dialog');
                    /*
                              final ahora = DateTime.now();
                              final Duration duration = ahora.difference(fechasistema);
                              CollectionReference historialmateria = db.collection("SOLICITUDES").doc(idcotizacion.toString()).collection("HISTORIAL");
                              HistorialEstado hisotrialnuevo = HistorialEstado(selectedEstado!, duration.inMinutes, DateTime.now());
                              historialmateria.doc(selectedEstado!).set(hisotrialnuevo.toMap());
                              //Ahora de forma local, cambiemos el estado a ver

                               */
                  },
                ),
                PrimaryStyleButton(
                  buttonColor: themeApp.primaryColor,
                  text: ' Cancel ',
                  function: () => Navigator.pop(context, 'User canceled dialog'),
                ),
              ],
            )
          ],
        ),
      );
    });
  }

  String _truncateLabel(String label) {
    const int maxLength = 30; // Define la longitud máxima permitida para la etiqueta
    if (label.length > maxLength) {
      return label.substring(0, maxLength - 3) + '...'; // Agrega puntos suspensivos
    }
    return label;
  }

}