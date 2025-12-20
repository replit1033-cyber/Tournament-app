import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const TournamentApp());
}

class TournamentApp extends StatelessWidget {
  const TournamentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FF Crown',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: const AuthGate(),
    );
  }
}

// Simple Phone Authentication screen
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  String _verificationId = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Phone Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _auth.currentUser == null ? Column(
          children: [
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(
                  labelText: 'Phone number', hintText: '+91xxxxxxxxxx'),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async {
                await _auth.verifyPhoneNumber(
                  phoneNumber: _phoneController.text,
                  verificationCompleted: (credential) async {
                    await _auth.signInWithCredential(credential);
                    setState(() {});
                  },
                  verificationFailed: (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(e.message ?? 'Error')),
                    );
                  },
                  codeSent: (id, token) {
                    _verificationId = id;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('OTP sent')),
                    );
                  },
                  codeAutoRetrievalTimeout: (id) {},
                );
              },
              child: const Text('Send OTP'),
            ),
            TextField(
              controller: _otpController,
              decoration: const InputDecoration(labelText: 'Enter OTP'),
              keyboardType: TextInputType.number,
            ),
            ElevatedButton(
              onPressed: () async {
                final credential = PhoneAuthProvider.credential(
                    verificationId: _verificationId,
                    smsCode: _otpController.text);
                await _auth.signInWithCredential(credential);
                setState(() {});
              },
              child: const Text('Verify OTP'),
            ),
          ],
        ) : const HomeScreen(),
      ),
    );
  }
}

// HomeScreen now fetches tournaments from Firestore
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final FirebaseFirestore _db = FirebaseFirestore.instance;

    return Scaffold(
      appBar: AppBar(title: const Text('Tournaments')),
      body: StreamBuilder<QuerySnapshot>(
        stream: _db.collection('tournaments').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final tournaments = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tournaments.length,
            itemBuilder: (context, index) {
              final data = tournaments[index].data() as Map<String, dynamic>;
              return TournamentCard(
                game: data['game'],
                prize: data['prize'],
                slots: data['slots'],
              );
            },
          );
        },
      ),
    );
  }
}

class TournamentCard extends StatelessWidget {
  final String game;
  final String prize;
  final String slots;

  const TournamentCard({
    required this.game,
    required this.prize,
    required this.slots,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(game,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Prize: $prize'),
            Text('Slots: $slots'),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Joined $game tournament!')),
                    );
                  },
                  child: const Text('Join'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
