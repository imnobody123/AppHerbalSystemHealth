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

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usuarioController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _loading = false;
  bool _obscureText = true;

  Future<void> _login() async {
    setState(() => _loading = true);

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/EmpleadosLogin/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'usuario': _usuarioController.text.trim(),
          'password': _passwordController.text.trim(),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bienvenido ${data['nombreEmpleado']}', 
              style: const TextStyle(fontFamily: "CenturyGothic")
            )
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(
              nombreEmpleado: data['nombreEmpleado'],
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
        content: Text(message, style: const TextStyle(fontFamily: "CenturyGothic")),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color verdePrincipal = Color.fromARGB(255, 0, 80, 40); // Tu verde pino

    return Scaffold(
      // 🎨 PASO 1: El fondo de la pantalla ahora es COMPLETAMENTE VERDE
      backgroundColor: verdePrincipal,
      body: SafeArea(
        bottom: false, // Permite que el contenedor blanco llegue hasta el fondo real físico del celular
        child: SingleChildScrollView(
          child: Column(
            children: [
              
              // ==================================================
              // LOGO SUPERIOR (ESPACIO VERDE)
              // ==================================================
              Container(
                height: 220, // Espacio controlado para el logo arriba
                width: double.infinity,
                color: verdePrincipal,
                child: Center(
                  child: Image.asset(
                    'assets/images/logo_blanco.png',
                    scale: 14.0,
                    fit: BoxFit.none,
                    alignment: Alignment.center,
                    color: Colors.white, // Mantiene tu logo en blanco sobre el fondo verde
                  ),
                ),
              ),

              // ==================================================
              // CONTENEDOR BLANCO CON LAS CURVAS HACIA ARRIBA (COMO TU IMAGEN)
              // ==================================================
              Container(
                width: double.infinity,
                // MediaQuery calcula la altura restante para que el contenedor blanco tape todo el fondo
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height - 220,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white, // Fondo blanco para el formulario
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(45),  // Redondeado superior izquierdo
                    topRight: Radius.circular(45), // Redondeado superior derecho
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 35),
                  child: Column(
                    children: [
                      // TEXTO INICIAL "hello!" / "¡Hola!"
                      const Text(
                        '¡Hola!',
                        style: TextStyle(
                          fontFamily: "CenturyGothic",
                          color: verdePrincipal,
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 35),

                      // INPUT 1: USUARIO
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.grey.shade300, width: 1.5), // Borde suave idéntico a tu imagen
                        ),
                        child: TextField(
                          controller: _usuarioController,
                          style: const TextStyle(fontFamily: "CenturyGothic"),
                          decoration: const InputDecoration(
                            hintText: 'Usuario',
                            hintStyle: TextStyle(fontFamily: "CenturyGothic", color: Colors.grey),
                            prefixIcon: Icon(Icons.person_outline, color: Colors.grey),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 20),

                      // INPUT 2: CONTRASEÑA
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.grey.shade300, width: 1.5),
                        ),
                        child: TextField(
                          controller: _passwordController,
                          obscureText: _obscureText,
                          style: const TextStyle(fontFamily: "CenturyGothic"),
                          decoration: InputDecoration(
                            hintText: 'Contraseña',
                            hintStyle: const TextStyle(fontFamily: "CenturyGothic", color: Colors.grey),
                            prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                setState(() => _obscureText = !_obscureText);
                              },
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                          ),
                        ),
                      ),

                      const SizedBox(height: 35),

                      // BOTÓN INGRESAR ESTILO OVALADO (PÍLDORA)
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: verdePrincipal,
                            foregroundColor: Colors.white,
                            elevation: 0, // En la imagen el botón es plano sin sombras pesadas
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: _loading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text(
                                  'Ingresar',
                                  style: TextStyle(
                                    fontFamily: "CenturyGothic",
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.0
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      // ENLACE INFERIOR
                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          '¿Olvidaste tu contraseña?',
                          style: TextStyle(
                            fontFamily: "CenturyGothic",
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      
                      // Un espacio extra abajo para asegurar que no se corte en pantallas pequeñas
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}