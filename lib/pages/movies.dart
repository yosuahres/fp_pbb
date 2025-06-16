// File: movies.dart
import 'package:flutter/material.dart';
import 'package:finalpbb/models/movie_model.dart';
import 'package:finalpbb/pages/popular_movies_page.dart';
import 'package:finalpbb/services/api_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

Widget buildMoviesHome({
  required bool isLoading,
  required List<Movie> movies,
  required BuildContext context,
}) {
  return StreamBuilder<User?>(
    stream: FirebaseAuth.instance.authStateChanges(),
    builder: (context, snapshot) {
      final user = snapshot.data;

      return isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Greeting & Notification
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(
                            backgroundImage: NetworkImage(
                              "https://randomuser.me/api/portraits/men/12.jpg",
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Welcome back 👋",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                user?.email ?? 'Guest',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Icon(Icons.notifications_none, color: Colors.black),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        "Now Showing",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text("See more", style: TextStyle(color: Colors.blue)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 280,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: movies.length,
                      itemBuilder: (context, index) {
                        final movie = movies[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              'movie',
                              arguments: {
                                'movieId': movie.id.toString(),
                                'movieName': movie.title,
                                'posterPath': movie.posterPath,
                                'overview': movie.overview,
                                'voteAverage': movie.voteAverage,
                              },
                            );
                          },
                          child: Container(
                            width: 160,
                            margin: const EdgeInsets.only(right: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    movie.posterUrl,
                                    height: 220,
                                    width: 160,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  movie.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                      size: 16,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      // Assuming vote_average is a double
                                      "${movie.voteAverage}/10 IMDb",
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Popular",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PopularMoviesPage(movies: movies),
                            ),
                          );
                        },
                        child: const Text(
                          "See more",
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Column(
                    children:
                        movies.take(3).map((movie) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                'movie',
                                arguments: {
                                  'movieId': movie.id.toString(),
                                  'movieName': movie.title,
                                  'posterPath': movie.posterPath,
                                  'overview': movie.overview,
                                  'voteAverage': movie.voteAverage,
                                },
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              child: IntrinsicHeight(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        movie.posterUrl,
                                        height: 120,
                                        width: 100,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            movie.title,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.star,
                                                color: Colors.amber,
                                                size: 16,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                "${movie.voteAverage}/10 IMDb",
                                                style: const TextStyle(fontSize: 12),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          FutureBuilder<List<String>>(
                                            future: ApiService.fetchKeywords(
                                              movie.id,
                                            ),
                                            builder: (context, snapshot) {
                                              if (snapshot.connectionState ==
                                                  ConnectionState.waiting) {
                                                return const SizedBox(); // Loader kecil kalau mau fancy
                                              } else if (snapshot.hasError ||
                                                  !snapshot.hasData ||
                                                  snapshot.data!.isEmpty) {
                                                return const Text("No tags");
                                              } else {
                                                final keywords = snapshot.data!;
                                                return Container(
                                                  constraints: const BoxConstraints(
                                                    maxHeight:
                                                        65, // 2 baris kira-kira
                                                  ),
                                                  child: SingleChildScrollView(
                                                    child: Wrap(
                                                      spacing: 6,
                                                      runSpacing: 4,
                                                      children:
                                                          keywords.map((
                                                            keyword,
                                                          ) {
                                                            return Chip(
                                                              label: Text(
                                                                keyword,
                                                                style:
                                                                    const TextStyle(
                                                                      fontSize:
                                                                          8,
                                                                    ),
                                                              ),
                                                              backgroundColor:
                                                                  Colors
                                                                      .grey[200],
                                                              padding:
                                                                  const EdgeInsets.symmetric(
                                                                    horizontal:
                                                                        2,
                                                                    vertical: 0,
                                                                  ),
                                                              shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      24,
                                                                    ),
                                                              ),
                                                              materialTapTargetSize:
                                                                  MaterialTapTargetSize
                                                                      .shrinkWrap,
                                                              visualDensity:
                                                                  VisualDensity
                                                                      .compact,
                                                            );
                                                          }).toList(),
                                                    ),
                                                  ),
                                                );
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                ],
              ),
            ),
          );
    },
  );
}
