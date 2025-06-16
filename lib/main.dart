import 'dart:ui';

import 'package:finalpbb/pages/movie.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

//pages
import 'package:finalpbb/pages/home.dart';
import 'package:finalpbb/pages/login.dart';
import 'package:finalpbb/pages/register.dart';
import 'package:finalpbb/pages/watchlist.dart';
import 'package:finalpbb/pages/fitur_tiket/ticketseat.dart';
import 'package:finalpbb/pages/fitur_tiket/ticketsummary.dart';
import 'package:finalpbb/pages/review.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Pass all uncaught "fatal" errors from the framework to Crashlytics
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    initialization();
    FlutterNativeSplash.remove();
  }

  void initialization() async {
    print("pausing..");
    await Future.delayed(const Duration(seconds: 3));
    print("done pausing..");
    FlutterNativeSplash.remove();
  }

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
        'review': (context) => const ReviewPage(),
      },
    );
  }
}
