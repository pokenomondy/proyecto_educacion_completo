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
    return Center(
      child: ItemsCard(
        width: 400,
        height: 500,
        children: [
          CircularLogo(asset: "logo.png", containerColor: ThemeApp().primaryColor, width: 150, height: 150,),
        ],
      ),
    );
  }
}