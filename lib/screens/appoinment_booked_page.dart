import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppointmentBookedPage extends StatefulWidget {
  const AppointmentBookedPage({super.key});

  @override
  _AppointmentBookedPageState createState() => _AppointmentBookedPageState();
}

class _AppointmentBookedPageState extends State<AppointmentBookedPage> {
  final _currentUserEmail = FirebaseAuth.instance.currentUser!.email;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booked Appointments'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('appointments')
            .where('doctorEmail', isEqualTo: _currentUserEmail)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No appointments found'));
          }
          return ListView(
            children: snapshot.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return ListTile(
                title: Text('Name: ${data['name']}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Age: ${data['age']}'),
                    Text('Phone: ${data['phone']}'),
                    Text('Email: ${data['email']}'),
                    Text('Health Issues: ${data['healthIssues']}'),
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
