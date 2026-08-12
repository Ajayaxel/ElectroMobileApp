import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:electro/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:electro/features/auth/presentation/bloc/auth_event.dart';
import 'package:electro/features/auth/presentation/bloc/auth_state.dart';
import 'package:electro/core/utils/custom_toast.dart';
import 'package:electro/widgets/custom_button.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _currentPasswordController;
  late TextEditingController _newPasswordController;
  bool _isNavigating = false;

  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthSuccess) {
      _nameController = TextEditingController(text: authState.user.name);
      _emailController = TextEditingController(text: authState.user.email);
      _phoneController = TextEditingController(text: authState.user.phone);
    } else {
      _nameController = TextEditingController();
      _emailController = TextEditingController();
      _phoneController = TextEditingController();
    }
    _currentPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _submitUpdate() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        UpdateProfileRequested(
          name: _nameController.text,
          email: _emailController.text,
          phone: _phoneController.text,
          currentPassword: _currentPasswordController.text,
          newPassword: _newPasswordController.text.isNotEmpty
              ? _newPasswordController.text
              : null,
          imagePath: _imageFile?.path,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess && !_isNavigating) {
          _isNavigating = true;
          CustomToast.showSuccess(context, 'Profile updated successfully');
          Navigator.pop(context);
        } else if (state is AuthFailure) {
          CustomToast.showError(context, state.message);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(title: const Text('Edit Profile'), elevation: 0),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildImagePicker(),
                const SizedBox(height: 32),
                _buildTextField(
                  controller: _nameController,
                  label: 'Full Name',
                  icon: Icons.person_outline_rounded,
                  validator: (value) => value == null || value.isEmpty
                      ? 'Name is required'
                      : null,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _emailController,
                  label: 'Email Address',
                  icon: Icons.email_outlined,
                  validator: (value) => value == null || !value.contains('@')
                      ? 'Enter a valid email'
                      : null,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _phoneController,
                  label: 'Phone Number',
                  icon: Icons.phone_outlined,
                ),
                const SizedBox(height: 32),
                const Divider(),
                const SizedBox(height: 24),
                _buildTextField(
                  controller: _currentPasswordController,
                  label: 'Current Password',
                  icon: Icons.lock_outline_rounded,
                  isPassword: true,
                  validator: (value) => value == null || value.isEmpty
                      ? 'Current password is required to save changes'
                      : null,
                  helperText: 'Required to verify your identity',
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _newPasswordController,
                  label: 'New Password (Optional)',
                  icon: Icons.lock_reset_rounded,
                  isPassword: true,
                  helperText: 'Leave empty to keep current password',
                ),
                const SizedBox(height: 40),
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    return CustomButton(
                      text: 'Save Changes',
                      onPressed: state is AuthLoading ? () {} : _submitUpdate,
                      isLoading: state is AuthLoading,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    final state = context.read<AuthBloc>().state;
    String? currentImageUrl;
    String name = 'User';
    if (state is AuthSuccess) {
      currentImageUrl = state.user.profileImage;
      name = state.user.name;
    }

    return Center(
      child: Stack(
        children: [
            Container(
              width: 120,
              height: 120,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFF8F9FD),
              ),
              child: ClipOval(
                child: _imageFile != null
                    ? Image.file(
                        _imageFile!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      )
                    : (currentImageUrl != null && currentImageUrl.isNotEmpty
                        ? Image.network(
                            currentImageUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            errorBuilder: (context, error, stackTrace) => Center(
                              child: Text(
                                name.isNotEmpty ? name.substring(0, 1).toUpperCase() : 'U',
                                style: const TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontFamily: 'Lufga',
                                ),
                              ),
                            ),
                          )
                        : Center(
                            child: Text(
                              name.isNotEmpty ? name.substring(0, 1).toUpperCase() : 'U',
                              style: const TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontFamily: 'Lufga',
                              ),
                            ),
                          )),
              ),
            ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: _pickImage,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    String? Function(String?)? validator,
    String? helperText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (helperText != null) ...[
          Text(
            helperText,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: controller,
          obscureText: isPassword,
          validator: validator,
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(icon, color: Colors.black54, size: 20),
            filled: true,
            fillColor: const Color(0xFFF8F9FD),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.black12, width: 1),
            ),
            labelStyle: const TextStyle(
              color: Colors.black54,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
