import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/auth_repositories.dart';
import 'data/repositories/user_repositories.dart';
import 'data/serivices/fcm_services.dart';
import 'firebase_options.dart';
import 'logic/blocs/auth/auth_bloc.dart';
import 'logic/blocs/user/user_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FCMService().init();
  runApp(const ChatApp());
}

class ChatApp extends StatelessWidget {
  const ChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc(AuthRepositories())),
        BlocProvider(create: (_) => UserBloc(UserRepositories())),
      ],
      child: MaterialApp.router(
        routerConfig: AppRouter.router,
        // theme: AppTheme.light,
        // darkTheme: AppTheme.dark,
      ),
    );
  }
}