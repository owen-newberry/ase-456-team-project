class Review {
  final int? id;
  final String movie;
  final String? user_id; // changed from 'user' to 'user_id'
  final String comment;

  Review({
    this.id,
    required this.movie,
    this.user_id,
    required this.comment,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      movie: json['movie'],
      user_id: json['user_id'], // match the column in Supabase
      comment: json['comment'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'movie': movie,
      'user_id': user_id,
      'comment': comment,
    };
  }
}
