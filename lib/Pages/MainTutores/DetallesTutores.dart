import 'package:dashboard_admin_flutter/Objetos/Tutores_objet.dart';
import 'package:fluent_ui/fluent_ui.dart';

import '../../Objetos/Objetos Auxiliares/Materias.dart';
import '../../Utils/Disenos.dart';
import '../../Utils/Firebase/Uploads.dart';

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
        SecundaryColumnTutores(tutor: widget.tutor,currentwith: tamanowidth,)
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
  List<String> valores = [];
  List<bool> editarcasilla = [false, false,false,false,false,false,false];
  String datoscambiostext = "";
  int numcelint = 0;

  @override
  void initState() {
    valores.add(widget.tutor.nombrewhatsapp);
    valores.add(widget.tutor.nombrecompleto);
    valores.add(widget.tutor.numerowhatsapp.toString());
    valores.add(widget.tutor.carrera);
    valores.add(widget.tutor.correogmail);
    valores.add(widget.tutor.univerisdad);
    valores.add(widget.tutor.activo.toString());
    super.initState();
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
          textoymodificable("Activo?", 6, false)
        ],
      ),
    );
  }

  Widget textoymodificable(String text,int index, bool bool){
    String ? cambio = "";
    int ? cambionum = 0;

    if (index == 1) {
      cambio = datoscambiostext;
    }else if(index == 2){
      cambionum = numcelint;
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
              //actualizar variable
              GestureDetector(
                onTap: () async{
                  await Uploads().modifyinfotutor(index, cambio!, widget.tutor,cambionum!);
                  if(index == 1){
                    valores[index] = cambio!;
                  }else if(index ==2){
                    valores[index] = cambionum!.toString();
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
  @override
  Widget build(BuildContext context) {
    final currentheight = MediaQuery.of(context).size.height-100;
    return Container(
      width: widget.currentwith,
      child: Column(
        children: [
          //Agregar nueva matería
          /*
          Container(
            height: 30,
            width: widget.currentwith-50,
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

           */
          const Text('Materias manejadas}'),
          SizedBox(
            height: currentheight,
            child: ListView.builder(
                itemCount: widget.tutor.materias.length,
                itemBuilder: (context, subindex){
                  Materia materia = widget.tutor.materias[subindex];

                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(materia.nombremateria),
                      ),
                    ],
                  );
                }

            ),
          ),
        ],
      ),
    );
  }
}


