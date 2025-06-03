import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'https://87.228.38.184';
  String authToken;
  final SharedPreferences prefs;

  // Ключи для хранения
  static const String guestResumeKey = 'guest_resume';
  static const String userResumesKey = 'user_resumes_';
  static const String pendingUpdatesKey = 'pending_updates_';

  ApiService({required this.authToken, required this.prefs});

  /* ========== ОСНОВНЫЕ МЕТОДЫ ========== */

  // Получение списка резюме
  Future<List<Map<String, dynamic>>> getResumes() async {
    if (isGuest) {
      return getLocalResumes();
    }

    try {
      final response = await http
          .get(Uri.parse('$baseUrl/resumes'), headers: _headers)
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final resumes = List<Map<String, dynamic>>.from(
          json.decode(response.body),
        );
        await saveLocalResumes(resumes);
        return resumes;
      }
    } catch (e) {
      print('Оффлайн режим: $e');
    }
    return getLocalResumes();
  }

  // Загрузка резюме
  Future<Map<String, dynamic>> uploadResume(File file) async {
    try {
      final uri = Uri.parse(
        isGuest ? '$baseUrl/guest/upload' : '$baseUrl/upload',
      );
      final request = http.MultipartRequest('POST', uri);

      if (!isGuest) request.headers.addAll(_headers);

      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          file.path,
          contentType: MediaType('application', 'pdf'),
        ),
      );

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final result = json.decode(responseBody);

      if (response.statusCode == 200) {
        if (isGuest) {
          // Парсим текст резюме из ответа
          final resumeText = json.decode(
            result['text'],
          ); // Декодируем вложенный JSON

          // Создаем структуру резюме
          final newResume = {
            'id': DateTime.now().millisecondsSinceEpoch,
            'title': resumeText['title'] ?? 'Без названия',
            'contacts': resumeText['contacts'] ?? '',
            'job': resumeText['job'] ?? '',
            'experience': resumeText['experience'] ?? '',
            'education': resumeText['education'] ?? '',
            'skills': resumeText['skills'] ?? '',
            'about': resumeText['about'] ?? '',
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
            'is_local': true,
            'file_path': file.path,
          };

          final resumes = getLocalResumes()..insert(0, newResume);
          await saveLocalResumes(resumes);
          return newResume;
        } else {
          // Для авторизованных получаем полное резюме по ID
          final fullResume = await getResumeById(result['resume_id']);
          final resumes = getLocalResumes()..insert(0, fullResume);
          await saveLocalResumes(resumes);
          return fullResume;
        }
      }
      throw Exception('Ошибка сервера: ${response.statusCode}');
    } catch (e) {
      if (isGuest) {}
      throw Exception('Не удалось загрузить резюме: $e');
    }
  }

  /* ========== МЕТОДЫ АНАЛИЗА ========== */

  // Проверка грамматики
  Future<Map<String, dynamic>> checkGrammar(int resumeId) async {
    if (isGuest) {
      final resume = getLocalResumes().firstWhere(
        (r) => r['id'] == resumeId,
        orElse: () => throw Exception('Резюме не найдено'),
      );
      Map<String, dynamic> res = await _processGuestAnalysis(
        '$baseUrl/guest/check/grammar',
        resume,
      );
      print(res);
      return res;
    }

    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/resume/$resumeId/check/grammar'),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        if (json.decode(response.body)['issues'].length != 0) {
          await incrementRecommendationsMetric();
        }
        print(json.decode(response.body));
        return json.decode(response.body);
      }
      throw Exception('Ошибка сервера: ${response.statusCode}');
    } catch (e) {
      throw Exception('Ошибка проверки грамматики: $e');
    }
  }

  // Проверка структуры
  Future<Map<String, dynamic>> checkStructure(int resumeId) async {
    if (isGuest) {
      final resume = getLocalResumes().firstWhere(
        (r) => r['id'] == resumeId,
        orElse: () => throw Exception('Резюме не найдено'),
      );
      return _processGuestAnalysis('$baseUrl/guest/check/structure', resume);
    }

    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/resume/$resumeId/check/structure'),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        if (json.decode(response.body)['issues'].length != 0) {
          await incrementRecommendationsMetric();
        }
        print(json.decode(response.body));
        return json.decode(response.body);
      }
      throw Exception('Ошибка сервера: ${response.statusCode}');
    } catch (e) {
      throw Exception('Ошибка проверки структуры: $e');
    }
  }

  // Анализ навыков
  Future<Map<String, dynamic>> analyzeSkills(int resumeId) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/resume/$resumeId/check/skills'),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        if (json.decode(response.body)['issues'].length != 0) {
          await incrementRecommendationsMetric();
        }
        print(json.decode(response.body));
        return json.decode(response.body);
      }
      throw Exception('Ошибка сервера: ${response.statusCode}');
    } catch (e) {
      throw Exception('Ошибка анализа навыков: $e');
    }
  }

  // Анализ раздела "Обо мне"
  Future<Map<String, dynamic>> analyzeAbout(int resumeId) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/resume/$resumeId/check/about'),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        if (json.decode(response.body)['comment'].toString().isNotEmpty) {
          await incrementRecommendationsMetric();
        }
        print(json.decode(response.body));
        return json.decode(response.body);
      }
      throw Exception('Ошибка сервера: ${response.statusCode}');
    } catch (e) {
      throw Exception('Ошибка анализа раздела "Обо мне": $e');
    }
  }

  // Анализ опыта работы
  Future<Map<String, dynamic>> analyzeExperience(int resumeId) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/resume/$resumeId/check/experience'),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        print(json.decode(response.body));
        if (json.decode(response.body)['comment'].toString().isNotEmpty) {
          await incrementRecommendationsMetric();
        }
        return json.decode(response.body);
      }
      throw Exception('Ошибка сервера: ${response.statusCode}');
    } catch (e) {
      throw Exception('Ошибка анализа опыта работы: $e');
    }
  }

  /* ========== ВСПОМОГАТЕЛЬНЫЕ МЕТОДЫ ========== */

  // Проверка авторизации
  bool get isGuest => authToken == 'guest_token';

  // Заголовки запросов
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $authToken',
  };

  // Получение локальных резюме
  List<Map<String, dynamic>> getLocalResumes() {
    final key =
        isGuest
            ? guestResumeKey
            : '$userResumesKey${prefs.getString('user_id')}';
    final data = prefs.getString(key);
    return data != null
        ? List<Map<String, dynamic>>.from(json.decode(data))
        : [];
  }

  // Сохранение локальных резюме
  Future<void> saveLocalResumes(List<Map<String, dynamic>> resumes) async {
    final key =
        isGuest
            ? guestResumeKey
            : '$userResumesKey${prefs.getString('user_id')}';
    await prefs.setString(key, json.encode(resumes));
  }

  // Обработка анализа для гостя
  Future<Map<String, dynamic>> _processGuestAnalysis(
    String url,
    Map<String, dynamic> resume,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'resume': json.encode(resume)}),
          )
          .timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      throw Exception('Ошибка сервера: ${response.statusCode}');
    } catch (e) {
      throw Exception('Ошибка анализа: $e');
    }
  }

  /* ========== МЕТОДЫ АВТОРИЗАЦИИ ========== */

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
      authToken = data['token'];
      await prefs.setString('user_token', data['token']);
      await prefs.setString('user_id', data['user_id'].toString());
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
      body: json.encode({'email': emailOrPhone, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      authToken = data['token'];
      await prefs.setString('user_token', data['token']);
      await prefs.setString('user_id', data['user_id'].toString());
    } else {
      throw Exception('Ошибка входа: ${response.statusCode}');
    }
  }

  Future<void> clearToken() async {
    authToken = 'guest_token';
    await prefs.remove('user_token');
    await prefs.remove('user_id');
  }

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

  Future<Map<String, dynamic>> getMetricsHistory(String range) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/metrics/history/$range'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Ошибка получения метрик: ${response.statusCode}');
      }
    } catch (e) {
      print('Ошибка получения истории метрик: $e');
      rethrow;
    }
  }

  Future<void> updateMetrics({
    required String source,
    required Map<String, dynamic> updates,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/metrics/update'),
        headers: _headers,
        body: json.encode({'source': source, 'updates': updates}),
      );

      if (response.statusCode != 200) {
        throw Exception('Ошибка обновления метрик: ${response.statusCode}');
      }
    } catch (e) {
      print('Ошибка обновления метрик: $e');
      rethrow;
    }
  }

  /* ========== ДОПОЛНИТЕЛЬНЫЕ МЕТОДЫ ========== */

  Future<Map<String, dynamic>> getResumeById(int id) async {
    try {
      // Для гостя всегда берем из локального хранилища
      if (isGuest) {
        final localResumes = getLocalResumes();
        return localResumes.firstWhere(
              (r) => r['id'] == id,
          orElse: () => throw Exception('Резюме не найдено'),
        );
      }

      // Для авторизованных пользователей
      final response = await http
          .get(Uri.parse('$baseUrl/resume/$id'), headers: _headers)
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Обновляем локальную копию
        final localResumes = getLocalResumes();
        final index = localResumes.indexWhere((r) => r['id'] == id);
        if (index != -1) {
          localResumes[index] = {
            ...localResumes[index], // сохраняем локальные изменения
            ...data, // обновляем данные с сервера
            'id': id, // гарантируем правильный ID
          };
          await saveLocalResumes(localResumes);
        }

        return _addDefaultValues(data);
      }

      // Если ошибка сервера, пробуем найти локально
      final localResumes = getLocalResumes();
      return localResumes.firstWhere(
            (r) => r['id'] == id,
        orElse: () => throw Exception('Не удалось загрузить резюме'),
      );
    } catch (e) {
      // В крайнем случае пробуем получить хоть какие-то данные
      final localResumes = getLocalResumes();
      final localResume = localResumes.firstWhere(
            (r) => r['id'] == id,
        orElse: () => throw Exception('Резюме не найдено: $e'),
      );

      return _addDefaultValues(localResume);
    }
  }

