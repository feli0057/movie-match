import 'package:flutter/material.dart';
import '../services/device_id_service.dart';
import '../services/http_helper.dart';

class MovieMatchingScreen extends StatefulWidget {
  const MovieMatchingScreen({super.key});

  @override
  State<MovieMatchingScreen> createState() => _MovieMatchingScreenState();
}

class _MovieMatchingScreenState extends State<MovieMatchingScreen> {
  bool _isLoading = true;
  List<dynamic> _movies = [];
  int _currentIndex = 0;
  Map<String, dynamic>? _currentMovie;

  @override
  void initState() {
    super.initState();
    _validateIDs();
    _loadMovie();
  }

  //Validate the device ID and session ID
  Future<void> _validateIDs() async {
    final deviceID = await DeviceIdService.getDeviceID();
    final sessionID = await HttpHelper.getSessionID();

    if (!mounted) return;

    //Return to the welcome screen if either device ID or session ID is unavailable
    if (deviceID.isEmpty || sessionID == null || sessionID.isEmpty) {
      Navigator.of(context).pushReplacementNamed('/');
    }
  }

  //Fetch popular movies from The MovieDB API
  Future<void> _loadMovie() async {
    try {
      final response = await HttpHelper.getPopularMovies();
      _movies = response['results'];

      if (!mounted) return;

      setState(() {
        _currentMovie = _movies[_currentIndex];
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _handleSwipe(DismissDirection direction) {
    // Move to next random movie in the array if available
    if (_currentIndex < _movies.length - 1) {
      setState(() {
        _currentIndex++;
        _currentMovie = _movies[_currentIndex];
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

    return Dismissible(
      key: Key(_currentMovie!['id'].toString()),
      onDismissed: _handleSwipe,
      dismissThresholds: const {
        DismissDirection.endToStart: 0.2,
        DismissDirection.startToEnd: 0.2,
      },
      background: Container(
        decoration: const BoxDecoration(),
        child: const Align(
          alignment: Alignment.center,
          child: Icon(
            Icons.thumb_up,
            color: Colors.green,
            size: 96,
          ),
        ),
      ),
      secondaryBackground: Container(
        decoration: const BoxDecoration(),
        child: const Align(
          alignment: Alignment.center,
          child: Icon(
            Icons.thumb_down,
            color: Colors.red,
            size: 96,
          ),
        ),
      ),
      child: Card(
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
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              posterPlaceholder,
                              fit: BoxFit.cover,
                            );
                          },
                        )
                      : Image.asset(
                          posterPlaceholder,
                          fit: BoxFit.cover,
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
                      'Released: ${_currentMovie!['release_date'] ?? 'Unknown'}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Rating: ${(_currentMovie!['vote_average'] ?? 0.0).toStringAsFixed(1)}/10 (${_currentMovie!['vote_count'] ?? 0} votes)',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ],
          ),
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
