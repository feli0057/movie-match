import 'package:flutter/material.dart';

class MovieMatchingScreen extends StatefulWidget {
  const MovieMatchingScreen({super.key});

  @override
  State<MovieMatchingScreen> createState() => _MovieMatchingScreenState();
}

class _MovieMatchingScreenState extends State<MovieMatchingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Movie Match',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('Movie Matching Screen'),
      ),
    );
  }
}
