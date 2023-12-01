import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dashboard_admin_flutter/Pages/SolicitudesNew.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Config/Config.dart';
import '../../Objetos/Objetos Auxiliares/Carreras.dart';
import '../../Objetos/Objetos Auxiliares/HistorialEstado.dart';
import '../../Objetos/Objetos Auxiliares/Materias.dart';
import '../../Objetos/Objetos Auxiliares/Universidad.dart';
import '../../Objetos/Solicitud.dart';
import '../../Objetos/Tutores_objet.dart';
import '../../Utils/Disenos.dart';
import '../../Utils/Firebase/Uploads.dart';

//DIALOGOS AGREGAR NUEVO PROSPECTO CLIENTE

class SolicitudesDialog extends StatefulWidget {
  final List<Carrera> carreraList;
  final List<Universidad> universidadList;
  final Function() onUpdateListaClientes; // Agrega esta variable

  const SolicitudesDialog({Key?key,
    required this.carreraList,
    required this.universidadList,
    required this.onUpdateListaClientes,
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
                              items: widget.carreraList.map<AutoSuggestBoxItem<Carrera>>(
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
                          AgregarCarreraDialog(carreraList: widget.carreraList, universidadList: widget.universidadList,CarreUniver: "CARRERA",onUpdateListaClientes: widget.onUpdateListaClientes,),
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
                              items: widget.universidadList.map<AutoSuggestBoxItem<Universidad>>(
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
                          AgregarCarreraDialog(carreraList: widget.carreraList, universidadList: widget.universidadList,CarreUniver: "UNIVERSIDAD",onUpdateListaClientes: widget.onUpdateListaClientes,),
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
  }

  Future<void> validar_antes_de_subir_cliente(BuildContext context) async {
    String universidad = selectedUniversidadobject?.nombreuniversidad ?? "NO REGISTRADO";
    String carrera = selectedCarreraobject?.nombrecarrera ?? "NO REGISTRADO";

    await Uploads().addCliente(carrera, universidad, nombrewasacliente, numwasaCliente,nombreCompleto,selectedProcedencia!);
    widget.onUpdateListaClientes();
    Future.delayed(Duration(milliseconds: 500), () {
      print("actualizando tablas");
      setState(() {
        selectedUniversidadobject = null;
        selectedCarreraobject = null;
        Navigator.pop(context);
      });
    });
  }
}

//AGREGAR CARRERAS DIALOGOS

class AgregarCarreraDialog extends StatefulWidget {
  final List<Carrera> carreraList;
  final List<Universidad> universidadList;
  final String CarreUniver;
  final Function() onUpdateListaClientes; // Agrega esta variable

  const AgregarCarreraDialog({Key?key,
    required this.carreraList,
    required this.universidadList,
    required this.CarreUniver,
    required this.onUpdateListaClientes
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
    widget.onUpdateListaClientes();
    Future.delayed(Duration(milliseconds: 500), () {
      print("a actualizar tablas");
      Navigator.pop(context, 'User deleted file');
      Navigator.pop(context, 'User deleted file');
    });
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
  List<String> EstadoList = [
    'DISPONIBLE',
    'EXPIRADO',
    'ESPERANDO',
    'NO PODEMOS'
  ];
  String? selectedEstado = "";

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
        _showDialog(context,widget.solicitud.idcotizacion);
      },
    ),);
  }

  void _showDialog(BuildContext context, int idcotizacion) async {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return ContentDialog(
              title: const Text('Cambiar estado del servicio'),
              content: Column(
                children: [
                  //seleccionar estado
                  ComboBox<String>(
                    value: selectedEstado,
                    items: EstadoList.map<ComboBoxItem<String>>((e) {
                      return ComboBoxItem<String>(
                        child: Text(e),
                        value: e,
                      );
                    }).toList(),
                    onChanged: (text) {
                      setState(() {
                        selectedEstado = text; // Update the local variable
                      });
                      print("materia seleccionado $selectedEstado");
                    },
                    placeholder: const Text('Seleccionar tipo servicio'),
                  ),
                ],
              ),
              actions: [
                Button(
                  child: const Text('Actualizar Estado'),
                  onPressed: () async {
                    print("actualizar estado $idcotizacion");
                    await Uploads().cambiarEstadoSolicitud(idcotizacion, selectedEstado!);
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