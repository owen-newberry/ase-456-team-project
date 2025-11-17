import 'package:flutter/material.dart';
import 'package:p3_movie/util/api.dart';
import 'movie_detail.dart';
import '../model/movie.dart';
import 'profile_page.dart';
import 'dart:math';
import 'dart:async';
import 'package:flutter/gestures.dart';



enum SortOption { title, releaseDate, voteAverage }
enum ContentMode { movies, tv }

// Sort helper (works on a copy)
List<Movie> sortMovies(List<Movie> inMovies, SortOption option, {bool ascending = true}) {
  final list = List<Movie>.from(inMovies);
  list.sort((a, b) {
    int result;
    switch (option) {
      case SortOption.title:
        result = a.title.compareTo(b.title);
        break;
      case SortOption.releaseDate:
        final aDate = DateTime.tryParse(a.releaseDate) ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bDate = DateTime.tryParse(b.releaseDate) ?? DateTime.fromMillisecondsSinceEpoch(0);
        result = aDate.compareTo(bDate);
        break;
      case SortOption.voteAverage:
        result = a.voteAverage.compareTo(b.voteAverage);
        break;
    }
    return ascending ? result : -result;
  });
  return list;
}

class ModeSwitch extends StatefulWidget {
  @override
  _ModeSwitchState createState() => _ModeSwitchState();
}

class _ModeSwitchState extends State<ModeSwitch> {
  @override
  Widget build(BuildContext context) {
    return Container(); // Replace with your widget UI
  }
}
class MovieList extends StatefulWidget {
  @override
    _MovieListState createState() => _MovieListState();
  final bool isDarkMode; // NEW
  final ValueChanged<bool> onThemeChanged; // NEW
  MovieList({ // UPDATED
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
  });
}

class InfiniteHorizontalScroll extends StatefulWidget {
  final List<Movie> movies;
  final String defaultImage;

  const InfiniteHorizontalScroll({
    Key? key,
    required this.movies,
    required this.defaultImage,
  }) : super(key: key);

  @override
  _InfiniteHorizontalScrollState createState() => _InfiniteHorizontalScrollState();
}

class _InfiniteHorizontalScrollState extends State<InfiniteHorizontalScroll> {
  late final ScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();

