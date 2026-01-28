import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:supabase_demo/home_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../auth/login/view/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final supabase = Supabase.instance.client;
  bool _redirected = false;
  late final StreamSubscription<AuthState> _authSubscription;

  @override
  void initState() {
    super.initState();
    _redirect();
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }

  Future<void> _redirect() async {
    // Check initial session
    final session = supabase.auth.currentSession;
    if (session != null) {
      _navigateToHome();
      return;
    }

    // Listen for auth state changes (e.g. from magic link deep link)
    _authSubscription = supabase.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      print("Auth State Change: $event");
      if (event == AuthChangeEvent.signedIn ||
          event == AuthChangeEvent.passwordRecovery) {
        _navigateToHome();
      }
    });

    // If no session found quickly and no deep link event immediately, show login
    await Future.delayed(const Duration(seconds: 3));
    if (mounted && !_redirected) {
      if (supabase.auth.currentSession == null) {
        _navigateToLogin();
      } else {
        _navigateToHome();
      }
    }
  }

  void _navigateToHome() {
    print("Scheduling navigation to Home...");
    if (_redirected || !mounted) {
       return;
    }
    _redirected = true;
    
    Future.delayed(Duration.zero, () {
      if (mounted) {
        print("Executing navigation to Home...");
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => HomeScreen()));
      }
    });
  }

  void _navigateToLogin() {
    print("Scheduling navigation to Login...");
    if (_redirected || !mounted) {
       return;
    }
    _redirected = true;
    
    Future.delayed(Duration.zero, () {
      if (mounted) {
         print("Executing navigation to Login...");
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => LoginScreen()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child:
        FlutterLogo(size: 100),
      ),
    );
  }
}
