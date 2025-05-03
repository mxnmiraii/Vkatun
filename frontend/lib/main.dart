import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vkatun/pages/entry_page.dart';
import 'package:vkatun/pages/register_page.dart';
import 'package:vkatun/pages/start_page.dart';
import 'api_service.dart';
import 'pages/resumes_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  // Гостевой токен или токен пользователя
  final authToken = prefs.getString('user_token') ?? 'guest_token';

  // Настройка HTTP-клиента
  HttpOverrides.global = HttpOverridesForTesting();

  runApp(
    Provider(
      create: (_) => ApiService(authToken: authToken, prefs: prefs),
      child: MyApp(authToken: authToken), // Используем MyApp с параметром
    ),
  );
}

class MyApp extends StatelessWidget {
  final String authToken;

  const MyApp({super.key, required this.authToken});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VKatun',
      debugShowCheckedModeBanner: false, // Отключение баннера здесь
      theme: ThemeData(
        primaryColor: Colors.white,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          color: Colors.white,
        ),
      ),
      home: authToken != 'guest_token' ? const ResumesPage() : const StartPage(),
      routes: {
        '/login': (_) => const EntryPage(),
        '/register': (_) => const RegisterPage(),
      },
    );
  }
}

class HttpOverridesForTesting extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final HttpClient client = super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
    client.connectionTimeout = const Duration(seconds: 15);
    return client;
  }
}