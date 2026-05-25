import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<dynamic> modulos = [];
  String senaDia = "Cargando...";
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    _fetchDatosBackend();
  }

  // Función que se conecta a Django
  Future<void> _fetchDatosBackend() async {
    try {
      final response = await http.get(Uri.parse('http://127.0.0.1:8000/api/modulos/'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          modulos = data['modulos'];
          senaDia = data['seña_del_dia']['palabra'];
          cargando = false;
        });
      } else {
        setState(() {
          senaDia = "Error: Código ${response.statusCode}";
          cargando = false;
        });
      }
    } catch (e) {
      setState(() {
        senaDia = "Asegúrate de que el servidor de Django esté corriendo";
        cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SignLearn - Panel Principal'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.teal),
              child: Text('Menú (Funcionalidades)', style: TextStyle(color: Colors.white, fontSize: 20)),
            ),
            ListTile(leading: const Icon(Icons.person), title: const Text('Mi Perfil (8)')),
            ListTile(leading: const Icon(Icons.star), title: const Text('Señas Favoritas (7)')),
            ListTile(leading: const Icon(Icons.history), title: const Text('Historial de Actividad (6)')),
            ListTile(leading: const Icon(Icons.admin_panel_settings), title: const Text('Panel Admin CRUD (9)')),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout), 
              title: const Text('Cerrar Sesión (10)'), 
              onTap: () => Navigator.pop(context), // Cierra el menú
            ),
          ],
        ),
      ),
      body: cargando 
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: ListView(
                children: [
                  // Funcionalidad 4: Seña del Día (Datos desde Django)
                  Card(
                    color: Colors.teal[50],
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        children: [
                          const Icon(Icons.lightbulb, color: Colors.teal, size: 40),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Text(
                              'Seña del Día (Desde Django): $senaDia', 
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal)
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  const Text('Módulos de Aprendizaje (Funcionalidades 1 y 5)', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  
                  // Módulos dinámicos traídos desde Django
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 300, 
                      crossAxisSpacing: 16, 
                      mainAxisSpacing: 16, 
                      mainAxisExtent: 140
                    ),
                    itemCount: modulos.length,
                    itemBuilder: (context, index) {
                      final mod = modulos[index];
                      return Card(
                        elevation: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(mod['titulo'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              const SizedBox(height: 8),
                              Text('${mod['señas_count']} señas disponibles'),
                              const SizedBox(height: 12),
                              LinearProgressIndicator(value: mod['progreso'] / 100, color: Colors.teal),
                              const SizedBox(height: 4),
                              Text('Progreso: ${mod['progreso']}%', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                  
                  // Funcionalidades 2 y 3: Diccionario y Evaluaciones
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(20)),
                          onPressed: (){}, 
                          icon: const Icon(Icons.book), 
                          label: const Text('Diccionario de Señas (2)', style: TextStyle(fontSize: 16))
                        )
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(20)),
                          onPressed: (){}, 
                          icon: const Icon(Icons.quiz), 
                          label: const Text('Evaluaciones / Quizzes (3)', style: TextStyle(fontSize: 16))
                        )
                      ),
                    ],
                  )
                ],
              ),
            ),
    );
  }
}