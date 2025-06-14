import 'package:cloud_firestore/cloud_firestore.dart';

class Seat {
  final String docId;
  final String seatId;
  String status;
  final String? userId;
  final Timestamp? timestamp;

  Seat({
    required this.docId,
    required this.seatId,
    required this.status,
    this.userId,
    this.timestamp,
  });

  factory Seat.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Seat(
      docId: doc.id,
      seatId: data['seatId'] ?? 'N/A',
      status: data['status'] ?? 'unavailable',
      userId: data['userId'],
      timestamp: data['timestamp'] as Timestamp?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'seatId': seatId,
      'status': status,
      'userId': userId,
      'timestamp': timestamp ?? FieldValue.serverTimestamp(),
    };
  }
}
