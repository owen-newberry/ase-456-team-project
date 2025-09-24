import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/movie.dart';
import '../model/review.dart';

class MovieDetail extends StatefulWidget {
  final Movie movie;
  MovieDetail(this.movie);

  @override
  _MovieDetailState createState() => _MovieDetailState();
}

class _MovieDetailState extends State<MovieDetail> {
  final String imgPath = 'https://image.tmdb.org/t/p/w500/';
  final TextEditingController user = TextEditingController();
  final TextEditingController comment = TextEditingController();

  List<Review> reviews = [];
  bool loading = false;

  @override
  void initState() {
    super.initState();
    fetchReviews();
  }

  Future<void> fetchReviews() async {
    setState(() => loading = true);

    final response = await Supabase.instance.client
        .from('user_reviews') // Supabase table name
        .select()
        .eq('movie', widget.movie.title);

    final data = response as List<dynamic>;
    final _reviews = data.map((json) => Review.fromJson(json)).toList();

    setState(() {
      reviews = _reviews;
      loading = false;
    });
  }

  Future<void> _addReview() async {
    if (user.text.isEmpty || comment.text.isEmpty) return;

    final newReview = {
      'movie': widget.movie.title,
      'user': user.text,
      'comment': comment.text,
    };

    final response =
        await Supabase.instance.client.from('user_reviews').insert(newReview);

    if (response is List && response.isNotEmpty) {
      user.clear();
      comment.clear();
      fetchReviews(); // refresh
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error adding review")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;

    // poster fallback
    String path = (widget.movie.posterPath != null)
        ? imgPath + widget.movie.posterPath
        : 'https://images.freeimages.com/images/large-previews/5eb/movie-clapboard-1184339.jpg';

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.movie.title),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Poster
              Container(
                padding: EdgeInsets.all(16),
                height: height / 1.5,
                child: Image.network(path),
              ),

              // Overview
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(widget.movie.overview),
              ),

              Divider(height: 30),

              // Review Form
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Add a Review!",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    TextField(
                      controller: user,
                      decoration: InputDecoration(labelText: "Your Username"),
                    ),
                    TextField(
                      controller: comment,
                      decoration: InputDecoration(labelText: "Your Review/Response"),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _addReview,
                      child: Text("Submit"),
                    ),
                  ],
                ),
              ),

              Divider(height: 30),

              // Reviews List
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text("Reviews",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              Container(
                height: 250, // fixed height so it scrolls independently
                child: loading
                    ? Center(child: CircularProgressIndicator())
                    : reviews.isEmpty
                        ? Center(child: Text("No reviews yet. Be the first!"))
                        : ListView.builder(
                            itemCount: reviews.length,
                            itemBuilder: (context, index) {
                              final r = reviews[index];
                              return Card(
                                child: ListTile(
                                  title: Text(r.user),
                                  subtitle: Text(r.comment),
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

