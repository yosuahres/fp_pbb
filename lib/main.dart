import 'package:finalpbb/pages/movie.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

//pages
import 'package:finalpbb/pages/home.dart';
import 'package:finalpbb/pages/login.dart';
import 'package:finalpbb/pages/register.dart';
import 'package:finalpbb/pages/watchlist.dart';
import 'package:finalpbb/pages/fitur_tiket/ticketseat.dart';
import 'package:finalpbb/pages/fitur_tiket/ticketsummary.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: 'home',
      routes: {
        'home': (context) => const HomeScreen(),
        'login': (context) => const LoginScreen(),
        'register': (context) => const RegisterScreen(),
        'movie':
            (context) => MoviePage(
              arguments: ModalRoute.of(context)?.settings.arguments as Map,
            ),
        'watchlist': (context) => watchlistScreen(),
        'ticketseat': (context) => const TicketSeatScreen(),
        'ticketsummary': (context) => const TicketSummaryScreen(),
      },
    );
  }
}
