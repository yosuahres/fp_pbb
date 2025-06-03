import 'package:finalpbb/db/firestore.dart';
import 'package:finalpbb/pages/login.dart';
import 'package:finalpbb/services/api_service.dart';
import 'package:finalpbb/models/movie_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Movie> _movies = [];
  bool _isLoading = true;
  final FirestoreService firestoreService = FirestoreService();
  int status = 0;

  @override
  void initState() {
    super.initState();
    _fetchMovies();
  }

  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    if (args != null && args['tab'] != null) {
      status = args['tab'] as int;
      setState(() {});
    }
  }

  void _fetchMovies() async {
    final movies = await ApiService.fetchPopularMovies();
    setState(() {
      _movies = movies ?? [];
      _isLoading = false;
    });
  }

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, 'login');
  }

  Widget _profile() {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        final user = snapshot.data;
        if (user != null) {
          // Logged in
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person, size: 80),
                SizedBox(height: 16),
                Text(user.email ?? 'No email', style: TextStyle(fontSize: 18)),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _logout(context),
                  child: Text('Logout'),
                ),
              ],
            ),
          );
        } else {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person_off, size: 80),
                SizedBox(height: 16),
                Text("You're not logged in", style: TextStyle(fontSize: 18)),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, 'login');
                  },
                  child: Text('Login'),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  Widget _bottomNavBar() {
    switch (status) {
      case 0:
        return _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
              itemCount: _movies.length,
              itemBuilder: (context, index) {
                final movie = _movies[index];
                return ListTile(
                  leading:
                      movie.posterPath.isNotEmpty
                          ? Image.network(movie.posterUrl)
                          : const SizedBox(width: 50),
                  title: Text(movie.title),
                  subtitle: Text(
                    movie.overview,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // trailing: IconButton(
                  //   icon: const Icon(Icons.favorite),
                  //   onPressed: () => _watchedMovie(movie),
                  // ),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      'movie',
                      arguments: {
                        'movieId': movie.id.toString(),
                        'movieName': movie.title,
                        'posterPath': movie.posterPath,
                        'overview': movie.overview,
                      },
                    );
                  },
                );
              },
            );
      case 1:
        return StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, userSnapshot) {
            final user = userSnapshot.data;
            if (user == null) {
              return const Center(
                child: Text('Please login to see your orders.'),
              );
            }
            return StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('orders')
                      .where('userId', isEqualTo: user.uid)
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snapshot.data!.docs;
                if (docs.isEmpty) {
                  return const Center(child: Text('Belum ada pesanan.'));
                }
                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    return ListTile(
                      leading:
                          data['posterPath'] != null && data['posterPath'] != ''
                              ? Image.network(
                                'https://image.tmdb.org/t/p/w200${data['posterPath']}',
                                width: 50,
                              )
                              : const Icon(Icons.movie),
                      title: Text(data['movieName'] ?? ''),
                      subtitle: Text(
                        'Kursi: ${(data['selectedSeats'] as List).join(', ')}\nTotal: Rp${data['totalPrice']}',
                      ),
                      isThreeLine: true,
                    );
                  },
                );
              },
            );
          },
        );

      case 2:
        return const Center(child: Text('Promos'));
      case 3:
        return _profile();
      default:
        return const Center(child: Text('Page not found'));
    }
  }

  void _tempStatus(int index) {
    setState(() {
      status = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // return StreamBuilder<User?>(
    // stream: FirebaseAuth.instance.authStateChanges(),
    // builder: (context, snapshot) {
    // if (snapshot.hasData) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Popular Movies'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.pushNamed(context, 'watchlist');
            },
          ),
        ],
      ),
      body: _bottomNavBar(),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black,
        currentIndex: status,
        onTap: _tempStatus,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.movie), label: 'Movies'),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'My Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_offer),
            label: 'Promos',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
      // _isLoading
      //     ? const Center(child: CircularProgressIndicator())
      //     : ListView.builder(
      //       itemCount: _movies.length,
      //       itemBuilder: (context, index) {
      //         final movie = _movies[index];
      //         return ListTile(
      //           leading:
      //               movie.posterPath.isNotEmpty
      //                   ? Image.network(movie.posterUrl)
      //                   : const SizedBox(width: 50),
      //           title: Text(movie.title),
      //           subtitle: Text(
      //             movie.overview,
      //             maxLines: 2,
      //             overflow: TextOverflow.ellipsis,
      //           ),
      //           trailing: IconButton(
      //             icon: const Icon(Icons.heart_broken),
      //             onPressed: () => _watchedMovie(movie),
      //           ),
      //           onTap:  () {
      //             Navigator.pushNamed(context, 'ticketseat',
      //             arguments: {
      //               'movieId': movie.id.toString(),
      //               'movieName': movie.title,
      //               'posterPath': movie.posterPath,
      //               // 'overview': movie.overview,
      //             }
      //             );
      //           },
      //         );
      //       },
      //     ),
    );
    // } else {
    //   return const LoginScreen();
    // }
    // },
    // );
  }
}
