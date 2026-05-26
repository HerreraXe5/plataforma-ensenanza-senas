import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class HistorialScreen extends StatefulWidget {
  const HistorialScreen({super.key});

  @override
  State<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  List<dynamic> _historial = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _fetchHistorial();
  }

  Future<void> _fetchHistorial() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) return;

    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/historial/'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        setState(() {
          _historial = jsonDecode(utf8.decode(response.bodyBytes));
          _cargando = false;
        });
      } else {
        setState(() { _cargando = false; });
      }
    } catch (e) {
      setState(() { _cargando = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Historial de Evaluaciones'), backgroundColor: Colors.teal, foregroundColor: Colors.white),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _historial.isEmpty
              ? const Center(child: Text('Aún no has completado ninguna evaluación.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _historial.length,
                  itemBuilder: (context, index) {
                    final registro = _historial[index];
                    final puntaje = registro['puntaje'];
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: puntaje >= 80 ? Colors.green : Colors.orange,
                          child: const Icon(Icons.assignment_turned_in, color: Colors.white),
                        ),
                        title: Text('Módulo: ${registro['modulo_titulo']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        trailing: Text(
                          '$puntaje%',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: puntaje >= 80 ? Colors.green : Colors.orange),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}