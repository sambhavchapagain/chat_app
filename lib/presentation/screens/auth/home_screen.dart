import 'package:chatapp/presentation/widgets/custom_loading_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../logic/blocs/auth/auth_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if(state.logoutStatus== LogoutStatus.loading){
          customLoadingWidget(context: context,title: "logout");
          

        }
        if(state.logoutStatus== LogoutStatus.logoutSucess){
          context.pushReplacementNamed('login');

        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(centerTitle: true, title: Text("Signup"),),
            body: Column(
              children: [
                Center(
                  child: ClipRRect(
                      borderRadius: BorderRadiusGeometry.circular(50),
                      child: Image.network("${state.value?.user?.photoURL}")),
                ), Center(
                  child: Text("Email: ${state.value?.user?.email}"),
                ),Center(
                  child: Text("Name: ${state.value?.user?.displayName}"),
                ),Center(
                  child: Text("PhoneNumber: ${state.value?.user?.phoneNumber}"),
                ),

                ElevatedButton(onPressed: () {
                  context.read<AuthBloc>().add(SignOutRequested());
                }, child: Text("log out"))
              ],
            ),
          );;
        },
      ),
    );
  }
}
