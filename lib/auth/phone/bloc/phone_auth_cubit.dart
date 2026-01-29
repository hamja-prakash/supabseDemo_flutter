import 'package:bloc/bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'phone_auth_state.dart';

class PhoneAuthCubit extends Cubit<PhoneAuthState> {
  final SupabaseClient supabase;

  PhoneAuthCubit({SupabaseClient? supabaseClient})
      : supabase = supabaseClient ?? Supabase.instance.client,
        super(PhoneAuthInitial());

  Future<void> signInWithPhoneNo(String phoneNumber) async {
    emit(PhoneAuthLoading());
    try {
      await supabase.auth.signInWithOtp(
        phone: phoneNumber,
        channel: OtpChannel.sms,
      );
      emit(PhoneAuthCodeSent());
    } catch (e) {
      emit(PhoneAuthFailure(e.toString()));
    }
  }

  Future<void> verifyOTP(String phoneNumber, String token) async {
    emit(PhoneAuthVerifyLoading());
    try {
      final response = await supabase.auth.verifyOTP(
        phone: phoneNumber,
        token: token,
        type: OtpType.sms,
      );
      if (response.session != null) {
        emit(PhoneAuthVerified());
      } else {
        emit(const PhoneAuthVerifyFailure("Verification failed"));
      }
    } catch (e) {
      emit(PhoneAuthVerifyFailure(e.toString()));
    }
  }
}
