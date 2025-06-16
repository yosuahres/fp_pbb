import 'package:cloud_firestore/cloud_firestore.dart';

// review_model.dart
class ReviewModel {
  final String movieId;
  final String movieName;
  final String posterPath;
  final String overview;
  final List<String> reviews;  // List of reviews for the movie

  ReviewModel({
    required this.movieId,
    required this.movieName,
    required this.posterPath,
    required this.overview,
    required this.reviews,
  });

  // Convert from JSON (for API/Firestore data)
  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      movieId: json['movieId'] as String,
      movieName: json['movieName'] as String,
      posterPath: json['posterPath'] as String,
      overview: json['overview'] as String,
      reviews: List<String>.from(json['reviews']),
    );
  }

  // Convert to JSON (for sending data to API/Firestore)
  Map<String, dynamic> toJson() {
    return {
      'movieId': movieId,
      'movieName': movieName,
      'posterPath': posterPath,
      'overview': overview,
      'reviews': reviews,
    };
  }
}
// File: models/review_model.dart
// Pastikan model Anda seperti ini agar cocok dengan Firestore
class Review {
  final String id;
  final String movieId;
  final String userId;
  final String content;
  final int rating;
  final DateTime timestamp;
  // Anda bisa menambahkan properti lain seperti userName jika perlu
  // final String userName;

  Review({
    required this.id,
    required this.movieId,
    required this.userId,
    required this.content,
    required this.rating,
    required this.timestamp,
    // required this.userName,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'movieId': movieId,
      'userId': userId,
      'content': content,
      'rating': rating,
      'timestamp': timestamp, // Firestore akan mengonversi ini ke Timestamp
    };
  }

  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      id: map['id'],
      movieId: map['movieId'],
      userId: map['userId'],
      content: map['content'],
      rating: map['rating'],
      // Firestore mengembalikan Timestamp, jadi kita perlu mengonversinya
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      // userName: map['userName'] ?? 'Anonymous',
    );
  }
}