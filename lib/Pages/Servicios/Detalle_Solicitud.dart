import 'package:dashboard_admin_flutter/Objetos/Solicitud.dart';
import 'package:dashboard_admin_flutter/Utils/Drive%20Api/GoogleDrive.dart';
import 'package:dashboard_admin_flutter/Utils/Firebase/Load_Data.dart';
import 'package:dashboard_admin_flutter/Utils/Firebase/Uploads.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:googleapis/drive/v2.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart' as dialog;
import '../../Objetos/Objetos Auxiliares/Materias.dart';
import '../../Utils/Disenos.dart';
import '../../Utils/FuncionesMaterial.dart';
import '../../Utils/Drive Api/GoogleDrive.dart';

class DetallesServicio extends StatefulWidget {
  final Solicitud solicitud;

  const DetallesServicio({Key?key,
    required this.solicitud,
  }) :super(key: key);

  @override
  DetallesServicioState createState() => DetallesServicioState();
}

class DetallesServicioState extends State<DetallesServicio> {


  @override
  Widget build(BuildContext context) {
    final currentwidth = MediaQuery.of(context).size.width;
    final tamanowidth = currentwidth/2 -30;
    return Row(
      children: [
        PrimaryColumn(solicitud: widget.solicitud,currentwith: tamanowidth,),
        SecundaryColumn(solicitud: widget.solicitud, currentwith: tamanowidth)
      ],
    );
  }

}

class PrimaryColumn extends StatefulWidget {
  final Solicitud solicitud;
  final double currentwith;

  const PrimaryColumn({Key?key,
    required this.solicitud,
    required this.currentwith,
  }) :super(key: key);

  @override
  PrimaryColumnState createState() => PrimaryColumnState();

}

class PrimaryColumnState extends State<PrimaryColumn> {
  String servicio = "";
  List<bool> editarcasilla = [false, false,false,false,false,false,false,false,false,false];
  List<String> serviciosList = ['PARCIAL','TALLER','QUIZ','ASESORIAS'];
  String? selectedServicio;
  Materia? selectedMateria;
  List<Materia> materiaList = [];
  List<String> valores = [];
  String datoscambiostext = "";
  DateTime cambiarfecha = DateTime.now();

  @override
  void initState() {
    valores.add(widget.solicitud.servicio);
    valores.add(widget.solicitud.idcotizacion.toString());
    valores.add(widget.solicitud.materia);
    valores.add("${DateFormat("dd/MM").format(widget.solicitud.fechaentrega)} ANTES DE ${DateFormat('hh:mma').format(widget.solicitud.fechaentrega)}");
    valores.add(widget.solicitud.cliente.toString());
    valores.add("${DateFormat("dd/MM").format(widget.solicitud.fechasistema)} A LAS ${DateFormat('hh:mma').format(widget.solicitud.fechasistema)}");
    valores.add(widget.solicitud.estado);
    valores.add(widget.solicitud.resumen);
    valores.add(widget.solicitud.infocliente);
    valores.add(widget.solicitud.urlArchivos);
    loadtablas();
    cambiarfecha = widget.solicitud.fechaentrega;
    super.initState();
  }

