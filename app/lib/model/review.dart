class Review {
  final int? id;
  final String movie;
  final String? user_id;
  final String? username;
  final String comment;
  final int? rating;

  Review({
    this.id,
    required this.movie,
    this.user_id,
    this.username,
    required this.comment,
    this.rating,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      movie: json['movie'],
      user_id: json['user_id'],
      username: json['username'],
      comment: json['comment'],
      rating: json['rating'], 
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'movie': movie,
      'user_id': user_id,
      'username': username,
      'comment': comment,
      'rating': rating, 
    };
  }
}
