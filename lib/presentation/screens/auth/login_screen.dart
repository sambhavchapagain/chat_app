import 'package:chatapp/core/constants/app_string.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../logic/blocs/auth/auth_bloc.dart';
import '../../widgets/custom_loading_widget.dart'; // Import the colors class



class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}


class _LoginScreenState extends State<LoginScreen> {
  final _emailController  = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }


  @override

  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,

      body: BlocListener<AuthBloc, AuthState>(
  listener: (context, state) {
    if(state.authStatus == AuthStatus.authenticated){
   return   context.goNamed('home');

    }
    if(state.authStatus == AuthStatus.loading){
      customLoadingWidget(context: context);

    }
    if(state.authStatus == AuthStatus.unauthenticated){
      context.pop();

    }
  },
  child: SafeArea(child:Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                AppStrings.loginTitle,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryText,
                ),
              ),
              const SizedBox(height: 48),
              TextField(controller: _emailController,
                decoration: InputDecoration(
                  hintText:AppStrings.enterEmailHint,
                  hintStyle: TextStyle(color: AppColors.grey500),
                  filled: true,
                  fillColor: AppColors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.grey200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.primaryBlue, width: 2),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(controller: _passwordController,
                obscureText: _obscurePassword,
                onChanged: (value) {
                  setState(() {
                    _obscurePassword = value.isEmpty;
                  });
                },
                decoration: InputDecoration(
                  hintText: AppStrings.passwordHint,
                  suffixIcon: Icon(Icons.visibility_off, color: AppColors.grey400),
                  hintStyle: TextStyle(color: AppColors.grey500),
                  filled: true,
                  fillColor: AppColors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.grey200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.primaryBlue, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Forgot password?',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    context.read<AuthBloc>().add(EmailSignInRequested(email:_emailController.text.trim(), password:_passwordController.text.trim()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
              ),

              const SizedBox(height: 24),
              _SocialButton(
                icon: Image.asset('assets/images/apple_logo.png', height: 24, width: 24),
                text: 'Login with Apple',
                onPressed: () {},
              ),
              const SizedBox(height: 16),
              _SocialButton(
                icon: Image.asset('assets/images/google_logo.png', height: 24, width: 24),
                text: 'Login with Google',
                onPressed: () {context.read<AuthBloc>().add(GoogleSignInRequested());

                },
              ),
              const Spacer(),
              Center(
                child: TextButton(
                  onPressed: () {
                    context.goNamed("signup");
                  },
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(color: AppColors.grey600, fontSize: 16),
                      children: [
                        const TextSpan(text: "Don't have an account? "),
                        const TextSpan(
                          text: 'Sign up',
                          style: TextStyle(
                            color: AppColors.primaryBlue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ))));

  }
}

class _SocialButton extends StatelessWidget {
  final Widget icon;
  final String text;
  final VoidCallback onPressed;

  const _SocialButton({
    required this.icon,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: icon,
        label:  Text(
          text,
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppColors.grey300),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}