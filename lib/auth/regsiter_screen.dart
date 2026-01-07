import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:supabase_demo/home_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {

  final email = TextEditingController();
  final password = TextEditingController();
  bool _isPasswordVisible = false;
  bool loading = false;
  final supabase = Supabase.instance.client;

  Future<void> register() async {
    setState(() {
      loading = true;
    });
    try {
      final result = await supabase.auth.signUp(
          email: email.text,
          password: password.text);
      if (result.user != null && result.session != null) {
          Navigator.pushAndRemoveUntil(context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
                  (context) => false);
      }
    } catch (e) {
      print(e.toString());
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 10,
                children: [
                  Icon(
                    Icons.lock_person_rounded,
                    size: 100,
                    color: Colors.deepPurple,
                  ),

                  SizedBox(height: 10),

                  TextFormField(
                    controller: email,
                    decoration: InputDecoration(
                      hintText: 'Email',
                    ),
                  ),

                  TextFormField(
                    controller: password,
                    textAlignVertical: TextAlignVertical.center,
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      hintText: 'Password',
                      suffixIcon: IconButton(onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      }, icon: Icon(_isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,))

                    ),
                  ),

                  SizedBox( height: 10),

                  loading ? Center(child: CircularProgressIndicator()): SizedBox.shrink(),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        register();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white
                      ),
                      child: const Text(
                        'Register',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),

                  TextButton(onPressed: () {

                  }, child: Text("Already have an account? Login",
                  style: TextStyle(color: Colors.deepPurple),))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
