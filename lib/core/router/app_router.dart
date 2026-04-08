
import 'package:chatapp/presentation/screens/auth/forgrtten_screen.dart';
import 'package:chatapp/presentation/screens/auth/home_screen.dart';
import 'package:chatapp/presentation/screens/chat/new_chatscreen.dart' hide NewChatScreen;
import 'package:chatapp/presentation/screens/splash/splash_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/signup_screen.dart';
import '../../presentation/screens/chat/chatscreen.dart';


class AppRouter {
  static final GoRouter _router = GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(path: '/forgot',
      name: 'forgot',
        builder: (context, state) => const ForgotPasswordScreen(),),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(path: '/newchatscreen',
      name: 'newchatscreen',
      builder: (context, state) => const NewChatScreen()),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(), // Replace with your home
      ),

      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(path: '/splash',
      name: 'splash',
      builder: (context, state) => const SplashScreen(),),
      // GoRoute (path: '/chats',
      // name: 'chats',
      // builder: (context,state ) =>ChatScreen(roomId: '1',),),
      //

    ],
    // Optional: Error handling
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Page not found: ${state.uri}')),
    ),
    // Optional: Redirect (e.g., if logged in, skip login)
    redirect: (context, state) {
      final isLoggedIn = FirebaseAuth.instance.currentUser != null;
      final path = state.uri.path;
      final isAuthPage = path == '/login' || path == '/signup';
      final isSplash = path == '/splash';


      if (isLoggedIn && isAuthPage) return '/newchatscreen';
      if (isLoggedIn && isSplash) return '/newchatscreen';



      // Add auth logic: final bool isLoggedIn = ...;
      // if (isLoggedIn && state.uri.toString() == '/login') return '/home';
      return null;
    },
  );

  static RouterConfig<Object> get router => _router;
}