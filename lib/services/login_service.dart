import 'dart:convert';
import 'package:http/http.dart' as http;

class LoginService {
  static const String _baseUrl = 'http://192.168.1.211:7107';

  static Future<Map<String, dynamic>> login(
      String usuario, String password) async {

    final response = await http.post(
      Uri.parse('$_baseUrl/api/EmpleadosLogin/login'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'usuario': usuario,
        'password': password,
      }),
    );

    if (response.statusCode == 200)
    {
      return jsonDecode(response.body);
    } 
    else if (response.statusCode == 401)
    {
      throw Exception('Usuario o contraseña incorrectos');
    } else{
      throw Exception('Error de servidor');
    }
  }
}