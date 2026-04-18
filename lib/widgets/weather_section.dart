import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import '../services/weather_service.dart';

class WeatherSection extends StatefulWidget {
  const WeatherSection({super.key});

  @override
  State<WeatherSection> createState() => _WeatherSectionState();
}

class _WeatherSectionState extends State<WeatherSection> {
  final WeatherService _weatherService = WeatherService();
  WeatherData? _weatherData;
  bool _isLoading = true;
  String? _errorMessage;
  String _currentCity = 'Dhaka'; // Default city

  @override
  void initState() {
    super.initState();
    _fetchWeatherData();
  }

  Future<void> _fetchWeatherData({String? cityName, bool isAuto = true}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      double lat, lon;

      if (cityName != null) {
        // Fetch specific city
        final coords = await _weatherService.fetchCoordinatesByCity(cityName);
        lat = coords['lat']!;
        lon = coords['lon']!;
      } else {
        // Automatic location detection with 5s timeout
        bool serviceEnabled;
        LocationPermission permission;

        serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          throw Exception('Location services are disabled.');
        }

        permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
          if (permission == LocationPermission.denied) {
            throw Exception('Location permissions are denied');
          }
        }

        // timeout after 5 seconds
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.low,
        ).timeout(const Duration(seconds: 5), onTimeout: () {
          throw Exception('Location request timed out. Please select manually.');
        });

        lat = position.latitude;
        lon = position.longitude;
      }

      final weather = await _weatherService.fetchWeather(lat, lon);

      if (mounted) {
        setState(() {
          _weatherData = weather;
          _isLoading = false;
          _currentCity = weather.city;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
        // If auto fails, maybe try default city if we have no data at all
        if (cityName == null && _weatherData == null) {
          _fetchWeatherData(cityName: 'Dhaka', isAuto: false);
        }
      }
    }
  }

  void _showLocationSearch() {
    String searchCity = "";
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Location', style: TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Enter city name (e.g. Dhaka, London)',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) => searchCity = value,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.black38)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              if (searchCity.isNotEmpty) {
                _fetchWeatherData(cityName: searchCity);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent),
            child: const Text('Update', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Weather Updates',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF455A64),
                ),
              ),
              Row(
                children: [
                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.only(right: 8.0),
                      child: SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.orangeAccent)),
                    ),
                  TextButton(
                    onPressed: _isLoading ? null : _showLocationSearch,
                    child: Text(_isLoading ? 'Updating...' : 'Set Location', style: const TextStyle(color: Colors.orangeAccent, fontSize: 13, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(
          height: 140,
          child: _isLoading && _weatherData == null
            ? _buildLoadingState()
            : _errorMessage != null && _weatherData == null
              ? _buildErrorState()
              : ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(left: 24),
                  children: [
                    _buildMainWeatherCard(),
                    ...(_weatherData?.daily.map((forecast) => 
                      _buildDailyWeather(forecast.day, forecast.temp, forecast.icon)
                    ).toList() ?? []),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Colors.orangeAccent),
          const SizedBox(height: 12),
          Text('Fetching weather...', style: TextStyle(color: Colors.black.withOpacity(0.3), fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Unable to get location', style: TextStyle(color: Colors.black.withOpacity(0.4))),
          TextButton(
            onPressed: _showLocationSearch,
            child: const Text('Select City Manually', style: TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildMainWeatherCard() {
    if (_weatherData == null) return const SizedBox();
    
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
          ),
        ],
      ),
      child: Stack(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _weatherData!.city, 
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      DateFormat('EEEE').format(DateTime.now()), 
                      style: const TextStyle(color: Colors.black38, fontSize: 12)
                    ),
                    const Spacer(),
                    Text(
                      '${_weatherData!.temperature.round()}°C', 
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.orangeAccent)
                    ),
                    Text(_weatherData!.condition, style: const TextStyle(color: Colors.black38, fontSize: 12)),
                  ],
                ),
              ),
              Icon(_weatherData!.icon, size: 48, color: Colors.orangeAccent),
            ],
          ),
          Positioned(
            right: 0,
            top: 0,
            child: GestureDetector(
              onTap: _showLocationSearch,
              child: Icon(Icons.edit_location_alt_outlined, size: 16, color: Colors.black.withOpacity(0.1)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyWeather(String day, String temp, IconData icon) {
    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.orangeAccent),
          const SizedBox(height: 12),
          Text(temp, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(day, style: const TextStyle(color: Colors.black38, fontSize: 12)),
        ],
      ),
    );
  }
}
