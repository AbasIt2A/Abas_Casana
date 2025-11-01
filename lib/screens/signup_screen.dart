import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../services/auth_services.dart';
import '../services/database_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final AuthService _authService = AuthService();
  final DatabaseService _dbService = DatabaseService();
  final ImagePicker _imagePicker = ImagePicker();

  bool _obscurePassword = true;
  bool _agreeToTerms = false;
  String _selectedCountryCode = '+1';
  bool _isLoading = false;
  File? _profileImage;

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
      );
      if (image != null) {
        setState(() {
          _profileImage = File(image.path);
        });
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  bool _hasEightChars = false;
  bool _hasUppercase = false;
  bool _hasNumber = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _validatePassword(String password) {
    setState(() {
      _hasEightChars = password.length >= 8;
      _hasUppercase = password.contains(RegExp(r'[A-Z]'));
      _hasNumber = password.contains(RegExp(r'[0-9]'));
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Top gradient section with logo
          SafeArea(
            bottom: false,
            child: Container(
              height: screenHeight * 0.35,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF3F51B5), Color(0xFF303F9F)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  _buildHeader(),
                  const SizedBox(height: 20),
                  Hero(
                    tag: 'app_logo',
                    child: Image.asset(
                      'assets/images/logo.png',
                      height: 80,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Bottom white card section
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: screenHeight * 0.72,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(child: _buildProfilePicturePicker()),
                      const SizedBox(height: 16),
                      Text(
                        'Create Account',
                        style: GoogleFonts.poppins(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Join thousands of users today',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _fullNameController,
                        hintText: 'Full Name',
                        icon: Icons.person_outline,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _emailController,
                        hintText: 'Email',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _passwordController,
                        hintText: 'Password',
                        icon: Icons.lock_outline,
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.next,
                        onChanged: _validatePassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: Colors.grey[500],
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildPasswordCriteriaCompact('8+ chars', _hasEightChars),
                          _buildPasswordCriteriaCompact('Uppercase', _hasUppercase),
                          _buildPasswordCriteriaCompact('Number', _hasNumber),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildPhoneField(),
                      const SizedBox(height: 12),
                      _buildTermsCheckbox(),
                      const SizedBox(height: 16),
                      _buildCreateAccountButton(),
                      const SizedBox(height: 12),
                      _buildSignInLink(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    void Function(String)? onChanged,
  }) {
    final baseBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
    );

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onChanged: onChanged,
      style: GoogleFonts.poppins(fontSize: 14.5),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.grey[600], size: 20),
        suffixIcon: suffixIcon,
        hintText: hintText,
        hintStyle: GoogleFonts.poppins(color: Colors.grey[500], fontSize: 14),
        filled: true,
        fillColor: Colors.grey[100],
        enabledBorder: baseBorder,
        focusedBorder: baseBorder.copyWith(
          borderSide: const BorderSide(color: Color(0xFF3F51B5), width: 1.2),
        ),
        errorBorder: baseBorder.copyWith(
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: baseBorder.copyWith(
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 12,
        ),
        isDense: true,
      ),
    );
  }

  Widget _buildProfilePicturePicker() {
    return GestureDetector(
      onTap: _pickImage,
      child: Center(
        child: Stack(
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(color: Colors.white, width: 3),
                image: _profileImage != null
                    ? DecorationImage(
                        image: FileImage(_profileImage!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: _profileImage == null
                  ? Icon(
                      Icons.person_outline,
                      size: 45,
                      color: Colors.grey[400],
                    )
                  : null,
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Color(0xFF3F51B5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildPasswordCriteriaCompact(String text, bool isMet) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isMet ? Icons.check_circle : Icons.radio_button_unchecked,
          color: isMet ? Colors.green : Colors.grey[400],
          size: 14,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: GoogleFonts.poppins(
            color: isMet ? Colors.green : Colors.grey[600],
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneField() {
    final baseBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
    );

    return Row(
      children: [
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButton<String>(
            value: _selectedCountryCode,
            underline: const SizedBox(),
            items: <String>['+1', '+63', '+44', '+91'].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedCountryCode = newValue;
                });
              }
            },
            icon: const Icon(Icons.arrow_drop_down, size: 20),
            iconSize: 20,
            elevation: 2,
            style: GoogleFonts.poppins(
              color: Colors.grey[800],
              fontSize: 14.5,
            ),
            dropdownColor: Colors.white,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.done,
            style: GoogleFonts.poppins(fontSize: 14.5),
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.phone_outlined, color: Colors.grey[600], size: 20),
              hintText: 'Phone Number',
              hintStyle: GoogleFonts.poppins(color: Colors.grey[500], fontSize: 14),
              filled: true,
              fillColor: Colors.grey[100],
              enabledBorder: baseBorder,
              focusedBorder: baseBorder.copyWith(
                borderSide: const BorderSide(color: Color(0xFF3F51B5), width: 1.2),
              ),
              errorBorder: baseBorder.copyWith(
                borderSide: const BorderSide(color: Colors.redAccent),
              ),
              focusedErrorBorder: baseBorder.copyWith(
                borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 14,
                horizontal: 12,
              ),
              isDense: true,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      children: [
        SizedBox(
          height: 20,
          width: 20,
          child: Checkbox(
            value: _agreeToTerms,
            onChanged: (bool? value) {
              setState(() {
                _agreeToTerms = value ?? false;
              });
            },
            activeColor: const Color(0xFF3F51B5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: GoogleFonts.poppins(
                color: Colors.grey[700],
                fontSize: 12,
              ),
              children: <TextSpan>[
                const TextSpan(text: 'I agree to the '),
                TextSpan(
                  text: 'Terms of Service',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF3F51B5),
                    fontWeight: FontWeight.w600,
                  ),
                  recognizer: TapGestureRecognizer()..onTap = () {},
                ),
                const TextSpan(text: ' and '),
                TextSpan(
                  text: 'Privacy Policy',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF3F51B5),
                    fontWeight: FontWeight.w600,
                  ),
                  recognizer: TapGestureRecognizer()..onTap = () {},
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCreateAccountButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading
            ? null
            : () async {
                if (!_agreeToTerms) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Please agree to the Terms of Service and Privacy Policy',
                      ),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                  return;
                }

                if (!_hasEightChars || !_hasUppercase || !_hasNumber) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Please ensure your password meets all requirements',
                      ),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                  return;
                }

                setState(() {
                  _isLoading = true;
                });

                try {
                  final phoneNumber =
                      '$_selectedCountryCode${_phoneController.text}';
                  final AuthResponse? authResponse = await _authService
                      .signUpWithEmailAndPassword(
                        email: _emailController.text.trim(),
                        password: _passwordController.text,
                        fullName: _fullNameController.text.trim(),
                        phoneNumber: phoneNumber,
                      );

                  // Upload profile picture if selected
                  if (authResponse?.user != null && _profileImage != null) {
                    final String? imageUrl = await _dbService
                        .uploadProfilePicture(
                          _profileImage!,
                          authResponse!.user!.id,
                        );

                    if (imageUrl != null) {
                      await _dbService.updateUserProfile(
                        userId: authResponse.user!.id,
                        profilePicUrl: imageUrl,
                      );
                    }
                  }

                  if (mounted) {
                    // Show success message and navigate to login
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Account created successfully! Please log in.',
                        ),
                      ),
                    );
                    Navigator.pop(context); // Go back to login screen
                  }
                } on AuthException catch (e) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(
                    content: Text(e.message),
                    backgroundColor: Colors.redAccent,
                  ));
                } finally {
                  if (mounted) {
                    setState(() {
                      _isLoading = false;
                    });
                  }
                }
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFB300), // Warm Yellow - matching login
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 1.5,
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.6,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.white,
                  ),
                ),
              )
            : Text(
                'Create Account',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }

  Widget _buildSignInLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Already have an account? ",
          style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 13),
        ),
        InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: () {
            Navigator.of(context).pop(); // Go back to the login screen
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 4.0),
            child: Text(
              'Sign In',
              style: GoogleFonts.poppins(
                color: const Color(0xFF3F51B5),
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
