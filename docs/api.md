# API Documentation

## Overview

The Movie App uses the [TMDB (The Movie Database) API](https://www.themoviedb.org/documentation/api) to fetch movie and TV show data. This document describes the API integration layer implemented in `app/lib/util/api.dart`.

---

## APIRunner Class

The `APIRunner` class provides methods to interact with the TMDB API.

### Configuration

```dart
class APIRunner {
  static const String apiKey = 'YOUR_API_KEY';
  static const String baseUrl = 'https://api.themoviedb.org/3';
}
```

---

## Movie Endpoints

### Get Upcoming Movies

Fetches a list of upcoming movies.

```dart
Future<List<Movie>?> getUpcomingMovies()
```

**Returns:** List of `Movie` objects or `null` on error.

**API Endpoint:** `GET /movie/upcoming`

---

### Get Action Movies

Fetches action movies (genre ID: 28).

```dart
Future<List<Movie>> getActionMovies()
```

**Returns:** List of `Movie` objects.

**API Endpoint:** `GET /discover/movie?with_genres=28`

---

### Get Comedy Movies

Fetches comedy movies (genre ID: 35).

```dart
Future<List<Movie>> getComedyMovies()
```

**Returns:** List of `Movie` objects.

**API Endpoint:** `GET /discover/movie?with_genres=35`

---

### Get Horror Movies

Fetches horror movies (genre ID: 27).

```dart
Future<List<Movie>> getHorrorMovies()
```

**Returns:** List of `Movie` objects.

**API Endpoint:** `GET /discover/movie?with_genres=27`

---

### Get Drama Movies

Fetches drama movies (genre ID: 18).

```dart
Future<List<Movie>> getDramaMovies()
```

**Returns:** List of `Movie` objects.

**API Endpoint:** `GET /discover/movie?with_genres=18`

---

### Get Animation Movies

Fetches animation movies (genre ID: 16).

```dart
Future<List<Movie>> getAnimationMovies()
```

**Returns:** List of `Movie` objects.

**API Endpoint:** `GET /discover/movie?with_genres=16`

---

### Get Romance Movies

Fetches romance movies (genre ID: 10749).

```dart
Future<List<Movie>> getRomanceMovies()
```

**Returns:** List of `Movie` objects.

**API Endpoint:** `GET /discover/movie?with_genres=10749`

---

### Search Movies

Searches for movies by query string.

```dart
Future<List<Movie>?> searchMovie(String query)
```

**Parameters:**
- `query` - Search term (URL encoded automatically)

**Returns:** List of matching `Movie` objects or `null` on error.

**API Endpoint:** `GET /search/movie?query={query}`

---

## TV Show Endpoints

### Get Popular Shows

Fetches popular TV shows.

```dart
Future<List<Movie>?> getPopularShows()
```

**Returns:** List of `Movie` objects (using Movie model for consistency).

**API Endpoint:** `GET /tv/popular`

---

### Get Top Rated TV

Fetches top-rated TV shows.

```dart
Future<List<Movie>?> getTopRatedTV()
```

**Returns:** List of `Movie` objects.

**API Endpoint:** `GET /tv/top_rated`

---

### Get Action Shows

Fetches action & adventure TV shows (genre ID: 10759).

```dart
Future<List<Movie>> getActionShows()
```

**Returns:** List of `Movie` objects.

**API Endpoint:** `GET /discover/tv?with_genres=10759`

---

### Get Comedy Shows

Fetches comedy TV shows (genre ID: 35).

```dart
Future<List<Movie>> getComedyShows()
```

**Returns:** List of `Movie` objects.

**API Endpoint:** `GET /discover/tv?with_genres=35`

---

### Get Drama Shows

Fetches drama TV shows (genre ID: 18).

```dart
Future<List<Movie>> getDramaShows()
```

**Returns:** List of `Movie` objects.

**API Endpoint:** `GET /discover/tv?with_genres=18`

---

### Get Animation Shows

Fetches animation TV shows (genre ID: 16).

```dart
Future<List<Movie>> getAnimationShows()
```

**Returns:** List of `Movie` objects.

**API Endpoint:** `GET /discover/tv?with_genres=16`

---

### Get Romance Shows

Fetches romance TV shows (genre ID: 10749).

```dart
Future<List<Movie>> getRomanceShows()
```

**Returns:** List of `Movie` objects.

**API Endpoint:** `GET /discover/tv?with_genres=10749`

---

### Search TV Shows

Searches for TV shows by query string.

```dart
Future<List<Movie>?> searchTVShow(String query)
```

**Parameters:**
- `query` - Search term (URL encoded automatically)

**Returns:** List of matching `Movie` objects or `null` on error.

**API Endpoint:** `GET /search/tv?query={query}`

---

## Data Models

### Movie Model

The `Movie` class represents both movies and TV shows.

```dart
class Movie {
  final int id;
  final String title;
  final double voteAverage;
  final String releaseDate;
  final String overview;
  final String posterPath;
}
```

**JSON Mapping:**

| Property | Movie JSON Field | TV Show JSON Field |
|----------|------------------|-------------------|
| `id` | `id` | `id` |
| `title` | `title` | `name` |
| `voteAverage` | `vote_average` | `vote_average` |
| `releaseDate` | `release_date` | `first_air_date` |
| `overview` | `overview` | `overview` |
| `posterPath` | `poster_path` | `poster_path` |

---

### Review Model

The `Review` class represents user reviews.

```dart
class Review {
  final int? id;
  final String movie;
  final String? user_id;
  final String? username;
  final String comment;
  final int? rating;
}
```

---

## Image URLs

Poster images are constructed using the TMDB image base URL:

```dart
String getPosterUrl(String posterPath) {
  return 'https://image.tmdb.org/t/p/w500$posterPath';
}
```

**Available sizes:** `w92`, `w154`, `w185`, `w342`, `w500`, `w780`, `original`

---

## Error Handling

All API methods handle errors gracefully:

- Network errors return `null` or empty list
- Invalid JSON responses are caught and logged
- Missing fields use default values (empty string, 0, etc.)

```dart
try {
  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    // Parse response
  } else {
    print('Request failed with status: ${response.statusCode}');
  }
} catch (e) {
  print('Error: $e');
  return null;
}
```

---

## Rate Limiting

TMDB API has rate limits:
- 40 requests per 10 seconds per IP address

The app handles this gracefully by:
- Caching results where appropriate
- Showing loading states during API calls
- Displaying error messages on failure

---

## Genre IDs Reference

### Movie Genres
| Genre | ID |
|-------|-----|
| Action | 28 |
| Comedy | 35 |
| Drama | 18 |
| Horror | 27 |
| Animation | 16 |
| Romance | 10749 |

### TV Show Genres
| Genre | ID |
|-------|-----|
| Action & Adventure | 10759 |
| Comedy | 35 |
| Drama | 18 |
| Animation | 16 |
| Romance | 10749 |
| Mystery | 9648 |
