import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Wait for Firebase to restore persisted session
    await FirebaseAuth.instance.authStateChanges().first;
    //                                              ↑
    // .first waits for the FIRST emission from the stream.
    // Firebase always emits either User or null within ~300ms on startup.

    if (!mounted) return;

    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      context.goNamed('home');   // already logged in → skip login
    } else {
      context.goNamed('login');  // not logged in → show login
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          children: [
            CircularProgressIndicator(),
            Text("data")
          ],
        ),
      ),
    );
  }
}