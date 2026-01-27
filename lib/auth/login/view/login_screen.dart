import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_demo/auth/login/bloc/login_cubit.dart';
import 'package:supabase_demo/auth/login/bloc/login_state.dart';
import 'package:supabase_demo/auth/register/view/register_screen.dart';
import 'package:supabase_demo/home_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../helper/assets_path.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final email = TextEditingController();
  final password = TextEditingController();
  bool _isPasswordVisible = false;
  final supabase = Supabase.instance.client;

  Future<void> continueWithGoogle() async {
    try{
      GoogleSignIn googleSignIn = GoogleSignIn.instance;
    await googleSignIn.initialize(
      serverClientId:dotenv.env['WEB_CLIENT'],
      clientId:Platform.isAndroid ? dotenv.env['ANDROID_CLIENT'] : dotenv.env['IOS_CLIENT'],
    );
    GoogleSignInAccount googleSignInAccount = await googleSignIn.authenticate();
    String idToken = googleSignInAccount.authentication.idToken ?? '';
    final authorization = await googleSignInAccount.authorizationClient.
                         authorizationForScopes(['email', 'profile']) ??
                         await googleSignInAccount.authorizationClient.
                         authorizeScopes(['email', 'profile']);

    final result = await supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken:authorization.accessToken,
    );
      if (result.user != null && result.session != null) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
                (context) => false);
      }
    } catch(e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginCubit(),
      child: Scaffold(
        body: SafeArea(
          child: BlocListener<LoginCubit, LoginState>(
            listener: (context, state) {
              if (state is LoginSuccess) {
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => HomeScreen()),
                    (context) => false);
              } else if (state is LoginFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              }
            },
            child: BlocBuilder<LoginCubit, LoginState>(
              builder: (context, state) {
                return Stack(
                  children: [
                    Center(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            spacing: 10,
                            children: [
                              Icon(
                                Icons.lock_person_rounded,
                                size: 100,
                                color: Colors.deepPurple,
                              ),
                              SizedBox(height: 10),
                              TextFormField(
                                controller: email,
                                decoration: InputDecoration(
                                  hintText: 'Email',
                                ),
                              ),
                              TextFormField(
                                controller: password,
                                textAlignVertical: TextAlignVertical.center,
                                obscureText: !_isPasswordVisible,
                                decoration: InputDecoration(
                                  hintText: 'Password',
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _isPasswordVisible = !_isPasswordVisible;
                                      });
                                    },
                                    icon: Icon(
                                      _isPasswordVisible
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 10),
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: state is LoginLoading
                                      ? null
                                      : () {
                                          FocusScope.of(context).unfocus();
                                          context.read<LoginCubit>().login(
                                                email.text,
                                                password.text,
                                              );
                                        },
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.deepPurple,
                                      foregroundColor: Colors.white),
                                  child: const Text(
                                    'Login',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                              ),

                              SizedBox(height: 5),

                              GestureDetector(
                                onTap: () {
                                  continueWithGoogle();
                                },
                                child: Row(
                                  spacing: 5,
                                  mainAxisAlignment:MainAxisAlignment.center,
                                  children: [
                                    Image.asset(AssetPath.googleLogo, height: 30),
                                    Text('Continue with Google')
                                  ],
                                ),
                              ),

                              SizedBox(height: 5),

                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => RegisterScreen()));
                                },
                                child: Text(
                                  "Don't have an account? Register",
                                  style: TextStyle(color: Colors.deepPurple),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (state is LoginLoading)
                      Container(
                        color: Colors.black54,
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
