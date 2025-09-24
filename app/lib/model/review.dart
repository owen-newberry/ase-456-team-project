class Review {
  final int? id;
  final String movie;
  final String user;
  final String comment;

  Review ({
    this.id,
    required this.movie,
    required this.user,
    required this.comment
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      movie: json['movie'],
      user: json['user'],
      comment: json['comment'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'movie': movie,
      'user': user,
      'comment': comment,
    };
  }
}