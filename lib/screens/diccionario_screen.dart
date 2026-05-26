import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DiccionarioScreen extends StatefulWidget {
  const DiccionarioScreen({super.key});

  @override
  State<DiccionarioScreen> createState() => _DiccionarioScreenState();
}

class _DiccionarioScreenState extends State<DiccionarioScreen> {
  List<dynamic> _senas = [];
  List<dynamic> _senasFiltradas = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _fetchSenas();
  }

  // Petición GET a la base de datos a través de Django
  Future<void> _fetchSenas() async {
    try {
      final response = await http.get(Uri.parse('http://127.0.0.1:8000/api/senas/'));
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes)); // utf8.decode para los acentos
        setState(() {
          _senas = data;
          _senasFiltradas = data;
          _cargando = false;
        });
      } else {
        setState(() { _cargando = false; });
      }
    } catch (e) {
      setState(() { _cargando = false; });
    }
  }

  // Lógica del buscador en tiempo real
  void _filtrarSenas(String texto) {
    setState(() {
      if (texto.isEmpty) {
        _senasFiltradas = _senas;
      } else {
        _senasFiltradas = _senas.where((sena) => 
          sena['palabra'].toString().toLowerCase().contains(texto.toLowerCase())
        ).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diccionario de Señas'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Barra de Búsqueda
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: _filtrarSenas,
              decoration: InputDecoration(
                labelText: 'Buscar seña...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          
          // Lista de Resultados
          Expanded(
            child: _cargando
                ? const Center(child: CircularProgressIndicator())
                : _senasFiltradas.isEmpty
                    ? const Center(child: Text('No se encontraron señas. Asegúrate de agregarlas desde el Admin de Django.', textAlign: TextAlign.center))
                    : ListView.builder(
                        itemCount: _senasFiltradas.length,
                        itemBuilder: (context, index) {
                          final sena = _senasFiltradas[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: ListTile(
                              leading: const Icon(Icons.sign_language, color: Colors.teal, size: 30),
                              title: Text(sena['palabra'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                              subtitle: const Text('Toca para ver el detalle de la seña'),
                              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                              onTap: () {
                                // Muestra un pequeño aviso en la parte de abajo con la URL de la imagen/GIF
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('URL a reproducir: ${sena['url_multimedia']}'),
                                    duration: const Duration(seconds: 3),
                                  ),
                                );
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