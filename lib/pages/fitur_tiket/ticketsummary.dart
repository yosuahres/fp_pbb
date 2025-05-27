import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finalpbb/db/firestore.dart';

class TicketSummaryScreen extends StatefulWidget {
  const TicketSummaryScreen({ Key? key }) : super(key: key);

  @override
  _TicketseatState createState() => _TicketseatState();
}

class _TicketseatState extends State<TicketSummaryScreen> {
  final FirestoreService _firestoreService = FirestoreService();


  @override
  Widget build(BuildContext context) {
    return Container(
      
    );
  }
}