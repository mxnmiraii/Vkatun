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

  // Получаем уникальный ключ для хранения резюме (на основе токена)
  String get _resumesStorageKey => 'local_resumes_${authToken.hashCode}';

  // Получаем локальные резюме текущего пользователя
  List<Map<String, dynamic>> get _localResumes {
    final data = prefs.getString(_resumesStorageKey);
    return data != null ? List<Map<String, dynamic>>.from(json.decode(data)) : [];
  }

  // Сохраняем локальные резюме текущего пользователя
  Future<void> _saveLocalResumes(List<Map<String, dynamic>> resumes) async {
    await prefs.setString(_resumesStorageKey, json.encode(resumes));
  }

  // При регистрации/входе сохраняем только токен
  Future<void> _saveToken(String token) async {
    authToken = token;
    await prefs.setString('user_token', token);
  }

  Future<void> clearToken() async {
    authToken = 'guest_token';
    await prefs.remove('user_token');
  }

  // Остальные методы остаются без изменений
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
      await _saveToken(data['token'] ?? 'guest_token');
      return;
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

  // Модифицируем методы регистрации и входа
  Future<void> _saveAuthData(String token, int userId) async {
    authToken = token;
    await prefs.setString('user_token', token);
    await prefs.setString('user_id', userId.toString()); // Сохраняем ID пользователя
  }

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $authToken',
  };

  // Основные методы
  Future<List<Map<String, dynamic>>> getResumes() async {
    try {
      // Пытаемся получить с сервера
      final response = await http.get(
        Uri.parse('$baseUrl/resumes'),
        headers: _headers,
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        print('Get resumes success');
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
        // printResponseBody(Map<String, dynamic>.from(json.decode(response.body)));
        return Map<String, dynamic>.from(json.decode(response.body));
      } else {
        print('Ошибка сервера: ${response.statusCode}');
      }
    } catch (e) {
      print('Ошибка получения резюме по ID: $e');
    }

    return {'title': null};
  }

  void printResponseBody(Map<String, dynamic> responseBody) {
    responseBody.forEach((key, value) {
      print('$key - $value');
    });
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

// Редактирование одной секции резюме
  Future<Map<String, dynamic>> editResumeSection({
    required int id,
    required String section,
    required String content,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/resume/$id/edit/$section'),
        headers: _headers,
        body: json.encode({'content': content}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Ошибка сервера: ${response.statusCode}');
      }
    } catch (e) {
      print('Ошибка редактирования секции: $e');
      rethrow;
    }
  }

// Проверка грамматики резюме
  Future<Map<String, dynamic>> checkResumeGrammar(int id) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/resume/$id/check/grammar'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        print(Map<String, dynamic>.from(json.decode(response.body)));
        return json.decode(response.body);
      } else {
        throw Exception('Ошибка проверки грамматики: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('Ошибка проверки грамматики: $e');
      rethrow;
    }
  }

// Проверка структуры резюме
  Future<Map<String, dynamic>> checkResumeStructure(int id) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/resume/$id/check/structure'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        print(Map<String, dynamic>.from(json.decode(response.body)));
        return json.decode(response.body);
      } else {
        throw Exception('Ошибка проверки структуры: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('Ошибка проверки структуры: $e');
      rethrow;
    }
  }

// Анализ навыков в резюме
  Future<Map<String, dynamic>> analyzeResumeSkills(int id) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/resume/$id/check/skills'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        Map<String, dynamic>.from(json.decode(response.body)).forEach((key, value) => print('$key - $value'));
        return json.decode(response.body);
      } else {
        throw Exception('Ошибка анализа навыков: ${response.statusCode}');
      }
    } catch (e) {
      print('Ошибка анализа навыков: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> analyzeResumeAbout(int id) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/resume/$id/check/about'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        Map<String, dynamic>.from(json.decode(response.body)).forEach((key, value) => print('$key - $value'));
        return json.decode(response.body);
      } else {
        throw Exception('Ошибка анализа пункта "Обо мне": ${response.statusCode}');
      }
    } catch (e) {
      print('Ошибка анализа: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> analyzeResumeExperience(int id) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/resume/$id/check/experience'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        Map<String, dynamic>.from(json.decode(response.body)).forEach((key, value) => print('$key - $value'));
        return json.decode(response.body);
      } else {
        throw Exception('Ошибка анализа опыта работы: ${response.statusCode}');
      }
    } catch (e) {
      print('Ошибка анализа опыта работы: $e');
      rethrow;
    }
  }

// Удаление резюме
  Future<void> deleteResume(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/resume/$id/delete'),
        headers: _headers,
      );

      if (response.statusCode != 200) {
        throw Exception('Ошибка удаления резюме: ${response.statusCode}');
      }
    } catch (e) {
      print('Ошибка удаления резюме: $e');
      rethrow;
    }
  }

// Получение профиля пользователя
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/profile'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Ошибка получения профиля: ${response.statusCode}');
      }
    } catch (e) {
      print('Ошибка получения профиля: $e');
      rethrow;
    }
  }

// Изменение имени пользователя
  Future<void> updateProfileName(String newName) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/profile/name'),
        headers: _headers,
        body: json.encode({'newName': newName}),
      );

      if (response.statusCode != 200) {
        throw Exception('Ошибка изменения имени: ${response.statusCode}');
      }
    } catch (e) {
      print('Ошибка изменения имени: $e');
      rethrow;
    }
  }

// Изменение пароля
  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/profile/password'),
        headers: _headers,
        body: json.encode({
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Ошибка изменения пароля: ${response.statusCode}');
      }
    } catch (e) {
      print('Ошибка изменения пароля: $e');
      rethrow;
    }
  }

// Получение метрик системы
  Future<Map<String, dynamic>> getMetrics() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/metrics'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Ошибка получения метрик: ${response.statusCode}');
      }
    } catch (e) {
      print('Ошибка получения метрик: $e');
      rethrow;
    }
  }

// Обновление метрик (для администраторов)
  Future<void> updateMetrics({
    required String source,
    required Map<String, dynamic> updates,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/metrics/update'),
        headers: _headers,
        body: json.encode({
          'source': source,
          'updates': updates,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Ошибка обновления метрик: ${response.statusCode}');
      }
    } catch (e) {
      print('Ошибка обновления метрик: $e');
      rethrow;
    }
  }
}