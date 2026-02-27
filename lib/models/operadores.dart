class Operadores 
{
  final int idOperador;
  final String nombre;
  bool seleccionado;

  Operadores
  ({
      required this.idOperador,
      required this.nombre,
      this.seleccionado = false
  });

  factory Operadores.fromJson(Map<String, dynamic> json) 
  {
    return Operadores
    (
      idOperador: json['idOperadorMolino'],
      nombre: json['nombreCompleto'],
    );
  }
}