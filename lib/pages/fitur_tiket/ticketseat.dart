import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finalpbb/db/firestore.dart'; 
import 'package:finalpbb/models/seat_model.dart';

class TicketSeatScreen extends StatefulWidget {
  const TicketSeatScreen({Key? key}) : super(key: key);

  @override
  _TicketSeatScreenState createState() => _TicketSeatScreenState();
}

class _TicketSeatScreenState extends State<TicketSeatScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  List<Seat> _allSeats = [];
  final List<String> _selectedSeatDocIds = []; 
  final double _seatPrice = 50000.0;
  
  bool _isLoading = true;

  final int _numRows = 5;
  final int _numCols = 8;

  @override
  void initState() {
    super.initState();
    _LoadSeats();
  }

  Future<void> _LoadSeats() async {
    await _firestoreService.initializeDefaultSeats(_numRows, _numCols);
    _loadSeats();
  }

  void _loadSeats() {
    _firestoreService.getSeats().listen((snapshot) {
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
        SnackBar(content: Text("Error loading seats: $error")),
      );
    });
  }

  void _onSeatTap(Seat seat) {
    if (seat.status == 'booked') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${seat.seatId} is already booked.')),
      );
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
    if (seat.status == 'booked') {
      return Colors.brown; 
    } else if (_selectedSeatDocIds.contains(seat.docId)) {
      return Colors.teal.shade700; 
    } else {
      return Colors.white70;
    }
  }

  Future<void> _bookSelectedSeats() async {
    if (_selectedSeatDocIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one seat.')),
      );
      return;
    }

    String DUMMY_USER_ID = "user123"; 

    setState(() { _isLoading = true; }); 

    try {
      WriteBatch batch = FirebaseFirestore.instance.batch();
      for (String seatDocId in _selectedSeatDocIds) {
        Seat s = _allSeats.firstWhere((seat) => seat.docId == seatDocId);

        DocumentReference seatRef = _firestoreService.seats.doc(seatDocId);
        batch.update(seatRef, {
          'status': 'booked',
          'userId': DUMMY_USER_ID,
          'timestamp': Timestamp.now(),
        });
      }
      await batch.commit();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${_selectedSeatDocIds.length} seat(s) booked successfully!')),
      );
      setState(() {
        _selectedSeatDocIds.clear(); 
        _isLoading = false;
      });

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error booking seats: $e')),
      );
      setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Seat> currentlySelectedSeats = _allSeats
        .where((seat) => _selectedSeatDocIds.contains(seat.docId))
        .toList();
    String selectedSeatNames = currentlySelectedSeats.map((s) => s.seatId).join(', ');
    double totalPrice = currentlySelectedSeats.length * _seatPrice;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Your Seat'),
      ),
      body: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomRight,
          end: Alignment.topLeft,
          colors: [
            Colors.white,
            Color(0xFF90CAF9), // Light blue
            Colors.white,
          ],
          stops: [0.0, 0.1, 0.5], // More white dominance
        ),
      ),

      child: _isLoading && _allSeats.isEmpty 
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // screen movie icon
                Padding(
                  padding: const EdgeInsets.only(top: 24.0, bottom: 12.0),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        alignment: Alignment.center,
                        child: ClipRRect(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(30),
                            bottom: Radius.circular(30),
                          ),
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.7,
                            height: 28,
                            color: Colors.teal.shade700,
                            alignment: Alignment.center,
                            child: const Text(
                              'Screen Area',
                              style: TextStyle(
                                color: Colors.brown,
                                // fontWeight: FontWeight.bold,
                                fontSize: 13,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
                
                Expanded(
                  child: _allSeats.isEmpty && !_isLoading
                      ? const Center(child: Text("No seats available or failed to load."))
                      : GridView.builder(
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
                                      color: _getSeatColor(seat) == Colors.black38 || _getSeatColor(seat) == Colors.grey
                                          ? Colors.black54
                                          : Colors.black87,
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
                
              if (_selectedSeatDocIds.isNotEmpty)  
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _legendItem(Colors.white10, "Available"),
                                _legendItem(Colors.grey.shade800, "Selected"),
                                _legendItem(Colors.brown, "Booked"),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                            // TEMPAT DUDUK column
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      selectedSeatNames.isEmpty ? "None" : selectedSeatNames,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    const SizedBox(height: 4),
                                  ],
                                ),
                              // TOTAL HARGA column
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    'Rp ${totalPrice.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                        fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      // backgroundColor: Colors.grey.shade400,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                    ),
                                    onPressed: _selectedSeatDocIds.isNotEmpty && !_isLoading
                                        ? () {
                                            setState(() {
                                              _selectedSeatDocIds.clear();
                                            });
                                          }
                                        : null,
                                    child: const Text(
                                      'Clear Picks',
                                      style: TextStyle(fontSize: 16, color: Colors.black),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.teal.shade700,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                    ),
                                    onPressed: _selectedSeatDocIds.isNotEmpty && !_isLoading
                                        ? () {
                                            Navigator.pushNamed(context, 'ticketsummary');
                                          }
                                        : null,
                                    child: const Text(
                                      'Continue',
                                      style: TextStyle(fontSize: 16, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                    ),
                  ),
                ),
              ],
            ),
      ),
    );
  }

  Widget _legendItem(Color color, String text) {
    return Row(
      children: [
        Container(width: 15, height: 15, color: color, margin: const EdgeInsets.only(right: 6)),
        Text(text),
      ],
    );
  }
}