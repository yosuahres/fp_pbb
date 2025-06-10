import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:finalpbb/db/firestore.dart'; 
import 'package:finalpbb/models/seat_model.dart';
import 'dart:math' as math;

class TicketSeatScreen extends StatefulWidget {
  const TicketSeatScreen({Key? key}) : super(key: key);

  @override
  _TicketSeatScreenState createState() => _TicketSeatScreenState();
}

class _TicketSeatScreenState extends State<TicketSeatScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late String movieId;
  late String movieName;
  late String posterPath;
  late String? orderId; // New: Optional orderId for editing
  late List<String> initialSelectedSeats; // New: For pre-selecting seats in edit mode
  late bool isEditing; // New: Flag to indicate edit mode

  List<Seat> _allSeats = [];
  final List<String> _selectedSeatDocIds = [];
  final double _seatPrice = 50000.0;

  bool _isLoading = true;

  final int _numRows = 5;
  final int _numCols = 8;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as Map?;
    if (args != null) {
      movieId = args['movieId'].toString() ?? '';
      movieName = args['movieName'] ?? '';
      posterPath = args['posterPath'] ?? '';
      orderId = args['orderId'] as String?; // Get orderId
      initialSelectedSeats = List<String>.from(args['selectedSeats'] ?? []); // Get initial selected seats
      isEditing = args['isEditing'] ?? false; // Get isEditing flag

      if (isEditing && initialSelectedSeats.isNotEmpty) {
        // Pre-select seats if in edit mode
        _selectedSeatDocIds.addAll(initialSelectedSeats);
      }
    }
    _LoadSeats();
  }

  Future<void> _LoadSeats() async {
    await _firestoreService.initializeDefaultSeats(movieId, _numRows, _numCols);
    _loadSeats();
  }

  void _loadSeats() {
    _firestoreService.getSeats(movieId).listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        setState(() {
          _allSeats = snapshot.docs.map((doc) => Seat.fromFirestore(doc)).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _allSeats = [];
          _isLoading = false;
        });
      }
    }, onError: (error) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("bad: $error")),
      );
    });
  }

  void _onSeatTap(Seat seat) {
    final currentUserUid = _auth.currentUser?.uid;

    // If the seat is booked by someone else, it's not selectable
    if (seat.status == 'booked' && seat.userId != currentUserUid) {
      return;
    }

    setState(() {
      if (_selectedSeatDocIds.contains(seat.docId)) {
        _selectedSeatDocIds.remove(seat.docId);
      } else {
        _selectedSeatDocIds.add(seat.docId);
      }
    });
  }

  Color _getSeatColor(Seat seat) {
    final currentUserUid = _auth.currentUser?.uid;

    if (seat.status == 'booked' && seat.userId != currentUserUid) {
      return Colors.grey.shade400; // Booked by another user
    } else if (_selectedSeatDocIds.contains(seat.docId)) {
      return Colors.blue.shade400; // Selected by current user
    } else {
      return Colors.blueGrey.shade900; // Available
    }
  }


  @override
  Widget build(BuildContext context) {
    List<Seat> currentlySelectedSeats = _allSeats
        .where((seat) => _selectedSeatDocIds.contains(seat.docId))
        .toList();
    double totalPrice = currentlySelectedSeats.length * _seatPrice;


    //login ora
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {

      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }

      if (!snapshot.hasData) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacementNamed(
            context,
            'home',
            arguments: {'tab': 3},
          );
        });
        return const SizedBox(); 
      }
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          movieName.isNotEmpty ? movieName : 'Pilih Kursi',
          style: const TextStyle(
            fontSize: 18, 
          ),
        ),
        // backgroundColor: Colors.grey.shade50,
      ),
      body: Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
      ),

      child: _isLoading && _allSeats.isEmpty 
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 12.0, bottom: 12.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center, 
                        children: [
                          _legendItem(Colors.blueGrey.shade900, "Tersedia"),
                          SizedBox(width: 18), 
                          _legendItem(Colors.grey.shade400, "Tidak Tersedia"),
                          SizedBox(width: 18),
                          _legendItem(Colors.blue.shade400, "Pilihanmu"),
                        ],
                      ),
                      // const SizedBox(height: 8),
                        const Divider(
                        thickness: 1,
                        color: Colors.grey,
                        height: 24,
                      ),
                    ],
                  ),
                ),
                
                // Expanded(
                //   child: _allSeats.isEmpty && !_isLoading
                //       ? const Center(child: Text("No seats available or failed to load."))
                //       : GridView.builder(
                //           padding: const EdgeInsets.all(16.0),
                //           gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                //             crossAxisCount: _numCols, 
                //             crossAxisSpacing: 8.0,
                //             mainAxisSpacing: 8.0,
                //             childAspectRatio: 1.2, 
                //           ),
                //           itemCount: _allSeats.length,
                //           itemBuilder: (context, index) {
                //             final seat = _allSeats[index];
                //             return InkWell(
                //               onTap: () => _onSeatTap(seat),
                //               child: Container(
                //                 decoration: BoxDecoration(
                //                   color: _getSeatColor(seat),
                //                   borderRadius: BorderRadius.circular(5.0),
                //                   border: Border.all(color: Colors.black26),
                //                 ),
                //                 child: Center(
                //                   child: Text(
                //                     seat.seatId,
                //                     style: TextStyle(
                //                       color: _getSeatColor(seat) == Colors.blueGrey.shade900 || _getSeatColor(seat) == Colors.blue.shade400 
                //                       ? Colors.white 
                //                       : Colors.grey.shade700,
                //                       fontWeight: FontWeight.bold,
                //                       fontSize: 12,
                //                     ),
                //                   ),
                //                 ),
                //               ),
                //             );
                //           },
                //         ),

                // ),

                Expanded(
                  child: _allSeats.isEmpty && !_isLoading
                      ? const Center(child: Text("bad"))
                      : Column(
                          children: [
                            Expanded(
                              child: GridView.builder(
                                padding: const EdgeInsets.all(16.0),
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: _numCols,
                                  crossAxisSpacing: 8.0,
                                  mainAxisSpacing: 8.0,
                                  childAspectRatio: 1.2,
                                ),
                                itemCount: _allSeats.length,
                                itemBuilder: (context, index) {
                                  final seat = _allSeats[index];
                                  return InkWell(
                                    onTap: () => _onSeatTap(seat),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: _getSeatColor(seat),
                                        borderRadius: BorderRadius.circular(5.0),
                                        border: Border.all(color: Colors.black26),
                                      ),
                                      child: Center(
                                        child: Text(
                                          seat.seatId,
                                          style: TextStyle(
                                            color: _getSeatColor(seat) == Colors.blueGrey.shade900 ||
                                                    _getSeatColor(seat) == Colors.blue.shade400
                                                ? Colors.white
                                                : Colors.grey.shade700,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            // Movie screen representation
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 60),
                              child: SizedBox(
                                height: 20,
                                width: double.infinity,
                                child: CustomPaint(
                                  painter: MovieScreenPainter(),
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
                
              // if (_selectedSeatDocIds.isNotEmpty)  
                Container(
                  padding: const EdgeInsets.all(16.0),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text(
                                  'Total Harga',
                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Rp ${totalPrice.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                      fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            height: 32,
                            width: 1,
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            color: Colors.grey.shade400,
                          ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text(
                                'Tempat Duduk',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 8),
                              currentlySelectedSeats.isEmpty
                                  ? const Text(
                                      "Kursi belum dipilih",
                                      style: TextStyle(fontSize: 12),
                                      textAlign: TextAlign.center,
                                    )
                                  : Wrap(
                                      spacing: 6,
                                      runSpacing: 6,
                                      alignment: WrapAlignment.center,
                                      children: currentlySelectedSeats.map((seat) {
                                        return Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: Colors.blueGrey.shade900,
                                            borderRadius: BorderRadius.circular(5.0),
                                            border: Border.all(color: Colors.black26),
                                          ),
                                          child: Text(
                                            seat.seatId,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 10,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                              const SizedBox(height: 4),
                            ],
                          ),
                        ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Action buttons section
                      Row(
                        children: [
                          // Expanded(
                          //   child: ElevatedButton(
                          //     style: ElevatedButton.styleFrom(
                          //       padding: const EdgeInsets.symmetric(vertical: 12),
                          //     ),
                          //     onPressed: _selectedSeatDocIds.isNotEmpty && !_isLoading
                          //         ? () {
                          //             setState(() {
                          //               _selectedSeatDocIds.clear();
                          //             });
                          //           }
                          //         : null,
                          //     child: const Text(
                          //       'Clear Picks',
                          //       style: TextStyle(fontSize: 16, color: Colors.black),
                          //     ),
                          //   ),
                          // ),

                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton(
                              style: FilledButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.zero, 
                                ),
                                backgroundColor: Colors.blueGrey.shade900,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                                onPressed: _selectedSeatDocIds.isNotEmpty && !_isLoading
                                    ? () {
                                        WidgetsBinding.instance.addPostFrameCallback((_) {
                                          Navigator.pushNamed(
                                            context,
                                            'ticketsummary',
                                            arguments: {
                                              //parsing data
                                              'movieId': movieId,
                                              'movieName': movieName,
                                              'selectedSeats': currentlySelectedSeats.map((s) => s.seatId).toList(),
                                              'seatDocIds': _selectedSeatDocIds,
                                              'totalPrice': totalPrice,
                                              'posterPath': posterPath,
                                              'orderId': orderId, // Pass orderId
                                              'isEditing': isEditing, // Pass isEditing flag
                                            },
                                          );
                                        });
                                      }
                                    : null,
                              child: Text(
                                'RINGKASAN ORDER',
                                style: TextStyle(fontSize: 14, color: Colors.yellow.shade700),
                              ),
                            ),
                          ),
                          
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
      ),
    );
      },
    );
  }

  Widget _legendItem(Color color, String text) {
    return Row(
      children: [
        Container(width: 15, height: 15, color: color, margin: const EdgeInsets.only(right: 6)),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
          ),
          ),
      ],
    );
  }
}

class MovieScreenPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade700
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height * 2);
    canvas.drawArc(
      rect,
      math.pi, 
      -math.pi, 
      false,
      paint,
    );

    final textPainter = TextPainter(
      text: TextSpan(
        text: "LAYAR BIOSKOP",
        style: TextStyle(
          color: Colors.grey.shade700,
          fontWeight: FontWeight.bold,
          fontSize: 12,
          // letterSpacing: 2,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    textPainter.layout(minWidth: 0, maxWidth: size.width);
    textPainter.paint(
      canvas,
      Offset((size.width - textPainter.width) / 2, 0),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
