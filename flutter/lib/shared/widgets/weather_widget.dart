import 'package:flutter/material.dart';
import '../../services/weather_service.dart';

class WeatherWidget extends StatefulWidget {
  const WeatherWidget({super.key});

  @override
  State<WeatherWidget> createState() => _WeatherWidgetState();
}

class _WeatherWidgetState extends State<WeatherWidget> {
  final WeatherService _weatherService = WeatherService();
  WeatherData? _weatherData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWeather();
  }

  Future<void> _loadWeather() async {
    final weather = await _weatherService.getCurrentWeather();
    if (mounted) {
      setState(() {
        _weatherData = weather;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    if (_weatherData == null) {
      return const Icon(Icons.cloud_off, size: 20);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _weatherData!.weatherIcon,
          style: const TextStyle(fontSize: 18),
        ),
        const SizedBox(width: 4),
        Text(
          '${_weatherData!.temperature.toStringAsFixed(1)}°C',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 4),
        Tooltip(
          message: _weatherData!.weatherDescription,
          child: const Icon(
            Icons.info_outline,
            size: 16,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}
