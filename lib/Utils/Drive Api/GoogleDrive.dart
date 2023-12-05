import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dashboard_admin_flutter/Objetos/AgendadoServicio.dart';
import 'package:dashboard_admin_flutter/Utils/Utiles/FuncionesUtiles.dart';
import 'package:dashboard_admin_flutter/Utils/Firebase/Uploads.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:intl/intl.dart';
import '../../Config/Config.dart';
import '../EnviarMensajesWhataspp.dart';
import '../Firebase/CollectionReferences.dart';

class ResultadosUpload{
  final int numberfilesUploaded;
  final String folderUrl;
  ResultadosUpload(this.numberfilesUploaded,this.folderUrl);
}

class ArchivoResultado{
  final String nombrearchivo;
  final String id;
  final String mimeType;
  ArchivoResultado(this.nombrearchivo,this.id,this.mimeType);
}

class DriveApiUsage {
  CollectionReferencias referencias =  CollectionReferencias();
  int archivosubidos = 0;

  //Subir solicitudes a Drive Api
  Future<ResultadosUpload> subirSolicitudes(String carpetaId, List<PlatformFile>? selectedFiles, String nombrecarpetanueva) async {
    try {
      final httpClient = await auth.clientViaServiceAccount(
        auth.ServiceAccountCredentials.fromJson({
          "type": "service_account",
          "project_id": "dufy-asesorias",
          "private_key_id": "79155babfe12e650c59a6f2873fd32eae388a925",
          "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQChcbVSve/TgLjM\nYg0kSYfY4L0JMMcnBXNX0wdiZ/YdUTlZMg5uRHnvDTCgf1GupfB3PxzoQQifTlXd\nA5/Bkkmw2wzFq7muUHXVJzzWrwXrNqDvb6cAcml8iJ4r6UX/+ntgoscX4ZHzPq0h\nVnzx8a6eSAyokxjM/Lxydxqn97GD87jmIDZnKCM+8w9rZHuPZJ76KpciUuBrWgxh\nAB1YBya8bApt3ssV8h/oHQ9QzWRYXQVlni8ZPo9RYbr3I5Ap6n4ba2Oll3QzLADR\nISyiFjUgGbPePtfyn2KxoAZADXhl873i1HTX9VCKtaTHnKNpKwIPlC9jKISsFR1H\nmSGsDJ+5AgMBAAECggEAIcboAF0zwYTzZPN4u2hU7zep5TPa3tuhk7TXnSuSDvUw\n8evqoABcoHqae2HX5ZnbMx+1vRPqKWZayYhaEsY3+7QAupSgnws/c+6nKGVq8Bi4\nWA/8mTfWwRLWQOqn1hQCXyf/ToxHnGQ3FbwCHR6LAZuiZlyMOksAZFRt88l7TtdI\nUWLdFYhzAjSmo3ULXeI8UFI/asEsqhEPwkr2wTqGhXT6KDotjXse3aMsUAU2GY+3\n3qeGS75O2Zz/DALkv16aCcRUULI2uU1LX7XELeBthGZxKeiIE11IJj9ld+bwl1Sp\ntGQUJyzFfFnUx+GP0XVEoL0rlfx2z4sa0R66sNCvRwKBgQDYl6pIUFpwoXnjKn0a\n8NE5Ix1rav0TPfcMuUIejEVcHIZxDXZ8jmvnpslhjqXR5yZNUvbMLUgPweIieZuy\nRE4ROrgx46z12L6M7mN+FXSmC8XcytoD040/in496N3qHHypyh/P9hPNJ7q1uvTl\nw/ZD2XUIBH66Nx6pu8145666twKBgQC+0V/heqcKLTueiIxcul1mLzPvfppvgy6+\nSImO9M7f9Ld/6AE2bEC7LU1U67buUIGp3fVdUMpvK1pavNfm90HnPxKBah4cCyvN\n1wNmPs0g3vMNISjgyCmbF2HwiFGcYMxpQsPQILL2+4VyjQSAUmQ/lpYdquTP3KHK\n8pgfe3rJDwKBgGBWZVkw1GlQiYRvO6ImBwmhAs7qkZJjd2VjaXNo9NjZnzrdwBv6\nxSgOWXhZGIxaggDWrAt5AJpxpIGtEYGjPA4RzifymtXnCCprRjmolW/dwK5KU9pr\n2GGw2iHzV/FvpktnKes4Cuqvhy6Z75/bH8hiCtn8FdoB9lOMwwHKGz/VAoGASzWt\nK+szAYDYmeDKKhZOj+MU/lWRO1iiSN/AUDdPftgup1xjdfbvAJeXflw1yvKyWKii\neDhKwcx9nXwHQQK92A51FcskuPryNfyEW31vToBxngAu44IhW/64XJzuRculZeup\n0FPDFjQG4iKQ3p8a4jFRU7oy23bj0mER8n6x46MCgYAeIKtL994t2/yEMZtGKzUe\nqH2fSctmLkeXCfrWtSeB/JdFjIHPMrUjAHfm2gqj5fOKu7awkKUEzJRM2ZJH8tE4\nYrwKHX608HC5/t67gfJBK5ClZDR2Ui1gsVNhMrmbDFZfJibsckaJgNqGIlAax+Fu\nkdHt5iqD0lUSVTd5svgmEA==\n-----END PRIVATE KEY-----\n",
          "client_email": "entorno-comun-de-datos-drive@dufy-asesorias.iam.gserviceaccount.com",
          "client_id": "106860579823050981946",
          "auth_uri": "https://accounts.google.com/o/oauth2/auth",
          "token_uri": "https://oauth2.googleapis.com/token",
          "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
          "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/entorno-comun-de-datos-drive%40dufy-asesorias.iam.gserviceaccount.com",
          "universe_domain": "googleapis.com"
        }),
        [drive.DriveApi.driveFileScope],
      );
      final driveApi = drive.DriveApi(httpClient);
      final query = "'$carpetaId' in parents";
      final carpetaPrincipal = await driveApi.files.list(q: query);

      if (carpetaPrincipal.files != null) {
        final foldernew = drive.File()
          ..name = '$nombrecarpetanueva' // Cambia 'NombreDeCarpetaDentro' por el nombre deseado
          ..mimeType = 'application/vnd.google-apps.folder' // Indicar que estás creando una carpeta
          ..parents = [carpetaId]; // ID de la carpeta principal

        final nuevaCarpetaDentro = await driveApi.files.create(foldernew);

        if (nuevaCarpetaDentro.id != null) {
          final folderUrl = 'https://drive.google.com/drive/folders/${nuevaCarpetaDentro.id}';
          print('Carpeta dentro de la carpeta principal creada con ID: ${nuevaCarpetaDentro.id}');
          print('Enlace a la carpeta dentro de la carpeta principal: $folderUrl');

          //Vamos a agregar archivos dentro de la carpeta de drive
          if (selectedFiles != null && selectedFiles.isNotEmpty) {
            for (var file in selectedFiles) {
              final fileToUpload = drive.File()
                ..name = file.name
                ..parents = [nuevaCarpetaDentro.id!];

              final media = drive.Media(
                Stream.fromIterable([Uint8List.fromList(file.bytes as List<int>)]),
                // Convierte los bytes en un Stream
                file.bytes?.length, // Tamaño del archivo
              );
              final result = await driveApi.files.create(fileToUpload, uploadMedia: media);
              if (result.id != null) {
                print('Archivo "${file.name}" subido correctamente a la nueva carpeta.');
                archivosubidos = archivosubidos + 1;
              } else {
                print('No se pudo subir el archivo "${file.name}" a la nueva carpeta.');
              }
            }
            //Aqui vamos a actualizar las estadisticas
            estadisticasSolicitudesDriveApi(selectedFiles.length);
            return ResultadosUpload(archivosubidos, folderUrl);
          }
        } else {
          print('No se pudo crear la carpeta dentro de la carpeta principal.');
          return ResultadosUpload(0, '0');
        }
      }
      return ResultadosUpload(0, '');
    } catch (e) {
      print("Error: $e");
      return ResultadosUpload(0, '');
    }
  }
  //Estadisticas de Solicitudes subidas
  Future estadisticasSolicitudesDriveApi(int numArchivos) async{
    await referencias.initCollections();
    CollectionReference rutaEstadisticasDriveApi = referencias.EstadisticaDriveSolicitudes!;

    final fechaActual = DateTime.now();
    final fechaActualString = DateFormat('dd-MM-yyyy').format(fechaActual);

    final estadisticaDiaDoc = rutaEstadisticasDriveApi.doc(fechaActualString);
    final estadisticaDiaSnapshot = await estadisticaDiaDoc.get();

    if (estadisticaDiaSnapshot.exists) {
      // Si ya existe la estadística para este día, actualiza el número de archivos subidos
      await estadisticaDiaDoc.update({
        'archivos_subidos': FieldValue.increment(numArchivos),
      });
    } else {
      // Si no existe la estadística para este día, crea un nuevo documento
      await estadisticaDiaDoc.set({
        'archivos_subidos': numArchivos,
        'fecha' : fechaActual,
      });
    }
  }

