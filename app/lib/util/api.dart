import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:p3_movie/model/movie.dart';

// 18361ad82497ec1cf55ca10b74f1d3750'; <- This is a dummy key
class APIRunner {
  final String api_key = 'api_key=2089f5b7283e2d6cb3e59ca839b91c99'; // Had to make this my moviedb api key
  final String urlBase = 'https://api.themoviedb.org/3';
  final String urlLanguage = '&language=en-US';

  // Movie Endpoints
  final String apiUpcoming = '/movie/upcoming?';
  final String apiSearch = '/search/movie?';

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
  
  // Movie Functions
  Future<List?> getUpcomingMovies() async {
    final String upcomingAPI = urlBase + apiUpcoming + api_key + urlLanguage;
    return runAPI(upcomingAPI);
  }

  Future<List?> searchMovie(String title) async {
    final String encodedTitle = Uri.encodeComponent(title);
    final String search = urlBase + apiSearch + 'query=' + encodedTitle + '&' + api_key;
    return runAPI(search);
  }

  // Tv Show Functions
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
}