import 'package:flutter/material.dart';
import '../pages/rendimientos_molinos.dart';
import '../pages/liberacion_calidad.dart';
import '../main.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HomePage extends StatelessWidget {
  final String nombreEmpleado;

  const HomePage({super.key, required this.nombreEmpleado});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      
      // ☰ ==================================================
      // SECCIÓN DEL MENÚ LATERAL (DRAWER)
      // ==================================================
      drawer: Drawer(
        child: Column(
          children: [
            // Encabezado del menú con diseño institucional
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 23, 81, 38), // Tu verde oscuro
              ),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.person,
                  color: Color.fromARGB(255, 23, 81, 38),
                  size: 38,
                ),
              ),
              accountName: Text(
                nombreEmpleado,
                style: const TextStyle(
                  fontFamily: "CenturyGothic",
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              accountEmail: const Text(
                "SALUD QUE TRASCIENDE",
                style: TextStyle(
                  fontFamily: "CenturyGothic",
                  fontSize: 12,
                  letterSpacing: 1.0,
                  color: Color.fromARGB(255, 204, 204, 204),
                ),
              ),
            ),

            // Opciones del menú lateral
            ListTile(
              leading: const Icon(
                Icons.update, 
                color: Color.fromARGB(255, 23, 81, 38)
              ),
              title: const Text(
                'Actualizar App',
                style: TextStyle(
                  fontFamily: "CenturyGothic", 
                  fontWeight: FontWeight.w600
                ),
              ),
              onTap: () {
                Navigator.pop(context); 
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text(
                      'Función en desarrollo...',
                      style: TextStyle(fontFamily: "CenturyGothic"),
                    ),
                    backgroundColor: const Color.fromARGB(255, 23, 81, 38), // Tu verde corporativo
                    duration: const Duration(seconds: 3), // Tiempo que se queda en pantalla
                    behavior: SnackBarBehavior.floating, // Hace que flote elegantemente
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                );               
              },
            ),
            
            const Divider(), // Línea divisora
            
            const Spacer(), // Empuja el botón de cerrar sesión hasta abajo
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Cerrar Sesión',
                style: TextStyle(
                  fontFamily: "CenturyGothic", 
                  color: Colors.red, fontWeight: FontWeight.bold
                ),
              ),
              onTap: () {
                // Aquí pondrías la lógica para regresar a la pantalla de Login
                Navigator.pop(context); // 1. Cierra el menú lateral (o el diálogo)
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LoginPage(), // Tu pantalla de Login
                  ),
                  (route) => false, // Al poner 'false' borra TODAS las pantallas anteriores
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      
      appBar: AppBar(
        title: const Text(
          'Inicio',
          style: TextStyle(
            fontFamily: "CenturyGothic"
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 23, 81, 38),
        foregroundColor: Colors.white,
        elevation: 0,
        // Nota: Flutter pone automáticamente el botón del menú aquí al detectar el "drawer".
      ),
      body: Column(
        children: [
          // =====================
          // TARJETA PRINCIPAL (DESTACADA)
          // =====================
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Card(
              elevation: 10,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🏢 1. LA FRANJA GRIS SUPERIOR
                  Container(
                    width: double.infinity,
                    color: const Color.fromARGB(255, 204, 204, 204),
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                    child: const Text(
                      'BIENVENIDO(A) A',
                      style: TextStyle(
                        fontFamily: "CenturyGothic",
                        color: Color.fromARGB(255, 102, 102, 102),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),

                  // 📝 2. EL CUERPO DE LA TARJETA
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/icono_planta_gris_HSH.png'),
                        scale: 15.0,
                        alignment: Alignment.centerRight,
                        fit: BoxFit.none,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'HERBAL',
                            style: TextStyle(
                              fontFamily: "CenturyGothic",
                              color: Color.fromARGB(255, 140, 187, 47),
                              fontSize: 26,
                              height: 0.9,
                            ),
                          ),
                          const Text(
                            'SYSTEM HEALTH',
                            style: TextStyle(
                              fontFamily: "CenturyGothic",
                              color: Color.fromARGB(255, 0, 80, 40),
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              height: 0.9,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Mobile',
                            style: TextStyle(
                              fontFamily: "CenturyGothic",
                              color: Color.fromARGB(255, 0, 80, 40),
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              height: 0.9,
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Icon(Icons.person, color: Colors.black, size: 22),
                              const SizedBox(width: 8),
                              Text(
                                nombreEmpleado,
                                style: const TextStyle(
                                  fontFamily: "CenturyGothic",
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // =====================
          // TARJETA SECUNDARIA (PROCESOS MOLINOS)
          // =====================
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RendimientosMolinos(),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Procesos Molinos',
                        style: TextStyle(
                          fontFamily: "CenturyGothic",
                          color: Color.fromARGB(255, 0, 80, 40),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const FaIcon(
                              FontAwesomeIcons.leaf,
                              color: Color.fromARGB(255, 0, 80, 40),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Control de molienda y rendimientos',
                              style: TextStyle(
                                fontFamily: "CenturyGothic",
                                color: Colors.black,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // =====================
          // TARJETA TERCERA (LIBERACIONES CALIDAD)
          // =====================
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LiberacionCalidad(),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Liberaciones Calidad',
                        style: TextStyle(
                          fontFamily: "CenturyGothic",
                          color: Color.fromARGB(255, 0, 80, 40),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: const Color.fromARGB(255, 0, 80, 40).withOpacity(0.1),
                            ),
                            child: const Icon(
                              Icons.verified_user, 
                              color: Color.fromARGB(255, 0, 80, 40),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Aprobación e inspección de materia prima',
                              style: TextStyle(
                                fontFamily: "CenturyGothic",
                                color: Colors.black,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // =====================
          // ESPACIO RESTANTE
          // =====================
          Expanded(
            child: Container(),
          ),
        ],
      ),
    );
  }
}