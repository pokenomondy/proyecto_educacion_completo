class HistorialEstado{
  String Estado = "";
  int tiempocambioconfirmacion = 0;
  DateTime tiempocambioestado = DateTime.now();


  HistorialEstado(this.Estado,this.tiempocambioconfirmacion,this.tiempocambioestado);

  Map<String,dynamic> toMap(){
    return{
      'Estado' :Estado,
      "Duracion de confirmacion" : tiempocambioconfirmacion,
      "fecha de confirmacion":tiempocambioestado,
    };
  }
}