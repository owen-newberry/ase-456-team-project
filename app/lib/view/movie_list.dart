import 'package:flutter/material.dart';
import 'package:p3_movie/util/api.dart';
import 'movie_detail.dart';
import '../model/movie.dart';

enum SortOption { title, releaseDate, voteAverage }

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
class _ModeSwitchState extends StatefulWidget {
  @override
  _ModeSwitchState createState() => _ModeSwitchState();
}

class MovieList extends StatefulWidget {
  @override
  _MovieListState createState() => _MovieListState();
}


class _MovieListState extends State<MovieList> {
  late APIRunner helper;
  int moviesCount = 0;
  List<Movie> movies = [];
  

  // Sorting state
  SortOption _selectedOption = SortOption.title;
  bool _ascending = true;

  final String iconBase = 'https://image.tmdb.org/t/p/w92/';
  final String defaultImage =
      'https://images.freeimages.com/images/large-previews/5eb/movie-clapboard-1184339.jpg';

  Icon visibleIcon = Icon(Icons.search);
  Widget searchBar = Text('Movies');

  @override
  void initState() {
    super.initState(); // call super first
    helper = APIRunner();
    initialize();
  }
  //Light/Dark mode Toggle
  //End Light/Dark mode Toggle
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: searchBar, actions: <Widget>[
        IconButton(
          icon: visibleIcon,
          onPressed: () {
            setState(() {
              if (this.visibleIcon.icon == Icons.search) {
                this.visibleIcon = Icon(Icons.cancel);
                this.searchBar = TextField(
                  textInputAction: TextInputAction.search,
                  onSubmitted: (String text) {
                    search(text);
                  },
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20.0,
                  ),
                );
              } else {
                this.visibleIcon = Icon(Icons.search);
                this.searchBar = Text('Movies');
              }
            });
          },
        ),
      ]),
      body: Column(
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

          // Movie list
          Expanded(
            child: ListView.builder(
              itemCount: moviesCount,
              itemBuilder: (BuildContext context, int position) {
                final movie = movies[position];
                final image = (movie.posterPath.isNotEmpty)
                    ? NetworkImage(iconBase + movie.posterPath)
                    : NetworkImage(defaultImage);

                return Card(
                  color: Colors.white,
                  elevation: 2.0,
                  child: ListTile(
                    onTap: () {
                      MaterialPageRoute route = MaterialPageRoute(builder: (_) => MovieDetail(movie));
                      Navigator.push(context, route);
                    },
                    leading: CircleAvatar(backgroundImage: image),
                    title: Text(movie.title),
                    subtitle: Text('Released: ${movie.releaseDate} - Vote: ${movie.voteAverage}'),
                  ),
                );
              },
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
    try {
      debugPrint('[initialize] fetching upcoming');
      final raw = await helper.getUpcoming();
      debugPrint('[initialize] raw result type: ${raw.runtimeType}');
      final results = _toMovieList(raw);
      debugPrint('[initialize] parsed ${results.length} movies');
      final sortedResult = sortMovies(results, _selectedOption, ascending: _ascending);
      setState(() {
        movies = sortedResult;
        moviesCount = movies.length;
      });
    } catch (e, st) {
      debugPrint('[initialize] error: $e\n$st');
      setState(() {
        movies = [];
        moviesCount = 0;
      });
    }
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
