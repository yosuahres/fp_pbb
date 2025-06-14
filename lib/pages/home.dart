import 'package:finalpbb/db/firestore.dart';
import 'package:finalpbb/services/api_service.dart';
import 'package:finalpbb/models/movie_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:finalpbb/pages/movies.dart';
import 'package:finalpbb/pages/profile.dart';
import 'package:finalpbb/pages/orders_detail.dart';

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

  final PageController _carouselController = PageController(
    viewportFraction: 0.8,
  );
  @override
  void dispose() {
    _carouselController.dispose();
    super.dispose();
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

  Widget _bottomNavBar() {
    switch (status) {
      case 0:
        return buildMoviesHome(
          isLoading: _isLoading,
          movies: _movies,
          context: context,
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
                      onTap:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => OrderDetailScreen(
                                    orderData: data,
                                    orderId: docs[index].id,
                                  ),
                            ),
                          ),
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
        return const ProfileScreen();
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
            icon: const Icon(Icons.favorite_border),
            onPressed: () {
              Navigator.pushNamed(context, 'watchlist');
            },
          ),
        ],
      ),
      body: _bottomNavBar(),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.purple.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
              offset: Offset(0, -2), // bayangan ke atas
            ),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor:
              Colors
                  .transparent, // transparan, biar BoxDecoration di atas keliatan
          elevation: 0, // hapus shadow bawaan
          selectedItemColor: Colors.purple, // warna icon saat aktif
          unselectedItemColor: Colors.black, // warna icon saat nonaktif
          currentIndex: status,
          onTap: _tempStatus,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Movies'),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag),
              label: 'Orders',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.local_offer),
              label: 'Promos',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}
