import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://87.228.38.184'; // или 'http://localhost:8080'?
  final String? authToken;

  ApiService({this.authToken});

  Map<String, String> get _headers {
    final headers = {'Content-Type': 'application/json'};
    if (authToken != null) {
      headers['Authorization'] = 'Bearer $authToken';
    }
    return headers;
  }

  Future<Map<String, dynamic>> uploadResume(File file) async {
    var uri = Uri.parse('$baseUrl/upload');
    var request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('file', file.path))
      ..headers.addAll(_headers);

    var response = await request.send();

    if (response.statusCode == 200) {
      final responseString = await response.stream.bytesToString();
      return json.decode(responseString);
    } else {
      throw Exception('Failed to upload resume: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> getResume(int id) async {
    var uri = Uri.parse('$baseUrl/resume/$id');
    var response = await http.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch resume: ${response.statusCode}');
    }
  }

  Future<List<dynamic>> getResumes() async {
    var uri = Uri.parse('$baseUrl/resumes');
    var response = await http.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch resumes: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> editResume(int id, Map<String, dynamic> data) async {
    var uri = Uri.parse('$baseUrl/resume/$id/edit');
    var response = await http.post(
      uri,
      headers: _headers,
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to update resume: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> editResumeSection(int id, String section, String content) async {
    var uri = Uri.parse('$baseUrl/resume/$id/edit/$section');
    var response = await http.post(
      uri,
      headers: _headers,
      body: json.encode({'content': content}),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to update resume section: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> checkGrammar(int id) async {
    var uri = Uri.parse('$baseUrl/resume/$id/check/grammar');
    var response = await http.post(uri, headers: _headers);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to check grammar: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> checkStructure(int id) async {
    var uri = Uri.parse('$baseUrl/resume/$id/check/structure');
    var response = await http.post(uri, headers: _headers);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to check structure: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> checkSkills(int id) async {
    var uri = Uri.parse('$baseUrl/resume/$id/check/skills');
    var response = await http.post(uri, headers: _headers);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to check skills: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> deleteResume(int id) async {
    var uri = Uri.parse('$baseUrl/resume/$id/delete');
    var response = await http.delete(uri, headers: _headers);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to delete resume: ${response.statusCode}');
    }
  }

  // Auth methods
  Future<Map<String, dynamic>> register(String email, String password, String name) async {
    var uri = Uri.parse('$baseUrl/register');
    var response = await http.post(
      uri,
      headers: _headers,
      body: json.encode({'email': email, 'password': password, 'name': name}),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to register: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    var uri = Uri.parse('$baseUrl/login');
    var response = await http.post(
      uri,
      headers: _headers,
      body: json.encode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to login: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> getProfile() async {
    var uri = Uri.parse('$baseUrl/profile');
    var response = await http.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get profile: ${response.statusCode}');
    }
  }

// ... другие методы по аналогии
}