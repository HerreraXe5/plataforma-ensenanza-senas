import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'diccionario_screen.dart';
import 'modulo_detalle_screen.dart';
import 'login_screen.dart';
import 'perfil_screen.dart';
import 'favoritas_screen.dart';
import 'historial_screen.dart';
import 'evaluaciones_screen.dart';

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

  Future<void> _fetchDatosBackend() async {
    try {
      final response = await http.get(Uri.parse('http://127.0.0.1:8000/api/modulos/'));
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        
        setState(() {
          modulos = data;
          if (modulos.isNotEmpty && modulos[0]['senas'].isNotEmpty) {
            senaDia = modulos[0]['senas'][0]['palabra'];
          } else {
            senaDia = "Agrega datos desde el admin";
          }
          cargando = false;
        });
      } else {
        setState(() {
          senaDia = "Error de carga";
          cargando = false;
        });
      }
    } catch (e) {
      setState(() {
        senaDia = "Error conectando a Django";
        cargando = false;
      });
    }
  }

  void _cerrarSesion() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SignLearn - Inicio'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.teal),
              child: Text('Menú Principal', style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
              leading: const Icon(Icons.person), 
              title: const Text('Mi Perfil (8)'),
              onTap: () {
                Navigator.pop(context); // Cierra el menú lateral antes de navegar
                Navigator.push(context, MaterialPageRoute(builder: (context) => const PerfilScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.star), 
              title: const Text('Señas Favoritas (7)'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const FavoritasScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.history), 
              title: const Text('Historial de Actividad (6)'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const HistorialScreen()));
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red), 
              title: const Text('Cerrar Sesión (10)', style: TextStyle(color: Colors.red)), 
              onTap: _cerrarSesion,
            ),
          ],
        ),
      ),
      body: cargando 
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchDatosBackend,
              child: ListView(
                padding: const EdgeInsets.all(24.0),
                children: [
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
                              'Seña del Día:\n$senaDia', 
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal)
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  const Text('Módulos de Aprendizaje (1 y 5)', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  
                  modulos.isEmpty 
                    ? const Text('No hay módulos disponibles.', style: TextStyle(color: Colors.grey))
                    : GridView.builder(
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
                          final int numSenas = mod['senas'].length;
                          
                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => ModuloDetalleScreen(modulo: mod)),
                              );
                            },
                            child: Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(mod['titulo'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18), maxLines: 1, overflow: TextOverflow.ellipsis),
                                    const SizedBox(height: 8),
                                    Text('$numSenas señas disponibles', style: TextStyle(color: Colors.grey[700])),
                                    const Spacer(),
                                    const Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text('Entrar ', style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold)),
                                        Icon(Icons.arrow_forward, color: Colors.teal, size: 16),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                  const SizedBox(height: 32),
                  
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(20),
                            backgroundColor: Colors.teal,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const DiccionarioScreen()),
                            );
                          }, 
                          icon: const Icon(Icons.book), 
                          label: const Text('Diccionario', style: TextStyle(fontSize: 16))
                        )
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(20),
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: (){
                            // Conectado a la pantalla de Evaluaciones
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const EvaluacionesScreen()),
                            );
                          }, 
                          icon: const Icon(Icons.quiz), 
                          label: const Text('Evaluaciones', style: TextStyle(fontSize: 16))
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