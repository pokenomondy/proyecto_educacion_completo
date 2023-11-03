import 'package:dashboard_admin_flutter/Objetos/Tutores_objet.dart';
import 'package:fluent_ui/fluent_ui.dart';

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
    final tamanowidth = currentwidth/2 -30;
    return Row(
      children: [
        PrimaryColumnTutores(tutor: widget.tutor, currentwith: tamanowidth),
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


    return Row(
      children: [
        if (!editarcasilla[index])
          Row(
          children: [
            Text(valores[index]),
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
              //actualizar variable
              GestureDetector(
                onTap: () async{
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