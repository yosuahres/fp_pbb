import 'package:finalpbb/pages/login.dart';
import 'package:finalpbb/services/api_service.dart';
import 'package:finalpbb/models/movie_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Movie> _movies = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMovies();
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

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Popular Movies'),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () => _logout(context),
                ),
              ],
            ),
            body:
                _isLoading
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
                        );
                      },
                    ),
          );
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}

// import 'package:finalpbb/pages/login.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';

// class HomeScreen extends StatelessWidget {
//   const HomeScreen({super.key});

//   void logout(context) async {
//     await FirebaseAuth.instance.signOut();
//     Navigator.pushReplacementNamed(context, 'login');
//   }

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<User?>(
//       stream: FirebaseAuth.instance.authStateChanges(),
//       builder: (context, snapshot) {
//         if (snapshot.hasData) {
//           return Scaffold(
//             appBar: AppBar(
//               title: const Text('Account Information'),
//               centerTitle: true,
//             ),
//             body: Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text('Logged in as ${snapshot.data?.email}'),
//                   const SizedBox(height: 24),
//                   OutlinedButton(
//                     onPressed: () => logout(context),
//                     child: const Text('Logout'),
//                   )
//                 ],
//               ),
//             ),
//           );
//         } else {
//           return const LoginScreen();
//         }
//       },
//     );
//   }
// }
