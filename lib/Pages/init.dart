import "package:dashboard_admin_flutter/Config/strings.dart";
import "package:flutter/material.dart";
import "../Config/theme.dart";

class InitPage extends StatefulWidget{
  const InitPage({super.key});
  @override
  InitPageState createState() => InitPageState();
}

class InitPageState extends State<InitPage>{
  @override
  Widget build(BuildContext context){
    final ThemeApp theme = ThemeApp();
    late TextEditingController textController = TextEditingController();
    return Center(
      child: ItemsCard(
        width: 400,
        height: 500,
        children: [
          CircularLogo(asset: "logo.png", containerColor: theme.primaryColor, width: 150, height: 150,),
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Text(
              "Empresa",
              style: theme.styleText(
                  18,
                  true,
                  theme.grayColor)
            ),
          ),
          RoundedTextField(
            topMargin: 6,
            bottomMargin: 8,
            width: 250,
            controller: textController,
            placeholder: "Ingrese el numero de empresa"
          ),
          PrimaryStyleButton(
              function: (){
                print(textController.text);
              },
              text: "Iniciar con empresa"
          ),
          Text(
            Strings().appVersion,
            style: theme.styleText(12, false, theme.grayColor.withOpacity(0.5)),
          ),
        ],
      ),
    );
  }
}