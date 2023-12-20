import 'dart:html';
import 'package:dashboard_admin_flutter/Objetos/HistorialServiciosAgendados.dart';
import 'package:dashboard_admin_flutter/Providers/Providers.dart';
import 'package:dashboard_admin_flutter/Utils/Firebase/StreamBuilders.dart';
import 'package:dashboard_admin_flutter/Utils/Utiles/FuncionesUtiles.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../Objetos/AgendadoServicio.dart';
import '../../Objetos/Objetos Auxiliares/Materias.dart';
import '../../Objetos/Tutores_objet.dart';
import '../../Utils/Disenos.dart';
import '../../Utils/Firebase/Load_Data.dart';
import '../../Utils/Firebase/Uploads.dart';
import '../../Utils/FuncionesMaterial.dart';
import 'Pagos.dart';

class ContaDash extends StatefulWidget {

  @override
  ContaDashState createState() => ContaDashState();

}

class ContaDashState extends State<ContaDash> {

  @override
  Widget build(BuildContext context) {
    final currentwidth = MediaQuery.of(context).size.width;
    final tamanowidth = (currentwidth/3)-30;
    return Container(
      child: Row(
        children: [
          PrimaryColumnContaDash(currentwidth: tamanowidth,),
          SecundaryColumnContaDash(currentwidth: tamanowidth,),
          TercerColumnContaDash(currentwidth: tamanowidth,),
        ],
      ),
    );
  }
}

class PrimaryColumnContaDash extends StatefulWidget {
  final double currentwidth;

  const PrimaryColumnContaDash({Key?key,
    required this.currentwidth,
  }) :super(key: key);

  @override
  PrimaryColumnContaDashState createState() => PrimaryColumnContaDashState();

}

class PrimaryColumnContaDashState extends State<PrimaryColumnContaDash> {
  List<bool> editarcasilla = [false, false,false,false,false,false,false,false,false,false,false,false,false];
  List<Materia> materiaList = [];
  List<String> valores = [];
  bool buscador = false;
  String datoscambiostext = "";
  Materia? selectedMateria;
  Tutores? selectedTutor;
  List<String> identificadoresList = ["T","P","Q","A"];
  String? selectedIdentificador;
  DateTime cambiarfecha = DateTime.now();
  List<Tutores> tutoresList = [];
  int valorcambio = 0;
  ServicioAgendado? servicioAgendado;

  //Pagos
  int sumaPagosClientes = 0;
  int sumaPagosTutores = 0;
  int sumaPagosReembolsoCliente = 0;
  int sumaPagosReembolsoTutores = 0;
  bool disabledbutton = false;
  Map<String, dynamic> uploadconfiguracion = {};

  @override
  void initState() {
    super.initState();
  }

  void actualizarpagosMain(ServicioAgendado codigo) async{
    //uploadconfiguracion = await Utiles().actualizarpagos(codigo, context);
    setState(() {
      sumaPagosClientes = uploadconfiguracion['sumaPagosClientes'];
      sumaPagosTutores = uploadconfiguracion['sumaPagosTutores'];
      sumaPagosReembolsoCliente = uploadconfiguracion['sumaPagosReembolsoCliente'];
      sumaPagosReembolsoTutores = uploadconfiguracion['sumaPagosReembolsoTutores'];
    });
  }



