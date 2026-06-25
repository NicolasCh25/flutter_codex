import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter GPS Codex',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
      ),
      home: const GpsCodexPage(),
    );
  }
}

class GpsCodexPage extends StatefulWidget {
  const GpsCodexPage({super.key});

  @override
  State<GpsCodexPage> createState() => _GpsCodexPageState();
}

class _GpsCodexPageState extends State<GpsCodexPage> {
  // Declara las variables para latitude, longitude y errorMessage inicializadas vacias
  String _latitude = '';
  String _longitude = '';
  String _errorMessage = '';
  bool _isLoading = false;

  // Define el metodo asincrono para verificar permisos, obtener la posicion actual con alta precision y manejar errores por codigo
  Future<void> _obtenerUbicacion() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Llama a Geolocator.checkPermission() para verificar el estado de los permisos
      LocationPermission permission = await Geolocator.checkPermission();
      
      // Si los permisos estan denegados o denegados para siempre muestra un mensaje informando que los active
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _errorMessage = 'Permiso de ubicación denegado por el usuario.';
          });
          return;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _errorMessage = 'El permiso está denegado permanentemente. Habilítelo en la configuración.';
        });
        return;
      }

      // Llama a Geolocator.getCurrentPosition pasando opciones de alta precision
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high
      );

      // Asigna las coordenadas obtenidas a las variables de estado correspondientes
      setState(() {
        _latitude = position.latitude.toString();
        _longitude = position.longitude.toString();
      });
    } catch (e) {
      // Dentro del catch maneja el error si el GPS del dispositivo esta apagado o no disponible
      setState(() {
        _errorMessage = 'El GPS o los servicios de ubicación están apagados/no disponibles.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Crea la funcion para verificar que las coordenadas existan y abrir la url externa de Google Maps
  Future<void> _abrirMapa() async {
    final Uri url = Uri.parse('https://www.google.com/maps?q=${_latitude},$_longitude');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Un encabezado (AppBar) con color azul y el título "Ubicación GPS".
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ubicación GPS'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Un icono grande "location-outline" de color azul en el centro.
            const Icon(Icons.location_searching, size: 60, color: Colors.blue),
            const SizedBox(height: 20),
            
            // Dos tarjetas (Card) de color "light" para mostrar la Latitud y la Longitud solo si ya se obtuvieron las coordenadas
            if (_latitude.isNotEmpty && _longitude.isNotEmpty) ...[
              Card(
                color: Colors.grey[200],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('Latitud: $_latitude', textAlign: TextAlign.center, style: const TextStyle(fontSize: 18)),
                ),
              ),
              Card(
                color: Colors.grey[200],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('Longitud: $_longitude', textAlign: TextAlign.center, style: const TextStyle(fontSize: 18)),
                ),
              ),
              const SizedBox(height: 10),
              
              // Un botón de color verde (success) que diga "Abrir en Google Maps" y que use la función abriéndose en otra pestaña.
              ElevatedButton.icon(
                onPressed: _abrirMapa,
                icon: const Icon(Icons.map, color: Colors.white),
                label: const Text('Abrir en Google Maps', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              ),
            ],
            
            // Un mensaje de error en texto rojo si la variable errorMessage tiene datos.
            if (_errorMessage.isNotEmpty) ...[
              const SizedBox(height: 15),
              Text(
                _errorMessage, 
                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ],
            
            const SizedBox(height: 20),
            
            // Un botón principal al final de la página que diga "Obtener Ubicación Actual" y que execute la función al hacer click.
            ElevatedButton(
              onPressed: _isLoading ? null : _obtenerUbicacion,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: Text(_isLoading ? 'Cargando...' : 'Obtener Ubicación Actual', style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}