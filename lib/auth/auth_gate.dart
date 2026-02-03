import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_demo/auth/login/view/login_screen.dart';
import 'package:supabase_demo/splash/splash_screen.dart';
import '../notes/notes_list/view/note_list_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      // stream: Supabase.instance.client.from(AppConstants.notesTable).stream(primaryKey: [AppConstants.idKey]),
      builder: (context, snapshot) {
        // If waiting for the initial connection state, show Splash
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        }

        // Access the session from the snapshot data
        final session = snapshot.hasData ? snapshot.data!.session : null;

        if (session != null) {
          return NoteListScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
