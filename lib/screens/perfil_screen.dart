import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  String _username = "Cargando...";
  String _email = "Cargando...";
  String _rol = "Cargando...";
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _fetchPerfil();
  }

  Future<void> _fetchPerfil() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) return;

    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/perfil/'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          // Capitaliza la primera letra del usuario
          _username = data['username'].toString().replaceFirst(
              data['username'][0], data['username'][0].toUpperCase());
          
          _email = data['email'] == "" ? "No registrado" : data['email'];
          
          // Verifica el booleano is_staff que viene de Django
          _rol = data['is_staff'] ? "Administrador" : "Estudiante Aprendiz";
          _cargando = false;
        });
      } else {
        setState(() {
          _username = "Error al cargar";
          _cargando = false;
        });
      }
    } catch (e) {
      setState(() {
        _username = "Error de conexión";
        _cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: _rol == "Administrador" ? Colors.orange : Colors.teal,
                      child: Icon(
                        _rol == "Administrador" ? Icons.admin_panel_settings : Icons.person, 
                        size: 80, 
                        color: Colors.white
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      _username,
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.teal),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Rol: $_rol',
                      style: TextStyle(
                        fontSize: 16, 
                        fontWeight: FontWeight.bold,
                        color: _rol == "Administrador" ? Colors.orange : Colors.grey
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.email, color: Colors.teal),
                      title: const Text('Correo Electrónico'),
                      subtitle: Text(_email),
                    ),
                    const ListTile(
                      leading: Icon(Icons.lock, color: Colors.teal),
                      title: Text('Contraseña'),
                      subtitle: Text('********'),
                    ),
                    const Divider(),
                    const Spacer(),
                    const Text('SignLearn v1.0', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ),
    );
  }
}