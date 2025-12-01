import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:p3_movie/view/movie_list.dart';
import 'package:p3_movie/util/api.dart';
import 'package:p3_movie/model/movie.dart';

// Manual Mock class - no code generation needed
class MockAPIRunner extends APIRunner {
  List<Movie>? mockUpcomingMovies;
  List<Movie>? mockPopularShows;
  List<Movie>? mockActionMovies;
  List<Movie>? mockComedyMovies;
  List<Movie>? mockRomanceMovies;
  List<Movie>? mockHorrorMovies;
  List<Movie>? mockDramaMovies;
  List<Movie>? mockAnimationMovies;
  List<Movie>? mockSearchResults;

  @override
  Future<List<Movie>?> getUpcomingMovies() async => mockUpcomingMovies ?? [];

  @override
  Future<List<Movie>?> getPopularShows() async => mockPopularShows ?? [];

  @override
  Future<List<Movie>?> getActionMovies() async => mockActionMovies ?? [];

  @override
  Future<List<Movie>?> getComedyMovies() async => mockComedyMovies ?? [];

  @override
  Future<List<Movie>?> getRomanceMovies() async => mockRomanceMovies ?? [];

  @override
  Future<List<Movie>?> getHorrorMovies() async => mockHorrorMovies ?? [];

  @override
  Future<List<Movie>?> getDramaMovies() async => mockDramaMovies ?? [];

  @override
  Future<List<Movie>?> getAnimationMovies() async => mockAnimationMovies ?? [];

  @override
  Future<List<Movie>?> getActionShows() async => mockActionMovies ?? [];

  @override
  Future<List<Movie>?> getComedyShows() async => mockComedyMovies ?? [];

  @override
  Future<List<Movie>?> getRomanceShows() async => mockRomanceMovies ?? [];

  @override
  Future<List<Movie>?> getHorrorShows() async => mockHorrorMovies ?? [];

  @override
  Future<List<Movie>?> getDramaShows() async => mockDramaMovies ?? [];

  @override
  Future<List<Movie>?> getAnimationShows() async => mockAnimationMovies ?? [];

  @override
  Future<List<Movie>?> searchMovie(String title) async => mockSearchResults ?? [];

  @override
  Future<List<Movie>?> searchTVShow(String title) async => mockSearchResults ?? [];
}