  @override
  Widget build(BuildContext context) {
    return Consumer<ContabilidadProvider>(
        builder: (context, pagosProvider, child) {
          List<ServicioAgendado> serviciosAgendadosList = pagosProvider.todoslosServiciosAgendados;

          return Column(
            children: [
                Row(
                  children: [
                    Container(
                      height: 30,
                      width: 200,
                      child: AutoSuggestBox<ServicioAgendado>(
                        items: serviciosAgendadosList.map<AutoSuggestBoxItem<ServicioAgendado>>(
                              (servicioagendado) => AutoSuggestBoxItem<ServicioAgendado>(
                            value: servicioagendado,
                            label: servicioagendado.codigo,
                            onFocusChange: (focused) {
                              if (focused) {
                                debugPrint('Focused #${servicioagendado.codigo} - ');
                              }
                            },
                          ),
                        )
                            .toList(),
                        decoration: Disenos().decoracionbuscador(),
                        onSelected: (item) {
                          setState(() {
                            servicioAgendado = item.value;
                            setState(() {
                              buscador = true;
                            });
                          });
                        },
                        onChanged: (text, reason) {
                          if (text.isEmpty ) {
                            setState(() {
                              servicioAgendado = null; // Limpiar la selección cuando se borra el texto
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
            ],
          );
        }
    );
  }

  Widget textoymodificable(String text, ServicioAgendado servicioAgendado,int index, bool bool){
    String? cambio = "";
    String valor = valores[index];

    if (index == 1) {
      if(selectedMateria!=null){
        cambio = selectedMateria?.nombremateria;
      }else{
        cambio = valor;
      }
    }else if(index == 4 ||index == 7){
      cambio = valorcambio.toString();
    }else if(index == 8){
      cambio = selectedIdentificador;
    }else if(index == 5){
      cambio = DateFormat('dd/MM/yyyy-hh:mm:ssa').format(cambiarfecha);
    }else if(index == 6){
      cambio = selectedTutor?.nombrewhatsapp;
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
              //Precio tutor y precio al cliente
              if(index == 4 || index == 7)
                Container(
                  width: 100,
                  child: TextBox(
                    placeholder: valor,
                    onChanged: (value){
                      setState(() {
                        valorcambio = int.parse(value);
                        cambio = valorcambio.toString();
                      });
                    },
                    maxLines: null,
                  ),
                ),
              //Fecha de entrega
              if(index == 5)
                selectfecha(context),
              if(index == 6)
                Container(
                  height: 30,
                  width: 300,
                  child: AutoSuggestBox<Tutores>(
                    items: tutoresList.map<AutoSuggestBoxItem<Tutores>>(
                          (tutor) => AutoSuggestBoxItem<Tutores>(
                        value: tutor,
                        label: _truncateLabel(tutor.nombrewhatsapp),
                        onFocusChange: (focused) {
                          if (focused) {
                            debugPrint('Focused #${tutor.nombrewhatsapp} - ');
                          }
                        },
                      ),
                    )
                        .toList(),
                    decoration: Disenos().decoracionbuscador(),
                    onSelected: (item) {
                      setState(() {
                        print("seleccionado ${item.label}");
                        selectedTutor = item.value; // Actualizar el valor seleccionado
                      });
                    },
                    onChanged: (text, reason) {
                      if (text.isEmpty ) {
                        setState(() {
                          selectedTutor = null; // Limpiar la selección cuando se borra el texto
                        });
                      }
                    },
                  ),
                ),
              //Lista materias
              if(index == 1)
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
              //Lista identificador codigo
              if(index == 8)
                Container(
                  height: 30,
                  width: 300,
                  child: AutoSuggestBox<String>(
                    items: identificadoresList.map((servicio) {
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
                      setState(() => selectedIdentificador = item.value);
                    },
                    decoration: Disenos().decoracionbuscador(),
                    placeholder: 'Selecciona tu servicio',
                    onChanged: (text, reason) {
                      if (text.isEmpty ) {
                        setState(() {
                          selectedIdentificador = null; // Limpiar la selección cuando se borra el texto
                        });
                      }
                    },
                  ),
                ),
              //actualizar variable
              GestureDetector(
                onTap: () async{
                  comprobaractualziardatos(index,cambio!,valor,valorcambio);
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

  void comprobaractualziardatos(int index,String cambio,String valor, int valorcambio,) async{
    int pagocliente = sumaPagosClientes-sumaPagosReembolsoCliente;
    int pagoTutor = sumaPagosTutores-sumaPagosReembolsoTutores;
    if(index == 1 && cambio == valor){
      Utiles().notificacion("Selecciona una materia", context, false,"desp");
    }else if(index == 4 && sumaPagosClientes>0){
      if(valorcambio < pagocliente ){
        Utiles().notificacion("No se puede cambiar, porque el precio es < al pagado", context, false,"desp");
      }else{
        Utiles().notificacion("CAMBIANDO PRECIO", context, true,"desp");
        _cambiarprecio(index, valor, cambio, valorcambio);
      }
    }else if(index == 7 && sumaPagosTutores>0){
      if(valorcambio < pagoTutor){
        Utiles().notificacion("No se puede editar el precio porque hay pagos", context, false,"desp");
      }else{
        Utiles().notificacion("CAMBIANDO PRECIO", context, true,"desp");
        _cambiarprecio(index, valor, cambio, valorcambio);
      }
    } else{
      _cambiarprecio(index, valor, cambio, valorcambio);
    }
  }

  Future<void> _cambiarprecio(int index,String valor,String cambio,int valorcambio) async{
    await Uploads().modifyServicioAgendado(index, servicioAgendado!.codigo, cambio!,valor!,valorcambio,cambiarfecha);
    setState(() {
      valores[index] = cambio!;
      editarcasilla[index] = false;  // Desactiva el modo de edición
    });
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
              final date = await Utiles().pickDate(context,cambiarfecha);
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

class SecundaryColumnContaDash extends StatefulWidget {
  final double currentwidth;

  const SecundaryColumnContaDash({Key?key,
    required this.currentwidth,
  }) :super(key: key);

  @override
  SecundaryColumnContaDashState createState() => SecundaryColumnContaDashState();

}

class SecundaryColumnContaDashState extends State<SecundaryColumnContaDash> {

  @override
  Widget build(BuildContext context) {
    return Consumer<ContabilidadProvider>(
        builder: (context, historialProvider, child) {
          List<HistorialAgendado> historialDelServicioSeleccionado = historialProvider.historialDelServicioSeleccionado;
          return Container(
            color: Colors.green,
            width: widget.currentwidth,
            child: Column(
              children: [
                Text('Aquí tenemos historial'),
                  Column(
                    children: [
                      Container(
                        height: 800,
                        child: ListView.builder(
                          itemCount: historialDelServicioSeleccionado.length,
                          itemBuilder: (context, index) {
                            HistorialAgendado historialcod = historialDelServicioSeleccionado[index];

                            return Container(
                              height: 100,
                              child: Card(
                                child: Column(
                                  children: [
                                    Text(historialcod.codigo),
                                    Text("CAMBIO DE ${historialcod.motivocambio} ${historialcod.cambioant} por ${historialcod.cambionew}")
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          );
        }
    );
  }
}

class TercerColumnContaDash extends StatefulWidget {
  final double currentwidth;

  const TercerColumnContaDash({Key?key,
    required this.currentwidth,
  }) :super(key: key);

  @override
  TercerColumnContaDashState createState() => TercerColumnContaDashState();

}

class TercerColumnContaDashState extends State<TercerColumnContaDash> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}






