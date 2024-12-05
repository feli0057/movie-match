import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class HttpHelper {
  static const String movieNightAPIbaseURL =
      'https://movie-night-api.onrender.com';
  static const String theMovieDBbaseURL = 'https://api.themoviedb.org/3';
  static const String sessionIDkey = 'session_id';

  // Get TMDB API Key from environment variables
  static String get tmdbAPIkey => dotenv.env['TMDB_API_KEY'] ?? '';

  // MovieNight API Methods
  static Future<Map<String, dynamic>> startSession(String deviceID) async {
    final response = await http.get(
      Uri.parse('$movieNightAPIbaseURL/start-session?device_id=$deviceID'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // Store session ID
      if (data['data']['session_id'] != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(sessionIDkey, data['data']['session_id']);
      }
      return data;
    } else {
      throw Exception('Failed to start session');
    }
  }

  static Future<Map<String, dynamic>> joinSession(
      String deviceID, int code) async {
    final response = await http.get(
      Uri.parse(
          '$movieNightAPIbaseURL/join-session?device_id=$deviceID&code=$code'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // Store session ID
      if (data['data']['session_id'] != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(sessionIDkey, data['data']['session_id']);
      }
      return data;
    } else {
      throw Exception('Failed to join session');
    }
  }

  static Future<Map<String, dynamic>> voteMovie(
      String sessionID, int movieID, bool vote) async {
    final response = await http.get(
      Uri.parse(
          '$movieNightAPIbaseURL/vote-movie?session_id=$sessionID&movie_id=$movieID&vote=$vote'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to vote on movie');
    }
  }

  // TMDB API Methods
  static Future<Map<String, dynamic>> getPopularMovies({int page = 1}) async {
    final response = await http.get(
      Uri.parse(
          '$theMovieDBbaseURL/movie/popular?api_key=$tmdbAPIkey&page=$page'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load popular movies');
    }
  }

  // Session ID Management
  static Future<String?> getSessionId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(sessionIDkey);
  }

  static Future<void> clearSessionId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(sessionIDkey);
  }
}
