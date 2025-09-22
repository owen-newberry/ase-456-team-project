import 'package:flutter/material.dart';
import 'package:p3_movie/util/api.dart';
import 'movie_detail.dart';
import '../model/movie.dart';

enum SortOption { title, releaseDate, voteAverage }

class MovieList extends StatefulWidget {
  @override
  _MovieListState createState() => _MovieListState();
}

//Sort by
List<Movie> sortMovies(List<Movie> movies, SortOption option, {bool ascending = true}) {
  movies.sort((a, b) {
    int result;
    switch (option) {
      case SortOption.title:
        result = a.title.compareTo(b.title);
        break;
      case SortOption.releaseDate:
        DateTime aDate = DateTime.tryParse(a.releaseDate) ?? DateTime(0);
        DateTime bDate = DateTime.tryParse(b.releaseDate) ?? DateTime(0);
        result = aDate.compareTo(bDate);
        break;
      case SortOption.voteAverage:
        result = a.voteAverage.compareTo(b.voteAverage);
        break;
    }
    return ascending ? result : -result;
  });
  return movies;
}

//End Sort By

class _MovieListState extends State<MovieList> {
  String? result;
  APIRunner? helper;
  int moviesCount = 0;
  List<Movie> movies = [];
  // More Sort By stuff
  SortOption _selectedOption = SortOption.title;
  bool _ascending = true;
  // End More Sort By stuff
  final String iconBase = 'https://image.tmdb.org/t/p/w92/';
  final String defaultImage =
      'https://images.freeimages.com/images/large-previews/5eb/movie-clapboard-1184339.jpg';
  Icon visibleIcon = Icon(Icons.search);
  Widget searchBar = Text('Movies');

  @override
  void initState() {
    helper = APIRunner();
    initialize();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    NetworkImage image;
    return Scaffold(
      appBar: AppBar(title: searchBar, actions: <Widget>[
        IconButton(
          icon: visibleIcon,
          onPressed: () {
            setState(
              () {
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
              },
            );
          },
        ),
      ]),
      body: Column(
  children: [
    // Sorting controls inserted
    Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        DropdownButton<SortOption>(
          value: _selectedOption,
          onChanged: (value) {
            if (value == null) return;
            setState(() {
              _selectedOption = value;
              movies = sortMovies(movies!, _selectedOption, ascending: _ascending);
            });
          },
          items: SortOption.values.map((option) {
            return DropdownMenuItem(
              value: option,
              child: Text(option.toString().split('.').last),
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
      ],
    ),

    // Movie list
    Expanded(
      child: ListView.builder(
        itemCount: (moviesCount),
        itemBuilder: (BuildContext context, int position) {
          final movie = movies[position];
          final image = (movie.posterPath != null)
              ? NetworkImage(iconBase + movie.posterPath)
              : NetworkImage(defaultImage);

          return Card(
            color: Colors.white,
            elevation: 2.0,
            child: ListTile(
              onTap: () {
                MaterialPageRoute route =
                    MaterialPageRoute(builder: (_) => MovieDetail(movie));
                Navigator.push(context, route);
              },
              leading: CircleAvatar(backgroundImage: image),
              title: Text(movie.title),
              subtitle: Text(
                'Released: ${movie.releaseDate} - Vote: ${movie.voteAverage}',
              ),
            ),
          );
        },
      ),
    ),
  ],
),

    );
  }

  Future<void> search(String text) async {
    final result = (await helper?.searchMovie(text));
    final sortedResult = sortMovies(movies, _selectedOption, ascending: _ascending);
    setState(
      () {
        moviesCount = sortedResult.length;
        movies = sortedResult;
      },
    );
  }

  Future initialize() async {
    final result = (await helper?.getUpcoming())!;
    final sortedResult = sortMovies(movies, _selectedOption, ascending: _ascending);
    setState(
      () {
        moviesCount = sortedResult.length;
        movies = sortedResult;
      },
    );
  }
}
