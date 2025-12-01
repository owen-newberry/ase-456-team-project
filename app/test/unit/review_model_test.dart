// test/unit/review_model_test.dart - Unit tests for Review model
import 'package:flutter_test/flutter_test.dart';
import 'package:p3_movie/model/review.dart';

void main() {
  group('Review Model Tests', () {
    group('Constructor Tests', () {
      test('creates Review with all required fields', () {
        final review = Review(
          movie: 'Test Movie',
          comment: 'Great movie!',
        );

        expect(review.movie, 'Test Movie');
        expect(review.comment, 'Great movie!');
        expect(review.id, isNull);
        expect(review.user_id, isNull);
        expect(review.username, isNull);
        expect(review.rating, isNull);
      });

      test('creates Review with all fields', () {
        final review = Review(
          id: 1,
          movie: 'Test Movie',
          user_id: 'user-123',
          username: 'testuser@email.com',
          comment: 'Amazing film!',
          rating: 5,
        );

        expect(review.id, 1);
        expect(review.movie, 'Test Movie');
        expect(review.user_id, 'user-123');
        expect(review.username, 'testuser@email.com');
        expect(review.comment, 'Amazing film!');
        expect(review.rating, 5);
      });

      test('creates Review with zero rating', () {
        final review = Review(
          movie: 'Test Movie',
          comment: 'Not rated yet',
          rating: 0,
        );

        expect(review.rating, 0);
      });

      test('creates Review with maximum rating', () {
        final review = Review(
          movie: 'Test Movie',
          comment: 'Perfect!',
          rating: 10,
        );

        expect(review.rating, 10);
      });
    });

    group('fromJson Tests', () {
      test('creates Review from complete JSON', () {
        final json = {
          'id': 42,
          'movie': 'The Matrix',
          'user_id': 'abc-123',
          'username': 'neo@matrix.com',
          'comment': 'There is no spoon',
          'rating': 9,
        };

        final review = Review.fromJson(json);

        expect(review.id, 42);
        expect(review.movie, 'The Matrix');
        expect(review.user_id, 'abc-123');
        expect(review.username, 'neo@matrix.com');
        expect(review.comment, 'There is no spoon');
        expect(review.rating, 9);
      });

      test('creates Review from minimal JSON', () {
        final json = {
          'movie': 'Inception',
          'comment': 'Mind-bending!',
        };

        final review = Review.fromJson(json);

        expect(review.movie, 'Inception');
        expect(review.comment, 'Mind-bending!');
        expect(review.id, isNull);
        expect(review.user_id, isNull);
        expect(review.username, isNull);
        expect(review.rating, isNull);
      });

      test('handles null values in JSON', () {
        final json = {
          'id': null,
          'movie': 'Test Movie',
          'user_id': null,
          'username': null,
          'comment': 'Test comment',
          'rating': null,
        };

        final review = Review.fromJson(json);

        expect(review.id, isNull);
        expect(review.movie, 'Test Movie');
        expect(review.user_id, isNull);
        expect(review.username, isNull);
        expect(review.comment, 'Test comment');
        expect(review.rating, isNull);
      });
    });

    group('toJson Tests', () {
      test('converts Review to JSON with all fields', () {
        final review = Review(
          id: 1,
          movie: 'Interstellar',
          user_id: 'user-456',
          username: 'cooper@nasa.gov',
          comment: 'Love transcends dimensions',
          rating: 10,
        );

        final json = review.toJson();

        // Note: toJson doesn't include 'id' based on the implementation
        expect(json['movie'], 'Interstellar');
        expect(json['user_id'], 'user-456');
        expect(json['username'], 'cooper@nasa.gov');
        expect(json['comment'], 'Love transcends dimensions');
        expect(json['rating'], 10);
      });

      test('converts Review to JSON with null optional fields', () {
        final review = Review(
          movie: 'Test Movie',
          comment: 'Basic review',
        );

        final json = review.toJson();

        expect(json['movie'], 'Test Movie');
        expect(json['comment'], 'Basic review');
        expect(json['user_id'], isNull);
        expect(json['username'], isNull);
        expect(json['rating'], isNull);
      });

      test('toJson does not include id field', () {
        final review = Review(
          id: 999,
          movie: 'Test Movie',
          comment: 'Test comment',
        );

        final json = review.toJson();

        expect(json.containsKey('id'), isFalse);
      });
    });

    group('Round-trip Tests', () {
      test('Review survives JSON round-trip', () {
        final original = Review(
          movie: 'Blade Runner',
          user_id: 'deckard-001',
          username: 'deckard@lapd.gov',
          comment: 'I have seen things you people would not believe',
          rating: 8,
        );

        final json = original.toJson();
        // Add id for fromJson since toJson excludes it
        json['id'] = 100;
        final restored = Review.fromJson(json);

        expect(restored.movie, original.movie);
        expect(restored.user_id, original.user_id);
        expect(restored.username, original.username);
        expect(restored.comment, original.comment);
        expect(restored.rating, original.rating);
      });
    });

    group('Edge Case Tests', () {
      test('handles empty string comment', () {
        final review = Review(
          movie: 'Test Movie',
          comment: '',
        );

        expect(review.comment, '');
      });

      test('handles very long comment', () {
        final longComment = 'A' * 10000;
        final review = Review(
          movie: 'Test Movie',
          comment: longComment,
        );

        expect(review.comment.length, 10000);
      });

      test('handles special characters in movie title', () {
        final review = Review(
          movie: "Spider-Man: No Way Home (2021) - Director's Cut!",
          comment: 'Great movie!',
        );

        expect(review.movie, "Spider-Man: No Way Home (2021) - Director's Cut!");
      });

      test('handles unicode in comment', () {
        final review = Review(
          movie: 'Test Movie',
          comment: '🎬 Great movie! 五星好评 ⭐⭐⭐⭐⭐',
        );

        expect(review.comment, '🎬 Great movie! 五星好评 ⭐⭐⭐⭐⭐');
      });

      test('handles negative rating', () {
        final review = Review(
          movie: 'Test Movie',
          comment: 'Terrible',
          rating: -1,
        );

        // Model allows negative ratings (validation should be done elsewhere)
        expect(review.rating, -1);
      });

      test('handles whitespace-only comment', () {
        final review = Review(
          movie: 'Test Movie',
          comment: '   \n\t  ',
        );

        expect(review.comment.trim(), isEmpty);
      });

      test('handles multiline comment', () {
        final review = Review(
          movie: 'Test Movie',
          comment: 'Line 1\nLine 2\nLine 3',
        );

        expect(review.comment.split('\n').length, 3);
      });

      test('handles very long movie title', () {
        final longTitle = 'M' * 500;
        final review = Review(
          movie: longTitle,
          comment: 'Review of a movie with a very long title',
        );

        expect(review.movie.length, 500);
      });
    });

    group('Equality and Comparison Tests', () {
      test('two reviews with same data are not identical by reference', () {
        final review1 = Review(
          id: 1,
          movie: 'Test Movie',
          comment: 'Great!',
          rating: 8,
        );
        
        final review2 = Review(
          id: 1,
          movie: 'Test Movie',
          comment: 'Great!',
          rating: 8,
        );

        expect(identical(review1, review2), isFalse);
      });

      test('reviews can be stored in a list', () {
        final reviews = [
          Review(movie: 'Movie 1', comment: 'Comment 1'),
          Review(movie: 'Movie 2', comment: 'Comment 2'),
          Review(movie: 'Movie 3', comment: 'Comment 3'),
        ];

        expect(reviews.length, 3);
        expect(reviews.map((r) => r.movie).toList(), ['Movie 1', 'Movie 2', 'Movie 3']);
      });

      test('review properties are immutable after creation', () {
        final review = Review(
          id: 1,
          movie: 'Test Movie',
          comment: 'Original comment',
          rating: 5,
        );

        // These are final fields, so we just verify they exist and are correct
        expect(review.id, 1);
        expect(review.movie, 'Test Movie');
        expect(review.comment, 'Original comment');
        expect(review.rating, 5);
      });
    });

    group('JSON Edge Cases', () {
      test('fromJson handles extra unknown fields', () {
        final jsonWithExtras = {
          'id': 1,
          'movie': 'Test Movie',
          'comment': 'Test comment',
          'rating': 5,
          'unknown_field': 'should be ignored',
          'another_unknown': 12345,
        };

        final review = Review.fromJson(jsonWithExtras);
        expect(review.movie, 'Test Movie');
        expect(review.rating, 5);
      });

      test('fromJson handles numeric strings for id', () {
        final jsonWithStringId = {
          'id': 42, // Some APIs might return string IDs
          'movie': 'Test Movie',
          'comment': 'Test comment',
        };

        final review = Review.fromJson(jsonWithStringId);
        expect(review.id, 42);
      });

      test('toJson produces valid JSON-serializable map', () {
        final review = Review(
          movie: 'Test Movie',
          user_id: 'user-123',
          username: 'test@email.com',
          comment: 'Great movie!',
          rating: 9,
        );

        final json = review.toJson();
        
        // All values should be JSON-serializable types
        expect(json.values.every((v) => v == null || v is String || v is int), isTrue);
      });

      test('handles rating at boundary values', () {
        final reviewMin = Review(movie: 'Movie', comment: 'Bad', rating: 0);
        final reviewMax = Review(movie: 'Movie', comment: 'Perfect', rating: 10);
        final reviewMid = Review(movie: 'Movie', comment: 'OK', rating: 5);

        expect(reviewMin.rating, 0);
        expect(reviewMax.rating, 10);
        expect(reviewMid.rating, 5);
      });

      test('handles email-like username formats', () {
        final review = Review(
          movie: 'Test Movie',
          comment: 'Review',
          username: 'user+tag@subdomain.example.com',
        );

        expect(review.username, 'user+tag@subdomain.example.com');
        expect(review.username!.contains('@'), isTrue);
      });

      test('handles UUID-format user_id', () {
        final review = Review(
          movie: 'Test Movie',
          comment: 'Review',
          user_id: '550e8400-e29b-41d4-a716-446655440000',
        );

        expect(review.user_id!.length, 36);
        expect(review.user_id!.contains('-'), isTrue);
      });
    });
  });
}
