
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/screens/auth/login_screen.dart';


class AppRouter {
  static final GoRouter _router = GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      // GoRoute(
      //   path: '/home',
      //   name: 'home',
      //   builder: (context, state) => const HomeScreen(), // Replace with your home
      // ),
      // Add more routes
      // GoRoute(
      //   path: '/profile',
      //   name: 'profile',
      //   builder: (context, state) => const ProfileScreen(),
      // ),
    ],
    // Optional: Error handling
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Page not found: ${state.uri}')),
    ),
    // Optional: Redirect (e.g., if logged in, skip login)
    redirect: (context, state) {
      // Add auth logic: final bool isLoggedIn = ...;
      // if (isLoggedIn && state.uri.toString() == '/login') return '/home';
      return null;
    },
  );

  static RouterConfig<Object> get router => _router;
}