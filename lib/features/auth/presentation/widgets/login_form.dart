import 'package:electro/core/theme/app_colors.dart';
import 'package:electro/widgets/custom_button.dart';
import 'package:flutter/material.dart';

class LoginForm extends StatefulWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isLoading;
  final VoidCallback onLogin;
  final VoidCallback onRegister;

  const LoginForm({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.isLoading,
    required this.onLogin,
    required this.onRegister,
  });

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Email Field
        _buildLabel('Email/Phone'),
        const SizedBox(height: 8),
        _buildTextField(
          controller: widget.emailController,
          hint: 'Email or phone number',
        ),
        const SizedBox(height: 20),

        // Password Field
        _buildLabel('Password'),
        const SizedBox(height: 8),
        _buildTextField(
          controller: widget.passwordController,
          hint: 'Password',
          isPassword: true,
          obscureText: _obscurePassword,
          onToggleVisibility: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
        const SizedBox(height: 12),

        // Forgot Password
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Forgot Password?',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ),
        const SizedBox(height: 30),

        // Login Button
        CustomButton(
          text: 'Login',
          isLoading: widget.isLoading,
          onPressed: widget.onLogin,
          backgroundColor: AppColors.accentTeal,
        ),
        const SizedBox(height: 30),

        // Divider
        Row(
          children: [
            Expanded(child: Divider(color: Colors.grey.withValues(alpha: 0.3))),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Or continue with',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ),
            Expanded(child: Divider(color: Colors.grey.withValues(alpha: 0.3))),
          ],
        ),
        const SizedBox(height: 30),

        // Social Buttons
        Row(
          children: [
            Expanded(
              child: _buildSocialButton(
                'Google',
                'assets/login/google.png',
                () {},
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildSocialButton(
                'Apple',
                'assets/login/apple.png',
                () {},
              ),
            ),
          ],
        ),
        const SizedBox(height: 40),

        // Footer
        Center(
          child: GestureDetector(
            onTap: widget.onRegister,
            child: RichText(
              text: const TextSpan(
                style: TextStyle(color: Colors.grey, fontSize: 14),
                children: [
                  TextSpan(text: "Don't have an account ? "),
                  TextSpan(
                    text: 'Sign in',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggleVisibility,
  }) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.fieldBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        textAlignVertical: TextAlignVertical.center,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          isCollapsed: true,
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical:
                14, // Adjusted for perfect vertical centering in 48px height
          ),
          suffixIcon: isPassword
              ? IconButton(
                  padding: EdgeInsets.zero,
                  icon: Icon(
                    obscureText
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: Colors.grey,
                    size: 20,
                  ),
                  onPressed: onToggleVisibility,
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildSocialButton(String text, String iconPath, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(100),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: AppColors.socialButtonBg,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(iconPath, height: 20, color: Colors.white),
            const SizedBox(width: 12),
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
