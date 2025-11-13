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
        height: 240, // adjust overall height
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
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    imageUrl,
                    height: 220,
                    fit: BoxFit.cover,
                  ),
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
  List<Movie> movies = [];
  List<Movie> ogMovies = [];
  TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  // Sorting state
  SortOption _selectedOption = SortOption.title;
  bool _ascending = true;

  // Toggle between Movies and Shows
  ContentMode _mode = ContentMode.movies;


  final String iconBase = 'https://image.tmdb.org/t/p/w92/';
  final String defaultImage =
      'https://images.freeimages.com/images/large-previews/5eb/movie-clapboard-1184339.jpg';

  Icon visibleIcon = Icon(Icons.search);
  Widget searchBar = Text('Movies');
  // Random Movie Stuff
  void _showRandomMovie() {
  if (movies.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No movies available to choose from.')),
    );
    return;
  }

  final random = Random();
  final index = random.nextInt(movies.length);
  final selectedMovie = movies[index];

  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => MovieDetail(selectedMovie)),
  );
}

  // End Random Movie Stuff
  @override
  void initState() {
    super.initState(); // call super first
    helper = APIRunner();
    initialize();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: searchBar, actions: <Widget>[
        IconButton( // Search
          icon: visibleIcon,
          onPressed: () {
            setState(() {
              if (this.visibleIcon.icon == Icons.search) {
                this.visibleIcon = Icon(Icons.cancel);
                this.searchBar = TextField(
                  controller: _searchController,
                  autofocus: true,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20.0,
                  ),
                  decoration: InputDecoration(
                    hintText: _mode == ContentMode.movies ? 'Search Movies...' : 'Search TV Shows...',
                    border: InputBorder.none,
                  ),
                  onChanged: (text) {
                    _onSearchChanged(text);
                  },
                );
              } else {
                this.visibleIcon = Icon(Icons.search);
                this.searchBar = Text(_mode == ContentMode.movies ? 'Movies' : 'TV Shows');
                _searchController.clear();
                movies = List<Movie>.from(ogMovies);
                moviesCount = movies.length;
              }
            });
          },
        ), // Movie or TV Show Toggle
        IconButton(
          icon: Icon(_mode == ContentMode.movies ? Icons.movie : Icons.tv),
          tooltip: _mode == ContentMode.movies ? 'Switch to TV Shows' : 'Switch to Movies',
          onPressed: () {
            setState(() {
              _mode = _mode == ContentMode.movies ? ContentMode.tv : ContentMode.movies;
              searchBar = Text(_mode == ContentMode.movies ? 'Movies' : 'TV Shows');
            });
            initialize();
          },
        ), // Profile Button
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
      ]),
      body: ListView(
        children: [
          //  Dark Mode toggle
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: SwitchListTile(
              title: const Text('Dark Mode'),
              value: widget.isDarkMode,
              onChanged: widget.onThemeChanged,
            ),
          ),

          //  Sorting controls
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

          //  Movie of the Day Banner
          if (movies.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => MovieDetail(movies.first)),
                  );
                },
                child: Stack(
                  alignment: Alignment.bottomLeft,
                  children: [
                    // Background image with fade
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: AnimatedOpacity(
                        opacity: 1.0,
                        duration: const Duration(seconds: 1),
                        child: Image.network(
                          'https://image.tmdb.org/t/p/w500${movies.first.posterPath}',
                          height: 280,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                    // Dark overlay for readability
                    Container(
                      height: 220,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                          Colors.black.withOpacity(0.7),
                          Colors.transparent,
                          ],
                        ),
                      ),
                    ),

                    // Text on top
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            " Movie of the Day",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            movies.first.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            //  Suggested Movies (Infinite Horizontal Scroll)
            if (movies.isNotEmpty) Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      " Suggested Movies",
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

          // 🎞 Full movie list
          ...movies.map((movie) {
            final image = (movie.posterPath.isNotEmpty)
              ? NetworkImage(iconBase + movie.posterPath)
              : NetworkImage(defaultImage);

            return Card(
              color: Theme.of(context).brightness == Brightness.dark
                ? Colors.black
                : Colors.white,
              elevation: 2.0,
              child: ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => MovieDetail(movie)),
                  );
                },
                leading: CircleAvatar(backgroundImage: image),
                title: Text(movie.title),
                subtitle: Text(
                  'Released: ${movie.releaseDate} - Vote: ${movie.voteAverage}',
                ),
              ),
            );
          }).toList(),

          //  Surprise Me button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: _showRandomMovie,
              icon: const Icon(Icons.shuffle),
              label: const Text('Surprise Me!'),
            ),
          ),
        ],
      ),
    );
  }

  // Helper that turns whatever the API returns into List<Movie>
  List<Movie> _toMovieList(dynamic raw) {
    try {
      if (raw == null) return [];
      if (raw is List<Movie>) return raw;
      if (raw is List) {
        return raw.map<Movie>((e) {
          if (e is Movie) return e;
          if (e is Map) {
            // ensure types are Map<String, dynamic>
            return Movie.fromJson(Map<String, dynamic>.from(e as Map));
          }
          // fallback: try to cast then fail-safe
          throw FormatException('Unknown element type in result list: ${e.runtimeType}');
        }).toList();
      }
      // single-object responses (unlikely)
      if (raw is Map) {
        return [Movie.fromJson(Map<String, dynamic>.from(raw))];
      }
      return [];
    } catch (e, st) {
      debugPrint('[_toMovieList] parse error: $e\n$st');
      return [];
    }
  }

  Future<void> search(String text) async {
    try {
      debugPrint('[search] querying for: "$text"');
      final raw = await helper.searchMovie(text); // expect List or List<Map>
      debugPrint('[search] raw result type: ${raw.runtimeType}');
      final results = _toMovieList(raw);
      debugPrint('[search] parsed ${results.length} movies');
      final sortedResult = sortMovies(results, _selectedOption, ascending: _ascending);
      setState(() {
        movies = sortedResult;
        moviesCount = movies.length;
      });
    } catch (e, st) {
      debugPrint('[search] error: $e\n$st');
      setState(() {
        movies = [];
        moviesCount = 0;
      });
    }
  }

  Future<void> initialize() async {
    debugPrint('[initialize] mode: ${_mode}');
    try {
      debugPrint('[initialize] fetching ${_mode == ContentMode.movies ? 'movies' : 'TV Shows'}');
      
      final raw = _mode == ContentMode.movies ? await helper.getUpcomingMovies() : await helper.getPopularShows();

      final results = _toMovieList(raw);
      debugPrint('[initialize] parsed ${results.length} items');

      final sortedResult = sortMovies(results, _selectedOption, ascending: _ascending);
      setState(() {
       movies = sortedResult;
       ogMovies = List<Movie>.from(sortedResult);
       moviesCount = movies.length;
       searchBar = Text(_mode == ContentMode.movies ? 'Movies' : 'TV Shows');

      // Pick a random "Movie of the Day"
      if (movies.isNotEmpty) {
       final random = Random();
       movieOfTheDay = movies[random.nextInt(movies.length)];
      }

      // Suggested Movies = top 5 by rating (or random if fewer)
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

  void _onSearchChanged(String query) {
    if(_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if(query.isEmpty) {
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
        final sortedResults = sortMovies(results, _selectedOption, ascending: _ascending);

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

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  // Optional: temporary test helper to verify UI works without the API
  // Call this from a button or init for quick sanity check.
  void loadSampleData() {
    final sample = <Movie>[
      Movie(id: 1, title: 'Sample A', voteAverage: 7.1, releaseDate: '2010-01-01', overview: '', posterPath: ''),
      Movie(id: 2, title: 'Sample B', voteAverage: 8.3, releaseDate: '2015-05-05', overview: '', posterPath: ''),
      Movie(id: 3, title: 'Another', voteAverage: 6.4, releaseDate: '2005-03-03', overview: '', posterPath: ''),
    ];
    setState(() {
      movies = sortMovies(sample, _selectedOption, ascending: _ascending);
      moviesCount = movies.length;
    });
  }
}