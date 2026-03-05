import 'package:flutter/material.dart';

void main() => runApp(const LiberacionCalidad());

class LiberacionCalidad extends StatelessWidget {
  const LiberacionCalidad({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
        inputDecorationTheme: const InputDecorationTheme(border: OutlineInputBorder()),
      ),
      // Aquí puedes pasar cualquier combinación de IDs
      home: const DashboardMultiArea(idsAreas: [1, 2, 4]), 
    );
  }
}

class DashboardMultiArea extends StatelessWidget {
  final List<int> idsAreas; // Ahora es una lista

  const DashboardMultiArea({super.key, required this.idsAreas});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Control de Calidad Multisección"),
        elevation: 2,
        backgroundColor: Colors.blue.shade50,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Formulario de Registro ERP",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text("Secciones activas: ${idsAreas.join(', ')}", 
                  style: TextStyle(color: Colors.blue.shade800, fontWeight: FontWeight.w500)),
              const SizedBox(height: 20),

              // RENDERIZADO DINÁMICO DE TODAS LAS ÁREAS ACTIVAS
              ...idsAreas.map((id) => _buildExpandableSection(id)).toList(),

              const SizedBox(height: 30),
              const Divider(),
              const Center(
                child: Text("Herbal Solutions Health",
                    style: TextStyle(color: Colors.grey, fontSize: 12)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Envolvemos cada sección en un Card para separarlas visualmente
  Widget _buildExpandableSection(int id) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(child: Text(id.toString()), radius: 15),
                const SizedBox(width: 10),
                Text("ÁREA $id", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            const Divider(),
            const SizedBox(height: 10),
            _getAreaWidget(id),
          ],
        ),
      ),
    );
  }

  Widget _getAreaWidget(int id) {
    switch (id) {
      case 1: return const SectionAreaOne();
      case 2: return const SectionAreaTwo();
      case 3: return const SectionAreaThree();
      case 4: return const SectionAreaFour();
      default:
        return Text("Área $id pendiente de configuración.");
    }
  }
}

// --- HELPERS Y SECCIONES (Se mantienen igual pero dentro del flujo dinámico) ---

Widget _buildNumericField(String label) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12.0),
    child: TextFormField(
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: label, isDense: true),
    ),
  );
}

Widget _buildDecisionRadios(String titulo) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
      Row(
        children: [
          Radio(value: 1, groupValue: 0, onChanged: (v) {}), const Text("Liberado"),
          const SizedBox(width: 10),
          Radio(value: 2, groupValue: 0, onChanged: (v) {}), const Text("Rechazado/Aceptado"),
        ],
      ),
    ],
  );
}

// Las clases SectionAreaOne, Two, Three, Four se mantienen como las tenías
// Solo asegúrate de que usen sus respectivos campos solicitados.

class SectionAreaOne extends StatelessWidget {
  const SectionAreaOne({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      _buildNumericField("Nivel de inspección"),
      _buildNumericField("Población Total"),
      _buildNumericField("Muestra Total"),
      _buildNumericField("Bolsas Rechazadas"),
      _buildNumericField("Materia Extraña"),
      _buildDecisionRadios("Estado Final:"),
    ]);
  }
}

class SectionAreaTwo extends StatelessWidget {
  const SectionAreaTwo({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      _buildNumericField("Corte Polvo"),
      _buildNumericField("Corte Té"),
      _buildDecisionRadios("Decisión:"),
    ]);
  }
}

class SectionAreaThree extends StatelessWidget {
  const SectionAreaThree({super.key});
  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(labelText: "Equipo de Tamizado"),
      items: ["Tamiz 1", "Tamiz 2"].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: (value) {},
    );
  }
}

class SectionAreaFour extends StatelessWidget {
  const SectionAreaFour({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      _buildNumericField("Fases de proceso"),
      _buildNumericField("Nivel de inspección"),
      _buildNumericField("Población Total"),
      _buildNumericField("Muestra Total"),
      _buildNumericField("Bolsas rechazadas"),
      _buildDecisionRadios("Estado Proceso:"),
      _buildDecisionRadios("Estado Final:"),
    ]);
  }
}