import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/control_entrada_molino.dart';
import '../config/api_config.dart';

Future<List<ControlEntradaMolino>> fetchControles(String path) async {
  final response = await http.get(
    Uri.parse('${ApiConfig.baseUrl}$path'),
  );

  if (response.statusCode == 200) {
    final List data = json.decode(response.body);
    return data
        .map((e) => ControlEntradaMolino.fromJson(e))
        .toList();
  } else {
    throw Exception('Error al cargar controles');
  }
}