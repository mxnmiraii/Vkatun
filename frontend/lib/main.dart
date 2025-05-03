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
  // 1. Сначала настраиваем HTTP-клиент
  HttpOverrides.global = HttpOverridesForTesting();

  // 2. Потом запускаем приложение
  runApp(
    Provider(
      create: (_) => ApiService(authToken: authToken, prefs: prefs),
      child: MaterialApp(
        home: authToken != 'guest_token' ? ResumesPage() : StartPage(),
        routes: {
          '/login': (_) => EntryPage(),
          '/register': (_) => RegisterPage(),
        },
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VKatun',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.white,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          color: Colors.white,
        ),
      ),
      home: const StartPage(),
    );
  }

}

class HttpOverridesForTesting extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final HttpClient client = super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;

    // Правильные параметры таймаута
    client.connectionTimeout = const Duration(seconds: 15);
    return client;
  }
}


