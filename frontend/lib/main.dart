import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vkatun/pages/start_page.dart';
import 'api_service.dart';
import 'pages/resumes_page.dart';

void main() {
  runApp(
    Provider(
      create: (context) => ApiService(), // или с токеном, если есть
      child: MyApp(),
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