  //Subir imagenes de pagos, y poder verlos desde la app
  Future<void> subirPago(String carpetaId, List<PlatformFile>? selectedFiles, String referencia) async {
    try {
      final httpClient = await auth.clientViaServiceAccount(
        auth.ServiceAccountCredentials.fromJson({
          "type": "service_account",
          "project_id": "dufy-asesorias",
          "private_key_id": "79155babfe12e650c59a6f2873fd32eae388a925",
          "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQChcbVSve/TgLjM\nYg0kSYfY4L0JMMcnBXNX0wdiZ/YdUTlZMg5uRHnvDTCgf1GupfB3PxzoQQifTlXd\nA5/Bkkmw2wzFq7muUHXVJzzWrwXrNqDvb6cAcml8iJ4r6UX/+ntgoscX4ZHzPq0h\nVnzx8a6eSAyokxjM/Lxydxqn97GD87jmIDZnKCM+8w9rZHuPZJ76KpciUuBrWgxh\nAB1YBya8bApt3ssV8h/oHQ9QzWRYXQVlni8ZPo9RYbr3I5Ap6n4ba2Oll3QzLADR\nISyiFjUgGbPePtfyn2KxoAZADXhl873i1HTX9VCKtaTHnKNpKwIPlC9jKISsFR1H\nmSGsDJ+5AgMBAAECggEAIcboAF0zwYTzZPN4u2hU7zep5TPa3tuhk7TXnSuSDvUw\n8evqoABcoHqae2HX5ZnbMx+1vRPqKWZayYhaEsY3+7QAupSgnws/c+6nKGVq8Bi4\nWA/8mTfWwRLWQOqn1hQCXyf/ToxHnGQ3FbwCHR6LAZuiZlyMOksAZFRt88l7TtdI\nUWLdFYhzAjSmo3ULXeI8UFI/asEsqhEPwkr2wTqGhXT6KDotjXse3aMsUAU2GY+3\n3qeGS75O2Zz/DALkv16aCcRUULI2uU1LX7XELeBthGZxKeiIE11IJj9ld+bwl1Sp\ntGQUJyzFfFnUx+GP0XVEoL0rlfx2z4sa0R66sNCvRwKBgQDYl6pIUFpwoXnjKn0a\n8NE5Ix1rav0TPfcMuUIejEVcHIZxDXZ8jmvnpslhjqXR5yZNUvbMLUgPweIieZuy\nRE4ROrgx46z12L6M7mN+FXSmC8XcytoD040/in496N3qHHypyh/P9hPNJ7q1uvTl\nw/ZD2XUIBH66Nx6pu8145666twKBgQC+0V/heqcKLTueiIxcul1mLzPvfppvgy6+\nSImO9M7f9Ld/6AE2bEC7LU1U67buUIGp3fVdUMpvK1pavNfm90HnPxKBah4cCyvN\n1wNmPs0g3vMNISjgyCmbF2HwiFGcYMxpQsPQILL2+4VyjQSAUmQ/lpYdquTP3KHK\n8pgfe3rJDwKBgGBWZVkw1GlQiYRvO6ImBwmhAs7qkZJjd2VjaXNo9NjZnzrdwBv6\nxSgOWXhZGIxaggDWrAt5AJpxpIGtEYGjPA4RzifymtXnCCprRjmolW/dwK5KU9pr\n2GGw2iHzV/FvpktnKes4Cuqvhy6Z75/bH8hiCtn8FdoB9lOMwwHKGz/VAoGASzWt\nK+szAYDYmeDKKhZOj+MU/lWRO1iiSN/AUDdPftgup1xjdfbvAJeXflw1yvKyWKii\neDhKwcx9nXwHQQK92A51FcskuPryNfyEW31vToBxngAu44IhW/64XJzuRculZeup\n0FPDFjQG4iKQ3p8a4jFRU7oy23bj0mER8n6x46MCgYAeIKtL994t2/yEMZtGKzUe\nqH2fSctmLkeXCfrWtSeB/JdFjIHPMrUjAHfm2gqj5fOKu7awkKUEzJRM2ZJH8tE4\nYrwKHX608HC5/t67gfJBK5ClZDR2Ui1gsVNhMrmbDFZfJibsckaJgNqGIlAax+Fu\nkdHt5iqD0lUSVTd5svgmEA==\n-----END PRIVATE KEY-----\n",
          "client_email": "entorno-comun-de-datos-drive@dufy-asesorias.iam.gserviceaccount.com",
          "client_id": "106860579823050981946",
          "auth_uri": "https://accounts.google.com/o/oauth2/auth",
          "token_uri": "https://oauth2.googleapis.com/token",
          "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
          "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/entorno-comun-de-datos-drive%40dufy-asesorias.iam.gserviceaccount.com",
          "universe_domain": "googleapis.com"
        }),
        [drive.DriveApi.driveFileScope],
      );
      final driveApi = drive.DriveApi(httpClient);
      for (var file in selectedFiles!) {
        final fileToUpload = drive.File()
          ..name = referencia
          ..parents = [carpetaId];

        final media = drive.Media(
          Stream.fromIterable([Uint8List.fromList(file.bytes as List<int>)]),
          // Convierte los bytes en un Stream
          file.bytes?.length, // Tamaño del archivo
        );
        final result = await driveApi.files.create(
            fileToUpload, uploadMedia: media);
        if (result.id != null) {
          print('Archivo "${file.name}" subido correctamente a la carpeta.');
          archivosubidos = archivosubidos + 1;
        } else {
          print('No se pudo subir el archivo "${file.name}" a la carpeta.');
        }
      }
    } catch (e) {

    }
  }

