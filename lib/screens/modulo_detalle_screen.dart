import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ModuloDetalleScreen extends StatefulWidget {
  final Map<String, dynamic> modulo;

  const ModuloDetalleScreen({super.key, required this.modulo});

  @override
  State<ModuloDetalleScreen> createState() => _ModuloDetalleScreenState();
}

class _ModuloDetalleScreenState extends State<ModuloDetalleScreen> {
  
  Future<void> _agregarAFavoritas(int senaId, String palabra) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) return;

    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/api/favoritas/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'sena': senaId}),
      );

      if (response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('¡"$palabra" guardada en tus favoritas! ❤️'), backgroundColor: Colors.green),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Esta seña ya está en tus favoritas'), backgroundColor: Colors.orange),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error de conexión'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // --- NUEVA FUNCIÓN: MUESTRA EL GIF O IMAGEN EN PANTALLA ---
  void _mostrarImagenSena(String palabra, String url) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(palabra, textAlign: TextAlign.center, style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image.network es la magia que descarga el GIF de internet
            Image.network(
              url,
              // Si pusiste un enlace roto en Django, mostramos este ícono para que la app no colapse
              errorBuilder: (context, error, stackTrace) => const Column(
                children: [
                  Icon(Icons.broken_image, size: 50, color: Colors.grey),
                  Text('Enlace de imagen roto', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar', style: TextStyle(fontSize: 18)),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<dynamic> senas = widget.modulo['senas'] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.modulo['titulo']),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: Colors.teal[50],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Descripción:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.teal)),
                const SizedBox(height: 8),
                Text(widget.modulo['descripcion'] ?? 'Sin descripción', style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Señas en este módulo:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: senas.isEmpty
                ? const Center(child: Text('Aún no hay señas en este módulo.'))
                : ListView.builder(
                    itemCount: senas.length,
                    itemBuilder: (context, index) {
                      final sena = senas[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListTile(
                          leading: const Icon(Icons.play_circle_fill, color: Colors.teal, size: 36),
                          title: Text(sena['palabra'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          trailing: IconButton(
                            icon: const Icon(Icons.favorite_border, color: Colors.red),
                            onPressed: () => _agregarAFavoritas(sena['id'], sena['palabra']),
                          ),
                          onTap: () {
                            // Al tocar la tarjeta, llamamos a la ventana emergente
                            _mostrarImagenSena(sena['palabra'], sena['url_multimedia']);
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}