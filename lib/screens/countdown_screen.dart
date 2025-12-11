import 'package:darjeeling_countdown/core/services/weather_service.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:ui';
import '../widgets/flip_clock_digit.dart';

class CountdownScreen extends StatefulWidget {
  const CountdownScreen({Key? key}) : super(key: key);

  @override
  State<CountdownScreen> createState() => _CountdownScreenState();
}

class _CountdownScreenState extends State<CountdownScreen> {
  late DateTime targetDate;
  Timer? timer;
  Timer? weatherTimer;
  late WeatherService weatherService;

  int days = 0;
  int hours = 0;
  int minutes = 0;
  int seconds = 0;

  Map<String, dynamic>? weatherData;
  bool isLoadingWeather = true;
  bool showCelebration = false;

  @override
  void initState() {
    super.initState();
    // Set your tour date here
    targetDate = DateTime(2026, 1, 9, 22, 15, 0);

    // Initialize weather service
    weatherService = WeatherService('57b52f0c6dd995e6d34f0663ebb87f81');
    _fetchWeather();

    _updateCountdown();
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      _updateCountdown();
    });

    weatherTimer = Timer.periodic(const Duration(hours: 2), (Timer t) {
      _fetchWeather();
    });
  }

  Future<void> _fetchWeather() async {
    try {
      final data = await weatherService.getWeatherForDarjeeling();
      if (mounted) {
        setState(() {
          weatherData = data;
          isLoadingWeather = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoadingWeather = false;
        });
      }
      print('Error fetching weather: $e');
    }
  }

  void _updateCountdown() {
    final now = DateTime.now();
    final difference = targetDate.difference(now);

    if (difference.isNegative || difference.inSeconds <= 0) {
      timer?.cancel();
      if (mounted) {
        setState(() {
          days = 0;
          hours = 0;
          minutes = 0;
          seconds = 0;
          showCelebration = true;
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        days = difference.inDays;
        hours = difference.inHours % 24;
        minutes = difference.inMinutes % 60;
        seconds = difference.inSeconds % 60;
        showCelebration = false;
      });
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    weatherTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.indigo.shade900,
              Colors.purple.shade800,
              Colors.deepPurple.shade900,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Header
                const Icon(Icons.landscape, size: 50, color: Colors.white70),
                const SizedBox(height: 15),
                const Text(
                  'Darjeeling Tour',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Via Vitae Solutions',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.7),
                    letterSpacing: 2,
                  ),
                ),

                const SizedBox(height: 30),

                // Weather Card
                _buildWeatherCard(),

                const SizedBox(height: 30),

                // Countdown or Celebration
                showCelebration ? _buildCelebration() : _buildCountdown(),

                const SizedBox(height: 30),

                // Footer
                Text(
                  showCelebration
                      ? 'Have a wonderful journey! 🎉'
                      : 'Get ready for the journey! 🏔️',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.6),
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCelebration() {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.pink.withOpacity(0.3),
            Colors.purple.withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
      ),
      child: Column(
        children: [
          const Icon(Icons.celebration, size: 60, color: Colors.white),
          const SizedBox(height: 20),
          const Text(
            'Happy Journey!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '🎊 Time to explore Darjeeling! 🎊',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.15),
                Colors.white.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: isLoadingWeather
              ? _buildLoadingWeather()
              : weatherData != null
              ? _buildWeatherContent()
              : _buildWeatherError(),
        ),
      ),
    );
  }

  Widget _buildLoadingWeather() {
    return const Column(
      children: [
        CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
        ),
        SizedBox(height: 16),
        Text(
          'Loading weather...',
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildWeatherContent() {
    final temp = weatherData!['main']['temp'].round();
    final humidity = weatherData!['main']['humidity'];
    final windSpeed = weatherData!['wind']['speed'];
    final pressure = weatherData!['main']['pressure'];
    final visibility = (weatherData!['visibility'] / 1000).toStringAsFixed(1);
    final description = weatherData!['weather'][0]['description'];
    final icon = weatherData!['weather'][0]['icon'];

    return Column(
      children: [
        // Temperature Section
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$temp',
                        style: const TextStyle(
                          fontSize: 56,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1,
                        ),
                      ),
                      const Text(
                        '°C',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white70,
                          height: 2.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    description.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.8),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Darjeeling',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            Image.network(
              'https://openweathermap.org/img/wn/$icon@2x.png',
              width: 70,
              height: 70,
              color: Colors.white.withOpacity(0.9),
              colorBlendMode: BlendMode.modulate,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.wb_sunny,
                  size: 50,
                  color: Colors.white70,
                );
              },
            ),
          ],
        ),

        const SizedBox(height: 15),

        // Divider
        Container(
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                Colors.white.withOpacity(0.3),
                Colors.transparent,
              ],
            ),
          ),
        ),

        const SizedBox(height: 15),

        // Weather Details
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildWeatherDetail(Icons.water_drop, '$humidity%', 'Humidity'),
            _buildWeatherDetail(Icons.air, '$windSpeed\nkm/h', 'Wind'),
            _buildWeatherDetail(Icons.speed, '$pressure\nhPa', 'Pressure'),
            _buildWeatherDetail(
              Icons.visibility,
              '$visibility\nkm',
              'Visibility',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWeatherDetail(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 18),
        const SizedBox(height: 5),
        Text(
          value,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 9),
        ),
      ],
    );
  }

  Widget _buildWeatherError() {
    return Column(
      children: [
        Icon(
          Icons.error_outline,
          color: Colors.white.withOpacity(0.7),
          size: 40,
        ),
        const SizedBox(height: 12),
        const Text(
          'N/A',
          style: TextStyle(color: Colors.white70, fontSize: 18),
        ),
      ],
    );
  }

  Widget _buildCountdown() {
    return Column(
      children: [
        Text(
          'COUNTDOWN',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.6),
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 20),
        // Days in full width
        _buildTimeUnit('DAYS', days, isFullWidth: true),
        const SizedBox(height: 20),
        // Hours, Minutes, Seconds in row
        Row(
          children: [
            Expanded(child: _buildTimeUnit('HRS', hours)),
            const SizedBox(width: 8),
            Expanded(child: _buildTimeUnit('MIN', minutes)),
            const SizedBox(width: 8),
            Expanded(child: _buildTimeUnit('SEC', seconds)),
          ],
        ),
      ],
    );
  }

  Widget _buildTimeUnit(String label, int value, {bool isFullWidth = false}) {
    final valueStr = value.toString().padLeft(2, '0');

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          constraints: BoxConstraints(
            maxWidth: isFullWidth ? double.infinity : 120,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: valueStr.split('').map((digit) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: _buildDigit(digit),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.6),
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildDigit(String digit) {
    return Container(
      width: 42,
      height: 58,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Center(
        child: Text(
          digit,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