  //Tutores -- Tutor
  Future<void> entregartrabajo(String codigo, List<PlatformFile>? selectedFiles,String carpetaId, BuildContext context, ServicioAgendado selectedServicio) async {
    try {
      print("carpeta entregas");
      final httpClient = await auth.clientViaServiceAccount(
        auth.ServiceAccountCredentials.fromJson({
          "type": "service_account",
          "project_id": "dufy-asesorias",
          "private_key_id": "79155babfe12e650c59a6f2873fd32eae388a925",
          "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQChcbVSve/TgLjM\nYg0kSYfY4L0JMMcnBXNX0wdiZ/YdUTlZMg5uRHnvDTCgf1GupfB3PxzoQQifTlXd\nA5/Bkkmw2wzFq7muUHXVJzzWrwXrNqDvb6cAcml8iJ4r6UX/+ntgoscX4ZHzPq0h\nVnzx8a6eSAyokxjM/Lxydxqn97GD87jmIDZnKCM+8w9rZHuPZJ76KpciUuBrWgxh\nAB1YBya8bApt3ssV8h/oHQ9QzWRYXQVlni8ZPo9RYbr3I5Ap6n4ba2Oll3QzLADR\nISyiFjUgGbPePtfyn2KxoAZADXhl873i1HTX9VCKtaTHnKNpKwIPlC9jKISsFR1H\nmSGsDJ+5AgMBAAECggEAIcboAF0zwYTzZPN4u2hU7zep5TPa3tuhk7TXnSuSDvUw\n8evqoABcoHqae2HX5ZnbMx+1vRPqKWZayYhaEsY3+7QAupSgnws/c+6nKGVq8Bi4\nWA/8mTfWwRLWQOqn1hQCXyf/ToxHnGQ3FbwCHR6LAZuiZlyMOksAZFRt88l7TtdI\nUWLdFYhzAjSmo3ULXeI8UFI/asEsqhEPwkr2wTqGhXT6KDotjXse3aMsUAU2GY+3\n3qeGS75O2Zz/DALkv16aCcRUULI2uU1LX7XELeBthGZxKeiIE11IJj9ld+bwl1Sp\ntGQUJyzFfFnUx+GP0XVEoL0rlfx2z4sa0R66sNCvRwKBgQDYl6pIUFpwoXnjKn0a\n8NE5Ix1rav0TPfcMuUIejEVcHIZxDXZ8jmvnpslhjqXR5yZNUvbMLUgPweIieZuy\nRE4ROrgx46z12L6M7mN+FXSmC8XcytoD040/in496N3qHHypyh/P9hPNJ7q1uvTl\nw/ZD2XUIBH66Nx6pu8145666twKBgQC+0V/heqcKLTueiIxcul1mLzPvfppvgy6+\nSImO9M7f9Ld/6AE2bEC7LU1U67buUIGp3fVdUMpvK1pavNfm90HnPxKBah4cCyvN\n1wNmPs0g3vMNISjgyCmbF2HwiFGcYMxpQsPQILL2+4VyjQSAUmQ/lpYdquTP3KHK\n8pgfe3rJDwKBgGBWZVkw1GlQiYRvO6ImBwmhAs7qkZJjd2VjaXNo9NjZnzrdwBv6\nxSgOWXhZGIxaggDWrAt5AJpxpIGtEYGjPA4RzifymtXnCCprRjmolW/dwK5KU9pr\n2GGw2iHzV/FvpktnKes4Cuqvhy6Z75/bH8hiCtn8FdoB9lOMwwHKGz/VAoGASzWt\nK+szAYDYmeDKKhZOj+MU/lWRO1iiSN/AUDdPftgup1xjdfbvAJeXflw1yvKyWKii\neDhKwcx9nXwHQQK92A51FcskuPryNfyEW31vToBxngAu44IhW/64XJzuRculZeup\n0FPDFjQG4iKQ3p8a4jFRU7oy23bj0mER8n6x46MCgYAeIKtL994t2/yEMZtGKzUe\nqH2fSctmLkeXCfrWtSeB/JdFjIHPMrUjAHfm2gqj5fOKu7awkKUEzJRM2ZJH8tE4\nYrwKHX608HC5/t67gfJBK5ClZDR2Ui1gsVNhMrmbDFZfJibsckaJgNqGIlAax+Fu\nkdHt5iqD0lUSVTd5svgmEA==\n-----END PRIVATE KEY-----\n",
          "client_email": "entorno-comun-de-datos-drive@dufy-asesorias.iam.gserviceaccount.com",
          "client_id": "106860579823050981946",
          "auth_uri": "https://accounts.google.com/o/oauth2/auth",
          "token_uri": "https://oauth2.googleapis.com/token",
          "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
          "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/entorno-comun-de-datos-drive%40dufy-asesorias.iam.gserviceaccount.com",
          "universe_domain": "googleapis.com"
        }),
        [drive.DriveApi.driveFileScope],);

      final driveApi = drive.DriveApi(httpClient);

        final foldernew = drive.File()
          ..name = '$codigo' // Cambia 'NombreDeCarpetaDentro' por el nombre deseado
          ..mimeType = 'application/vnd.google-apps.folder' // Indicar que estás creando una carpeta
          ..parents = [carpetaId]; // ID de la carpeta principal

        final nuevaCarpetaDentro = await driveApi.files.create(foldernew);

        print("carpeta entregas ${nuevaCarpetaDentro.id}");

        if(nuevaCarpetaDentro.id != null){

          if(selectedFiles != null && selectedFiles.isNotEmpty){
            for(var file in selectedFiles){
              final fileToUpload = drive.File()
                ..name = file.name
                ..parents = [nuevaCarpetaDentro.id!];
              final media = drive.Media(
                Stream.fromIterable(
                    [Uint8List.fromList(file.bytes as List<int>)]),
                // Convierte los bytes en un Stream
                file.bytes?.length, // Tamaño del archivo
              );
              final result = await driveApi.files.create(
                  fileToUpload, uploadMedia: media);
              if (result.id != null) {
                print('Archivo "${file
                    .name}" subido correctamente a la nueva carpeta.');
                archivosubidos = archivosubidos + 1;

              } else {
                print('No se pudo subir el archivo "${file
                    .name}" a la nueva carpeta.');
                Utiles().notificacion("ERROR", context, false, "Informa al dufy admin, hubo error");
              }
            }
            Uploads().modifyServicioAgendadoEntregado(codigo);
            Utiles().notificacion("ARCHIVO SUBIDO", context, true, "archivo subido");
            enviarmensajewsp().sendMessageAvisoTrabajoEntregadoAdmin("573161585420", selectedServicio!.codigo, selectedServicio!.cliente, selectedServicio!.fechaentrega.toString(), selectedServicio!.tutor);
          }
        }

    } catch (e, stackTrace) {
      print('Error: $e');
      print('Stack trace: $stackTrace');
      Utiles().notificacion("ERROR", context, false, "Informa al dufy admin, hubo error");
    }
  }

