// test/integration/api_integration_test.dart - Integration tests for API calls
import 'package:flutter_test/flutter_test.dart';
import 'package:p3_movie/util/api.dart';
import 'package:p3_movie/model/movie.dart';

/// Integration tests that verify the API layer works correctly with the Movie model.
/// These tests verify that real API responses can be parsed into Movie objects.
/// Note: These tests make real network calls and require internet connectivity.
void main() {
  group('API Integration Tests', () {
    late APIRunner apiRunner;

    setUp(() {
      apiRunner = APIRunner();
    });

    group('Movie API Integration', () {
      test('getUpcomingMovies returns valid Movie list', () async {
        final movies = await apiRunner.getUpcomingMovies();

        expect(movies, isNotNull);
        expect(movies, isA<List>());
        
        if (movies != null && movies.isNotEmpty) {
          final movie = movies.first as Movie;
          expect(movie.id, isA<int>());
          expect(movie.title, isA<String>());
          expect(movie.title, isNotEmpty);
          expect(movie.voteAverage, isA<double>());
          expect(movie.voteAverage, greaterThanOrEqualTo(0));
          expect(movie.voteAverage, lessThanOrEqualTo(10));
        }
      }, timeout: Timeout(Duration(seconds: 30)));

      test('getRomanceMovies returns movies with valid structure', () async {
        final movies = await apiRunner.getRomanceMovies();

        expect(movies, isNotNull);
        if (movies != null && movies.isNotEmpty) {
          for (final movie in movies.take(5)) {
            expect(movie.id, greaterThan(0));
            expect(movie.title, isNotEmpty);
            expect(movie.releaseDate, isNotNull);
          }
        }
      }, timeout: Timeout(Duration(seconds: 30)));

      test('getActionMovies returns movies', () async {
        final movies = await apiRunner.getActionMovies();

        expect(movies, isNotNull);
        expect(movies, isA<List<Movie>>());
      }, timeout: Timeout(Duration(seconds: 30)));

      test('getComedyMovies returns movies', () async {
        final movies = await apiRunner.getComedyMovies();

        expect(movies, isNotNull);
        expect(movies, isA<List<Movie>>());
      }, timeout: Timeout(Duration(seconds: 30)));

      test('getHorrorMovies returns movies', () async {
        final movies = await apiRunner.getHorrorMovies();

        expect(movies, isNotNull);
        expect(movies, isA<List<Movie>>());
      }, timeout: Timeout(Duration(seconds: 30)));

      test('getDramaMovies returns movies', () async {
        final movies = await apiRunner.getDramaMovies();

        expect(movies, isNotNull);
        expect(movies, isA<List<Movie>>());
      }, timeout: Timeout(Duration(seconds: 30)));

      test('getAnimationMovies returns movies', () async {
        final movies = await apiRunner.getAnimationMovies();

        expect(movies, isNotNull);
        expect(movies, isA<List<Movie>>());
      }, timeout: Timeout(Duration(seconds: 30)));

      test('searchMovie returns results for known movie', () async {
        final movies = await apiRunner.searchMovie('The Dark Knight');

        expect(movies, isNotNull);
        expect(movies, isNotEmpty);
        
        // Verify at least one result contains the search term
        final titles = movies!.map((m) => m.title.toLowerCase()).toList();
        expect(titles.any((t) => t.contains('dark') || t.contains('knight')), isTrue);
      }, timeout: Timeout(Duration(seconds: 30)));

      test('searchMovie handles special characters', () async {
        final movies = await apiRunner.searchMovie("Spider-Man: No Way Home");

        expect(movies, isNotNull);
        // Should not throw an error
      }, timeout: Timeout(Duration(seconds: 30)));

      test('searchMovie returns empty list for gibberish query', () async {
        final movies = await apiRunner.searchMovie('xyzabc123notamovie999');

        expect(movies, isNotNull);
        expect(movies, isEmpty);
      }, timeout: Timeout(Duration(seconds: 30)));
    });

    group('TV Show API Integration', () {
      test('getPopularShows returns valid list', () async {
        final shows = await apiRunner.getPopularShows();

        expect(shows, isNotNull);
        expect(shows, isA<List<Movie>>());
        
        if (shows != null && shows.isNotEmpty) {
          final show = shows.first;
          expect(show.id, isA<int>());
          expect(show.title, isNotEmpty);
        }
      }, timeout: Timeout(Duration(seconds: 30)));

      test('getTopRatedTV returns shows', () async {
        final shows = await apiRunner.getTopRatedTV();

        expect(shows, isNotNull);
        expect(shows, isA<List<Movie>>());
      }, timeout: Timeout(Duration(seconds: 30)));

      test('searchTVShow returns results for known show', () async {
        final shows = await apiRunner.searchTVShow('Breaking Bad');

        expect(shows, isNotNull);
        expect(shows, isNotEmpty);
      }, timeout: Timeout(Duration(seconds: 30)));

      test('getActionShows returns shows', () async {
        final shows = await apiRunner.getActionShows();

        expect(shows, isNotNull);
        expect(shows, isA<List<Movie>>());
      }, timeout: Timeout(Duration(seconds: 30)));

      test('getComedyShows returns shows', () async {
        final shows = await apiRunner.getComedyShows();

        expect(shows, isNotNull);
        expect(shows, isA<List<Movie>>());
      }, timeout: Timeout(Duration(seconds: 30)));

      test('getDramaShows returns shows', () async {
        final shows = await apiRunner.getDramaShows();

        expect(shows, isNotNull);
        expect(shows, isA<List<Movie>>());
      }, timeout: Timeout(Duration(seconds: 30)));

      test('getAnimationShows returns shows', () async {
        final shows = await apiRunner.getAnimationShows();

        expect(shows, isNotNull);
        expect(shows, isA<List<Movie>>());
      }, timeout: Timeout(Duration(seconds: 30)));

      test('getRomanceShows returns shows', () async {
        final shows = await apiRunner.getRomanceShows();

        expect(shows, isNotNull);
        expect(shows, isA<List<Movie>>());
      }, timeout: Timeout(Duration(seconds: 30)));
    });

    group('Data Consistency Tests', () {
      test('Movie and TV show use consistent data model', () async {
        final movies = await apiRunner.getUpcomingMovies();
        final shows = await apiRunner.getPopularShows();

        expect(movies, isNotNull);
        expect(shows, isNotNull);

        if (movies!.isNotEmpty && shows!.isNotEmpty) {
          final movie = movies.first;
          final show = shows.first;

          // Both should have the same properties
          expect(movie.id.runtimeType, show.id.runtimeType);
          expect(movie.title.runtimeType, show.title.runtimeType);
          expect(movie.voteAverage.runtimeType, show.voteAverage.runtimeType);
          expect(movie.releaseDate.runtimeType, show.releaseDate.runtimeType);
          expect(movie.overview.runtimeType, show.overview.runtimeType);
          expect(movie.posterPath.runtimeType, show.posterPath.runtimeType);
        }
      }, timeout: Timeout(Duration(seconds: 60)));

      test('Multiple API calls return consistent data types', () async {
        final action = await apiRunner.getActionMovies();
        final comedy = await apiRunner.getComedyMovies();
        final horror = await apiRunner.getHorrorMovies();

        expect(action.runtimeType, comedy.runtimeType);
        expect(comedy.runtimeType, horror.runtimeType);
      }, timeout: Timeout(Duration(seconds: 60)));
    });

    group('Pagination Tests', () {
      test('API returns expected number of results', () async {
        final movies = await apiRunner.getUpcomingMovies();

        expect(movies, isNotNull);
        // TMDB typically returns 20 results per page
        if (movies!.isNotEmpty) {
          expect(movies.length, lessThanOrEqualTo(20));
        }
      }, timeout: Timeout(Duration(seconds: 30)));

      test('different genre endpoints return different content', () async {
        final action = await apiRunner.getActionMovies();
        final comedy = await apiRunner.getComedyMovies();

        expect(action, isNotNull);
        expect(comedy, isNotNull);

        if (action!.isNotEmpty && comedy!.isNotEmpty) {
          // Different genres should return different movies (usually)
          final actionIds = action.map((m) => m.id).toSet();
          final comedyIds = comedy.map((m) => m.id).toSet();
          
          // There might be some overlap, but not complete overlap
          final overlap = actionIds.intersection(comedyIds);
          expect(overlap.length, lessThan(action.length));
        }
      }, timeout: Timeout(Duration(seconds: 60)));
    });

    group('Search Functionality Tests', () {
      test('search is case insensitive', () async {
        final lowerCase = await apiRunner.searchMovie('batman');
        final upperCase = await apiRunner.searchMovie('BATMAN');
        final mixedCase = await apiRunner.searchMovie('BaTmAn');

        expect(lowerCase, isNotNull);
        expect(upperCase, isNotNull);
        expect(mixedCase, isNotNull);

        // All should return results
        if (lowerCase!.isNotEmpty && upperCase!.isNotEmpty && mixedCase!.isNotEmpty) {
          // First result should be the same across all searches
          expect(lowerCase.first.id, upperCase.first.id);
          expect(upperCase.first.id, mixedCase.first.id);
        }
      }, timeout: Timeout(Duration(seconds: 60)));

      test('search handles unicode characters', () async {
        final movies = await apiRunner.searchMovie('東京');

        expect(movies, isNotNull);
        // Should not throw error even if no results
      }, timeout: Timeout(Duration(seconds: 30)));

      test('search handles numeric queries', () async {
        final movies = await apiRunner.searchMovie('2001');

        expect(movies, isNotNull);
        // Should find "2001: A Space Odyssey" or similar
      }, timeout: Timeout(Duration(seconds: 30)));

      test('TV show search returns relevant results', () async {
        final shows = await apiRunner.searchTVShow('Game of Thrones');

        expect(shows, isNotNull);
        expect(shows, isNotEmpty);

        final titles = shows!.map((s) => s.title.toLowerCase()).toList();
        expect(titles.any((t) => t.contains('game') || t.contains('thrones')), isTrue);
      }, timeout: Timeout(Duration(seconds: 30)));

      test('search with single character returns results', () async {
        final movies = await apiRunner.searchMovie('X');

        expect(movies, isNotNull);
        // Should find X-Men movies or similar
      }, timeout: Timeout(Duration(seconds: 30)));
    });

    group('Data Validation Tests', () {
      test('all movies have valid IDs', () async {
        final movies = await apiRunner.getUpcomingMovies();

        expect(movies, isNotNull);
        for (final movie in movies!) {
          expect(movie.id, isA<int>());
          expect(movie.id, greaterThan(0));
        }
      }, timeout: Timeout(Duration(seconds: 30)));

      test('all movies have non-empty titles', () async {
        final movies = await apiRunner.getTopRatedTV();

        expect(movies, isNotNull);
        for (final movie in movies!) {
          expect(movie.title, isA<String>());
          expect(movie.title.trim(), isNotEmpty);
        }
      }, timeout: Timeout(Duration(seconds: 30)));

      test('vote averages are within valid range', () async {
        final movies = await apiRunner.getActionMovies();

        expect(movies, isNotNull);
        for (final movie in movies!) {
          expect(movie.voteAverage, greaterThanOrEqualTo(0.0));
          expect(movie.voteAverage, lessThanOrEqualTo(10.0));
        }
      }, timeout: Timeout(Duration(seconds: 30)));

      test('release dates are parseable', () async {
        final movies = await apiRunner.getComedyMovies();

        expect(movies, isNotNull);
        for (final movie in movies!) {
          if (movie.releaseDate.isNotEmpty && movie.releaseDate != 'Unknown') {
            final parsed = DateTime.tryParse(movie.releaseDate);
            // Some dates might be incomplete (just year) but shouldn't crash
            if (parsed != null) {
              expect(parsed.year, greaterThan(1800));
              expect(parsed.year, lessThan(2100));
            }
          }
        }
      }, timeout: Timeout(Duration(seconds: 30)));

      test('overviews are strings', () async {
        final movies = await apiRunner.getDramaMovies();

        expect(movies, isNotNull);
        for (final movie in movies!) {
          expect(movie.overview, isA<String>());
        }
      }, timeout: Timeout(Duration(seconds: 30)));
    });

    group('Error Handling Tests', () {
      test('empty search query returns results or empty list', () async {
        final movies = await apiRunner.searchMovie('');

        // Should return empty list or handle gracefully
        expect(movies, isNotNull);
      }, timeout: Timeout(Duration(seconds: 30)));

      test('search with only spaces returns results or empty list', () async {
        final movies = await apiRunner.searchMovie('   ');

        expect(movies, isNotNull);
      }, timeout: Timeout(Duration(seconds: 30)));
    });

    group('Performance Tests', () {
      test('API response time is reasonable', () async {
        final stopwatch = Stopwatch()..start();
        
        await apiRunner.getUpcomingMovies();
        
        stopwatch.stop();
        
        // API should respond within 10 seconds
        expect(stopwatch.elapsedMilliseconds, lessThan(10000));
      }, timeout: Timeout(Duration(seconds: 30)));

      test('multiple concurrent requests complete successfully', () async {
        final futures = [
          apiRunner.getActionMovies(),
          apiRunner.getComedyMovies(),
          apiRunner.getHorrorMovies(),
        ];

        final results = await Future.wait(futures);

        for (final result in results) {
          expect(result, isNotNull);
        }
      }, timeout: Timeout(Duration(seconds: 60)));
    });
  });
}