  Future loadtablas() async{
    materiaList = await LoadData().tablasmateria();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.red,
      width: widget.currentwith,
      child: Column(
        children: [
          textoymodificable('Tipo de servicio',widget.solicitud,servicio,0,false,),
          textoymodificable('Id cotización ',widget.solicitud,servicio,1,true),
          textoymodificable('Matería  ',widget.solicitud,servicio,2,false),
          textoymodificable('Fecha de entrega  ',widget.solicitud,servicio,3,false),
          textoymodificable('Cliente  ',widget.solicitud,servicio,4,true),
          textoymodificable('fecha sistema  ',widget.solicitud,servicio,5,true),
          textoymodificable('Estado  ',widget.solicitud,servicio,6,true),
          textoymodificable('Resumen  ',widget.solicitud,servicio,7,false),
          textoymodificable('Info cliente ',widget.solicitud,servicio,8,false),
          textoymodificable('url archivos ',widget.solicitud,servicio,9,true),
        ],
      ),
    );
  }

  Widget textoymodificable(String text, Solicitud solicitud, String servicio,int index, bool bool){
    String? cambio = "";
    String valor = valores[index];

    if (index == 0) {
      cambio = selectedServicio;
    } else if (index == 1) {
    } else if (index == 2) {
      cambio = selectedMateria?.nombremateria;
    } else if (index == 3) {
      cambio = "";
    } else if (index == 4) {
    } else if (index == 5) {
    } else if (index == 6) {
    } else if (index == 7) {
      cambio = datoscambiostext;
    } else if (index == 8) {
      cambio = datoscambiostext;
    } else if (index == 9) {
    }

    return Row(
      children: [
        if (!editarcasilla[index])
          Padding(
            padding: const EdgeInsets.all(12.0),
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
              if(index == 7 || index == 8)
                Container(
                  width: 100,
                  child: TextBox(
                    placeholder: valor,
                    onChanged: (value){
                      setState(() {
                        datoscambiostext = value;
                      });
                    },
                    maxLines: null,
                  ),
                ),
              if(index == 0 )
                Container(
                  width: 300,
                  child: AutoSuggestBox<String>(
                    items: serviciosList.map((servicio) {
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
              if(index == 2)
                Container(
                  height: 30,
                  width: 300,
                  child: AutoSuggestBox<Materia>(
                    items: materiaList.map<AutoSuggestBoxItem<Materia>>(
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
              if(index == 3)
                Container(
                    child: selectfecha(context)),
              //actualizar variable
              GestureDetector(
                onTap: () async{
                  await Uploads().modifyServiciosolicitud(index, cambio!, cambiarfecha,solicitud.idcotizacion);
                  setState(() {
                    if(index !=3){
                      valores[index] = cambio!;
                    }else{
                      valores[index] = "${DateFormat("dd/MM").format(cambiarfecha)} ANTES DE ${DateFormat('hh:mma').format(cambiarfecha)}";
                    }
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
          ),
      ],
    );
  }

  String _truncateLabel(String label) {
    const int maxLength = 30; // Define la longitud máxima permitida para la etiqueta
    if (label.length > maxLength) {
      return label.substring(0, maxLength - 3) + '...'; // Agrega puntos suspensivos
    }
    return label;
  }

  Column selectfecha(BuildContext context){
    return Column(
      children: [
        Container(
          child: GestureDetector(
            onTap: () async{
              final date = await FuncionesMaterial().pickDate(context,cambiarfecha);
              if(date == null) return;

              final newDateTime = DateTime(
                date.year,
                date.month,
                date.day,
                cambiarfecha.hour,
                cambiarfecha.minute,
              );

              setState( () =>
              cambiarfecha = newDateTime
              );
            },
            child: Disenos().fecha_y_entrega('${cambiarfecha.day}/${cambiarfecha.month}/${cambiarfecha.year}',400),
          ),
        ),
        Container(
          child: GestureDetector(
            onTap: () async {
              final time = await FuncionesMaterial().pickTime(context,cambiarfecha);
              if (time == null) return;

              final newDateTime = DateTime(
                cambiarfecha.year,
                cambiarfecha.month,
                cambiarfecha.day,
                time.hour,
                time.minute,
              );
              setState(() =>
              cambiarfecha = newDateTime
              );
              final formattedTime = DateFormat('hh:mm a').format(cambiarfecha);
              print(formattedTime);
            },
            child: Disenos().fecha_y_entrega(DateFormat('hh:mm  a').format(cambiarfecha), 400),
          ),
        ),
      ],
    );
  }

  }

class SecundaryColumn extends StatefulWidget {
  final Solicitud solicitud;
  final double currentwith;

  const SecundaryColumn({Key?key,
    required this.solicitud,
    required this.currentwith,
  }) :super(key: key);

  @override
  SecundaryColumnState createState() => SecundaryColumnState();

}

class SecundaryColumnState extends State<SecundaryColumn> {
  List<ArchivoResultado> archivosresultados = [];


  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue,
      width: widget.currentwith,
      child: Column(
        children: [
          //Generar lista de archivos que hay en la carpeta de esta solicitud
          FilledButton(child: Text('vericiar'), onPressed: (){
            DriveApiUsage().viewarchivosolicitud(widget.solicitud.idcotizacion);
          }),
          FutureBuilder(
              future: DriveApiUsage().viewarchivosolicitud(widget.solicitud.idcotizacion),
              builder: (context,snapshot){
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // Mientras se espera, mostrar un mensaje de carga
                  return const Center(
                    child: Text('cargando'), // O cualquier otro widget de carga
                  );
                } else if (snapshot.hasError) {
                  // Si ocurre un error en el Future, mostrar un mensaje de error
                  return const Center(
                    child: Text("Error al cargar los datos"),
                  );
                } else {
                  List<ArchivoResultado>? archivosList = snapshot.data;

                  return _TarjetaArchivos(archivosList: archivosList);
                }
              }),
        ],
      ),
    );
  }
}

class _TarjetaArchivos extends StatefulWidget{
  final List<ArchivoResultado>? archivosList;

  const _TarjetaArchivos({Key?key,
    required this.archivosList,
  }) :super(key: key);

  @override
  _TarjetaArchivosState createState() => _TarjetaArchivosState();

}

class _TarjetaArchivosState extends State<_TarjetaArchivos> {
  @override
  Widget build(BuildContext context) {
    final currentheight = MediaQuery.of(context).size.height;
    return Column(
      children: [
        Text("hay ${widget.archivosList?.length.toString()} archivos"),
        SizedBox(
            height: currentheight-90,
            child: ListView.builder(
                itemCount: widget.archivosList?.length,
                itemBuilder: (context,index) {
                  ArchivoResultado? archivo = widget.archivosList?[index];

                  return GestureDetector(
                    onTap: (){
                      print("te toco");
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5,horizontal: 8),
                      child: Card(
                        child:Column(
                          children: [
                            //nombre del archivo
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(child: Text(archivo!.nombrearchivo)),
                              ],
                            ),
                            //extension de pdf
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(child: Text(archivo!.mimeType)),
                              ],
                            ),
                            //id de archivo
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(child: Text(archivo!.id)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }
            )
        ),
      ],
    );
  }
}

