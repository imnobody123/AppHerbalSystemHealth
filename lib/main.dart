import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'Principal/HomePage.dart';
import '../config/api_config.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}

// =====================
// LOGIN PAGE
// =====================
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usuarioController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _loading = false;

  Future<void> _login() async {
    setState(() => _loading = true);

    try 
    {
      final response = await http.post
      (
        Uri.parse('${ApiConfig.baseUrl}/EmpleadosLogin/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(
        {
          'usuario': _usuarioController.text.trim(),
          'password': _passwordController.text.trim(),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bienvenido ${data['nombreEmpleado']}')),
        );

        // 🔹 Navegar a la nueva pantalla
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(
              nombreEmpleado: data['nombreEmpleado'], // Pasamos el parámetro
            ),
          ),
        );
      } else if (response.statusCode == 401) {
        _showError('Usuario o contraseña incorrectos');
      } else {
        _showError('Error del servidor');
      }
    } catch (e) {
      _showError('No se pudo conectar con el servidor $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: Column(
        children: [
          // =====================
          // HEADER VERDE CURVO
          // =====================
          Container(
            height: 240,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFF66BB6A),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(120),
                bottomRight: Radius.circular(120),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 50,
                    color: Color(0xFF66BB6A),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Bienvenido',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // =====================
          // FORMULARIO
          // =====================
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  TextField(
                    controller: _usuarioController,
                    decoration: const InputDecoration(
                      labelText: 'Usuario',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Contraseña',
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // BOTÓN INGRESAR
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: _loading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Ingresar',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('Registrar',
                          style: TextStyle(color: Color(0xFF4CAF50))),
                      Text('¿Olvidaste tu contraseña?',
                          style: TextStyle(color: Color(0xFF4CAF50))),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}