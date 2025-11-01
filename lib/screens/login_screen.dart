import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_services.dart';
import 'signup_screen.dart'; // Import the signup screen

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  bool _obscurePassword = true;
  bool _isLoading = false;
  final AuthService authService = AuthService();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Top gradient section
          SafeArea(
            bottom: false,
            child: Container(
              height: screenHeight * 0.42,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF3F51B5), Color(0xFF303F9F)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Center(
                child: Hero(
                  tag: 'app_logo',
                  child: Image.asset(
                    'assets/images/logo.png', // Make sure you have a logo here
                    height: 120,
                  ),
                ),
              ),
            ),
          ),
          // Bottom white card section
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: screenHeight * 0.65,
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
                  padding: const EdgeInsets.fromLTRB(24.0, 32.0, 24.0, 24.0),
                  child: Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome Back',
                          style: GoogleFonts.poppins(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Sign in to your account',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 28),
                        _buildTextField(
                          controller: _emailController,
                          hintText: 'Email',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          focusNode: _emailFocus,
                          onFieldSubmitted: (_) =>
                              _passwordFocus.requestFocus(),
                          validator: (value) {
                            final text = (value ?? '').trim();
                            if (text.isEmpty) return 'Please enter your email';
                            final emailRegex = RegExp(r'^\S+@\S+\.\S+$');
                            if (!emailRegex.hasMatch(text))
                              return 'Enter a valid email';
                            return null;
                          },
                        ),
                        const SizedBox(height: 18),
                        _buildTextField(
                          controller: _passwordController,
                          hintText: 'Password',
                          icon: Icons.lock_outline,
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.done,
                          focusNode: _passwordFocus,
                          onFieldSubmitted: (_) => _signIn(),
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
                          validator: (value) {
                            if ((value ?? '').isEmpty)
                              return 'Please enter your password';
                            if ((value ?? '').length < 6)
                              return 'Minimum 6 characters';
                            return null;
                          },
                        ),
                        const SizedBox(height: 28),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _signIn,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(
                                0xFFFFB300,
                              ), // Warm Yellow
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 1.5,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.6,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : Text(
                                    'Login',
                                    style: GoogleFonts.poppins(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildDivider(),
                        const SizedBox(height: 24),
                        _buildSocialLogin(),
                        const SizedBox(height: 28),
                        _buildSignupLink(context),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _signIn() async {
    if (!mounted) return;
    if (_formKey.currentState?.validate() != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please correct the highlighted fields'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await authService.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      // AuthWrapper will handle navigation on success
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: Colors.redAccent),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await authService.signInWithGoogle();
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: Colors.redAccent),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    FocusNode? focusNode,
    void Function(String)? onFieldSubmitted,
    String? Function(String?)? validator,
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
      focusNode: focusNode,
      onFieldSubmitted: onFieldSubmitted,
      validator: validator,
      style: GoogleFonts.poppins(fontSize: 15.5),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.grey[600]),
        suffixIcon: suffixIcon,
        hintText: hintText,
        hintStyle: GoogleFonts.poppins(color: Colors.grey[500]),
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
          vertical: 18,
          horizontal: 12,
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.grey[300])),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Text(
            'or continue with',
            style: GoogleFonts.poppins(color: Colors.grey[500]),
          ),
        ),
        Expanded(child: Divider(color: Colors.grey[300])),
      ],
    );
  }

  Widget _buildSocialLogin() {
    return Center(
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : _signInWithGoogle,
        icon: Image.asset('assets/images/google.png', height: 22.0),
        label: Text(
          'Sign in with Google',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.black87,
          backgroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: Colors.grey.shade300),
          ),
          elevation: 0,
        ),
      ),
    );
  }

  Widget _buildSignupLink(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account? ",
          style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 15),
        ),
        InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const SignupScreen()),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 4.0),
            child: Text(
              'Sign up',
              style: GoogleFonts.poppins(
                color: const Color(0xFF3F51B5),
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
