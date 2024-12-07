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
  bool _isLoadingMore = false;
  List<dynamic> _movies = [];
  int _currentIndex = 0;
  int _currentPage = 1;
  Map<String, dynamic>? _currentMovie;

  @override
  void initState() {
    super.initState();
    _validateIDs();
    _loadMovies();
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
  Future<void> _loadMovies({bool loadMore = false}) async {
    try {
      if (!loadMore) {
        final response = await HttpHelper.getPopularMovies(page: _currentPage);
        _movies = response['results'];
      } else {
        setState(() {
          _isLoadingMore = true;
        });

        //Get the next page of movies
        final response =
            await HttpHelper.getPopularMovies(page: _currentPage + 1);
        final newMovies = response['results'] as List<dynamic>;

        //Add new movies to the existing list
        if (mounted) {
          setState(() {
            _movies.addAll(newMovies);
            _currentPage++;
            _isLoadingMore = false;
          });
        }
      }

      if (!mounted) return;

      if (!loadMore) {
        setState(() {
          _currentMovie = _movies[_currentIndex];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  void _handleSwipe(DismissDirection direction) async {
    // Swipe right means the user liked the movie (bool is set to true)
    final bool liked = direction == DismissDirection.startToEnd;

    // Store the movie that the user just swiped
    final currentMovieBeforeSwipe = _currentMovie;

    // Update the screen to show the next movie card
    if (_currentIndex < _movies.length - 1) {
      setState(() {
        _currentIndex++;
        _currentMovie = _movies[_currentIndex];
      });

      // Load more movies when there are only 3 movies left in the array
      if (_currentIndex >= _movies.length - 3 && !_isLoadingMore) {
        _loadMovies(loadMore: true);
      }
    }

    if (currentMovieBeforeSwipe != null) {
      await _voteOnMovie(liked, currentMovieBeforeSwipe);
    }
  }

  Future<void> _voteOnMovie(bool liked, Map<String, dynamic> votedMovie) async {
    try {
      final sessionID = await HttpHelper.getSessionID();
      if (sessionID == null || sessionID.isEmpty) return;

      final movieID = votedMovie['id'] as int;
      final result = await HttpHelper.voteMovie(
        sessionID: sessionID,
        movieID: movieID,
        vote: liked,
      );

      // Only show the dialog if there's a match and we're still mounted
      if (result['match'] == true && mounted) {
        final movieTitle = votedMovie['title'] as String;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                'It\'s a match! 🍿',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'You both liked',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    movieTitle,
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: ElevatedButton(
                            onPressed: () =>
                                Navigator.of(context).pushReplacementNamed('/'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              foregroundColor:
                                  Theme.of(context).colorScheme.onPrimary,
                            ),
                            child: const Text('End'),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              foregroundColor:
                                  Theme.of(context).colorScheme.onPrimary,
                            ),
                            child: const Text('Continue'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      }
    } catch (e) {
      throw Exception('Failed to vote on movie');
    }
  }

  // Build the movie card
  Widget _buildMovieCard() {
    if (_currentMovie == null) {
      return const Center(
        child: Text(
          'Failed to load movie',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
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
        color: Theme.of(context).colorScheme.surface,
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
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Released: ${_currentMovie!['release_date'] ?? 'Unknown'}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Rating: ${(_currentMovie!['vote_average'] ?? 0.0).toStringAsFixed(1)}/10 (${_currentMovie!['vote_count'] ?? 0} votes)',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                          ),
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
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.deepPurple)
            : _buildMovieCard(),
      ),
    );
  }
}
