// test/api_test.dart - Unit tests for API layer
import 'package:flutter_test/flutter_test.dart';
import 'package:p3_movie/util/api.dart';
import 'package:p3_movie/model/movie.dart';

void main() {
  group('APIRunner Unit Tests', () {
    late APIRunner apiRunner;

    setUp(() {
      apiRunner = APIRunner();
    });

    test('API key is configured', () {
      expect(apiRunner.api_key, isNotEmpty);
      expect(apiRunner.api_key, contains('api_key='));
    });

    test('base URL is correct', () {
      expect(apiRunner.urlBase, 'https://api.themoviedb.org/3');
    });

    test('movie endpoints are defined', () {
      expect(apiRunner.apiUpcoming, '/movie/upcoming?');
      expect(apiRunner.apiSearch, '/search/movie?');
      expect(apiRunner.apiDiscover, '/discover/movie?');
    });

    test('TV endpoints are defined', () {
      expect(apiRunner.apiPopularTV, '/tv/popular?');
      expect(apiRunner.apiSearchTV, '/search/tv?');
    });

    group('URL Construction', () {
      test('constructs valid upcoming movies URL', () {
        final expectedBase = 'https://api.themoviedb.org/3/movie/upcoming?';
        final url = apiRunner.urlBase + apiRunner.apiUpcoming;
        expect(url, expectedBase);
      });

      test('constructs valid search URL with encoded query', () {
        final query = 'The Dark Knight';
        final encodedQuery = Uri.encodeComponent(query);
        expect(encodedQuery, 'The%20Dark%20Knight');
      });

      test('constructs valid genre discovery URL', () {
        final romanceUrl = apiRunner.urlBase + 
            apiRunner.apiDiscover + 
            apiRunner.api_key + 
            apiRunner.urlLanguage +
            '&with_genres=10749';
        expect(romanceUrl, contains('with_genres=10749'));
        expect(romanceUrl, contains('language=en-US'));
      });
    });

    group('Genre ID Validation', () {
      test('romance genre URL contains correct ID', () {
        final url = apiRunner.urlBase + 
            apiRunner.apiDiscover + 
            apiRunner.api_key + 
            apiRunner.urlLanguage +
            '&with_genres=10749';
        expect(url, contains('10749')); // Romance genre ID
      });

      test('action genre URL contains correct ID', () {
        final url = apiRunner.urlBase + 
            apiRunner.apiDiscover + 
            apiRunner.api_key + 
            apiRunner.urlLanguage +
            '&with_genres=28';
        expect(url, contains('28')); // Action genre ID
      });

      test('comedy genre URL contains correct ID', () {
        final url = apiRunner.urlBase + 
            apiRunner.apiDiscover + 
            apiRunner.api_key + 
            apiRunner.urlLanguage +
            '&with_genres=35';
        expect(url, contains('35')); // Comedy genre ID
      });
    });

    group('API Method Availability', () {
      test('has getUpcomingMovies method', () {
        expect(apiRunner.getUpcomingMovies, isA<Function>());
      });

      test('has getRomanceMovies method', () {
        expect(apiRunner.getRomanceMovies, isA<Function>());
      });

      test('has getActionMovies method', () {
        expect(apiRunner.getActionMovies, isA<Function>());
      });

      test('has getComedyMovies method', () {
        expect(apiRunner.getComedyMovies, isA<Function>());
      });

      test('has getHorrorMovies method', () {
        expect(apiRunner.getHorrorMovies, isA<Function>());
      });

      test('has getDramaMovies method', () {
        expect(apiRunner.getDramaMovies, isA<Function>());
      });

      test('has getAnimationMovies method', () {
        expect(apiRunner.getAnimationMovies, isA<Function>());
      });

      test('has searchMovie method', () {
        expect(apiRunner.searchMovie, isA<Function>());
      });

      test('has getPopularShows method', () {
        expect(apiRunner.getPopularShows, isA<Function>());
      });

      test('has searchTVShow method', () {
        expect(apiRunner.searchTVShow, isA<Function>());
      });
    });
  });
}