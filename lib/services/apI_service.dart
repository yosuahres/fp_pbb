import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/movie_model.dart'; // <-- model untuk parsing JSON

class ApiService {
  // Base URL TMDB v3
  static const String _baseUrl = 'https://api.themoviedb.org/3';
  // Masukkan API Key dan Read Access Token Anda di sini
  static const String _apiKey = '32f8fe469d1dab8f9284f2090f58c951';
  static const String _readAccessToken =
      'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIzMmY4ZmU0NjlkMWRhYjhmOTI4NGYyMDkwZjU4Yzk1MSIsIm5iZiI6MTc0NzkyOTE0MC45NjIsInN1YiI6IjY4MmY0ODM0MjU2YmMzZWQxZDVlZDVhMCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.3ZfZn_El9ABCsFt5Y-zzeRtY55J7m5_b0607utySGyI';

  // Header yang akan dipakai di semua request
  static Map<String, String> _defaultHeaders() => {
    'Authorization': 'Bearer $_readAccessToken',
    'Content-Type': 'application/json;charset=utf-8',
  };

  /// Contoh GET daftar film populer
  static Future<List<Movie>?> fetchPopularMovies({int page = 1}) async {
    final uri = Uri.parse(
      '$_baseUrl/movie/popular?api_key=$_apiKey&page=$page',
    );

    try {
      final response = await http.get(uri, headers: _defaultHeaders());
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        final List results = jsonData['results'];
        // Ubah list JSON ke List<Movie>
        return results.map((e) => Movie.fromJson(e)).toList();
      } else {
        print('Failed to load movies: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching popular movies: $e');
    }
    return null;
  }
}
