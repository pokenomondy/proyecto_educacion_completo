class ArchivoSolicitud{
  String nombrearchivo = "";
  String urlsolicitud = "";
  String fileextension = "";

  ArchivoSolicitud(this.nombrearchivo,this.urlsolicitud,this.fileextension);

  Map<String, dynamic> toMap() {
    return{
      'nombre archivo':nombrearchivo,
      'url archivo':urlsolicitud,
      'Extensión archivo':fileextension,
    };

  }
}