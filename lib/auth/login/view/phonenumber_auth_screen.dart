import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:supabase_demo/auth/login/bloc/login_cubit.dart';
import 'package:supabase_demo/auth/login/bloc/login_state.dart';
import 'package:supabase_demo/helper/appconstant.dart';

import '../../../home_screen.dart';

class PhonenumberAuthScreen extends StatelessWidget {
  const PhonenumberAuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginCubit(),
      child: const _PhoneNumberAuthView(),
    );
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
    if (_formKey.currentState!.validate()) {
      context.read<LoginCubit>().signInWithPhoneNo(_phoneController.text);
    }
  }

  void _verifyOtp(String otp) {
    context.read<LoginCubit>().verifyOTP(_phoneController.text, otp);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        // title: const Text("Phone Authentication"),
      ),
      body: BlocListener<LoginCubit, LoginState>(
          listener: (context, state) {
            if (state is OTPFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Error: ${state.message}")),
              );
            } else if (state is OTPVerifyFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Verification Error: ${state.message}")),
              );
            } else if (state is OTPSuccess) {
              setState(() {
                _isOtpSent = true;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text(AppConstants.otpSuccessSent)),
              );
            }
            else if (state is OTPVerifySuccess) {
              Navigator.of(context).pop();
            }
          },
          child: BlocBuilder<LoginCubit, LoginState>(
            builder: (context, state) {
              final isLoading = state is OTPLoading || state is OTPVerifyLoading;
              return Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Icon(
                          Icons.phonelink_lock_rounded,
                          size: 80,
                          color: Colors.deepPurple,
                        ),
                        const SizedBox(height: 32),

                        if (!_isOtpSent) ...[
                          const Text(
                            AppConstants.enterPhoneNoToContinue,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),

                          const SizedBox(height: 24),

                          TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              labelText: AppConstants.phoneNo,
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.phone),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return AppConstants.enterPhoneNo;
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 24),

                          SizedBox(
                            height: 50,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : _sendOtp,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                                  : const Text(AppConstants.sendOTP),
                            ),
                          ),
                        ] else
                          ...[
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
              );
            },
          )
      ),
    );
  }
}
