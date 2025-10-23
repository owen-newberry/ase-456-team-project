class Movie {
  late int id;
  late String title;
  late double voteAverage;
  late String releaseDate;
  late String overview;
  late String posterPath;

  Movie(
      {required this.id,
      required this.title,
      required this.voteAverage,
      required this.releaseDate,
      required this.overview,
      required this.posterPath});

  Movie.fromJson(Map<String, dynamic> parsedJson) {
    id= parsedJson['id'] ?? 0;

    title = parsedJson['title'] ?? parsedJson['name'] ?? 'Untitled';

    var vote = parsedJson['vote_average'];
    if (vote is int) {
      voteAverage = vote.toDouble();
    } else if (vote is double) {
      voteAverage = vote;
    } else {
      voteAverage = 0.0;
    }

    releaseDate = parsedJson['release_date'] ?? parsedJson['first_air_date'] ?? 'Unknown';

    overview = parsedJson['overview'] ?? '';
    posterPath = parsedJson['poster_path'] ?? '';
  }
}
