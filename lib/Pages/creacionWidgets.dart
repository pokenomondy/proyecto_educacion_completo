
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
        "RESUMEN",
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