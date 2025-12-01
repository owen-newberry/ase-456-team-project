// test/movie_model_test.dart - Unit tests for Movie model
import 'package:flutter_test/flutter_test.dart';
import 'package:p3_movie/model/movie.dart';

void main() {
  group('Movie Model Tests', () {
    test('creates Movie from JSON correctly', () {
      final json = {
        'id': 123,
        'title': 'Test Movie',
        'poster_path': '/test.jpg',
        'release_date': '2023-01-15',
        'vote_average': 8.5,
        'overview': 'This is a test movie overview',
      };

      final movie = Movie.fromJson(json);

      expect(movie.id, 123);
      expect(movie.title, 'Test Movie');
      expect(movie.posterPath, '/test.jpg');
      expect(movie.releaseDate, '2023-01-15');
      expect(movie.voteAverage, 8.5);
      expect(movie.overview, 'This is a test movie overview');
    });

    test('handles missing poster_path gracefully', () {
      final json = {
        'id': 123,
        'title': 'Test Movie',
        'poster_path': null,
        'release_date': '2023-01-15',
        'vote_average': 8.5,
        'overview': 'Test overview',
      };

      final movie = Movie.fromJson(json);
      expect(movie.posterPath, '');
    });

    test('handles missing overview gracefully', () {
      final json = {
        'id': 123,
        'title': 'Test Movie',
        'poster_path': '/test.jpg',
        'release_date': '2023-01-15',
        'vote_average': 8.5,
        'overview': null,
      };

      final movie = Movie.fromJson(json);
      expect(movie.overview, '');
    });

    test('handles missing release_date gracefully', () {
      final json = {
        'id': 123,
        'title': 'Test Movie',
        'poster_path': '/test.jpg',
        'release_date': null,
        'vote_average': 8.5,
        'overview': 'Test',
      };

      final movie = Movie.fromJson(json);
      expect(movie.releaseDate, 'Unknown');
    });

    test('handles zero vote_average', () {
      final json = {
        'id': 123,
        'title': 'Test Movie',
        'poster_path': '/test.jpg',
        'release_date': '2023-01-15',
        'vote_average': 0,
        'overview': 'Test',
      };

      final movie = Movie.fromJson(json);
      expect(movie.voteAverage, 0);
    });

    test('handles integer vote_average (converted to double)', () {
      final json = {
        'id': 123,
        'title': 'Test Movie',
        'poster_path': '/test.jpg',
        'release_date': '2023-01-15',
        'vote_average': 7,
        'overview': 'Test',
      };

      final movie = Movie.fromJson(json);
      expect(movie.voteAverage, 7.0);
    });

    test('handles high vote_average (10.0)', () {
      final json = {
        'id': 123,
        'title': 'Perfect Movie',
        'poster_path': '/test.jpg',
        'release_date': '2023-01-15',
        'vote_average': 10.0,
        'overview': 'Test',
      };

      final movie = Movie.fromJson(json);
      expect(movie.voteAverage, 10.0);
    });

    test('handles decimal vote_average', () {
      final json = {
        'id': 123,
        'title': 'Test Movie',
        'poster_path': '/test.jpg',
        'release_date': '2023-01-15',
        'vote_average': 7.89,
        'overview': 'Test',
      };

      final movie = Movie.fromJson(json);
      expect(movie.voteAverage, 7.89);
    });

    test('creates multiple movies from JSON array', () {
      final jsonArray = [
        {
          'id': 1,
          'title': 'Movie 1',
          'poster_path': '/1.jpg',
          'release_date': '2023-01-01',
          'vote_average': 7.0,
          'overview': 'Test 1',
        },
        {
          'id': 2,
          'title': 'Movie 2',
          'poster_path': '/2.jpg',
          'release_date': '2023-02-01',
          'vote_average': 8.0,
          'overview': 'Test 2',
        },
      ];

      final movies = jsonArray.map((json) => Movie.fromJson(json)).toList();

      expect(movies.length, 2);
      expect(movies[0].id, 1);
      expect(movies[1].id, 2);
      expect(movies[0].title, 'Movie 1');
      expect(movies[1].title, 'Movie 2');
    });

    test('handles empty title', () {
      final json = {
        'id': 123,
        'title': '',
        'poster_path': '/test.jpg',
        'release_date': '2023-01-15',
        'vote_average': 8.5,
        'overview': 'Test',
      };

      final movie = Movie.fromJson(json);
      expect(movie.title, '');
    });

    test('handles very long overview', () {
      final longOverview = 'A' * 1000;
      final json = {
        'id': 123,
        'title': 'Test Movie',
        'poster_path': '/test.jpg',
        'release_date': '2023-01-15',
        'vote_average': 8.5,
        'overview': longOverview,
      };

      final movie = Movie.fromJson(json);
      expect(movie.overview.length, 1000);
    });

    test('handles special characters in title', () {
      final json = {
        'id': 123,
        'title': 'The Movie: Part 2 - "Revenge"',
        'poster_path': '/test.jpg',
        'release_date': '2023-01-15',
        'vote_average': 8.5,
        'overview': 'Test',
      };

      final movie = Movie.fromJson(json);
      expect(movie.title, 'The Movie: Part 2 - "Revenge"');
    });

    test('handles future release date', () {
      final json = {
        'id': 123,
        'title': 'Future Movie',
        'poster_path': '/test.jpg',
        'release_date': '2030-12-31',
        'vote_average': 8.5,
        'overview': 'Test',
      };

      final movie = Movie.fromJson(json);
      expect(movie.releaseDate, '2030-12-31');
    });

    test('handles old release date', () {
      final json = {
        'id': 123,
        'title': 'Classic Movie',
        'poster_path': '/test.jpg',
        'release_date': '1950-01-01',
        'vote_average': 8.5,
        'overview': 'Test',
      };

      final movie = Movie.fromJson(json);
      expect(movie.releaseDate, '1950-01-01');
    });
  });

  group('Movie Constructor Tests', () {
    test('creates Movie using constructor', () {
      final movie = Movie(
        id: 456,
        title: 'Direct Construction',
        posterPath: '/direct.jpg',
        releaseDate: '2023-05-20',
        voteAverage: 9.2,
        overview: 'Created directly',
      );

      expect(movie.id, 456);
      expect(movie.title, 'Direct Construction');
      expect(movie.posterPath, '/direct.jpg');
      expect(movie.releaseDate, '2023-05-20');
      expect(movie.voteAverage, 9.2);
      expect(movie.overview, 'Created directly');
    });

    test('creates Movie with empty strings', () {
      final movie = Movie(
        id: 789,
        title: '',
        posterPath: '',
        releaseDate: '',
        voteAverage: 0.0,
        overview: '',
      );

      expect(movie.id, 789);
      expect(movie.title, '');
      expect(movie.posterPath, '');
      expect(movie.releaseDate, '');
      expect(movie.voteAverage, 0.0);
      expect(movie.overview, '');
    });
  });
}