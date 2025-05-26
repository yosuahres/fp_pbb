//////////////
///Author: Yosua Hares
///Desc: Daftar “Sudah Ditonton” CRUD
////////////////

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finalpbb/db/firestore.dart';

class HistoryPage extends StatelessWidget {
  final FirestoreService _firestoreService = FirestoreService();

  HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Watched Movies'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestoreService.getWatchedMovie(),
        builder: (context, snapshot) {
          final docs = snapshot.data?.docs ?? [];
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              return ListTile(
                leading: data['posterPath'] != null && data['posterPath'].isNotEmpty
                    ? Image.network('https://image.tmdb.org/t/p/w92${data['posterPath']}')
                    : const SizedBox(width: 50),
                title: Text(data['title'] ?? 'No Title'),
                subtitle: Text(
                  data['overview'] ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () async {
                    await _firestoreService.deleteWatchedMovie(docs[index].id);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}