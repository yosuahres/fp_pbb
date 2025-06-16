class Movie {
  final int id;
  final String title;
  final String overview;
  final String posterPath;
  //vote_average
  final double voteAverage;

  Movie({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.voteAverage,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'],
      title: json['title'],
      overview: json['overview'],
      posterPath: json['poster_path'] ?? '',
      voteAverage: double.parse(((json['vote_average'] as num?) ?? 0.0).toStringAsFixed(1)),
    );
  }

  String get posterUrl => 'https://image.tmdb.org/t/p/w500$posterPath';
}
