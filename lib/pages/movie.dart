import 'package:finalpbb/db/firestore.dart';
import 'package:finalpbb/models/movie_model.dart';
import 'package:flutter/material.dart';

class MoviePage extends StatefulWidget {
  final Map arguments;
  const MoviePage({super.key, required this.arguments});

  @override
  State<MoviePage> createState() => _MoviePageState();
}

class _MoviePageState extends State<MoviePage>
    with SingleTickerProviderStateMixin {
  final FirestoreService firestoreService = FirestoreService();
  late TabController _tabController;
  bool isInWatchlist = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _checkWatchlist();
  }

  Future<void> _checkWatchlist() async {
    final args = widget.arguments;
    final movieId = int.tryParse(args['movieId'].toString()) ?? 0;
    final exists = await firestoreService.isMovieInWatchlistMovie(movieId);
    setState(() {
      isInWatchlist = exists;
    });
  }

  Future<void> _toggleWatchlist(Movie movie) async {
    if (isInWatchlist) {
      await firestoreService.deleteWatchlistMovieByMovieId(movie.id);
    } else {
      await firestoreService.addWatchlistMovie(
        movie.id,
        movie.title,
        movie.posterPath,
        movie.overview,
      );
    }
    setState(() {
      isInWatchlist = !isInWatchlist;
    });
  }

  @override
  Widget build(BuildContext context) {
    final args = widget.arguments;
    final movie = Movie(
      id: int.tryParse(args['movieId'].toString()) ?? 0,
      title: args['movieName'] ?? '',
      posterPath: args['posterPath'] ?? '',
      overview: args['overview'] ?? '',
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(args['movieName'], overflow: TextOverflow.ellipsis),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.favorite,
              color: isInWatchlist ? Colors.pink : Colors.black,
            ),
            onPressed: () => _toggleWatchlist(movie),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'Sinopsis'), Tab(text: 'Pilih Tiket')],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                SingleChildScrollView(
                  child: Column(
                    children: [
                      if (args['posterPath'] != null &&
                          args['posterPath'].toString().isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.network(
                              'https://image.tmdb.org/t/p/w342${args['posterPath']}',
                              height: 250,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(args['overview'] ?? 'Tidak ada sinopsis.'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          throw Exception('Test Crash for Crashlytics');
                        },
                        child: const Text('Test Crash'),
                      ),
                    ],
                  ),
                ),
                Center(
                  child: ElevatedButton(
                    child: const Text('Pilih Kursi & Beli Tiket'),
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        'ticketseat',
                        arguments: {
                          'movieId': args['movieId'],
                          'movieName': args['movieName'],
                          'posterPath': args['posterPath'],
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
