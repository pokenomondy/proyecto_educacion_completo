
import "package:flutter/material.dart";

import "../Config/elements.dart";
import "../Objetos/Solicitud.dart";

class CreacionWidgets extends StatelessWidget{
  const CreacionWidgets({super.key});

  @override
  Widget build(BuildContext context){
    final Solicitud solicitud = Solicitud(
        "SERVICIO",
        1,
        "MATERIA",
        DateTime.now(),
        "DIEGO ES HOMOSEXUAL TAREA REALIZADA, Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.",
        "INFO CLIENTE",
        0,
        DateTime.now(),
        "ESTADO",
        [],
        DateTime.now(),
        "URL ARCHIVOS",
        DateTime.now()
    );

    return Center(
      child: TarjetaSolicitudes(solicitud: solicitud,),
    );
  }
}