    // Infinite scroll logic: jump to start when nearing end
    _controller.addListener(() {
      if (_controller.position.pixels >= _controller.position.maxScrollExtent - 300) {
        _controller.jumpTo(_controller.position.minScrollExtent + 1);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final movies = widget.movies;
    if (movies.isEmpty) {
      return const Center(child: Text('No movies available'));
    }

    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(
        dragDevices: {
          PointerDeviceKind.touch,
          PointerDeviceKind.mouse, // enables mouse drag
        },
      ),
      child: SizedBox(
        height: 300, // adjust overall height
        child: ListView.builder(
          controller: _controller,
          scrollDirection: Axis.horizontal,
          itemCount: movies.length * 1000, // "infinite" repetition
          itemBuilder: (context, index) {
            final movie = movies[index % movies.length];
            final imageUrl = movie.posterPath.isNotEmpty
                ? 'https://image.tmdb.org/t/p/w300${movie.posterPath}'
                : widget.defaultImage;

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => MovieDetail(movie)),
                );
              },
              child: Container(
                width: 150,
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        imageUrl,
                        height: 220,
                        width: 150,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      width: 150,
                      child: Text(
                        movie.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.6,
                          color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _MovieListState extends State<MovieList> {
  late APIRunner helper;
  int moviesCount = 0;
  Movie? movieOfTheDay;
  List<Movie> suggestedMovies = [];
  List<Movie> romanceMovies = [];
  List<Movie> movies = [];
  List<Movie> ogMovies = [];
  TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  bool _isSearching = false;

  // Sorting state
  SortOption _selectedOption = SortOption.title;
  bool _ascending = true;

  // Toggle between Movies and Shows
  ContentMode _mode = ContentMode.movies;

  final String defaultImage =
      'https://images.freeimages.com/images/large-previews/5eb/movie-clapboard-1184339.jpg';

  Icon visibleIcon = Icon(Icons.search);
  Widget searchBar = Text('Movies');

  @override
  void initState() {
    super.initState();
    helper = APIRunner();
    initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: searchBar,
        actions: [
          // Search button
          IconButton(
            icon: visibleIcon,
            onPressed: () {
              setState(() {
                if (visibleIcon.icon == Icons.search) {
                  visibleIcon = Icon(Icons.cancel);
                  searchBar = TextField(
                    controller: _searchController,
                    autofocus: true,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20.0,
                    ),
                    decoration: InputDecoration(
                      hintText: _mode == ContentMode.movies
                          ? 'Search Movies...'
                          : 'Search TV Shows...',
                      border: InputBorder.none,
                    ),
                    onChanged: _onSearchChanged,
                  );
                  _isSearching = true;
                } else {
                  visibleIcon = Icon(Icons.search);
                  searchBar =
                      Text(_mode == ContentMode.movies ? 'Movies' : 'TV Shows');
                  _searchController.clear();
                  movies = List<Movie>.from(ogMovies);
                  moviesCount = movies.length;
                  _isSearching = false;
                }
              });
            },
          ),

          // Mode toggle (Movies/TV)
          IconButton(
            icon: Icon(_mode == ContentMode.movies ? Icons.movie : Icons.tv),
            tooltip:
                _mode == ContentMode.movies ? 'Switch to TV Shows' : 'Switch to Movies',
            onPressed: () {
              setState(() {
                _mode =
                    _mode == ContentMode.movies ? ContentMode.tv : ContentMode.movies;
                searchBar =
                    Text(_mode == ContentMode.movies ? 'Movies' : 'TV Shows');
              });
              initialize();
            },
          ),
          IconButton(
            icon: Icon(
              widget.isDarkMode ? Icons.dark_mode : Icons.light_mode,
            ),
            tooltip: widget.isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode',
            onPressed: () {
              widget.onThemeChanged(!widget.isDarkMode);
            },
          ),
          // Profile
          IconButton(
            icon: const Icon(Icons.account_circle),
            tooltip: 'Profile',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ProfilePage()),
              );
            },
          ),
        ],
      ),
      body: _isSearching ? _buildSearchResults() : _buildNormalContent(),
    );
  }

