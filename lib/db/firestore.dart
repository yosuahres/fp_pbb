// init db
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final CollectionReference movie =
      FirebaseFirestore.instance.collection('movie');

  Future<void> addWatchedMovie(int movieId, String title, String posterPath, String overview) {
    return movie.add({
      'movieId': movieId,
      'title': title,
      'posterPath': posterPath,
      'overview': overview,
      'timestamp': Timestamp.now(),
    });
  }

  Stream<QuerySnapshot> getWatchedMovie() {
    return movie.orderBy('timestamp', descending: true).snapshots();
  }

  Future<void> updateWatchedMovie(String movieId, String comment) {
    return movie.doc(movieId).update({
      'comment': comment,
      'timestamp': Timestamp.now(), 
    });
  } 

  Future<void> deleteWatchedMovie(String movieId) {
    return movie.doc(movieId).delete();
  }
}                        