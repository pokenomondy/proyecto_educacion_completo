import 'package:dashboard_admin_flutter/Config/theme.dart';
import 'package:flutter/material.dart' as dialog;
import 'package:fluent_ui/fluent_ui.dart';

class MensajeTextBox extends StatelessWidget{

  final TextEditingController controller;
  final String placeholder;
  final double width;
  final double heigth;
  final bool solicitud;

  const MensajeTextBox({
    Key?key,
    required this.controller,
    required this.placeholder,
    this.width = 450,
    this.heigth = 150,
    this.solicitud = true,
  }):super(key: key);

  @override
  Widget build(BuildContext context){
    const double tamanio = 12;
    return SizedBox(
      width: width,
      child: Column(
        children: [
          botones(tamanio),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            width: width,
            height: heigth,
            child: TextBox(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20)
              ),
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
              textAlignVertical: TextAlignVertical.top,
              placeholder: placeholder,
              controller: controller,
              maxLines: null,
            ),
          ),
        ]
      ),
    );
  }

  Column botones(double tamanio){
    if(solicitud){
      return Column(
        children: [
          Row(
            children: [
              PrimaryStyleButton(
                  tamanio: tamanio,
                  function: (){
                    int posicion = controller.selection.baseOffset;

                    controller.text = "${controller.text.substring(0, posicion)}/servicio/${controller.text.substring(posicion)}";

                    controller.selection = TextSelection.fromPosition(
                        TextPosition(offset: posicion + "/servicio/".length)
                    );
                  },
                  text: "Servicio"
              ),
              PrimaryStyleButton(
                  tamanio: tamanio,
                  function: (){
                    int posicion = controller.selection.baseOffset;

                    controller.text = "${controller.text.substring(0, posicion)}/idcotizacion/${controller.text.substring(posicion)}";

                    controller.selection = TextSelection.fromPosition(
                        TextPosition(offset: posicion + "/idcotizacion/".length)
                    );
                  },
                  text: "Id Cotizacion"
              ),
              PrimaryStyleButton(
                  tamanio: tamanio,
                  function: (){
                    int posicion = controller.selection.baseOffset;

                    controller.text = "${controller.text.substring(0, posicion)}/materia/${controller.text.substring(posicion)}";

                    controller.selection = TextSelection.fromPosition(
                        TextPosition(offset: posicion + "/materia/".length)
                    );
                  },
                  text: "Materia"
              ),
              PrimaryStyleButton(
                  tamanio: tamanio,
                  function: (){
                    int posicion = controller.selection.baseOffset;

                    controller.text = "${controller.text.substring(0, posicion)}/resumen/${controller.text.substring(posicion)}";

                    controller.selection = TextSelection.fromPosition(
                      TextPosition(offset: posicion + "/resumen/".length)
                    );
                  },
                  text: "Resumen"
              ),
            ],
          ),
          Row(
            children: [
              PrimaryStyleButton(
                  width: 110,
                  tamanio: tamanio,
                  function: (){
                    int posicion = controller.selection.baseOffset;

                    controller.text = "${controller.text.substring(0, posicion)}/fechaentrega/${controller.text.substring(posicion)}";

                    controller.selection = TextSelection.fromPosition(
                        TextPosition(offset: posicion + "/fechaentrega/".length)
                    );
                  },
                  text: "Fecha de Entrega"
              ),
              PrimaryStyleButton(
                  width: 110,
                  tamanio: tamanio,
                  function: (){
                    int posicion = controller.selection.baseOffset;

                    controller.text = "${controller.text.substring(0, posicion)}/horaentrega/${controller.text.substring(posicion)}";

                    controller.selection = TextSelection.fromPosition(
                        TextPosition(offset: posicion + "/horaentrega/".length)
                    );
                  },
                  text: "Hora de Entrega"
              ),
              PrimaryStyleButton(
                  tamanio: tamanio,
                  width: 140,
                  function: (){
                    int posicion = controller.selection.baseOffset;

                    controller.text = "${controller.text.substring(0, posicion)}/infocliente/${controller.text.substring(posicion)}";

                    controller.selection = TextSelection.fromPosition(
                        TextPosition(offset: posicion + "/infocliente/".length)
                    );
                  },
                  text: "Informacion Cliente"
              ),
            ],
          ),
        ],
      );
    }else{
      return Column(
        children: [
          Row(
            children: [
              PrimaryStyleButton(
                  tamanio: tamanio,
                  function: (){
                    int posicion = controller.selection.baseOffset;

                    controller.text = "${controller.text.substring(0, posicion)}/servicioplural/${controller.text.substring(posicion)}";

                    controller.selection = TextSelection.fromPosition(
                        TextPosition(offset: posicion + "/servicioplural/".length)
                    );
                  },
                  text: "Servicio Plural"
              ),
              PrimaryStyleButton(
                  tamanio: tamanio,
                  function: (){
                    int posicion = controller.selection.baseOffset;

                    controller.text = "${controller.text.substring(0, posicion)}/servicio/${controller.text.substring(posicion)}";

                    controller.selection = TextSelection.fromPosition(
                        TextPosition(offset: posicion + "/servicio/".length)
                    );
                  },
                  text: "Servicio"
              ),
              PrimaryStyleButton(
                  tamanio: tamanio,
                  function: (){
                    int posicion = controller.selection.baseOffset;

                    controller.text = "${controller.text.substring(0, posicion)}/fecha de entrega/${controller.text.substring(posicion)}";

                    controller.selection = TextSelection.fromPosition(
                        TextPosition(offset: posicion + "/fecha de entrega/".length)
                    );
                  },
                  text: "Fecha de Entrega"
              ),
            ],
          ),
          Row(
            children: [
              PrimaryStyleButton(
                  tamanio: tamanio,
                  function: (){
                    int posicion = controller.selection.baseOffset;

                    controller.text = "${controller.text.substring(0, posicion)}/materia/${controller.text.substring(posicion)}";

                    controller.selection = TextSelection.fromPosition(
                        TextPosition(offset: posicion + "/materia/".length)
                    );
                  },
                  text: "Materia"
              ),
              PrimaryStyleButton(
                width: 50,
                  tamanio: tamanio,
                  function: (){
                    int posicion = controller.selection.baseOffset;

                    controller.text = "${controller.text.substring(0, posicion)}/rolusuario/${controller.text.substring(posicion)}";

                    controller.selection = TextSelection.fromPosition(
                        TextPosition(offset: posicion + "/rolusuario/".length)
                    );
                  },
                  text: "Rol"
              ),
              PrimaryStyleButton(
                  tamanio: tamanio,
                  function: (){
                    int posicion = controller.selection.baseOffset;

                    controller.text = "${controller.text.substring(0, posicion)}/nombreusuario/${controller.text.substring(posicion)}";

                    controller.selection = TextSelection.fromPosition(
                        TextPosition(offset: posicion + "/nombreusuario/".length)
                    );
                  },
                  text: "Nombre Usuario"
              ),
              PrimaryStyleButton(
                  tamanio: tamanio,
                  function: (){
                    int posicion = controller.selection.baseOffset;

                    controller.text = "${controller.text.substring(0, posicion)}/codigo/${controller.text.substring(posicion)}";

                    controller.selection = TextSelection.fromPosition(
                        TextPosition(offset: posicion + "/codigo/".length)
                    );
                  },
                  text: "Codigo"
              ),
            ],
          ),
        ],
      );
    }
  }

}

