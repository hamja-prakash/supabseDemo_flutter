import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:supabase_demo/auth/phone/bloc/phone_auth_cubit.dart';
import 'package:supabase_demo/auth/phone/bloc/phone_auth_state.dart';
import 'package:supabase_demo/helper/appconstant.dart';
import '../../../shared/common_widget/common_textfield.dart';

class PhonenumberAuthScreen extends StatelessWidget {
  const PhonenumberAuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (context) => PhoneAuthCubit(), child: const _PhoneNumberAuthView());
  }
}

class _PhoneNumberAuthView extends StatefulWidget {
  const _PhoneNumberAuthView();

  @override
  State<_PhoneNumberAuthView> createState() => _PhoneNumberAuthViewState();
}

class _PhoneNumberAuthViewState extends State<_PhoneNumberAuthView> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  bool _isOtpSent = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _sendOtp() {
    FocusScope.of(context).unfocus();

    final phone = _phoneController.text.trim();

    // Step 1: Check Empty
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppConstants.enterPhoneNo), backgroundColor: Colors.red),
      );
      return;
    }

    // Step 2: Send OTP
    context.read<PhoneAuthCubit>().signInWithPhoneNo(phone);
  }


  void _verifyOtp(String otp) {
    context.read<PhoneAuthCubit>().verifyOTP(_phoneController.text, otp);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
        // title: const Text("Phone Authentication"),
      ),
      body: BlocListener<PhoneAuthCubit, PhoneAuthState>(
        listener: (context, state) {
          if (state is PhoneAuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: ${state.message}")));
          } else if (state is PhoneAuthVerifyFailure) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Verification Error: ${state.message}")));
          } else if (state is PhoneAuthCodeSent) {
            setState(() {
              _isOtpSent = true;
            });
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text(AppConstants.otpSuccessSent)));
          } else if (state is PhoneAuthVerified) {
            Navigator.of(context).pop();
          }
        },
        child: BlocBuilder<PhoneAuthCubit, PhoneAuthState>(
          builder: (context, state) {
            final isLoading = state is PhoneAuthLoading || state is PhoneAuthVerifyLoading;
            return Center(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Icon(Icons.phonelink_lock_rounded, size: 80, color: Colors.deepPurple),
                        const SizedBox(height: 32),

                        if (!_isOtpSent) ...[
                          const Text(
                            AppConstants.enterPhoneNoToContinue,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),

                          const SizedBox(height: 24),

                          CustomTextField(
                            controller: _phoneController,
                            hint: AppConstants.phoneNo,
                            keyboardType: TextInputType.phone,
                            prefixIcon: Icon(Icons.phone),
                          ),

                          const SizedBox(height: 24),

                          SizedBox(
                            height: 50,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : _sendOtp,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                    )
                                  : const Text(AppConstants.sendOTP),
                            ),
                          ),
                        ] else ...[
                          Text(
                            "Enter the code sent to ${_phoneController.text}",
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                          const SizedBox(height: 24),
                          OtpTextField(
                            numberOfFields: 6,
                            borderColor: Colors.deepPurple,
                            showFieldAsBox: true,
                            fieldWidth: 45,
                            borderRadius: BorderRadius.circular(8),
                            textStyle: const TextStyle(fontSize: 18, color: Colors.black),
                            margin: const EdgeInsets.symmetric(horizontal: 4.0),
                            onSubmit: (String verificationCode) {
                              _verifyOtp(verificationCode);
                            }, // end onSubmit
                          ),
                          const SizedBox(height: 24),
                          // Verify Button (Optional if onSubmit handles it, but good for UX)
                          if (isLoading)
                            const Center(child: CircularProgressIndicator())
                          else
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _isOtpSent = false;
                                });
                              },
                              child: const Text(AppConstants.changePhoneNo),
                            ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
