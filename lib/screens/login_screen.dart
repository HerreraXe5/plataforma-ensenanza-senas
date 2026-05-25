import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200], // Fondo gris claro para resaltar la tarjeta
      body: Center(
        child: SizedBox(
          width: 400, // Ancho máximo para que se vea bien en web
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min, // Se ajusta al contenido
                children: [
                  const Icon(
                    Icons.sign_language,
                    size: 80,
                    color: Colors.teal,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Bienvenido a SignLearn',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Campo de Correo
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Correo Electrónico',
                      prefixIcon: const Icon(Icons.email),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Campo de Contraseña
                  TextField(
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      prefixIcon: const Icon(Icons.lock),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Botón de Iniciar Sesión
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        // Aquí luego pondremos la navegación al Dashboard
                        print("Intentando iniciar sesión...");
                      },
                      child: const Text(
                        'Iniciar Sesión',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}