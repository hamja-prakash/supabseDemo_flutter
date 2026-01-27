import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final SupabaseClient supabase;

  LoginCubit({SupabaseClient? supabaseClient})
      : supabase = supabaseClient ?? Supabase.instance.client,
        super(LoginInitial());

  Future<void> login(String email, String password) async {
    emit(LoginLoading());
    try {
      final result = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (result.user != null && result.session != null) {
        emit(LoginSuccess());
      } else {
        emit(const LoginFailure('Login failed: Unknown error'));
      }
    } catch (e) {
      emit(LoginFailure(e.toString()));
    }
  }

  Future<void> loginWithGoogle() async {
    emit(GoogleLoginLoading());

    try {
      final googleSignIn = GoogleSignIn.instance;

      await googleSignIn.initialize(
        serverClientId: dotenv.env['WEB_CLIENT'],
        clientId: Platform.isAndroid
            ? dotenv.env['ANDROID_CLIENT']
            : dotenv.env['IOS_CLIENT'],
      );

      final googleUser = await googleSignIn.authenticate();
      final googleAuth = googleUser.authentication;

      final authClient = googleUser.authorizationClient;
      final authorization = await authClient.authorizationForScopes(['email', 'profile']) ??
          await authClient.authorizeScopes(['email', 'profile']);

      final result = await supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: googleAuth.idToken!,
        accessToken: authorization.accessToken,
      );

      if (result.user != null) {
        emit(GoogleLoginSuccess());
      } else {
        emit(const GoogleLoginFailure("Google login failed"));
      }
    } catch (e) {
      emit(GoogleLoginFailure(e.toString()));
    }
  }
}
