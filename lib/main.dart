import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const DarjeelingCountdownApp());
}

class DarjeelingCountdownApp extends StatelessWidget {
  const DarjeelingCountdownApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Darjeeling Tour Countdown',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue, fontFamily: 'Roboto'),
      home: const SplashScreen(),
    );
  }
}
