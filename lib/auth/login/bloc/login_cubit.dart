import 'package:bloc/bloc.dart';
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
}
