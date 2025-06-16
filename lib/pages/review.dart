import 'package:flutter/material.dart';
import '../models/movie_model.dart';
import '../services/api_service.dart';
import 'reviewdetail.dart';  // Import the ReviewDetailPage
import '../models/review_model.dart';  // Import the ReviewModel

class ReviewPage extends StatefulWidget {
  const ReviewPage({Key? key}) : super(key: key);

  @override
  _ReviewPageState createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  List<Movie> _movies = [];
  bool _isLoading = true;

  // Fetch movies from the API
  void _fetchMovies() async {
    final movies = await ApiService.fetchPopularMovies();
    setState(() {
      _movies = movies ?? [];
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchMovies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _movies.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.6,
                    ),
                    itemBuilder: (context, index) {
                      final movie = _movies[index];
                      return GestureDetector(
                        onTap: () {
                          // Konversi Movie ke ReviewModel
                          final reviewModel = ReviewModel(
                            movieId: movie.id.toString(),
                            movieName: movie.title,
                            posterPath: movie.posterUrl,
                            overview: movie.overview,
                            reviews: [], // Atau ambil dari sumber lain jika ada
                          );
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ReviewDetailPage(movie: reviewModel),
                            ),
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Stack(
                            children: [
                              movie.posterPath.isNotEmpty
                                  ? Image.network(
                                      movie.posterUrl,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                    )
                                  : Container(
                                      color: Colors.grey.shade800,
                                      child: const Center(
                                        child: Icon(
                                          Icons.movie,
                                          size: 40,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 4,
                                  ),
                                  color: Colors.black.withOpacity(0.6),
                                  child: Text(
                                    movie.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );

                    },
                  ),
                ],
              ),
            ),
    );
  }
}