class UtilDialogs{

  final BuildContext context;
  final double height;

  UtilDialogs({
    required this.context,
    this.height = 220,
  });

  void error (String text, String title) => showDialog(
      context: context,
      builder: (BuildContext errorContext) => _errorDialog(text, title, errorContext)
  );
  
  void exito(String text, String title) => showDialog(
    context: context,
    builder: (BuildContext context) => _successDialog(text, title)
  );

  void confirmar (String text, String title, VoidCallback function, [VoidCallback? cancelFunction]) => showDialog(
        context: context,
        builder: (BuildContext context) =>  _confirmDialog(text, title, function, cancelFunction ?? (){})
  );

  void cargar(String text, String title) => showDialog(
      context: context,
      builder: (BuildContext context) => _cargaDialog(text, title)
  );

  dialog.Dialog _errorDialog(String text, String title, BuildContext errorContext){
    final ThemeApp themeApp = ThemeApp();
    return dialog.Dialog(
      backgroundColor: themeApp.whitecolor.withOpacity(0),
      child: ItemsCard(
        shadow: true,
        width: 200,
        height: height,
        children: [
          Icon(dialog.Icons.error, size: 70, color: themeApp.redColor,),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3.0),
            child: Text(title, style: themeApp.styleText(20, true, themeApp.grayColor), textAlign: TextAlign.center,),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 5.0, bottom: 10.0),
            child: Text(text),
          ),
          PrimaryStyleButton(
              width: 100,
              buttonColor: themeApp.redColor,
              function: (){
                Navigator.pop(errorContext);
              }, text: "Cerrar")
        ],
      ),
    );
  }

  dialog.Dialog _successDialog(String text, String title){
    final ThemeApp themeApp = ThemeApp();
    return dialog.Dialog(
      backgroundColor: themeApp.whitecolor.withOpacity(0),
      child: ItemsCard(
        shadow: true,
        width: 200,
        height: height,
        children: [
          Icon(dialog.Icons.check_circle_rounded, size: 70, color: themeApp.greenColor,),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3.0),
            child: Text(title, style: themeApp.styleText(20, true, themeApp.grayColor),),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 5.0, bottom: 10.0),
            child: Text(text),
          ),
          PrimaryStyleButton(
              width: 100,
              buttonColor: themeApp.greenColor,
              function: (){
                Navigator.pop(context);
              }, text: "Cerrar")
        ],
      ),
    );
  }

  dialog.Dialog _confirmDialog(String text, String title, VoidCallback function, VoidCallback cancelFunction){
    final ThemeApp themeApp = ThemeApp();
    return dialog.Dialog(
      backgroundColor: themeApp.whitecolor.withOpacity(0),
      child: ItemsCard(
        shadow: true,
        width: 250,
        height: height + 10,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: Icon(dialog.Icons.info, size: 70, color: themeApp.primaryColor,),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3.0),
            child: Text(title, style: themeApp.styleText(20, true, themeApp.grayColor),),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 5.0, bottom: 10.0,),
            child: SizedBox(
              width: 230,
              child: Text(
                text,
                maxLines: null,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(bottom: 15.0),
            width: 180,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  PrimaryStyleButton(
                      width: 80,
                      function: (){
                        Navigator.pop(context);
                        function();
                      }, text: "Aceptar"),
                  PrimaryStyleButton(
                      width: 80,
                      buttonColor: themeApp.redColor,
                      function: (){
                        Navigator.pop(context);
                        cancelFunction();
                      }, text: "Cerrar"),
                ]
            ),
          )
        ],
      ),
    );
  }

  dialog.Dialog _cargaDialog(String text, String title,){
    final ThemeApp themeApp = ThemeApp();
    return dialog.Dialog(
      backgroundColor: themeApp.blackColor.withOpacity(0),
      child: ItemsCard(
        width: 260,
        height: height - 50,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 12.0, bottom: 10.0),
            child: dialog.CircularProgressIndicator(
              strokeWidth: 4.0,
              color: themeApp.primaryColor,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3.0),
            child: Text(title, style: themeApp.styleText(20, true, themeApp.primaryColor),),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 5.0, bottom: 10.0),
            child: Text(text),
          ),
        ],
      ),
    );
  }

}