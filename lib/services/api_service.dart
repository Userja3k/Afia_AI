import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://localhost:8000/api';

  Future<Map<String, dynamic>> diagnoseMalaria(
      Map<String, dynamic> symptoms) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/paludisme/diagnose'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(symptoms),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Erreur lors du diagnostic: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  Future<Map<String, dynamic>> diagnoseSkin(
      File imageFile, Map<String, dynamic> additionalInfo) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/skin/diagnose'),
      );

      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );

      request.fields.addAll(
        additionalInfo.map((key, value) => MapEntry(key, value.toString())),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Erreur lors du diagnostic: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  Future<Map<String, dynamic>> diagnoseSkinWeb(Uint8List imageBytes,
      String filename, Map<String, dynamic> additionalInfo) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/skin/diagnose'),
      );

      request.files.add(
        http.MultipartFile.fromBytes('image', imageBytes, filename: filename),
      );

      request.fields.addAll(
        additionalInfo.map((key, value) => MapEntry(key, value.toString())),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Erreur lors du diagnostic: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  Future<Map<String, dynamic>> uploadAudio(File audioFile) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/audio/analyze'),
      );

      request.files.add(
        await http.MultipartFile.fromPath('audio', audioFile.path),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
            'Erreur lors de l\'analyse audio: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }
}
