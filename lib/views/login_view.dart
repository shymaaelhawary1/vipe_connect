import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vipe_connect/views/HomeLayout.dart';
import 'package:vipe_connect/views/community_view.dart';
import '../controllers/auth_cubit.dart';
import '../controllers/auth_state.dart';
import 'register_view.dart';

class LoginView extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthCubit(),
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/login_bg.png',
              fit: BoxFit.cover,
            ),
            SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32.0, vertical: 80),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 150),
                    _buildTextField("Email", emailController),
                    const SizedBox(height: 16),
                    _buildTextField("Password", passwordController,
                        isPassword: true),
                    const SizedBox(height: 30),
                    BlocConsumer<AuthCubit, AuthState>(
                      listener: (context, state) {
                        if (state is AuthSuccess) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Login Success!')),
                          );
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const HomeLayout()),
                          );
                        } else if (state is AuthFailure) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(state.message)),
                          );
                        }
                      },
                      builder: (context, state) {
                        if (state is AuthLoading) {
                          return const CircularProgressIndicator(
                              color: Colors.white);
                        }
                        return ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[800],
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          onPressed: () {
                            final email = emailController.text.trim();
                            final password = passwordController.text.trim();
                            context.read<AuthCubit>().login(email, password);
                          },
                          child: const Text("Log in",
                              style:
                                  TextStyle(fontSize: 24, color: Colors.white)),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (_) => RegisterView()));
                      },
                      child: const Text(
                        "Don’t have an account? Sign up",
                        style: TextStyle(color: Colors.white70),
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String hint, TextEditingController controller,
      {bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withOpacity(0.2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