  Widget _buildSplitHeroSlideshow(List<Movie> movies) {
    return SizedBox(
      height: 380, // taller to fit bigger poster
      child: PageView.builder(
        itemCount: movies.length,
        controller: PageController(viewportFraction: 0.9),
        itemBuilder: (context, index) {
          final movie = movies[index];
          final imageUrl = movie.posterPath.isNotEmpty
              ? 'https://image.tmdb.org/t/p/w500${movie.posterPath}'
              : defaultImage;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  // Background card
                  Container(
                    color: Colors.grey[900],
                    child: Row(
                      children: [
                        // Movie Poster
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            bottomLeft: Radius.circular(16),
                          ),
                          child: Image.network(
                            imageUrl,
                            width: 260, // increased from 160
                            height: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),

                        // Right side info
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Movie title
                                Text(
                                  movie.title,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),

                                // Rating + release date
                                Row(
                                  children: [
                                    Icon(Icons.star, color: Colors.yellow[700], size: 20),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${movie.voteAverage}',
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                    const SizedBox(width: 16),
                                    Text(
                                      movie.releaseDate,
                                      style: TextStyle(color: Colors.grey[300]),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),

                                // Overview
                                if (movie.overview.isNotEmpty)
                                  Text(
                                    movie.overview,
                                    maxLines: 4,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.grey[300],
                                      fontSize: 14,
                                    ),
                                  ),
                                const SizedBox(height: 12),

                                // Action buttons
                                Row(
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) => MovieDetail(movie)),
                                        );
                                      },
                                      icon: const Icon(Icons.play_arrow),
                                      label: const Text('Watch'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.redAccent,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 18, vertical: 8),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Gradient overlay on poster for readability
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    width: 180,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Colors.black.withOpacity(0.5),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // === Normal mode content ===
  Widget _buildNormalContent() {
    return ListView(
      children: [
        // Sorting controls
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            DropdownButton<SortOption>(
              value: _selectedOption,
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _selectedOption = value;
                  movies = sortMovies(movies, _selectedOption, ascending: _ascending);
                });
              },
              items: SortOption.values.map((option) {
                final label = option.toString().split('.').last;
                final display = label[0].toUpperCase() + label.substring(1);
                return DropdownMenuItem(
                  value: option,
                  child: Text(display),
                );
              }).toList(),
            ),
            IconButton(
              icon: Icon(_ascending ? Icons.arrow_upward : Icons.arrow_downward),
              onPressed: () {
                setState(() {
                  _ascending = !_ascending;
                  movies = sortMovies(movies, _selectedOption, ascending: _ascending);
                });
              },
            ),
          ]),
        ),

        // Hero Row
        if (movies.isNotEmpty) _buildSplitHeroSlideshow(movies),

        // Suggested Movies horizontal scroll
        if (movies.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    "Suggested Movies",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                InfiniteHorizontalScroll(
                  movies: movies,
                  defaultImage: defaultImage,
                ),
              ],
            ),
          ),

        // Romance Movies horizontal scroll - NEW SECTION
        if (romanceMovies.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Icon(Icons.favorite, color: Colors.pink, size: 22),
                      const SizedBox(width: 8),
                      const Text(
                        "Romance Movies",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                InfiniteHorizontalScroll(
                  movies: romanceMovies,
                  defaultImage: defaultImage,
                ),
              ],
            ),
          ),
        
        // Top Rated Movies horizontal scroll
        if (movies.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    "Top Rated Movies",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),

                InfiniteHorizontalScroll(
                  movies: (List<Movie>.from(movies)
                        ..sort((a, b) => b.voteAverage.compareTo(a.voteAverage)))
                      .take(10)
                      .toList(),
                  defaultImage: defaultImage,
                ),
              ],
            ),
          ),

        // Surprise Me button
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            onPressed: _showRandomMovie,
            icon: const Icon(Icons.shuffle),
            label: const Text('Surprise Me!'),
          ),
        ),
      ],
    );
  }

  // === Search mode content ===
  Widget _buildSearchResults() {
  if (movies.isEmpty) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          'No results found.',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }

  return ListView.builder(
    itemCount: movies.length,
    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    itemBuilder: (context, index) {
      final movie = movies[index];
      final imageUrl = movie.posterPath.isNotEmpty
          ? 'https://image.tmdb.org/t/p/w300${movie.posterPath}'
          : defaultImage;

      return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => MovieDetail(movie)),
          );
        },
        child: Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 4,
          child: Container(
            height: 180,
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                // Poster with shadow
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      imageUrl,
                      width: 120,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Movie info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        movie.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.yellow[700], size: 20),
                          const SizedBox(width: 4),
                          Text(
                            '${movie.voteAverage}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            movie.releaseDate,
                            style: TextStyle(color: Colors.grey[700], fontSize: 14),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (movie.overview.isNotEmpty)
                        Text(
                          movie.overview,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
  List<Movie> rankAndSortMovies(
    List<Movie> movies, String query, SortOption option, bool ascending) {
      final lowerQuery = query.toLowerCase().trim();

      // Assign a match score to each movie
      final scoredMovies = movies.map((m) {
        final title = m.title.toLowerCase().trim();
        int score;
        if (title == lowerQuery) score = 0;       // perfect match
        else if (title.contains(lowerQuery)) score = 1; // partial match
        else score = 2;                           // no match
        return {'movie': m, 'score': score};
      }).toList();

      // Sort by score first, then by the chosen SortOption
      scoredMovies.sort((a, b) {
        final scoreA = a['score'] as int;
        final scoreB = b['score'] as int;
        if (scoreA != scoreB) return scoreA.compareTo(scoreB);

        final movieA = a['movie'] as Movie;
        final movieB = b['movie'] as Movie;

        int optionResult;
        switch (option) {
          case SortOption.title:
            optionResult = movieA.title.compareTo(movieB.title);
            break;
          case SortOption.releaseDate:
            final aDate = DateTime.tryParse(movieA.releaseDate) ?? DateTime.fromMillisecondsSinceEpoch(0);
            final bDate = DateTime.tryParse(movieB.releaseDate) ?? DateTime.fromMillisecondsSinceEpoch(0);
            optionResult = aDate.compareTo(bDate);
            break;
          case SortOption.voteAverage:
            optionResult = movieA.voteAverage.compareTo(movieB.voteAverage);
            break;
        }

        return ascending ? optionResult : -optionResult;
      });

      return scoredMovies.map((e) => e['movie'] as Movie).toList();
    }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (query.isEmpty) {
        setState(() {
          movies = List<Movie>.from(ogMovies);
          moviesCount = movies.length;
        });
        return;
      }

      try {
        final raw = _mode == ContentMode.movies
            ? await helper.searchMovie(query)
            : await helper.searchTVShow(query);

        final results = _toMovieList(raw);

        // Use the new ranking + sorting function
        final sortedResults = rankAndSortMovies(results, query, _selectedOption, _ascending);

        setState(() {
          movies = sortedResults;
          moviesCount = movies.length;
        });
      } catch (e, st) {
        debugPrint('[_onSearchChanged] error: $e\n$st');
        setState(() {
          movies = [];
          moviesCount = 0;
        });
      }
    });
  }

  List<Movie> _toMovieList(dynamic raw) {
    try {
      if (raw == null) return [];
      if (raw is List<Movie>) return raw;
      if (raw is List) {
        return raw.map<Movie>((e) {
          if (e is Movie) return e;
          if (e is Map) return Movie.fromJson(Map<String, dynamic>.from(e));
          throw FormatException('Unknown element type: ${e.runtimeType}');
        }).toList();
      }
      if (raw is Map) return [Movie.fromJson(Map<String, dynamic>.from(raw))];
      return [];
    } catch (e, st) {
      debugPrint('[_toMovieList] parse error: $e\n$st');
      return [];
    }
  }

  Future<void> initialize() async {
    try {
      final raw = _mode == ContentMode.movies
          ? await helper.getUpcomingMovies()
          : await helper.getPopularShows();
      final results = _toMovieList(raw);
      final sortedResults =
          sortMovies(results, _selectedOption, ascending: _ascending);

      // NEW: Fetch romance movies only in movies mode
      List<Movie> fetchedRomanceMovies = [];
      if (_mode == ContentMode.movies) {
        try {
          final romanceRaw = await helper.getRomanceMovies();
          fetchedRomanceMovies = _toMovieList(romanceRaw);
        } catch (e) {
          debugPrint('[initialize] error fetching romance movies: $e');
        }
      }

      setState(() {
        movies = sortedResults;
        ogMovies = List<Movie>.from(sortedResults);
        moviesCount = movies.length;
        romanceMovies = fetchedRomanceMovies;
        
        if (movies.isNotEmpty) {
          final random = Random();
          movieOfTheDay = movies[random.nextInt(movies.length)];
        }

        // Suggested top 5 by rating
        suggestedMovies = List<Movie>.from(movies);
        suggestedMovies.sort((a, b) => b.voteAverage.compareTo(a.voteAverage));
        if (suggestedMovies.length > 5) {
          suggestedMovies = suggestedMovies.take(5).toList();
        }
      });
    } catch (e, st) {
      debugPrint('[initialize] error: $e\n$st');
      setState(() {
        movies = [];
        moviesCount = 0;
      });
    }
  }

  void _showRandomMovie() {
    if (movies.isEmpty) return;
    final random = Random();
    final selectedMovie = movies[random.nextInt(movies.length)];
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MovieDetail(selectedMovie)),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }
}
