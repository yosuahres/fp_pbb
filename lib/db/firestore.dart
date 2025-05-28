import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  // final CollectionReference users =
  //     FirebaseFirestore.instance.collection('users');

  // // --- USER MANAGEMENT ---


  final CollectionReference seats =
      FirebaseFirestore.instance.collection('seats');

  CollectionReference getSeatsCollection(String movieId) {
    return FirebaseFirestore.instance.collection('movies').doc(movieId).collection('seats');
  }    

  // --- SEAT MANAGEMENT ---


  Stream<QuerySnapshot> getSeats(String movieId) {
    return getSeatsCollection(movieId).orderBy('seatId').snapshots();
  }

  Future<void> updateSeatStatus(String seatDocId, String newStatus, String? userId) {
    return seats.doc(seatDocId).update({
      'status': newStatus,
      'userId': newStatus == 'booked' ? userId : null, 
      'timestamp': Timestamp.now(),
    });
  }

  Future<void> addSeat(String seatId, String status) {
    return seats.add({
      'seatId': seatId,
      'status': status, 
      'userId': null,  
      'timestamp': Timestamp.now(),
    });
  }

  Future<void> initializeDefaultSeats(String movieId, int rows, int cols) async {
    final seatsCollection = getSeatsCollection(movieId);
    final QuerySnapshot existingSeats = await seatsCollection.limit(1).get();
    if (existingSeats.docs.isEmpty) {
      WriteBatch batch = FirebaseFirestore.instance.batch();
      for (int i = 0; i < rows; i++) {
        String rowChar = String.fromCharCode('A'.codeUnitAt(0) + i);
        for (int j = 1; j <= cols; j++) {
          String seatId = '$rowChar$j';
          DocumentReference seatRef = seatsCollection.doc(seatId);
          batch.set(seatRef, {
            'seatId': seatId,
            'status': 'available',
            'userId': null,
            'timestamp': Timestamp.now(),
          });
        }
      }
      await batch.commit();
    }
  }

  // --- MOVIE MANAGEMENT ---

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

  Future<void> updateWatchedMovie(String docId, String comment) { 
    return movie.doc(docId).update({
      'comment': comment,
      'timestamp': Timestamp.now(),
    });
  }

  Future<void> deleteWatchedMovie(String docId) { 
    return movie.doc(docId).delete();
  }
}