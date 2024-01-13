import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:wifapp/glassmorphism.dart';
// import 'package:english_words/english_words.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen>
    with SingleTickerProviderStateMixin {
  static DateTime? _lastCallTime;
  static Map<String, dynamic>? _cachedWeatherData;
  bool _isLoading = true;
  late AnimationController _controller;

  final List<Color> colors = [
    Colors.white,
    const Color.fromARGB(255, 178, 116, 189),
    const Color.fromARGB(255, 214, 183, 219),
    Colors.white,
    const Color.fromARGB(255, 214, 183, 219),
    Colors.white, // End with the same color as you started
  ];

  List<Color> getGradientColors(double value, List<Color> colors) {
    // Use a smoother, slower transition function
    double transformedValue = (1 - math.cos(value * 2 * math.pi)) / 2;

    final int index = (transformedValue * (colors.length - 1)).floor();
    final Color startColor = colors[index];
    final Color endColor = colors[(index + 1) % colors.length];
    final double localValue = (transformedValue * (colors.length - 1)) - index;

    return [
      Color.lerp(startColor, endColor, localValue)!,
      Color.lerp(startColor, endColor, localValue)!.withOpacity(1),
      endColor,
    ];
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat(); // or use some other repeating logic if needed

    print(_controller.isAnimating);
    _loadWeatherData();
  }

  void _loadWeatherData() {
    final now = DateTime.now();
    if (_lastCallTime == null ||
        now.difference(_lastCallTime!).inMinutes >= 10) {
      _fetchWeatherData();
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> incrementApiCallCount() async {
    final prefs = await SharedPreferences.getInstance();
    final lastApiCallDate = prefs.getString('lastApiCallDate');
    final currentDate = DateTime.now().toIso8601String().split('T')[0];

    if (lastApiCallDate != currentDate) {
      prefs.setInt('apiCallCount', 0); // Reset if new day
      prefs.setString('lastApiCallDate', currentDate);
    }

    int currentCount = prefs.getInt('apiCallCount') ?? 0;
    prefs.setInt('apiCallCount', currentCount + 1);
  }

  Future<void> _fetchWeatherData() async {
    setState(() {
      _isLoading = true;
    });

    final apiKey = dotenv.env['OPENWEATHERMAP_API_KEY'];
    var city = 'Avignon'; // Example city
    var url =
        'http://api.openweathermap.org/data/2.5/weather?q=$city&units=metric&appid=$apiKey';

    await incrementApiCallCount();

    try {
      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        _lastCallTime = DateTime.now();
        _cachedWeatherData = json.decode(response.body);
      } else {
        // Handle the error; perhaps show an alert dialog
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      // Handle the error; perhaps show an alert dialog
      print(Exception(e));
    }

    setState(() {
      _isLoading = false;
    });
  }

  String getWeatherIconCode() {
    if (_cachedWeatherData != null) {
      return _cachedWeatherData?['weather'][0]['icon'];
    }
    return '01d'; // Default icon code
  }

  String getIconUrl(String iconCode) {
    return 'https://openweathermap.org/img/wn/$iconCode@2x.png';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        // background image
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/avignon.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),

        //content
        Center(
          child: _isLoading
              ? const CircularProgressIndicator() // show loading indicator
              : _cachedWeatherData == null
                  ? const Text('No data available') // show error message
                  : buildWeatherContent(context), // show weather data
        ),
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: _fetchWeatherData,
        tooltip: 'Refresh',
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget buildWeatherContent(BuildContext context) {
    // Temperature conversion
    double tempCelsiusData = _cachedWeatherData?['main']['temp'] ?? 0.0;
    int tempCelsius = tempCelsiusData.round();
    int tempFahrenheit = (tempCelsius * 9 / 5 + 32).round();

    // Sunrise and Sunset time conversion
    int sunriseTimestamp = _cachedWeatherData?['sys']['sunrise'] ?? 0;
    int sunsetTimestamp = _cachedWeatherData?['sys']['sunset'] ?? 0;
    DateTime sunriseTime =
        DateTime.fromMillisecondsSinceEpoch(sunriseTimestamp * 1000).toUtc();
    DateTime sunsetTime =
        DateTime.fromMillisecondsSinceEpoch(sunsetTimestamp * 1000).toUtc();
    String sunrise = DateFormat('hh:mm a')
        .format(sunriseTime); // Using DateFormat from intl package
    String sunset = DateFormat('hh:mm a').format(sunsetTime);
    // weather content
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final List<Color> gradientColors =
                getGradientColors(_controller.value, colors);

            return Center(
              child: Stack(
                children: [
                  // Shadow (Black and slightly offset text)
                  Positioned(
                    left: 4.0, // Horizontal offset
                    top: 4.0, // Vertical offset
                    child: Text(
                      '${_cachedWeatherData!['main']['temp'].round()}°',
                      style: const TextStyle(
                        fontSize: 120,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 78, 16, 89),
                      ),
                    ),
                  ),

                  // Gradient Text
                  ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: gradientColors,
                      ).createShader(bounds);
                    },
                    child: Text(
                      '${_cachedWeatherData!['main']['temp'].round()}°',
                      style: const TextStyle(
                        fontSize: 120,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        // Spacer after the temperature
        const SizedBox(height: 30),
        // Inside your build method or another widget
        Image.network(getIconUrl(getWeatherIconCode())),
        Text(
          '${_cachedWeatherData!['weather'][0]['main']}',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white, // Change the color as needed
          ),
        ),
        Text(
          '${_cachedWeatherData!['weather'][0]['description']}',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white, // Change the color as needed
          ),
        ),
        // Spacer or Sized Box to add space between the temperature and the rest of the content
        const SizedBox(height: 30),
        // Glassmorphic panel with weather data
        Center(
          child: ClipRect(
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: Container(
                width: MediaQuery.of(context).size.width *
                    0.8, // Adjust the width as needed
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.white
                      .withOpacity(0.6), // Adjust opacity for glass effect
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                        'City: ${_cachedWeatherData!['name']}, ${_cachedWeatherData!['sys']['country']}'),
                    Text('Temperature: $tempFahrenheit °F / $tempCelsius °C'),
                    Text(
                        'Weather: ${_cachedWeatherData!['weather'][0]['main']}'),
                    Text(
                        'Description: ${_cachedWeatherData!['weather'][0]['description']}'),
                    Text('Sunrise: $sunrise UTC'),
                    Text('Sunset: $sunset UTC'),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