// Добавляет обязательные поля с default значениями
  Map<String, dynamic> _addDefaultValues(Map<String, dynamic> resume) {
    return {
      'id': resume['id'],
      'title': resume['title'] ?? '',
      'job': resume['job'] ?? '',
      'contacts': resume['contacts'] ?? '',
      'experience': resume['experience'] ?? '',
      'education': resume['education'] ?? '',
      'skills': resume['skills'] ?? '',
      'about': resume['about'] ?? '',
      'created_at': resume['created_at'] ?? DateTime.now().toIso8601String(),
      'updated_at': resume['updated_at'] ?? DateTime.now().toIso8601String(),
      ...resume, // остальные поля
    };
  }

  Future<Map<String, dynamic>> editResume(
    int id,
    Map<String, dynamic> data,
  ) async {
    final resumes = getLocalResumes();
    final index = resumes.indexWhere((r) => r['id'] == id);

    if (index == -1) throw Exception('Резюме не найдено');

    final updatedResume = {
      ...resumes[index],
      ...data,
      'updated_at': DateTime.now().toIso8601String(),
      if (!isGuest) 'is_modified': true,
    };

    resumes[index] = updatedResume;
    await saveLocalResumes(resumes);

    if (!isGuest) {
      try {
        final response = await http
            .post(
              Uri.parse('$baseUrl/resume/$id/edit'),
              headers: _headers,
              body: json.encode(data),
            )
            .timeout(const Duration(seconds: 5));

        if (response.statusCode == 200) {
          // Обновляем локальную копию после успешного обновления на сервере
          resumes[index].remove('is_modified');
          await saveLocalResumes(resumes);
        } else {
          // Оставляем флаг is_modified для последующей синхронизации
          print('Ошибка обновления резюме: ${response.statusCode}');
        }
      } catch (e) {
        print('Ошибка сети при обновлении резюме: $e');
        // Ошибка будет обработана при следующей синхронизации
      }
    }

    return updatedResume;
  }

  Future<Map<String, dynamic>> editResumeSection({
    required int id,
    required String section,
    required dynamic content,
  }) async {
    final resumes = getLocalResumes();
    final index = resumes.indexWhere((r) => r['id'] == id);

    if (index == -1) throw Exception('Резюме не найдено');

    // Создаем обновленную копию резюме
    final updatedResume = {
      ...resumes[index],
      section: content,
      'updated_at': DateTime.now().toIso8601String(),
      'is_modified': !isGuest,
    };

    // Обновляем локальную копию
    resumes[index] = updatedResume;
    await saveLocalResumes(resumes);

    // Для онлайн-режима пробуем синхронизировать с сервером
    if (!isGuest) {
      try {
        await http.post(
          Uri.parse('$baseUrl/resume/$id/edit/$section'),
          headers: _headers,
          body: json.encode({'content': content}),
        ).timeout(const Duration(seconds: 5));

        // Убираем флаг модификации после успешной синхронизации
        resumes[index].remove('is_modified');
        await saveLocalResumes(resumes);
      } catch (e) {
        print('Ошибка синхронизации (сохранено локально): $e');
      }
    }

    return updatedResume;
  }

  Future<void> deleteResume(int id) async {
    final resumes = getLocalResumes()..removeWhere((r) => r['id'] == id);
    await saveLocalResumes(resumes);

    if (!isGuest) {
      try {
        await http.delete(
          Uri.parse('$baseUrl/resume/$id/delete'),
          headers: _headers,
        );
      } catch (e) {
        // Ошибка будет обработана при следующей синхронизации
      }
    }
  }

  Future<void> syncData() async {
    if (isGuest) return;

    try {
      // 1. Получаем текущие локальные резюме
      final localResumes = getLocalResumes();

      // 2. Проверяем соединение с интернетом
      bool hasInternet = false;
      List<Map<String, dynamic>> serverResumes = [];

      try {
        final response = await http.get(
          Uri.parse('$baseUrl/resumes'),
          headers: _headers,
        ).timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          serverResumes = List<Map<String, dynamic>>.from(json.decode(response.body));
          hasInternet = true;
        }
      } catch (e) {
        print('Ошибка получения списка резюме с сервера: $e');
      }

      // 3. Если есть интернет - синхронизируем изменения
      if (hasInternet) {
        // Отправляем локальные изменения на сервер
        for (final localResume in localResumes.where((r) => r['is_modified'] == true)) {
          try {
            final sectionsToUpdate = {
              'title': localResume['title'],
              'contacts': localResume['contacts'],
              'job': localResume['job'],
              'experience': localResume['experience'],
              'education': localResume['education'],
              'skills': localResume['skills'],
              'about': localResume['about'],
            };

            for (final entry in sectionsToUpdate.entries) {
              if (entry.value != null) {
                await http.post(
                  Uri.parse('$baseUrl/resume/${localResume['id']}/edit/${entry.key}'),
                  headers: _headers,
                  body: json.encode({'content': entry.value}),
                ).timeout(const Duration(seconds: 5));
              }
            }

            // Убираем флаг модификации после успешной синхронизации
            localResume.remove('is_modified');
          } catch (e) {
            print('Ошибка синхронизации резюме ${localResume['id']}: $e');
          }
        }

        // Получаем полные данные с сервера
        final List<Map<String, dynamic>> completeResumes = [];
        for (final serverResume in serverResumes) {
          try {
            final response = await http.get(
              Uri.parse('$baseUrl/resume/${serverResume['id']}'),
              headers: _headers,
            ).timeout(const Duration(seconds: 5));

            if (response.statusCode == 200) {
              completeResumes.add(json.decode(response.body));
            }
          } catch (e) {
            print('Ошибка загрузки резюме ${serverResume['id']}: $e');
          }
        }

        // Объединяем данные
        final mergedResumes = <Map<String, dynamic>>[];

        // Добавляем серверные данные
        mergedResumes.addAll(completeResumes);

        // Добавляем локальные резюме, которых нет на сервере
        final serverIds = serverResumes.map((r) => r['id']).toSet();
        for (final localResume in localResumes) {
          if (!serverIds.contains(localResume['id'])) {
            mergedResumes.add(localResume);
          }
        }

        // Сохраняем объединенные данные
        await saveLocalResumes(mergedResumes);
      } else {
        // В оффлайн режиме просто проверяем целостность данных
        await saveLocalResumes(await _validateLocalResumes(localResumes));
      }
    } catch (e) {
      print('Критическая ошибка синхронизации: $e');
      // В крайнем случае сохраняем текущие локальные данные
      await saveLocalResumes(getLocalResumes());
    }
  }

  // Проверяет целостность локальных резюме
  Future<List<Map<String, dynamic>>> _validateLocalResumes(
    List<Map<String, dynamic>> resumes,
  ) async {
    final List<Map<String, dynamic>> validResumes = [];

    for (final resume in resumes) {
      try {
        // Проверяем обязательные поля
        if (resume['id'] != null &&
            resume['title'] != null &&
            resume['created_at'] != null) {
          validResumes.add(resume);
        }
      } catch (e) {
        print('Поврежденное резюме удалено: ${resume['id']}');
      }
    }

    return validResumes;
  }

  /// Отправляет метрику о новой рекомендации
  Future<void> incrementRecommendationsMetric() async {
    try {
      final response = await http
          .post(
            Uri.parse(
              'https://87.228.38.184/metrics/increment/recommendations',
            ),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode != 200) {
        print('Ошибка отправки метрики рекомендаций: ${response.statusCode}');
      }
    } catch (e) {
      print('Ошибка сети при отправке метрики рекомендаций: $e');
    }
  }

  /// Отправляет метрику о принятой рекомендации
  Future<void> incrementAcceptedMetric() async {
    try {
      final response = await http
          .post(
            Uri.parse('https://87.228.38.184/metrics/increment/accepted'),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode != 200) {
        print(
          'Ошибка отправки метрики принятых рекомендаций: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Ошибка сети при отправке метрики принятых рекомендаций: $e');
    }
  }
}
