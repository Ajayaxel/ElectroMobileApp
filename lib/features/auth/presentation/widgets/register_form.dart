import 'package:electro/core/theme/app_colors.dart';
import 'package:electro/widgets/custom_button.dart';
import 'package:flutter/material.dart';

class RegisterForm extends StatefulWidget {
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool isLoading;
  final VoidCallback onRegister;
  final VoidCallback onLogin;

  const RegisterForm({
    super.key,
    required this.nameController,
    required this.emailController,
    required this.phoneController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.isLoading,
    required this.onRegister,
    required this.onLogin,
  });

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Name Field
        _buildLabel('Name'),
        const SizedBox(height: 8),
        _buildTextField(
          controller: widget.nameController,
          hint: 'Enter your name',
        ),
        const SizedBox(height: 16),

        // Phone Number Field
        _buildLabel('Phone Number'),
        const SizedBox(height: 8),
        _buildTextField(
          controller: widget.phoneController,
          hint: 'Enter your phone number',
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),

        // Email Address Field
        _buildLabel('Email Address'),
        const SizedBox(height: 8),
        _buildTextField(
          controller: widget.emailController,
          hint: 'Enter your email id',
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),

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
        const SizedBox(height: 16),

        // Confirm Password Field
        _buildLabel('Confirm Password'),
        const SizedBox(height: 8),
        _buildTextField(
          controller: widget.confirmPasswordController,
          hint: 'Confirm Password',
          isPassword: true,
          obscureText: _obscureConfirmPassword,
          onToggleVisibility: () {
            setState(() {
              _obscureConfirmPassword = !_obscureConfirmPassword;
            });
          },
        ),
        const SizedBox(height: 30),

        // Sign in Button (Wait, image says Sign in but it's the register action)
        CustomButton(
          text: 'Sign in',
          isLoading: widget.isLoading,
          onPressed: widget.onRegister,
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
            onTap: widget.onLogin,
            child: RichText(
              text: const TextSpan(
                style: TextStyle(color: Colors.grey, fontSize: 14),
                children: [
                  TextSpan(text: "Already have an account ? "),
                  TextSpan(
                    text: 'Login',
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
        const SizedBox(height: 20),
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
    TextInputType keyboardType = TextInputType.text,
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
        keyboardType: keyboardType,
        textAlignVertical: TextAlignVertical.center,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          isCollapsed: true,
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
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
