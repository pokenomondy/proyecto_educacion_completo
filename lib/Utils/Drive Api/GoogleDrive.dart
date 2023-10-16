import 'dart:typed_data';
import 'package:dashboard_admin_flutter/Utils/Utiles/FuncionesUtiles.dart';
import 'package:dashboard_admin_flutter/Utils/Firebase/Uploads.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/auth_io.dart' as auth;

class ResultadosUpload{
  final int numberfilesUploaded;
  final String folderUrl;
  ResultadosUpload(this.numberfilesUploaded,this.folderUrl);
}

class DriveApi {
  int archivosubidos = 0;

  //Subir solicitudes a Drive Api
  Future<ResultadosUpload> subirSolicitudes(String carpetaId,
      List<PlatformFile>? selectedFiles, String nombrecarpetanueva) async {
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
          final folderUrl = 'https://drive.google.com/drive/folders/${nuevaCarpetaDentro
              .id}';
          print(
              'Carpeta dentro de la carpeta principal creada con ID: ${nuevaCarpetaDentro
                  .id}');
          print(
              'Enlace a la carpeta dentro de la carpeta principal: $folderUrl');

          //Vamos a agregar archivos dentro de la carpeta de drive
          if (selectedFiles != null && selectedFiles.isNotEmpty) {
            for (var file in selectedFiles) {
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
              }
            }
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

  //Subir imagenes de pagos, y poder verlos desde la app
  Future<void> subirPago(String carpetaId, List<PlatformFile>? selectedFiles,
      String referencia) async {
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
  Future<bool?> entrega_tutor(String carpetaid, String nametutor,String codigo,List<PlatformFile>? selectedFiles, BuildContext context) async {
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

      // Realizar una consulta para encontrar la carpeta "ENTREGAS"
      final query = "mimeType='application/vnd.google-apps.folder' and name='ENTREGAS' and '$carpetaid' in parents";
      final response = await driveApi.files.list(q: query);

      if (response.files != null && response.files!.isNotEmpty) {
        // La carpeta "ENTREGAS" ya existe, puedes realizar operaciones aquí
        String entregasFolderId = response.files![0].id!;
        print('La carpeta "ENTREGAS" ya existe con el ID: $entregasFolderId');

        //ya existen
        await entregartrabajo(codigo,selectedFiles,entregasFolderId,context);

      } else {
        // La carpeta "ENTREGAS" no existe, créala dentro de la carpeta principal
        final folder = drive.File();
        folder.name = "ENTREGAS";
        folder.parents = [carpetaid]; // Establece la carpeta principal
        folder.mimeType = "application/vnd.google-apps.folder";

        final createdFolder = await driveApi.files.create(folder);
        String entregasFolderId = createdFolder.id!;
        print('La carpeta "ENTREGAS" ha sido creada con el ID: $entregasFolderId');
        await entregartrabajo(codigo,selectedFiles,entregasFolderId,context);
      }
      //Ya despues de verificado, ahora vamos a entregar el trabajo con el código
      return true; // Operación exitosa
    } catch (e) {
      // Maneja cualquier error aquí
      print('Error: $e');
      return false; // Retorna falso en caso de error
    }
  }

  Future<void> entregartrabajo(String codigo, List<PlatformFile>? selectedFiles,String carpetaentregas, BuildContext context) async {
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
        [drive.DriveApi.driveFileScope],
      );
      final driveApi = drive.DriveApi(httpClient);
      final query = "'$carpetaentregas' in parents";
      final carpetaPrincipal = await driveApi.files.list(q: query);
      // Verificar si la carpeta ya existe
      final querydos = "name = '$codigo' and '$carpetaentregas' in parents";
      final existingFolders = await driveApi.files.list(q: querydos);
      if (existingFolders.files != null && existingFolders.files!.isNotEmpty) {
        print('La carpeta ya existe. No se realizará ninguna acción.');
      }else{
        final foldernew = drive.File()
          ..name = '$codigo' // Cambia 'NombreDeCarpetaDentro' por el nombre deseado
          ..mimeType = 'application/vnd.google-apps.folder' // Indicar que estás creando una carpeta
          ..parents = [carpetaentregas]; // ID de la carpeta principal

        final entregacarpeta = await driveApi.files.create(foldernew);

        print("carpeta entregas ${entregacarpeta.id}");

        if(entregacarpeta.id != null){

          if(selectedFiles != null && selectedFiles.isNotEmpty){
            for(var file in selectedFiles){
              final fileToUpload = drive.File()
                ..name = file.name
                ..parents = [entregacarpeta.id!];
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
                Uploads().modifyServicioAgendado(codigo);
                Utiles().notificacion("ARCHIVO SUBIDO", context, true, "archivo subido");
              } else {
                print('No se pudo subir el archivo "${file
                    .name}" a la nueva carpeta.');
                Utiles().notificacion("ERROR", context, false, "Informa al dufy admin, hubo error");
              }
              //Expongamos el caso de que si se subio, se debe modificar la base de datos

            }
          }
        }
      }

    } catch (e, stackTrace) {
      print('Error: $e');
      print('Stack trace: $stackTrace');
      Utiles().notificacion("ERROR", context, false, "Informa al dufy admin, hubo error");
    }
  }

}
