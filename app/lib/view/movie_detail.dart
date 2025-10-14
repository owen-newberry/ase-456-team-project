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
  final TextEditingController commentController = TextEditingController();

  List<Review> reviews = [];
  bool loading = false;
  String? movieStatus; // tracks current user's movie status

  @override
  void initState() {
    super.initState();
    fetchReviews();
    fetchStatus();
  }

  // Fetch reviews for this movie
  Future<void> fetchReviews() async {
    setState(() => loading = true);

    final response = await Supabase.instance.client
        .from('user_reviews')
        .select()
        .eq('movie', widget.movie.title);

    final data = response as List<dynamic>;
    final _reviews = data.map((json) => Review.fromJson(json)).toList();

    setState(() {
      reviews = _reviews;
      loading = false;
    });
  }

  // Fetch current user's movie status
  Future<void> fetchStatus() async {
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser == null) return;

    final response = await Supabase.instance.client
        .from('users_movies')
        .select('status')
        .eq('user_id', currentUser.id)
        .eq('movie_title', widget.movie.title)
        .maybeSingle();

    if (response != null && response['status'] != null) {
      setState(() {
        movieStatus = response['status'];
      });
    }
  }

  // Update watched / want-to-watch status
  Future<void> updateStatus(String status) async {
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please log in first")),
      );
      return;
    }

    await Supabase.instance.client.from('users_movies').upsert({
      'user_id': currentUser.id,
      'movie_title': widget.movie.title,
      'status': status,
    });

    setState(() {
      movieStatus = status;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Marked as $status")),
    );
  }

  // Add a review using logged-in user
  Future<void> _addReview() async {
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please log in to submit a review")),
      );
      return;
    }

    if (commentController.text.isEmpty) return;

    final newReview = {
      'movie': widget.movie.title,
      'user_id': currentUser.id, 
      'comment': commentController.text,
    };

    final response = await Supabase.instance.client
        .from('user_reviews')
        .insert(newReview)
        .select();

    if (response is List && response.isNotEmpty) {
      commentController.clear();
      fetchReviews();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error adding review")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
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
            children: [
              // Poster
              Container(
                padding: EdgeInsets.all(16),
                height: height / 1.5,
                child: Image.network(path),
              ),

              // Overview
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(widget.movie.overview),
              ),

              const Divider(height: 30),

              // Watched / Want to Watch buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      icon: Icon(
                        Icons.check_circle,
                        color: movieStatus == 'watched'
                            ? Colors.green
                            : Colors.white,
                      ),
                      label: const Text("Watched"),
                      onPressed: () => updateStatus('watched'),
                    ),
                    ElevatedButton.icon(
                      icon: Icon(
                        Icons.star,
                        color: movieStatus == 'want_to_watch'
                            ? Colors.amber
                            : Colors.white,
                      ),
                      label: const Text("Want to Watch"),
                      onPressed: () => updateStatus('want_to_watch'),
                    ),
                  ],
                ),
              ),

              const Divider(height: 30),

              // Review Form
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Add a Review!",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    TextField(
                      controller: commentController,
                      decoration:
                          const InputDecoration(labelText: "Your Review"),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _addReview,
                      child: const Text("Submit"),
                    ),
                  ],
                ),
              ),

              const Divider(height: 30),

              // Reviews List
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: const Text("Reviews",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              Container(
                height: 250,
                child: loading
                    ? const Center(child: CircularProgressIndicator())
                    : reviews.isEmpty
                        ? const Center(
                            child: Text("No reviews yet. Be the first!"))
                        : ListView.builder(
                            itemCount: reviews.length,
                            itemBuilder: (context, index) {
                              final r = reviews[index];
                              return Card(
                                child: ListTile(
                                  title: Text(r.user_id ?? "Anonymous"),
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

