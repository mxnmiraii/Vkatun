import 'dart:io';

import 'package:appmetrica_plugin/appmetrica_plugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vkatun/pages/entry_page.dart';
import 'package:vkatun/pages/register_page.dart';
import 'package:vkatun/pages/start_page.dart';
import 'api_service.dart';
import 'pages/resumes_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // AppMetrica
  AppMetrica.activate(AppMetricaConfig("ea65dfe6-942b-4380-a06d-adb48f3a7b20"));
  AppMetrica.reportEvent('app_start');

  final prefs = await SharedPreferences.getInstance();
  final authToken = prefs.getString('user_token') ?? 'guest_token';
  HttpOverrides.global = HttpOverridesForTesting();

  runApp(
    Provider(
      create: (_) => ApiService(authToken: authToken, prefs: prefs),
      child: MyApp(authToken: authToken),
    ),
  );
}

class MyApp extends StatelessWidget {
  final String authToken;

  const MyApp({super.key, required this.authToken});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: MaterialApp(
        title: 'VKatun',
        debugShowCheckedModeBanner: false, // Отключение баннера здесь
        theme: ThemeData(
          primaryColor: Colors.white,
          scaffoldBackgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.black),
          appBarTheme: const AppBarTheme(
            color: Colors.white,
          ),
        ),
        home: authToken != 'guest_token' ? const ResumesPage() : const StartPage(),
        routes: {
          '/login': (_) => const EntryPage(),
          '/register': (_) => const RegisterPage(),
        },
      ),
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