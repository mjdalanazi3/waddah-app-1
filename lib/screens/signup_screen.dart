import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  bool _emailTouched = false;
  bool _passwordTouched = false;
  bool _confirmTouched = false;

  static const Color primaryPurple = Color(0xFF7B2FBE);
  static const Color primaryGreen = Color(0xFF00C950);
  static const Color fieldBorder = Color(0xFFD1B3F0);
  static const Color iconColor = Color(0xFFAD46FF);
  static const Color errorColor = Color(0xFFE53935);
  static const Color successColor = Color(0xFF00C950);

  bool get _emailValid {
    final email = _emailController.text;
    return RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,}$').hasMatch(email);
  }

  bool get _hasMinLength => _passwordController.text.length >= 8;
  bool get _hasNumber => _passwordController.text.contains(RegExp(r'[0-9]'));
  bool get _passwordValid => _hasMinLength && _hasNumber;

  bool get _passwordsMatch =>
      _passwordController.text == _confirmPasswordController.text &&
      _confirmPasswordController.text.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(() => setState(() => _emailTouched = true));
    _passwordController
        .addListener(() => setState(() => _passwordTouched = true));
    _confirmPasswordController
        .addListener(() => setState(() => _confirmTouched = true));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_emailValid || !_passwordValid || !_passwordsMatch) return;

    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(
              userName: _nameController.text.trim(),
            ),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'email-already-in-use') {
        message = 'البريد الإلكتروني مستخدم بالفعل، يرجى تسجيل الدخول';
      } else if (e.code == 'invalid-email') {
        message = 'البريد الإلكتروني غير صالح';
      } else if (e.code == 'weak-password') {
        message = 'كلمة المرور ضعيفة جدًا';
      } else {
        message = 'حدث خطأ: ${e.code}';
      }

      if (mounted) {
showDialog(
  context: context,
  builder: (context) => Directionality(
    textDirection: TextDirection.rtl,
    child: AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      contentPadding: const EdgeInsets.all(24),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 36,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'تنبيه',
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1A1A1A),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            message,
            style: GoogleFonts.cairo(
              fontSize: 15,
              color: const Color(0xFF666666),
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
              ),
              child: Text(
                'حسنًا',
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  ),
);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildRequirement(String text, bool met) {
    return Row(
      textDirection: TextDirection.rtl,
      children: [
        Icon(
          met ? Icons.check_circle : Icons.cancel,
          size: 15,
          color: met ? successColor : errorColor,
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: GoogleFonts.cairo(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: met ? successColor : errorColor,
          ),
        ),
      ],
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool obscure = false,
    VoidCallback? onToggle,
    bool? isValid,
    bool touched = false,
  }) {
    Color borderColor = fieldBorder.withOpacity(0.7);
    if (touched && isValid != null) {
      borderColor = isValid ? successColor : errorColor;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Directionality(
          textDirection: TextDirection.rtl,
          child: Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF333333),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.55),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor, width: 1.5),
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword ? obscure : false,
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            style: GoogleFonts.cairo(
              fontSize: 15,
              color: const Color(0xFF333333),
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.cairo(
                color: const Color(0xFF888888).withOpacity(0.7),
                fontSize: 15,
              ),
              hintTextDirection: TextDirection.rtl,
              prefixIcon: isPassword
                  ? IconButton(
                      icon: Icon(
                        obscure
                            ? Icons.lock_outline
                            : Icons.lock_open_outlined,
                        color: iconColor,
                        size: 22,
                      ),
                      onPressed: onToggle,
                    )
                  : Icon(icon, color: iconColor, size: 22),
              suffixIcon: touched && isValid != null
                  ? Icon(
                      isValid ? Icons.check_circle : Icons.cancel,
                      color: isValid ? successColor : errorColor,
                      size: 20,
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 15,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFC9A8F0),
              Color(0xFFA8E8C8),
              Color(0xFFC0CDE0),
              Color(0xFFC9A8F0),
            ],
            stops: [0.0, 0.35, 0.65, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 8),

                    // Logo
                    Image.asset('assets/UI/RoundLogo.png', height: 115),

                    const SizedBox(height: 8),

                    // Title
                    Text(
                      'انضم إلى وضاح!',
                      style: GoogleFonts.cairo(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF9000FF)
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 4),

                    // Subtitle
                    Text(
                      'أنشئ حسابك وابدأ التعلم',
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        color: const Color(0xFF666666),
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 20),

                    // Full Name
                    _buildField(
                      controller: _nameController,
                      label: 'الاسم الكامل',
                      hint: 'أدخل اسمك',
                      icon: Icons.person_outline,
                    ),

                    const SizedBox(height: 10),

                    // Email
                    _buildField(
                      controller: _emailController,
                      label: 'البريد الإلكتروني',
                      hint: 'أدخل بريدك الإلكتروني',
                      icon: Icons.mail_outline,
                      isValid: _emailValid,
                      touched: _emailTouched,
                    ),
                    if (_emailTouched && !_emailValid) ...[
                      const SizedBox(height: 6),
                      Directionality(
                        textDirection: TextDirection.rtl,
                        child: Row(
                          children: [
                            const Icon(Icons.cancel,
                                size: 15, color: errorColor),
                            const SizedBox(width: 6),
                            Text(
                              'يرجى إدخال بريد إلكتروني صحيح',
                              style: GoogleFonts.cairo(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: errorColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 10),

                    // Password
                    _buildField(
                      controller: _passwordController,
                      label: 'كلمة المرور',
                      hint: 'أنشئ كلمة المرور',
                      icon: Icons.lock_outline,
                      isPassword: true,
                      obscure: _obscurePassword,
                      onToggle: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                      isValid: _passwordValid,
                      touched: _passwordTouched,
                    ),
                    if (_passwordTouched) ...[
                      const SizedBox(height: 8),
                      Directionality(
                        textDirection: TextDirection.rtl,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildRequirement(
                                '8 أحرف على الأقل', _hasMinLength),
                            const SizedBox(height: 4),
                            _buildRequirement(
                                'رقم واحد على الأقل', _hasNumber),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 10),

                    // Confirm Password
                    _buildField(
                      controller: _confirmPasswordController,
                      label: 'تأكيد كلمة المرور',
                      hint: 'أكد كلمة المرور',
                      icon: Icons.lock_outline,
                      isPassword: true,
                      obscure: _obscureConfirm,
                      onToggle: () =>
                          setState(() => _obscureConfirm = !_obscureConfirm),
                      isValid: _passwordsMatch,
                      touched: _confirmTouched,
                    ),
                    if (_confirmTouched) ...[
                      const SizedBox(height: 6),
                      Directionality(
                        textDirection: TextDirection.rtl,
                        child: _buildRequirement(
                          _passwordsMatch
                              ? 'كلمتا المرور متطابقتان'
                              : 'كلمتا المرور غير متطابقتين',
                          _passwordsMatch,
                        ),
                      ),
                    ],

                    const SizedBox(height: 20),

                    // Sign Up Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _signUp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryGreen,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : Text(
                                'إنشاء حساب',
                                style: GoogleFonts.cairo(
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Login link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'لديك حساب بالفعل؟',
                          style: GoogleFonts.cairo(
                            color: const Color(0xFF666666),
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () {  Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                                );
                              },
                          child: Text(
                            'تسجيل الدخول',
                            style: GoogleFonts.cairo(
                              color: primaryGreen,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}