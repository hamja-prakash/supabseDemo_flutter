import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_demo/auth/register/bloc/register_cubit.dart';
import 'package:supabase_demo/auth/register/bloc/register_state.dart';
import 'package:supabase_demo/auth/login/view/login_screen.dart';

import '../../../helper/appconstant.dart';
import '../../../shared/common_widget/common_textfield.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final name = TextEditingController();
  final email = TextEditingController();
  final country = TextEditingController();
  final city = TextEditingController();
  final street = TextEditingController();
  final postalCode = TextEditingController();
  final phone = TextEditingController();
  final password = TextEditingController();
  File? profileImage;
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RegisterCubit(),
      child: Scaffold(
        body: SafeArea(
          child: BlocListener<RegisterCubit, RegisterState>(
            listener: (context, state) {
              if (state is RegisterSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registration successful')));
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (context) => false,
                );
              } else if (state is RegisterFailure) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
              }
            },
            child: BlocBuilder<RegisterCubit, RegisterState>(
              builder: (context, state) {
                return Stack(
                  children: [
                    Center(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            spacing: 10,
                            children: [
                              // const Icon(
                              //   Icons.lock_person_rounded,
                              //   size: 100,
                              //   color: Colors.deepPurple,
                              // ),
                              // const SizedBox(height: 2),
                              GestureDetector(
                                onTap: () async {
                                  final selectedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
                                  if (selectedImage != null) {
                                    setState(() {
                                      profileImage = File(selectedImage.path);
                                    });
                                  }
                                },
                                child: CircleAvatar(
                                  radius: 80,
                                  backgroundImage: profileImage == null ? null : FileImage(profileImage!),
                                ),
                              ),

                              const SizedBox(height: 2),

                              CustomTextField(controller: name, hint: AppConstants.name),

                              const SizedBox(height: 2),

                              CustomTextField(
                                controller: email,
                                hint: AppConstants.email,
                                keyboardType: TextInputType.emailAddress,
                              ),

                              const SizedBox(height: 2),

                              CustomTextField(controller: country, hint: AppConstants.country),

                              const SizedBox(height: 2),

                              CustomTextField(controller: city, hint: AppConstants.city),

                              const SizedBox(height: 2),

                              CustomTextField(controller: street, hint: AppConstants.street),

                              const SizedBox(height: 2),

                              CustomTextField(controller: postalCode, hint: AppConstants.postalCode),

                              const SizedBox(height: 2),

                              CustomTextField(
                                controller: phone,
                                hint: AppConstants.phoneNo,
                                keyboardType: TextInputType.phone,
                              ),

                              const SizedBox(height: 2),

                              CustomTextField(
                                controller: password,
                                hint: AppConstants.password,
                                obscureText: !_isPasswordVisible,
                                suffixIcon: IconButton(
                                  icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                                  onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                                ),
                              ),

                              const SizedBox(height: 2),

                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: state is RegisterLoading
                                      ? null
                                      : () {
                                          if (profileImage == null) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('Please select a profile image')),
                                            );
                                            return;
                                          }

                                          if (name.text.trim().isEmpty) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(const SnackBar(content: Text('Please enter your name')));
                                            return;
                                          }

                                          if (email.text.trim().isEmpty) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(const SnackBar(content: Text('Please enter your email')));
                                            return;
                                          }

                                          if (country.text.trim().isEmpty) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(const SnackBar(content: Text('Please enter your country')));
                                            return;
                                          }

                                          if (city.text.trim().isEmpty) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(const SnackBar(content: Text('Please enter your city')));
                                            return;
                                          }

                                          if (street.text.trim().isEmpty) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(const SnackBar(content: Text('Please enter your street')));
                                            return;
                                          }

                                          if (postalCode.text.trim().isEmpty) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(const SnackBar(content: Text('Please enter your postalCode')));
                                            return;
                                          }

                                          if (phone.text.trim().isEmpty) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('Please enter your phone number')),
                                            );
                                            return;
                                          }

                                          if (password.text.trim().isEmpty) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(const SnackBar(content: Text('Please enter your password')));
                                            return;
                                          }

                                          FocusScope.of(context).unfocus();
                                          context.read<RegisterCubit>().register(
                                            name.text,
                                            phone.text,
                                            profileImage!,
                                            email.text,
                                            password.text,
                                            country.text,
                                            city.text,
                                            street.text,
                                            postalCode.text,
                                          );
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.deepPurple,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),

                                  child: const Text('Register', style: TextStyle(fontSize: 16)),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text(
                                  "Already have an account? Login",
                                  style: TextStyle(color: Colors.deepPurple),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (state is RegisterLoading)
                      Container(
                        color: Colors.black54,
                        child: const Center(child: CircularProgressIndicator()),
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
