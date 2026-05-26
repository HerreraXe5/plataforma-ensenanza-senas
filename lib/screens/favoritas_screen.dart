import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritasScreen extends StatefulWidget {
  const FavoritasScreen({super.key});

  @override
  State<FavoritasScreen> createState() => _FavoritasScreenState();
}

class _FavoritasScreenState extends State<FavoritasScreen> {
  List<dynamic> _favoritas = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _fetchFavoritas();
  }

  Future<void> _fetchFavoritas() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) return;

    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/favoritas/'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        setState(() {
          _favoritas = jsonDecode(utf8.decode(response.bodyBytes));
          _cargando = false;
        });
      } else {
        setState(() { _cargando = false; });
      }
    } catch (e) {
      setState(() { _cargando = false; });
    }
  }

  Future<void> _eliminarFavorita(int id, int index) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    
    final response = await http.delete(
      Uri.parse('http://127.0.0.1:8000/api/favoritas/$id/'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 204) {
      setState(() { _favoritas.removeAt(index); });
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Eliminada de favoritas')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis Señas Favoritas'), backgroundColor: Colors.teal, foregroundColor: Colors.white),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _favoritas.isEmpty
              ? const Center(child: Text('Aún no tienes señas favoritas guardadas.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _favoritas.length,
                  itemBuilder: (context, index) {
                    final fav = _favoritas[index];
                    final senaDetalle = fav['sena_detalle'];
                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ListTile(
                        leading: const Icon(Icons.favorite, color: Colors.red, size: 30),
                        title: Text(senaDetalle['palabra'], style: const TextStyle(fontWeight: FontWeight.bold)),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => _eliminarFavorita(fav['id'], index),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}