  //mostrar archivos en lista
  Future<List<ArchivoResultado>> viewarchivosolicitud(int idcotizacion)async{
    List<ArchivoResultado> resultados = [];
    Config configuracion = Config();
    try{
      String carpetaid = configuracion.idcarpetaSolicitudes!;
      final httpClient = await auth.clientViaServiceAccount(
        auth.ServiceAccountCredentials.fromJson({
          "type": "service_account",
          "project_id": "dufy-asesorias",
          "private_key_id": "79155babfe12e650c59a6f2873fd32eae388a925",
          "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQChcbVSve/TgLjM\nYg0kSYfY4L0JMMcnBXNX0wdiZ/YdUTlZMg5uRHnvDTCgf1GupfB3PxzoQQifTlXd\nA5/Bkkmw2wzFq7muUHXVJzzWrwXrNqDvb6cAcml8iJ4r6UX/+ntgoscX4ZHzPq0h\nVnzx8a6eSAyokxjM/Lxydxqn97GD87jmIDZnKCM+8w9rZHuPZJ76KpciUuBrWgxh\nAB1YBya8bApt3ssV8h/oHQ9QzWRYXQVlni8ZPo9RYbr3I5Ap6n4ba2Oll3QzLADR\nISyiFjUgGbPePtfyn2KxoAZADXhl873i1HTX9VCKtaTHnKNpKwIPlC9jKISsFR1H\nmSGsDJ+5AgMBAAECggEAIcboAF0zwYTzZPN4u2hU7zep5TPa3tuhk7TXnSuSDvUw\n8evqoABcoHqae2HX5ZnbMx+1vRPqKWZayYhaEsY3+7QAupSgnws/c+6nKGVq8Bi4\nWA/8mTfWwRLWQOqn1hQCXyf/ToxHnGQ3FbwCHR6LAZuiZlyMOksAZFRt88l7TtdI\nUWLdFYhzAjSmo3ULXeI8UFI/asEsqhEPwkr2wTqGhXT6KDotjXse3aMsUAU2GY+3\n3qeGS75O2Zz/DALkv16aCcRUULI2uU1LX7XELeBthGZxKeiIE11IJj9ld+bwl1Sp\ntGQUJyzFfFnUx+GP0XVEoL0rlfx2z4sa0R66sNCvRwKBgQDYl6pIUFpwoXnjKn0a\n8NE5Ix1rav0TPfcMuUIejEVcHIZxDXZ8jmvnpslhjqXR5yZNUvbMLUgPweIieZuy\nRE4ROrgx46z12L6M7mN+FXSmC8XcytoD040/in496N3qHHypyh/P9hPNJ7q1uvTl\nw/ZD2XUIBH66Nx6pu8145666twKBgQC+0V/heqcKLTueiIxcul1mLzPvfppvgy6+\nSImO9M7f9Ld/6AE2bEC7LU1U67buUIGp3fVdUMpvK1pavNfm90HnPxKBah4cCyvN\n1wNmPs0g3vMNISjgyCmbF2HwiFGcYMxpQsPQILL2+4VyjQSAUmQ/lpYdquTP3KHK\n8pgfe3rJDwKBgGBWZVkw1GlQiYRvO6ImBwmhAs7qkZJjd2VjaXNo9NjZnzrdwBv6\nxSgOWXhZGIxaggDWrAt5AJpxpIGtEYGjPA4RzifymtXnCCprRjmolW/dwK5KU9pr\n2GGw2iHzV/FvpktnKes4Cuqvhy6Z75/bH8hiCtn8FdoB9lOMwwHKGz/VAoGASzWt\nK+szAYDYmeDKKhZOj+MU/lWRO1iiSN/AUDdPftgup1xjdfbvAJeXflw1yvKyWKii\neDhKwcx9nXwHQQK92A51FcskuPryNfyEW31vToBxngAu44IhW/64XJzuRculZeup\n0FPDFjQG4iKQ3p8a4jFRU7oy23bj0mER8n6x46MCgYAeIKtL994t2/yEMZtGKzUe\nqH2fSctmLkeXCfrWtSeB/JdFjIHPMrUjAHfm2gqj5fOKu7awkKUEzJRM2ZJH8tE4\nYrwKHX608HC5/t67gfJBK5ClZDR2Ui1gsVNhMrmbDFZfJibsckaJgNqGIlAax+Fu\nkdHt5iqD0lUSVTd5svgmEA==\n-----END PRIVATE KEY-----\n",
          "client_email": "entorno-comun-de-datos-drive@dufy-asesorias.iam.gserviceaccount.com",
          "client_id": "106860579823050981946",
          "auth_uri": "https://accounts.google.com/o/oauth2/auth",
          "token_uri": "https://oauth2.googleapis.com/token",
          "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
          "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/entorno-comun-de-datos-drive%40dufy-asesorias.iam.gserviceaccount.com",
          "universe_domain": "googleapis.com"
        }),
        [drive.DriveApi.driveFileScope],
      );
      final driveApi = drive.DriveApi(httpClient);
      //realizar consulta de que exista la carpeta de solicitudes
      final query = "mimeType='application/vnd.google-apps.folder' and name='${idcotizacion.toString()}' and '$carpetaid' in parents";
      final carpetaResponse = await driveApi.files.list(q: query);
      if (carpetaResponse.files != null && carpetaResponse.files!.isNotEmpty) {
        print("si existe la carpeta");
        final idCarpeta = carpetaResponse.files![0].id;
        final archivosQuery = "'$idCarpeta' in parents";
        final archivosResponse = await driveApi.files.list(q: archivosQuery);
        if (archivosResponse.files != null && archivosResponse.files!.isNotEmpty) {
          // Recorre la lista de archivos e imprime sus nombres
          for (var file in archivosResponse.files!) {
            print("Nombre del archivo: ${file.name}");
            String namefile = "${file.name}";
            String id = "${file.id}";
            String mimeType = "${file.mimeType}";

            print(archivosResponse.files);

            print("Archivo:");
            for (var key in file.toJson().keys) {
              print("$key: ${file.toJson()[key]}");
            }
            print("\n");
            resultados.add(ArchivoResultado(namefile,id,mimeType));

          }
        } else {
          print("La carpeta está vacía.");
        }
      }else{
        print("no existe la carpeta");
      }
    }catch(e){
      print(e);
    }

    return resultados;

  }

}
