import "package:dashboard_admin_flutter/Config/theme.dart";
import "package:flutter/material.dart";
import "../Config/elements.dart";

class CreacionWidgets extends StatelessWidget{
  const CreacionWidgets({super.key});

  @override
  Widget build(BuildContext context){

    return Center(
      child: PrimaryStyleButton(
        text: "Presione",
        function: (){
          UtilDialogs dialog = UtilDialogs(context: context);
          dialog.confirmar(
              "Desea confirmar?",
                  (){
                    dialog.error("Confirmado");
                  },
              (){
                dialog.error("No confirmado");
              }
          );
        },
      ),
    );
  }
}