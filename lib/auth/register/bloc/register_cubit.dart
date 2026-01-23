import 'package:bloc/bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  final SupabaseClient supabase;

  RegisterCubit({SupabaseClient? supabaseClient})
      : supabase = supabaseClient ?? Supabase.instance.client,
        super(RegisterInitial());

  Future<void> register(String email, String password) async {
    emit(RegisterLoading());
    try {
      final result = await supabase.auth.signUp(
        email: email,
        password: password,
      );
      if (result.user != null && result.session != null) {
        emit(RegisterSuccess());
      } else {
          emit(const RegisterFailure('Registration failed: Unknown error'));
        }
    } catch (e) {
      emit(RegisterFailure(e.toString()));
    }
  }
}
