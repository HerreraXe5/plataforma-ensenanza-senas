import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class EvaluacionesScreen extends StatefulWidget {
  const EvaluacionesScreen({super.key});

  @override
  State<EvaluacionesScreen> createState() => _EvaluacionesScreenState();
}

class _EvaluacionesScreenState extends State<EvaluacionesScreen> {
  bool _cargando = true;
  List<dynamic> _modulosConQuiz = [];
  
  // Variables del Quiz en progreso
  Map<String, dynamic>? _moduloSeleccionado;
  List<dynamic> _preguntas = [];
  int _preguntaActual = 0;
  int _aciertos = 0;
  bool _quizTerminado = false;
  int _puntajeFinal = 0;

  @override
  void initState() {
    super.initState();
    _fetchModulos();
  }

  // 1. Descargar módulos y ver cuáles tienen preguntas
  Future<void> _fetchModulos() async {
    try {
      final response = await http.get(Uri.parse('http://127.0.0.1:8000/api/modulos/'));
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          // Filtramos: Solo mostramos módulos que tengan al menos 1 pregunta
          _modulosConQuiz = data.where((mod) => mod['preguntas'].length > 0).toList();
          _cargando = false;
        });
      }
    } catch (e) {
      setState(() { _cargando = false; });
    }
  }

  // 2. Iniciar un Quiz
  void _iniciarQuiz(Map<String, dynamic> modulo) {
    setState(() {
      _moduloSeleccionado = modulo;
      _preguntas = modulo['preguntas'];
      _preguntaActual = 0;
      _aciertos = 0;
      _quizTerminado = false;
    });
  }

  // 3. Evaluar la respuesta elegida
  void _responderPregunta(int opcionSeleccionada) {
    final correcta = _preguntas[_preguntaActual]['respuesta_correcta'];
    
    // Si la opción que tocó (1, 2, 3 o 4) es igual a la correcta de la base de datos
    if (opcionSeleccionada == correcta) {
      _aciertos++;
    }

    if (_preguntaActual < _preguntas.length - 1) {
      setState(() {
        _preguntaActual++;
      });
    } else {
      // Si era la última pregunta, calculamos el porcentaje (Regla de 3)
      _puntajeFinal = ((_aciertos / _preguntas.length) * 100).round();
      _guardarResultadoBackend();
      setState(() {
        _quizTerminado = true;
      });
    }
  }

  // 4. Enviar la calificación al historial de la base de datos
  Future<void> _guardarResultadoBackend() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return;

    await http.post(
      Uri.parse('http://127.0.0.1:8000/api/historial/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'modulo': _moduloSeleccionado!['id'],
        'puntaje': _puntajeFinal,
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_moduloSeleccionado == null ? 'Evaluaciones' : 'Quiz: ${_moduloSeleccionado!['titulo']}'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _construirCuerpo(),
    );
  }

  // Máquina de estados para saber qué pantalla mostrar
  Widget _construirCuerpo() {
    if (_modulosConQuiz.isEmpty) {
      return const Center(child: Text('Aún no hay evaluaciones creadas por el administrador.'));
    }

    if (_moduloSeleccionado == null) {
      // ESTADO 1: Seleccionar qué quiz tomar
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _modulosConQuiz.length,
        itemBuilder: (context, index) {
          final mod = _modulosConQuiz[index];
          return Card(
            elevation: 3,
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              leading: const Icon(Icons.quiz, color: Colors.orange, size: 40),
              title: Text('Evaluación: ${mod['titulo']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              subtitle: Text('${mod['preguntas'].length} preguntas disponibles'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _iniciarQuiz(mod),
            ),
          );
        },
      );
    }

    if (_quizTerminado) {
      // ESTADO 3: Resultados
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.emoji_events, color: _puntajeFinal >= 80 ? Colors.amber : Colors.grey, size: 100),
            const SizedBox(height: 24),
            const Text('¡Evaluación Finalizada!', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Text('Puntaje: $_puntajeFinal%', style: TextStyle(fontSize: 24, color: _puntajeFinal >= 80 ? Colors.green : Colors.orange, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Acertaste $_aciertos de ${_preguntas.length} preguntas'),
            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16)),
              onPressed: () {
                // Volvemos a la lista de selección
                setState(() { _moduloSeleccionado = null; });
              },
              child: const Text('Volver a Evaluaciones', style: TextStyle(fontSize: 16)),
            )
          ],
        ),
      );
    }

    // ESTADO 2: Haciendo el Quiz (Pregunta activa)
    final preguntaActiva = _preguntas[_preguntaActual];
    // Agrupamos las opciones para mostrarlas fácil
    final opciones = [
      preguntaActiva['opcion_1'],
      preguntaActiva['opcion_2'],
      preguntaActiva['opcion_3'],
      preguntaActiva['opcion_4'],
    ];

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Pregunta ${_preguntaActual + 1} de ${_preguntas.length}', style: const TextStyle(fontSize: 18, color: Colors.grey)),
          const SizedBox(height: 16),
          // La pregunta
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(color: Colors.teal[50], borderRadius: BorderRadius.circular(16)),
            child: Text(
              preguntaActiva['texto'],
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.teal),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
          // Los 4 botones de respuesta
          ...List.generate(
            opciones.length,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(20),
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.teal,
                  side: const BorderSide(color: Colors.teal),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                // Se envía index + 1 porque en Django las respuestas son 1, 2, 3 o 4
                onPressed: () => _responderPregunta(index + 1),
                child: Text(opciones[index], style: const TextStyle(fontSize: 18)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}