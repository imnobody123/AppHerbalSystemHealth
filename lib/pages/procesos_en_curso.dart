import 'package:flutter/material.dart';
import '../models/control_entrada_molino.dart';
import '../services/controles_service.dart';
import 'rendimientos_molinos.dart';

class ProcesosEnCursoPage extends StatefulWidget 
{
  const ProcesosEnCursoPage({super.key}); 
  
  @override
  State<ProcesosEnCursoPage> createState() => _ProcesosEnCursoPageState();
}

class _ProcesosEnCursoPageState extends State<ProcesosEnCursoPage> 
{
  List<ControlEntradaMolino> controles = [];
  bool cargando = true;

  @override
  void initState() 
  {
    super.initState();
    _cargarControles();
  }

  Future<void> _cargarControles() async {
    try {
      final List<ControlEntradaMolino> data =
          await fetchControles('/ProcesosMolinosRegistros/ObtenerProcesosMolinosRegistrados');

      setState(() {
        controles = data;
        cargando = false;
      });

      debugPrint('Proceso cargado');
    } catch (e) {
      debugPrint('Error: $e');
      setState(() => cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) 
  {
    if (cargando) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controles.length,
        itemBuilder: (context, index) {
          final control = controles[index];

          return Card(
            elevation: 3,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.factory),
                    title: Text(
                      control.controlMP,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),

                  const SizedBox(height: 8),

                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.edit),
                      label: const Text('Editar / Continuar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RendimientosMolinos(
                              idProcesoMolino: control.idProcesoMolino,
                              controlMPEditar: control.controlMP,
                              kg: control.KG,
                              ),
                            ),
                          );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}