import 'package:flutter/material.dart';
import 'package:movie_booking_flutter_backend/provider/get_hall_provider.dart';
import 'package:movie_booking_flutter_backend/provider/get_movie_provider.dart';
import 'package:movie_booking_flutter_backend/provider/hall_provider.dart';
import 'package:movie_booking_flutter_backend/provider/login_provider.dart';
import 'package:movie_booking_flutter_backend/provider/movie_provider.dart';
import 'package:movie_booking_flutter_backend/provider/signup_provider.dart';
import 'package:movie_booking_flutter_backend/provider/users_provider.dart';
import 'package:movie_booking_flutter_backend/splash_screen.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => LoginProvider()),
        ChangeNotifierProvider(create: (context) => SignUpProvider()),
        ChangeNotifierProvider(create: (context) => MovieProvider()),
        ChangeNotifierProvider(create: (context) => UsersProvider()),
        ChangeNotifierProvider(create: (context) => GetMovieProvider()),
        ChangeNotifierProvider(create: (context) => HallProvider()),
        ChangeNotifierProvider(create: (context) => GetHallProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movie Booking',
      theme: ThemeData(
        primarySwatch: createMaterialColor(const Color(0xFFFCC434)),
      ),
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}

MaterialColor createMaterialColor(Color color) {
  List strengths = <double>[.05];
  Map<int, Color> swatch = {};
  final int r = color.red, g = color.green, b = color.blue;

  for (int i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }
  for (var strength in strengths) {
    final double ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((ds < 0 ? r : (255 - r)) * ds).round(),
      g + ((ds < 0 ? g : (255 - g)) * ds).round(),
      b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      1,
    );
  }
  return MaterialColor(color.value, swatch);
}
