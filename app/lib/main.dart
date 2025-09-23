import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:p3_movie/view/movie_list.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://pcmnadxqjllhftgmjhjg.supabase.co', // replace with your Supabase URL
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBjbW5hZHhxamxsaGZ0Z21qaGpnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTg1NDQwMzksImV4cCI6MjA3NDEyMDAzOX0.OLeOApXyMNKOqi1nc60o0ULbZlwH1W13k05UJMjrSGk', // replace with your Supabase anon/public key
  );

  runApp(MyMovies());
}

class MyMovies extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Movies',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
      ),
      home: AuthPage(), // start with login/signup
    );
  }
}

/// AuthPage: handles login and signup
class AuthPage extends StatefulWidget {
  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLogin = true; // toggle between login and signup

  Future<void> handleAuth() async {
    final auth = Supabase.instance.client.auth;

    try {
      if (isLogin) {
        final res = await auth.signInWithPassword(
          email: emailController.text,
          password: passwordController.text,
        );
        if (res.session != null) {
          // go to MovieList after login
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => MovieList()),
          );
        }
      } else {
        final res = await auth.signUp(
          email: emailController.text,
          password: passwordController.text,
        );
        if (res.user != null) {
          // after signup, you can log them in automatically or require confirmation
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => MovieList()),
          );
        }
      }
    } on AuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isLogin ? 'Login' : 'Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: handleAuth,
              child: Text(isLogin ? 'Login' : 'Sign Up'),
            ),
            TextButton(
              onPressed: () => setState(() => isLogin = !isLogin),
              child: Text(isLogin
                  ? "Don't have an account? Sign Up"
                  : "Already have an account? Login"),
            ),
          ],
        ),
      ),
    );
  }
}
