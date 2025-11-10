import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  static const String _baseUrl = 'https://api.open-meteo.com/v1/forecast';
  static const double _latitude = -33.45;
  static const double _longitude = -70.67;

  Future<WeatherData?> getCurrentWeather() async {
    try {
      final url = Uri.parse(
        '$_baseUrl?latitude=$_latitude&longitude=$_longitude&current_weather=true',
      );
      
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return WeatherData.fromJson(data['current_weather']);
      }
      return null;
    } catch (e) {
      // ignore: avoid_print
      print('Error fetching weather: $e');
      return null;
    }
  }
}

class WeatherData {
  final double temperature;
  final double windSpeed;
  final int windDirection;
  final int weatherCode;
  final int isDay;

  WeatherData({
    required this.temperature,
    required this.windSpeed,
    required this.windDirection,
    required this.weatherCode,
    required this.isDay,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      temperature: (json['temperature'] as num).toDouble(),
      windSpeed: (json['windspeed'] as num).toDouble(),
      windDirection: json['winddirection'] as int,
      weatherCode: json['weathercode'] as int,
      isDay: json['is_day'] as int,
    );
  }

  String get weatherDescription {
    // WMO Weather interpretation codes
    switch (weatherCode) {
      case 0:
        return 'Despejado';
      case 1:
      case 2:
      case 3:
        return 'Parcialmente nublado';
      case 45:
      case 48:
        return 'Niebla';
      case 51:
      case 53:
      case 55:
        return 'Llovizna';
      case 61:
      case 63:
      case 65:
        return 'Lluvia';
      case 71:
      case 73:
      case 75:
        return 'Nieve';
      case 77:
        return 'Granizo';
      case 80:
      case 81:
      case 82:
        return 'Aguacero';
      case 85:
      case 86:
        return 'Nevada';
      case 95:
        return 'Tormenta';
      case 96:
      case 99:
        return 'Tormenta con granizo';
      default:
        return 'Desconocido';
    }
  }

  String get weatherIcon {
    // Returns appropriate weather icon
    if (weatherCode == 0) {
      return isDay == 1 ? '☀️' : '🌙';
    } else if (weatherCode <= 3) {
      return '⛅';
    } else if (weatherCode <= 48) {
      return '🌫️';
    } else if (weatherCode <= 65) {
      return '🌧️';
    } else if (weatherCode <= 77) {
      return '❄️';
    } else if (weatherCode <= 82) {
      return '🌦️';
    } else if (weatherCode <= 86) {
      return '🌨️';
    } else {
      return '⛈️';
    }
  }
}
