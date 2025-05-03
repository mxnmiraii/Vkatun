import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'https://87.228.38.184';
  String authToken; // Теперь обязательный параметр
  final SharedPreferences prefs;

  ApiService({required this.authToken, required this.prefs});

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $authToken',
  };

  // Локальное хранилище резюме
  List<Map<String, dynamic>> get _localResumes {
    final data = prefs.getString('local_resumes');
    return data != null ? List<Map<String, dynamic>>.from(json.decode(data)) : [];
  }

  Future<void> _saveLocalResumes(List<Map<String, dynamic>> resumes) async {
    await prefs.setString('local_resumes', json.encode(resumes));
  }

  // Основные методы
  Future<List<Map<String, dynamic>>> getResumes() async {
    try {
      // Пытаемся получить с сервера
      final response = await http.get(
        Uri.parse('$baseUrl/resumes'),
        headers: _headers,
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final serverResumes = List<Map<String, dynamic>>.from(json.decode(response.body));
        await _mergeResumes(serverResumes);
        return serverResumes;
      }
    } catch (e) {
      print('Оффлайн режим: $e');
    }

    // Возвращаем локальные данные если сервер недоступен
    return _localResumes;
  }

  Future<Map<String, dynamic>> getResumeById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/resume/$id'),
        headers: _headers,
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(json.decode(response.body));
      } else {
        print('Ошибка сервера: ${response.statusCode}');
      }
    } catch (e) {
      print('Ошибка получения резюме по ID: $e');
    }

    return {'title': null};
  }

  Future<void> _mergeResumes(List<Map<String, dynamic>> serverResumes) async {
    final localResumes = _localResumes;
    final merged = <Map<String, dynamic>>[];

    // Сливаем данные, сохраняя локальные изменения
    for (final serverResume in serverResumes) {
      final localVersion = localResumes.firstWhere(
            (r) => r['id'] == serverResume['id'],
        orElse: () => {},
      );

      merged.add({
        ...serverResume,
        ...localVersion, // Локальные изменения имеют приоритет
      });
    }

    await _saveLocalResumes(merged);
  }

  Future<Map<String, dynamic>> uploadResume(File file) async {
    try {
      print('[UPLOAD] Начало загрузки: ${file.path}');

      var uri = Uri.parse('$baseUrl/upload');
      var request = http.MultipartRequest('POST', uri);

      // 1. Подготавливаем заголовки
      final headers = {
        'Accept': 'application/json',
        'Content-Type': 'multipart/form-data',
      };

      if (authToken != 'guest_token') {
        headers['Authorization'] = 'Bearer $authToken';
      } else {
        print('[UPLOAD] Используется гостевой режим');
        // headers['X-Guest-Token'] = 'true'; // Раскомментировать если нужно
      }

      request.headers.addAll(headers);

      // 2. Добавляем файл
      request.files.add(await http.MultipartFile.fromPath(
        'file',
        file.path,
        filename: 'resume_${DateTime.now().millisecondsSinceEpoch}.pdf',
      ));

      print('[UPLOAD] Отправка запроса...');
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      print('[UPLOAD] Ответ сервера (${response.statusCode}): $responseBody');

      if (response.statusCode == 200) {
        return json.decode(responseBody);
      } else {
        throw Exception('Ошибка сервера: ${response.statusCode}');
      }
    } catch (e) {
      print('[UPLOAD] Ошибка: $e');
      throw Exception('Не удалось загрузить резюме');
    }
  }

  Future<Map<String, dynamic>> editResume(int id, Map<String, dynamic> data) async {
    // Сначала обновляем локально
    final resumes = _localResumes;
    final index = resumes.indexWhere((r) => r['id'] == id);

    if (index != -1) {
      resumes[index] = {...resumes[index], ...data, 'is_modified': true};
      await _saveLocalResumes(resumes);
    }

    try {
      // Пытаемся синхронизировать с сервером
      final response = await http.post(
        Uri.parse('$baseUrl/resume/$id/edit'),
        headers: _headers,
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        // Снимаем флаг изменения после успешной синхронизации
        if (index != -1) {
          resumes[index].remove('is_modified');
          await _saveLocalResumes(resumes);
        }
        return json.decode(response.body);
      }
    } catch (e) {
      print('Ошибка синхронизации: $e');
    }

    return resumes[index]; // Возвращаем локальную версию
  }

  Future<void> _saveToken(String token) async {
    authToken = token;
    await prefs.setString('user_token', token);
  }

  Future<void> clearToken() async {
    authToken = 'guest_token';
    await prefs.remove('user_token');
  }

  Future<void> register({
    required String username,
    required String emailOrPhone,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': emailOrPhone,
        'password': password,
        'name': username,
      }),
    );

    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      await _saveToken(data['token']);
    } else {
      throw Exception('Ошибка регистрации: ${response.body}');
    }
  }

  Future<void> login({
    required String emailOrPhone,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': emailOrPhone,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      await _saveToken(data['token']);
    } else {
      throw Exception('Ошибка входа: ${response.statusCode}');
    }
  }
}