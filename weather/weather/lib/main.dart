import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2196F3),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      home: const MyHomePage(title: 'Weather'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class WeatherService {
  Future<Map<String, dynamic>> fetchWeather(
    double latitude,
    double longitude,
  ) async {
    const apiKey =
        '1798f91b4b0f6d11f3e52c68849797bb'; // Replace with your API key
    final url = Uri.parse(
      'https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&appid=$apiKey&units=metric',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load weather data');
    }
  }
}

class _MyHomePageState extends State<MyHomePage> {
  String _weatherInfo = 'Fetching weather...';
  Map<String, dynamic>? _weatherData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getWeather();
  }

  Future<void> _getWeather() async {
    setState(() {
      _isLoading = true;
    });

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      WeatherService weatherService = WeatherService();
      Map<String, dynamic> weatherData = await weatherService.fetchWeather(
        position.latitude,
        position.longitude,
      );

      setState(() {
        _weatherData = weatherData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _weatherInfo = 'Failed to fetch weather: $e';
        _isLoading = false;
      });
    }
  }

  String _getWeatherIcon(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear sky':
        return '☀️';
      case 'few clouds':
        return '🌤️';
      case 'scattered clouds':
        return '☁️';
      case 'broken clouds':
        return '☁️';
      case 'shower rain':
        return '🌧️';
      case 'rain':
        return '🌧️';
      case 'thunderstorm':
        return '⛈️';
      case 'snow':
        return '🌨️';
      case 'mist':
        return '🌫️';
      default:
        return '☁️';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          widget.title,
          style: const TextStyle(color: Colors.black87),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black87),
            onPressed: _getWeather,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _getWeather,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (_weatherData != null) ...[
                        Text(
                          _weatherData!['name'],
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          _getWeatherIcon(_weatherData!['weather'][0]['description']),
                          style: const TextStyle(fontSize: 72),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          '${_weatherData!['main']['temp'].round()}°C',
                          style: const TextStyle(
                            fontSize: 64,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        Text(
                          _weatherData!['weather'][0]['description']
                              .toString()
                              .toUpperCase(),
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.black54,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 30),
                        _buildWeatherDetailsCard(),
                      ] else
                        Text(_weatherInfo),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildWeatherDetailsCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildWeatherDetail(
              'Humidity',
              '${_weatherData!['main']['humidity']}%',
              Icons.water_drop,
            ),
            const Divider(),
            _buildWeatherDetail(
              'Wind Speed',
              '${_weatherData!['wind']['speed']} m/s',
              Icons.air,
            ),
            const Divider(),
            _buildWeatherDetail(
              'Pressure',
              '${_weatherData!['main']['pressure']} hPa',
              Icons.speed,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherDetail(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).primaryColor),
          const SizedBox(width: 16),
          Text(
            label,
            style: const TextStyle(fontSize: 16),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
