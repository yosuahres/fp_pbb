import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:finalpbb/models/movie_model.dart';

class ApiService {
  static const String _baseUrl = 'https://api.themoviedb.org/3';
  static const String _apiKey = '32f8fe469d1dab8f9284f2090f58c951';
  static const String _readAccessToken =
      'Bearer eyJhbGciOiJIUzI1NiJ9...utySGyI'; // disingkat buat rapi

  static final Map<String, String> _headers = {
    'Authorization': _readAccessToken,
    'Content-Type': 'application/json;charset=utf-8',
  };

  /// Fetch popular movies
  static Future<List<Movie>> fetchPopularMovies({int page = 1}) async {
    final uri = Uri.parse(
      '$_baseUrl/movie/popular?api_key=$_apiKey&page=$page',
    );

    final response = await http.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List results = data['results'];
      return results.map((e) => Movie.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch popular movies: ${response.statusCode}');
    }
  }

  /// Fetch keywords based on movieId
  static Future<List<String>> fetchKeywords(int movieId) async {
    final uri = Uri.parse('$_baseUrl/movie/$movieId/keywords?api_key=$_apiKey');

    final response = await http.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List keywords = data['keywords'];
      return keywords.map((k) => k['name'].toString()).toList();
    } else {
      throw Exception('Failed to fetch keywords: ${response.statusCode}');
    }
  }
}
