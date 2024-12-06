import 'package:flutter/material.dart';
import '../services/device_id_service.dart';
import '../services/http_helper.dart';
import 'dart:math';

class MovieMatchingScreen extends StatefulWidget {
  const MovieMatchingScreen({super.key});

  @override
  State<MovieMatchingScreen> createState() => _MovieMatchingScreenState();
}

class _MovieMatchingScreenState extends State<MovieMatchingScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _currentMovie;

  @override
  void initState() {
    super.initState();
    _validateIDs();
    _loadMovie();
  }

  // Validate the device ID and session ID
  Future<void> _validateIDs() async {
    final deviceID = await DeviceIdService.getDeviceID();
    final sessionID = await HttpHelper.getSessionId();

    if (!mounted) return;

    if (deviceID.isEmpty || sessionID == null || sessionID.isEmpty) {
      Navigator.of(context).pushReplacementNamed('/');
    }
  }

  // Fetch popular movies from The MovieDB API
  Future<void> _loadMovie() async {
    try {
      final response = await HttpHelper.getPopularMovies();
      final List<dynamic> movies = response['results'];

      if (!mounted) return;

      // Get a random movie from the results
      final random = Random();
      final randomIndex = random.nextInt(movies.length);

      setState(() {
        _currentMovie = movies[randomIndex];
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Create the movie card
  Widget _buildMovieCard() {
    if (_currentMovie == null) {
      return const Center(
        child: Text('Failed to load movie'),
      );
    }

    final posterPath = _currentMovie!['poster_path'];
    final posterURL = posterPath != null
        ? 'https://image.tmdb.org/t/p/w300$posterPath'
        : null;
    final posterPlaceholder = 'assets/images/placeholder.png';

    return Card(
      elevation: 8,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.7,
        height: MediaQuery.of(context).size.height * 0.65,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: posterURL != null
                    ? Image.network(
                        posterURL,
                        fit: BoxFit.fitHeight,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            posterPlaceholder,
                            fit: BoxFit.fitHeight,
                          );
                        },
                      )
                    : Image.asset(
                        posterPlaceholder,
                        fit: BoxFit.fitHeight,
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    _currentMovie!['title'] ?? 'Unknown Title',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Release Date: ${_currentMovie!['release_date'] ?? 'Unknown'}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Rating: ${(_currentMovie!['vote_average'] ?? 0.0).toStringAsFixed(1)}/10',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

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
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.deepPurple)
            : _buildMovieCard(),
      ),
    );
  }
}
