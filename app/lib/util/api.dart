import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:p3_movie/model/movie.dart';

// 18361ad82497ec1cf55ca10b74f1d3750'; <- This is a dummy key
class APIRunner {
  final String api_key = 'api_key=2089f5b7283e2d6cb3e59ca839b91c99'; 
  final String urlBase = 'https://api.themoviedb.org/3';
  final String urlLanguage = '&language=en-US';

  // Movie Endpoints
  final String apiUpcoming = '/movie/upcoming?';
  final String apiSearch = '/search/movie?';
  final String apiDiscover = '/discover/movie?';

  //TV Endpoints
  final String apiPopularTV = '/tv/popular?';
  final String apiAiringToday = '/tv/airing_today?';
  final String apiTopRatedTV = '/tv/top_rated?';
  final String apiSearchTV = '/search/tv?';

  Future<List<Movie>?> runAPI(API) async {
    final response = await http.get(Uri.parse(API));
    
    if (response.statusCode == HttpStatus.ok) {
      final jsonResponse = json.decode(response.body);
      final List<dynamic> results = jsonResponse['results'] ?? [];
      
      final movies = results.map((item) => Movie.fromJson(item)).toList();

      debugPrint('Successfully parsed ${movies.length} movies');
      return movies;
    } else {
      debugPrint('Request failed with status: ${response.statusCode}');
      return [];
    }
  }

  // ---------------------------
  // MOVIE FUNCTIONS
  // ---------------------------

  Future<List?> getUpcomingMovies() async {
    final String upcomingAPI = urlBase + apiUpcoming + api_key + urlLanguage;
    return runAPI(upcomingAPI);
  }

  Future<List<Movie>?> getRomanceMovies() async {
    final String romanceAPI = urlBase + apiDiscover + api_key + urlLanguage +
        '&with_genres=10749&without_genres=16,878,14&sort_by=popularity.desc&vote_count.gte=2000';
    return runAPI(romanceAPI);
  }

  Future<List?> searchMovie(String title) async {
    final String encodedTitle = Uri.encodeComponent(title);
    final String search = urlBase + apiSearch + 'query=' + encodedTitle + '&' + api_key;
    return runAPI(search);
  }

  /// Action (28)
  Future<List<Movie>?> getActionMovies() async {
    final String api = urlBase + apiDiscover + api_key + urlLanguage +
        '&with_genres=28&without_genres=16,878,14&sort_by=popularity.desc&vote_count.gte=1500';
    return runAPI(api);
  }

  /// Comedy (35)
  Future<List<Movie>?> getComedyMovies() async {
    final String api = urlBase + apiDiscover + api_key + urlLanguage +
        '&with_genres=35&without_genres=16,878,14&sort_by=popularity.desc&vote_count.gte=1500';
    return runAPI(api);
  }

  /// Horror (27)
  Future<List<Movie>?> getHorrorMovies() async {
    final String api = urlBase + apiDiscover + api_key + urlLanguage +
        '&with_genres=27&without_genres=16,878,14&sort_by=popularity.desc&vote_count.gte=1500';
    return runAPI(api);
  }

  /// Drama (18)
  Future<List<Movie>?> getDramaMovies() async {
    final String api = urlBase + apiDiscover + api_key + urlLanguage +
        '&with_genres=18&without_genres=16,878,14&sort_by=popularity.desc&vote_count.gte=1500';
    return runAPI(api);
  }

  /// Animation (16)
  Future<List<Movie>?> getAnimationMovies() async {
    final String api = urlBase + apiDiscover + api_key + urlLanguage +
        '&with_genres=16&sort_by=popularity.desc&vote_count.gte=1000';
    return runAPI(api);
  }

  // ---------------------------
  // TV SHOW FUNCTIONS
  // ---------------------------

  Future<List<Movie>?> getPopularShows() async {
    final String api = urlBase + apiPopularTV + api_key + urlLanguage;
    return runAPI(api);
  }

  Future<List<Movie>?> getTopRatedTV() async {
    final String api = urlBase + apiTopRatedTV + api_key + urlLanguage;
    return runAPI(api);
  }

  Future<List<Movie>?> searchTVShow(String title) async {
    final String encodedTitle = Uri.encodeComponent(title);
    final String api = urlBase + apiSearchTV + 'query=' + encodedTitle + '&' + api_key;
    return runAPI(api);
  }

  /// Action & Adventure (10759)
  Future<List<Movie>?> getActionShows() async {
    final String api = urlBase + '/discover/tv?' + api_key + urlLanguage +
        '&with_genres=10759&sort_by=popularity.desc&vote_count.gte=500';
    return runAPI(api);
  }

  /// Comedy (35)
  Future<List<Movie>?> getComedyShows() async {
    final String api = urlBase + '/discover/tv?' + api_key + urlLanguage +
        '&with_genres=35&sort_by=popularity.desc&vote_count.gte=500';
    return runAPI(api);
  }

  /// Drama (18)
  Future<List<Movie>?> getDramaShows() async {
    final String api = urlBase + '/discover/tv?' + api_key + urlLanguage +
        '&with_genres=18&sort_by=popularity.desc&vote_count.gte=500';
    return runAPI(api);
  }

  /// Animation (16)
  Future<List<Movie>?> getAnimationShows() async {
    final String api = urlBase + '/discover/tv?' + api_key + urlLanguage +
        '&with_genres=16&sort_by=popularity.desc&vote_count.gte=300';
    return runAPI(api);
  }

  /// Romance (10749)
  Future<List<Movie>?> getRomanceShows() async {
    final String api = urlBase + '/discover/tv?' + api_key + urlLanguage +
        '&with_genres=10749&sort_by=popularity.desc&vote_count.gte=500';
    return runAPI(api);
  }

  /// Horror / Mystery / Thriller equivalent (9648 Mystery)
  Future<List<Movie>?> getHorrorShows() async {
    final String api = urlBase + '/discover/tv?' + api_key + urlLanguage +
        '&with_genres=9648&sort_by=popularity.desc&vote_count.gte=300';
    return runAPI(api);
  }
}