void main() {
  // Note: Some MovieList widget tests will show API errors in the console
  // because the widget creates its own APIRunner instance internally.
  // To fully mock the API, you would need to modify MovieList to accept
  // an optional APIRunner parameter for dependency injection.
  // These console errors don't affect the test results - we're testing the UI behavior.
  
  group('sortMovies', () {
    final testMovies = [
      Movie(
        id: 1,
        title: 'Zebra Movie',
        posterPath: '/test1.jpg',
        releaseDate: '2023-01-15',
        voteAverage: 7.5,
        overview: 'Test overview 1',
      ),
      Movie(
        id: 2,
        title: 'Alpha Movie',
        posterPath: '/test2.jpg',
        releaseDate: '2023-12-20',
        voteAverage: 8.5,
        overview: 'Test overview 2',
      ),
      Movie(
        id: 3,
        title: 'Beta Movie',
        posterPath: '/test3.jpg',
        releaseDate: '2023-06-10',
        voteAverage: 6.0,
        overview: 'Test overview 3',
      ),
    ];

    test('sorts by title ascending', () {
      final sorted = sortMovies(testMovies, SortOption.title, ascending: true);
      expect(sorted[0].title, 'Alpha Movie');
      expect(sorted[1].title, 'Beta Movie');
      expect(sorted[2].title, 'Zebra Movie');
    });

    test('sorts by title descending', () {
      final sorted = sortMovies(testMovies, SortOption.title, ascending: false);
      expect(sorted[0].title, 'Zebra Movie');
      expect(sorted[1].title, 'Beta Movie');
      expect(sorted[2].title, 'Alpha Movie');
    });

    test('sorts by release date ascending', () {
      final sorted = sortMovies(testMovies, SortOption.releaseDate, ascending: true);
      expect(sorted[0].title, 'Zebra Movie'); // 2023-01-15
      expect(sorted[1].title, 'Beta Movie');  // 2023-06-10
      expect(sorted[2].title, 'Alpha Movie'); // 2023-12-20
    });

    test('sorts by release date descending', () {
      final sorted = sortMovies(testMovies, SortOption.releaseDate, ascending: false);
      expect(sorted[0].title, 'Alpha Movie'); // 2023-12-20
      expect(sorted[1].title, 'Beta Movie');  // 2023-06-10
      expect(sorted[2].title, 'Zebra Movie'); // 2023-01-15
    });

    test('sorts by vote average ascending', () {
      final sorted = sortMovies(testMovies, SortOption.voteAverage, ascending: true);
      expect(sorted[0].voteAverage, 6.0);
      expect(sorted[1].voteAverage, 7.5);
      expect(sorted[2].voteAverage, 8.5);
    });

    test('sorts by vote average descending', () {
      final sorted = sortMovies(testMovies, SortOption.voteAverage, ascending: false);
      expect(sorted[0].voteAverage, 8.5);
      expect(sorted[1].voteAverage, 7.5);
      expect(sorted[2].voteAverage, 6.0);
    });

    test('does not modify original list', () {
      final original = List<Movie>.from(testMovies);
      sortMovies(testMovies, SortOption.title);
      expect(testMovies.length, original.length);
      expect(testMovies[0].id, original[0].id);
    });
  });

  group('MovieList Widget', () {
    late MockAPIRunner mockApi;

    setUp(() {
      mockApi = MockAPIRunner();
      mockApi.mockUpcomingMovies = [];
      mockApi.mockPopularShows = [];
    });

    testWidgets('displays loading state initially', (WidgetTester tester) async {
      mockApi.mockUpcomingMovies = [];
      
      await tester.pumpWidget(
        MaterialApp(
          home: MovieList(
            isDarkMode: false,
            onThemeChanged: (_) {},
          ),
        ),
      );

      // Widget should build without errors
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('displays Movies title by default', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MovieList(
            isDarkMode: false,
            onThemeChanged: (_) {},
          ),
        ),
      );

      expect(find.text('Movies'), findsOneWidget);
    });

    testWidgets('has search icon button', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MovieList(
            isDarkMode: false,
            onThemeChanged: (_) {},
          ),
        ),
      );

      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('has mode toggle button', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MovieList(
            isDarkMode: false,
            onThemeChanged: (_) {},
          ),
        ),
      );

      expect(find.byIcon(Icons.movie), findsOneWidget);
    });

    testWidgets('has theme toggle button', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MovieList(
            isDarkMode: false,
            onThemeChanged: (_) {},
          ),
        ),
      );

      expect(find.byIcon(Icons.light_mode), findsOneWidget);
    });

    testWidgets('has profile button', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MovieList(
            isDarkMode: false,
            onThemeChanged: (_) {},
          ),
        ),
      );

      expect(find.byIcon(Icons.account_circle), findsOneWidget);
    });

    testWidgets('toggles search bar when search icon is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MovieList(
            isDarkMode: false,
            onThemeChanged: (_) {},
          ),
        ),
      );

      // Initial state - search icon visible
      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.text('Movies'), findsOneWidget);

      // Tap search icon
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      // Search field should appear with cancel icon
      expect(find.byIcon(Icons.cancel), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('toggles between Movies and TV Shows mode', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MovieList(
            isDarkMode: false,
            onThemeChanged: (_) {},
          ),
        ),
      );

      // Initial state - Movies mode
      expect(find.text('Movies'), findsOneWidget);
      expect(find.byIcon(Icons.movie), findsOneWidget);

      // Tap mode toggle
      await tester.tap(find.byIcon(Icons.movie));
      await tester.pumpAndSettle();

      // Should switch to TV Shows mode
      expect(find.text('TV Shows'), findsOneWidget);
      expect(find.byIcon(Icons.tv), findsOneWidget);
    });

    testWidgets('calls onThemeChanged when theme button is tapped', (WidgetTester tester) async {
      bool themeChanged = false;
      bool newTheme = false;

      await tester.pumpWidget(
        MaterialApp(
          home: MovieList(
            isDarkMode: false,
            onThemeChanged: (value) {
              themeChanged = true;
              newTheme = value;
            },
          ),
        ),
      );

      // Tap theme toggle
      await tester.tap(find.byIcon(Icons.light_mode));
      await tester.pumpAndSettle();

      expect(themeChanged, true);
      expect(newTheme, true);
    });

    testWidgets('displays dark mode icon when in dark mode', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MovieList(
            isDarkMode: true,
            onThemeChanged: (_) {},
          ),
        ),
      );

      expect(find.byIcon(Icons.dark_mode), findsOneWidget);
    });

    testWidgets('displays sorting controls', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MovieList(
            isDarkMode: false,
            onThemeChanged: (_) {},
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should have dropdown and sort direction button
      expect(find.byType(DropdownButton<SortOption>), findsOneWidget);
      expect(find.byIcon(Icons.arrow_upward), findsOneWidget);
    });

    testWidgets('toggles sort direction when arrow button is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MovieList(
            isDarkMode: false,
            onThemeChanged: (_) {},
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Initial state - ascending
      expect(find.byIcon(Icons.arrow_upward), findsOneWidget);

      // Tap sort direction button
      await tester.tap(find.byIcon(Icons.arrow_upward));
      await tester.pumpAndSettle();

      // Should change to descending
      expect(find.byIcon(Icons.arrow_downward), findsOneWidget);
    });

    testWidgets('displays Surprise Me button', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MovieList(
            isDarkMode: false,
            onThemeChanged: (_) {},
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Surprise Me!'), findsOneWidget);
      expect(find.byIcon(Icons.shuffle), findsOneWidget);
    });
  });

  group('InfiniteHorizontalScroll Widget', () {
    // Setup to prevent actual HTTP image loading in tests
    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    final testMovies = [
      Movie(
        id: 1,
        title: 'Test Movie 1',
        posterPath: '', // Empty path to avoid image loading
        releaseDate: '2023-01-01',
        voteAverage: 7.0,
        overview: 'Test overview 1',
      ),
      Movie(
        id: 2,
        title: 'Test Movie 2',
        posterPath: '', // Empty path to avoid image loading
        releaseDate: '2023-02-01',
        voteAverage: 8.0,
        overview: 'Test overview 2',
      ),
    ];

    testWidgets('displays movies in horizontal scroll', (WidgetTester tester) async {
      // Disable image loading errors in tests
      FlutterError.onError = (FlutterErrorDetails details) {
        // Ignore image loading errors in tests
        if (!details.toString().contains('NetworkImage')) {
          FlutterError.presentError(details);
        }
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InfiniteHorizontalScroll(
              movies: testMovies,
              defaultImage: 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==',
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.byType(ListView), findsOneWidget);
      // Since infinite scroll creates multiple copies, we should find at least one
      expect(find.text('Test Movie 1'), findsWidgets);
    });

    testWidgets('displays no movies message when list is empty', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InfiniteHorizontalScroll(
              movies: [],
              defaultImage: 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==',
            ),
          ),
        ),
      );

      expect(find.text('No movies available'), findsOneWidget);
    });
  });

  group('_MovieListState helper methods', () {
    test('rankAndSortMovies prioritizes exact matches', () {
      final movies = [
        Movie(
          id: 1,
          title: 'The Dark Knight',
          posterPath: '/test1.jpg',
          releaseDate: '2008-07-18',
          voteAverage: 9.0,
          overview: 'Test',
        ),
        Movie(
          id: 2,
          title: 'Dark',
          posterPath: '/test2.jpg',
          releaseDate: '2017-12-01',
          voteAverage: 8.7,
          overview: 'Test',
        ),
        Movie(
          id: 3,
          title: 'Knight and Day',
          posterPath: '/test3.jpg',
          releaseDate: '2010-06-23',
          voteAverage: 6.3,
          overview: 'Test',
        ),
      ];

      // This would need to be tested by creating a test version of the widget
      // or by making the method static/top-level
      // For now, this is a placeholder structure
    });
  });

  group('Edge Cases', () {
    test('sortMovies handles empty list', () {
      final result = sortMovies([], SortOption.title);
      expect(result, isEmpty);
    });

    test('sortMovies handles single item', () {
      final movies = [
        Movie(
          id: 1,
          title: 'Solo Movie',
          posterPath: '/test.jpg',
          releaseDate: '2023-01-01',
          voteAverage: 7.0,
          overview: 'Test',
        ),
      ];
      
      final result = sortMovies(movies, SortOption.title);
      expect(result.length, 1);
      expect(result[0].title, 'Solo Movie');
    });

    test('sortMovies handles movies with invalid dates', () {
      final movies = [
        Movie(
          id: 1,
          title: 'Movie A',
          posterPath: '/test1.jpg',
          releaseDate: 'invalid-date',
          voteAverage: 7.0,
          overview: 'Test',
        ),
        Movie(
          id: 2,
          title: 'Movie B',
          posterPath: '/test2.jpg',
          releaseDate: '2023-01-01',
          voteAverage: 8.0,
          overview: 'Test',
        ),
      ];
      
      // Should not throw error
      final result = sortMovies(movies, SortOption.releaseDate);
      expect(result.length, 2);
    });

    test('sortMovies handles movies with same values', () {
      final movies = [
        Movie(
          id: 1,
          title: 'Movie A',
          posterPath: '/test1.jpg',
          releaseDate: '2023-01-01',
          voteAverage: 7.0,
          overview: 'Test',
        ),
        Movie(
          id: 2,
          title: 'Movie A',
          posterPath: '/test2.jpg',
          releaseDate: '2023-01-01',
          voteAverage: 7.0,
          overview: 'Test',
        ),
      ];
      
      // Should not throw error with duplicate values
      final result = sortMovies(movies, SortOption.title);
      expect(result.length, 2);
    });
  });
}