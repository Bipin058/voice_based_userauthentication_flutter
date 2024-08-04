import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppointmentBookingPage extends StatefulWidget {
  const AppointmentBookingPage({super.key});

  @override
  _AppointmentBookingPageState createState() => _AppointmentBookingPageState();
}

class _AppointmentBookingPageState extends State<AppointmentBookingPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _healthIssuesController = TextEditingController();
  String? _selectedDoctorEmail;
  List<String> _doctorEmails = [];

  @override
  void initState() {
    super.initState();
    _fetchDoctorEmails();
    _setUserEmail();
  }

  Future<void> _fetchDoctorEmails() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('doctors').get();
    final emails = snapshot.docs.map((doc) => doc['email'] as String).toList();
    setState(() {
      _doctorEmails = emails;
    });
  }

  Future<void> _setUserEmail() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _emailController.text = user.email ?? '';
    }
  }

  void _registerAppointment() async {
    if (_formKey.currentState!.validate()) {
      await FirebaseFirestore.instance.collection('appointments').add({
        'name': _nameController.text,
        'age': _ageController.text,
        'phone': _phoneController.text,
        'email': _emailController.text,
        'doctorEmail': _selectedDoctorEmail,
        'healthIssues': _healthIssuesController.text,
      });

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Success'),
          content: const Text(
              'Your appointment booking registration is successful, thank you!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                Navigator.pop(context); // Go back to user home page
              },
              child: const Text('Back'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointment Booking'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _ageController,
                decoration: const InputDecoration(labelText: 'Age'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your age';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone No.'),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                readOnly: true, // Make the email field read-only
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: "Doctor's Email"),
                items: _doctorEmails.map((email) {
                  return DropdownMenuItem(
                    value: email,
                    child: Text(email),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedDoctorEmail = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return "Please select a doctor's email";
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _healthIssuesController,
                decoration: const InputDecoration(labelText: 'Health Issues'),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please describe your health issues';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _registerAppointment,
                child: const Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
