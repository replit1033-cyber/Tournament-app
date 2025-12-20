        import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FF Crown',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FF Crown Tournaments'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          tournamentCard('Free Fire', 'Entry ₹50', 'Win ₹500'),
          tournamentCard('BGMI', 'Entry ₹100', 'Win ₹1000'),
        ],
      ),
    );
  }

  Widget tournamentCard(String game, String entry, String prize) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(game,
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(entry),
            Text(prize),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Join Tournament'),
            )
          ],
        ),
      ),
    );
  }
}
