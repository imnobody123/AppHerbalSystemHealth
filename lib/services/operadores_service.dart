import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/operadores.dart';
import '../config/api_config.dart';

Future<List<Operadores>> fetchOperadores() async {
  final response = await http.get
  (
    Uri.parse('${ApiConfig.baseUrl}/OperadoresMolinos/DatosOperadores'),
  );

  if (response.statusCode == 200) 
  {
    final List data = json.decode(response.body);
    return data
        .map((e) => Operadores.fromJson(e))
        .toList();
  } 
  else 
  {
    throw Exception('Error al cargar controles');
  }
}