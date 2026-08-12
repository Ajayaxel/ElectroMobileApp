import 'package:electro/core/theme/app_colors.dart';
import 'package:electro/core/utils/custom_toast.dart';
import 'package:electro/features/auth/presentation/widgets/register_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:electro/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:electro/features/auth/presentation/bloc/auth_event.dart';
import 'package:electro/features/auth/presentation/bloc/auth_state.dart';
import 'package:electro/features/auth/presentation/pages/vehicle_type_selection_screen.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isNavigating = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess && !_isNavigating) {
            _isNavigating = true;
            CustomToast.showSuccess(context, 'Registration Successful!');
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => const VehicleTypeSelectionScreen(),
              ),
              (route) => false,
            );
          } else if (state is AuthFailure) {
            CustomToast.showError(context, state.message);
          }
        },
        child: Column(
          children: [
            const SizedBox(height: 80),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.backgroundDark,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(48)),
                ),
                clipBehavior: Clip.antiAlias,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 30),
                      // Logo
                      Image.asset(
                        'assets/login/electro.png',
                        height: 40,
                        color: Colors.white,
                        errorBuilder: (context, error, stackTrace) =>
                            const Text(
                              'ELECTRO',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2,
                              ),
                            ),
                      ),
                      const SizedBox(height: 12),
                      // Subtitle
                      const Text(
                        'Sign in to power your EV, smarter & faster.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 30),
                      // Form
                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          return RegisterForm(
                            nameController: _nameController,
                            emailController: _emailController,
                            phoneController: _phoneController,
                            passwordController: _passwordController,
                            confirmPasswordController:
                                _confirmPasswordController,
                            isLoading: state is AuthLoading,
                            onRegister: () {
                              context.read<AuthBloc>().add(
                                RegisterRequested(
                                  name: _nameController.text.trim(),
                                  email: _emailController.text.trim(),
                                  phone: _phoneController.text.trim(),
                                  password: _passwordController.text,
                                  confirmPassword:
                                      _confirmPasswordController.text,
                                ),
                              );
                            },
                            onLogin: () {
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
