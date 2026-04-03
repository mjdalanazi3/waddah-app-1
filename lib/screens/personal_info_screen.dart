import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _ageController;
  late TextEditingController _parentPhoneController;

  bool _isLoading = false;
  bool _isFetching = true;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    _nameController = TextEditingController(text: user?.displayName ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _ageController = TextEditingController();
    _parentPhoneController = TextEditingController();
    _loadFirestoreData();
  }

  Future<void> _loadFirestoreData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final data = doc.data() ?? {};
      if (mounted) {
        setState(() {
          _ageController.text = data['age'] as String? ?? '';
          _parentPhoneController.text = data['parentPhone'] as String? ?? '';
          _isFetching = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isFetching = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    _parentPhoneController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      _showSnackBar('يرجى إدخال الاسم', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Update display name — wrapped separately so a transient network
      // error here doesn't abort the Firestore save.
      try {
        await user.updateDisplayName(name);
      } on FirebaseAuthException catch (e) {
        debugPrint('⚠️ updateDisplayName FirebaseAuthException: ${e.code} - ${e.message}');
      } catch (e) {
        debugPrint('⚠️ updateDisplayName error: $e');
      }

      // Update Firestore
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'displayName': name,
        'age': _ageController.text.trim(),
        'parentPhone': _parentPhoneController.text.trim(),
      }, SetOptions(merge: true));

      if (mounted) _showSnackBar('تم حفظ التغييرات بنجاح ✅');
    } on FirebaseException catch (e) {
      debugPrint('❌ Firestore error: ${e.code} - ${e.message}');
      String msg = 'حدث خطأ أثناء الحفظ';
      if (e.code == 'permission-denied') {
        msg = 'خطأ في صلاحيات Firestore — تحقق من القواعد في Firebase Console';
      } else if (e.code == 'unavailable') {
        msg = 'لا يوجد اتصال بالإنترنت';
      }
      if (mounted) _showSnackBar(msg, isError: true);
    } catch (e) {
      debugPrint('❌ _saveChanges unexpected error: $e');
      if (mounted) _showSnackBar('خطأ: ${e.runtimeType}', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _showChangePasswordDialog() async {
    final currentPasswordCtrl = TextEditingController();
    final newPasswordCtrl = TextEditingController();
    final confirmPasswordCtrl = TextEditingController();
    bool obscureCurrent = true;
    bool obscureNew = true;
    bool obscureConfirm = true;
    bool dialogLoading = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: Text(
              'تغيير كلمة المرور',
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: const Color(0xFF9000FF)),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dialogPasswordField(
                  controller: currentPasswordCtrl,
                  label: 'كلمة المرور الحالية',
                  obscure: obscureCurrent,
                  onToggle: () => setDialogState(() => obscureCurrent = !obscureCurrent),
                ),
                const SizedBox(height: 12),
                _dialogPasswordField(
                  controller: newPasswordCtrl,
                  label: 'كلمة المرور الجديدة',
                  obscure: obscureNew,
                  onToggle: () => setDialogState(() => obscureNew = !obscureNew),
                ),
                const SizedBox(height: 12),
                _dialogPasswordField(
                  controller: confirmPasswordCtrl,
                  label: 'تأكيد كلمة المرور',
                  obscure: obscureConfirm,
                  onToggle: () => setDialogState(() => obscureConfirm = !obscureConfirm),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: dialogLoading ? null : () => Navigator.pop(ctx),
                child: Text('إلغاء', style: GoogleFonts.cairo(color: Colors.grey)),
              ),
              ElevatedButton(
                onPressed: dialogLoading
                    ? null
                    : () async {
                        final newPass = newPasswordCtrl.text;
                        final confirmPass = confirmPasswordCtrl.text;
                        final currentPass = currentPasswordCtrl.text;

                        if (currentPass.isEmpty || newPass.isEmpty || confirmPass.isEmpty) {
                          _showSnackBar('يرجى ملء جميع الحقول', isError: true);
                          return;
                        }
                        if (newPass != confirmPass) {
                          _showSnackBar('كلمتا المرور غير متطابقتان', isError: true);
                          return;
                        }
                        if (newPass.length < 6) {
                          _showSnackBar('كلمة المرور يجب أن تكون 6 أحرف على الأقل', isError: true);
                          return;
                        }

                        setDialogState(() => dialogLoading = true);
                        try {
                          final user = FirebaseAuth.instance.currentUser!;
                          final credential = EmailAuthProvider.credential(
                            email: user.email!,
                            password: currentPass,
                          );
                          await user.reauthenticateWithCredential(credential);
                          await user.updatePassword(newPass);
                          if (mounted) Navigator.pop(ctx);
                          if (mounted) _showSnackBar('تم تغيير كلمة المرور بنجاح 🔐');
                        } on FirebaseAuthException catch (e) {
                          setDialogState(() => dialogLoading = false);
                          String msg = 'حدث خطأ أثناء تغيير كلمة المرور';
                          if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
                            msg = 'كلمة المرور الحالية غير صحيحة';
                          }
                          if (mounted) _showSnackBar(msg, isError: true);
                        } catch (_) {
                          setDialogState(() => dialogLoading = false);
                          if (mounted) _showSnackBar('حدث خطأ غير متوقع', isError: true);
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9000FF),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: dialogLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Text('تغيير', style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          );
        });
      },
    );
  }

  Widget _dialogPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: GoogleFonts.cairo(fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.cairo(fontSize: 13, color: Colors.grey),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        suffixIcon: IconButton(
          icon: Icon(obscure ? Icons.visibility_off : Icons.visibility, size: 20, color: Colors.grey),
          onPressed: onToggle,
        ),
      ),
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: isError ? Colors.redAccent : const Color(0xFF00C853),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE9D4FF),
              Color(0xFFB9F8CF),
              Color(0xFFE9D4FF),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2))],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_forward, color: Color(0xFF00C853)),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ],
                ),
              ),

              // Main Card
              Expanded(
                child: _isFetching
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(32),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'معلوماتي الشخصية',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.cairo(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF1E293B),
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Editable Fields
                              _buildInputField(
                                label: 'الاسم',
                                controller: _nameController,
                                icon: Icons.person_outline,
                                enabled: true,
                              ),
                              _buildInputField(
                                label: 'البريد الإلكتروني',
                                controller: _emailController,
                                icon: Icons.mail_outline,
                                enabled: false, // Email change requires special flow
                              ),
                              _buildInputField(
                                label: 'العمر',
                                controller: _ageController,
                                icon: Icons.calendar_today_outlined,
                                enabled: true,
                                keyboardType: TextInputType.number,
                              ),
                              _buildInputField(
                                label: 'رقم ولي الأمر',
                                controller: _parentPhoneController,
                                icon: Icons.phone_outlined,
                                enabled: true,
                                keyboardType: TextInputType.phone,
                              ),

                              // Password row (non-editable inline, uses dialog)
                              _buildPasswordRow(),

                              const SizedBox(height: 8),

                              // Save Button
                              ElevatedButton(
                                onPressed: _isLoading ? null : _saveChanges,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF00C853),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  elevation: 4,
                                  shadowColor: const Color(0xFF00C853).withValues(alpha: 0.4),
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        height: 22,
                                        width: 22,
                                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                                      )
                                    : Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'حفظ التغييرات',
                                            style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(width: 8),
                                          const Text('💾', style: TextStyle(fontSize: 20)),
                                        ],
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool enabled = true,
    TextInputType? keyboardType,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: enabled ? const Color(0xFFF9FAFB) : const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF475569), size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF64748B),
                  ),
                ),
                TextField(
                  controller: controller,
                  enabled: enabled,
                  keyboardType: keyboardType,
                  style: GoogleFonts.cairo(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: enabled ? const Color(0xFF333333) : const Color(0xFF888888),
                  ),
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            decoration: BoxDecoration(
              color: enabled ? const Color(0xFF9000FF) : Colors.grey.shade400,
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(8),
            child: Icon(enabled ? Icons.edit : Icons.lock_outline, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordRow() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(Icons.lock_outline, color: Color(0xFF475569), size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'كلمة المرور',
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF64748B),
                  ),
                ),
                Text(
                  '••••••••',
                  style: GoogleFonts.cairo(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF333333),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: _showChangePasswordDialog,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF9000FF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'تغيير',
                style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }
}