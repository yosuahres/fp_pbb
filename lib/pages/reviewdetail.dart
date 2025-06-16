// reviewdetail_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import 'package:finalpbb/db/firestore.dart'; // Sesuaikan dengan path Anda
import 'package:finalpbb/models/review_model.dart'; // Sesuaikan dengan path Anda


class ReviewDetailPage extends StatefulWidget {
  final ReviewModel movie;

  const ReviewDetailPage({Key? key, required this.movie}) : super(key: key);

  @override
  _ReviewDetailPageState createState() => _ReviewDetailPageState();
}

class _ReviewDetailPageState extends State<ReviewDetailPage> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _reviewController = TextEditingController();
  final String? _currentUserId = FirebaseAuth.instance.currentUser?.uid;
  
  int _userRating = 5;
  String? _editingReviewId; // Untuk melacak ID review yang sedang diedit

  // Fungsi untuk mengirim atau memperbarui review
  void _submitReview() async {
    if (_reviewController.text.isEmpty || _currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_currentUserId == null
            ? "You must be logged in to review."
            : "Review cannot be empty."),
      ));
      return;
    }

    if (_editingReviewId == null) {
      // Menambah review baru
      final newReview = {
        'id': const Uuid().v4(),
        'movieId': widget.movie.movieId.toString(),
        'userId': _currentUserId,
        'content': _reviewController.text.trim(),
        'rating': _userRating,
        // Timestamp akan ditambahkan oleh FirestoreService
      };
      await _firestoreService.addReview(newReview);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Review added successfully!")));
    } else {
      // Memperbarui review yang ada
      final updatedReview = {
        'id': _editingReviewId!,
        'content': _reviewController.text.trim(),
        'rating': _userRating,
      };
      await _firestoreService.updateReview(updatedReview);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Review updated successfully!")));
    }
    
    // Reset form
    setState(() {
      _reviewController.clear();
      _userRating = 5;
      _editingReviewId = null;
    });
  }

  // Fungsi untuk memulai mode edit
  void _startEditing(Review review) {
    setState(() {
      _reviewController.text = review.content;
      _userRating = review.rating;
      _editingReviewId = review.id;
    });
  }
  
  // Fungsi untuk menghapus review
  void _deleteReview(String reviewId) async {
    // Tampilkan dialog konfirmasi
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Review"),
          content: const Text("Are you sure you want to delete this review?"),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text("Delete"),
              onPressed: () async {
                await _firestoreService.deleteReview(reviewId);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Review deleted.")));
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF22223B), // Warna latar belakang gelap
      appBar: AppBar(
        title: Text(widget.movie.movieName, style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF22223B),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMovieHeader(),
            const SizedBox(height: 24),
            _buildReviewInput(),
            const SizedBox(height: 24),
            const Text(
              "Reviews",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 8),
            _buildReviewsList(),
          ],
        ),
      ),
    );
  }

  // Widget untuk header informasi film
  Widget _buildMovieHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            widget.movie.posterPath,
            width: 120,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.movie.movieName,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                widget.movie.overview,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
                maxLines: 6,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Widget untuk input review
  Widget _buildReviewInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF4A4E69),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _editingReviewId == null ? "Write a Review" : "Edit Your Review",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 12),
          // Bintang untuk rating
          Row(
            children: List.generate(5, (index) {
              return IconButton(
                onPressed: () => setState(() => _userRating = index + 1),
                icon: Icon(
                  index < _userRating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _reviewController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Share your thoughts...",
              hintStyle: TextStyle(color: Colors.grey[400]),
              filled: true,
              fillColor: const Color(0xFF22223B),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: _submitReview,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
              ),
              child: Text(_editingReviewId == null ? "Submit" : "Update"),
            ),
          ),
        ],
      ),
    );
  }
  
  // Widget untuk daftar review dari Firestore
  Widget _buildReviewsList() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _firestoreService.getReviewsForMovie(widget.movie.movieId.toString()),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text("Be the first to review!", style: TextStyle(color: Colors.grey)),
          );
        }

        final reviews = snapshot.data!.map((map) => Review.fromMap(map)).toList();

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(), // Agar tidak ada scroll di dalam scroll
          itemCount: reviews.length,
          itemBuilder: (context, index) {
            final review = reviews[index];
            final isUserReview = review.userId == _currentUserId;

            return _buildReviewCard(review, isUserReview);
          },
        );
      },
    );
  }

  // Widget untuk satu kartu review
  Widget _buildReviewCard(Review review, bool isUserReview) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF4A4E69),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: Colors.purple,
                child: Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isUserReview ? "Your Review" : "A User's Review", // Bisa diganti dengan username jika ada
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    Row(
                      children: List.generate(5, (i) => Icon(
                        i < review.rating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 16,
                      )),
                    ),
                  ],
                ),
              ),
              // Tampilkan tombol edit & hapus hanya untuk review milik user
              if (isUserReview)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.white70, size: 20),
                      onPressed: () => _startEditing(review),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20),
                      onPressed: () => _deleteReview(review.id),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            review.content,
            style: const TextStyle(color: Colors.white, fontSize: 15),
          ),
        ],
      ),
    );
  }
}