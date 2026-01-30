import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_demo/auth/login/bloc/login_cubit.dart';
import 'package:supabase_demo/auth/login/bloc/login_state.dart';
import 'package:supabase_demo/auth/register/view/register_screen.dart';
import 'package:supabase_demo/helper/appconstant.dart';
import '../../../helper/assets_path.dart';
import '../../../shared/common_widget/common_textfield.dart';
import '../../phone/view/phonenumber_auth_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final email = TextEditingController();
  final password = TextEditingController();
  bool _isPasswordVisible = false;
  final _formKey = GlobalKey<FormState>();

  bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginCubit(),
      child: Scaffold(
        body: SafeArea(
          child: BlocListener<LoginCubit, LoginState>(
            listener: (context, state) {
              // Navigation handled by AuthGate
              if (state is MagicLinkSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Check your email for login link")));
              }

              if (state is MagicLinkFailure) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
              }

              if (state is LoginFailure) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
              }

              if (state is GoogleLoginFailure) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
              }

              if (state is AppleLoginFailure) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
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
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              spacing: 10,
                              children: [
                                Icon(Icons.lock_person_rounded, size: 100, color: Colors.deepPurple),
                                SizedBox(height: 10),
                                CustomTextField(
                                  controller: email,
                                  hint: AppConstants.email,
                                  keyboardType: TextInputType.emailAddress,
                                ),

                                SizedBox(height: 2),

                                CustomTextField(
                                  controller: password,
                                  hint: AppConstants.password,
                                  obscureText: !_isPasswordVisible,
                                  suffixIcon: IconButton(
                                    icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                                    onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                                  ),
                                ),

                                SizedBox(height: 2),

                                SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: ElevatedButton(
                                    onPressed: state is LoginLoading
                                        ? null
                                        : () {
                                            FocusScope.of(context).unfocus();

                                            final emailText = email.text.trim();
                                            final passwordText = password.text.trim();

                                            // Step 1: Validate Email
                                            if (emailText.isEmpty) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text(AppConstants.emailRequired),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                              return;
                                            }

                                            if (!isValidEmail(emailText)) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text(AppConstants.emailValidation),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                              return;
                                            }

                                            // Step 2: Validate Password ONLY if Email is valid
                                            if (passwordText.isEmpty) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text(AppConstants.passwordRequired),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                              return;
                                            }

                                            if (passwordText.length < 6) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text(AppConstants.passwordValidation),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                              return;
                                            }

                                            // Step 3: Call Login API
                                            context.read<LoginCubit>().login(emailText, passwordText);
                                          },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.deepPurple,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    child: const Text(AppConstants.login, style: TextStyle(fontSize: 16)),
                                  ),
                                ),

                                SizedBox(height: 5),

                                Row(
                                  children: [
                                    // Google Button
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          context.read<LoginCubit>().loginWithGoogle();
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                          decoration: BoxDecoration(
                                            border: Border.all(color: Colors.grey.shade300),
                                            borderRadius: BorderRadius.circular(10),
                                            color: Colors.white,
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Image.asset(AssetPath.googleLogo, height: 24),
                                              const SizedBox(width: 8),
                                              const Text(AppConstants.google),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(width: 12),

                                    // Apple Button
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          context.read<LoginCubit>().signInWithApple();
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                          decoration: BoxDecoration(
                                            border: Border.all(color: Colors.grey.shade300),
                                            borderRadius: BorderRadius.circular(10),
                                            color: Colors.black,
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.apple, color: Colors.white),
                                              const SizedBox(width: 8),
                                              const Text(AppConstants.apple, style: TextStyle(color: Colors.white)),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(height: 2),

                                Row(
                                  children: [
                                    // Magic Link Button
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          FocusScope.of(context).unfocus();
                                          if (email.text.isNotEmpty) {
                                            context.read<LoginCubit>().signInWithMagicLink(email.text);
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(SnackBar(content: Text("Magic link sent to your email")));
                                          } else {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(SnackBar(content: Text("Enter email first")));
                                          }
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                          decoration: BoxDecoration(
                                            border: Border.all(color: Colors.grey.shade300),
                                            borderRadius: BorderRadius.circular(10),
                                            color: Colors.white,
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.email, color: Colors.deepPurple),
                                              const SizedBox(width: 8),
                                              const Text("Magic Link"),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(width: 12),

                                    // Phone Number Button
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (context) => PhonenumberAuthScreen()),
                                          );
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                          decoration: BoxDecoration(
                                            border: Border.all(color: Colors.grey.shade300),
                                            borderRadius: BorderRadius.circular(10),
                                            color: Colors.green,
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.phone, color: Colors.white),
                                              const SizedBox(width: 8),
                                              const Text("Phone OTP", style: TextStyle(color: Colors.white)),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(height: 2),

                                TextButton(
                                  onPressed: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterScreen()));
                                  },
                                  child: Text(AppConstants.dontHaveAccount, style: TextStyle(color: Colors.deepPurple)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (state is LoginLoading ||
                        state is GoogleLoginLoading ||
                        state is AppleLoginLoading ||
                        state is MagicLinkLoading)
                      Container(
                        color: Colors.black54,
                        child: Center(child: CircularProgressIndicator()),
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
