import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:supabase_demo/helper/appconstant.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  final SupabaseClient supabase;

  RegisterCubit({SupabaseClient? supabaseClient})
    : supabase = supabaseClient ?? Supabase.instance.client,
      super(RegisterInitial());

  Future<void> register(
    String name,
    String address,
    String phoneNumber,
    File profilePic,
    String email,
    String password,
  ) async {
    emit(RegisterLoading());
    try {
      final result = await supabase.auth.signUp(email: email, password: password);
      if (result.user != null && result.session != null) {
        await supabase.storage.from(AppConstants.profileBucket).upload('Users/${result.user?.id}', profilePic);
        String url = supabase.storage.from(AppConstants.profileBucket).getPublicUrl('Users/${result.user?.id}');
        print('Url: $url');
        print('User ID: ${result.user!.id}');

        final user = result.user!;

        final insertData = {
          AppConstants.idKey: user.id,
          AppConstants.nameKey: name,
          AppConstants.addressKey: address,
          AppConstants.emailKey: email,
          AppConstants.phoneNumberKey: phoneNumber,
          AppConstants.profilePicKey: url,
        };
        await supabase.from(AppConstants.profilesTable).insert(insertData);
        emit(RegisterSuccess());
      } else {
        emit(const RegisterFailure('Registration failed: Unknown error'));
      }
    } catch (e) {
      print('Full error: $e'); // Print full error
      print('Error type: ${e.runtimeType}'); // Print error type
      emit(RegisterFailure(e.toString()));
    }
  }
}
