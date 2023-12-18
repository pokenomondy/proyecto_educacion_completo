import 'package:fluent_ui/fluent_ui.dart';

class DashboardAdmin extends StatefulWidget {

  @override
  DashboardAdminState createState() => DashboardAdminState();

}

class DashboardAdminState extends State<DashboardAdmin> {
  String nombreempresa = "";
  String contrasena = "";

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        //Nombre empresa
        Row(
          children: [
            Text('Nombre nueva empresa ='),
            Container(
              width: 200,
              child: TextBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                ),
                placeholder: 'Nombre empresa',
                onChanged: (value){
                  nombreempresa = value;
                },
                maxLines: null,
              ),
            ),

          ],
        ),
        //contraseña de empresa
        Row(
          children: [
            Text('Contraseña para empresa ='),
            Container(
              width: 200,
              child: TextBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                ),
                placeholder: 'Contraseña empresa',
                onChanged: (value){
                  nombreempresa = value;
                },
                maxLines: null,
              ),
            ),

          ],
        ),
        //Bqasico plugin
        Row(
          children: [
            Text('Tiempo licencia de aplicación'),
            Container(
              width: 200,
              child: TextBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                ),
                placeholder: 'Contraseña empresa',
                onChanged: (value){
                  nombreempresa = value;
                },
                maxLines: null,
              ),
            ),

          ],
        ),
        //Perfil de administrador, crear un nuevo tutor
      ],
    );
  }
}