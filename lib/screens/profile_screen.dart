import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'personal_info_screen.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedAvatarIndex = 0;

  final List<Map<String, String>> avatars = [
    {'emoji': '👦', 'label': 'ولد'},
    {'emoji': '👧', 'label': 'بنت'},
    {'emoji': '🦸‍♂️', 'label': 'بطل'},
    {'emoji': '🦸‍♀️', 'label': 'بطلة'},
    {'emoji': '🤴', 'label': 'أمير'},
    {'emoji': '👸', 'label': 'أميرة'},
    {'emoji': '😎', 'label': 'رائع'},
    {'emoji': '🤓', 'label': 'ذكي'},
    {'emoji': '🌸', 'label': 'وردة'},
    {'emoji': '⭐', 'label': 'نجمة'},
    {'emoji': '🚀', 'label': 'صاروخ'},
    {'emoji': '🎨', 'label': 'فنان'},
    {'emoji': '🦁', 'label': 'أسد'},
    {'emoji': '🐼', 'label': 'باندا'},
    {'emoji': '🦄', 'label': 'يونيكورن'},
    {'emoji': '🎮', 'label': 'لاعب'},
  ];

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return const Scaffold(body: Center(child: Text('يرجى تسجيل الدخول أولاً')));
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('users').doc(currentUser.uid).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasError) {
          return const Scaffold(body: SizedBox.shrink());
        }

        final userDoc = snapshot.data?.data() ?? {};
        final userName = userDoc['displayName'] as String? ?? currentUser.displayName ?? 'طالب';
        final stars = userDoc['stars'] as int? ?? 0;
        final selectedAvatarIndex = userDoc['avatarIndex'] as int? ?? _selectedAvatarIndex;
        const taskTotal = 3;
        final completedStages = (userDoc['completedStages'] as Map<String, dynamic>?) ?? {};
        final tasksCompleted = completedStages.length.clamp(0, taskTotal);

        return Scaffold(
          body: Container(
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
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.centerRight,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.arrow_forward, color: Color(0xFF00C853)),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFFE8F5E9),
                              border: Border.all(color: Colors.white, width: 4),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                avatars[selectedAvatarIndex]['emoji']!,
                                style: const TextStyle(fontSize: 48),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            userName,
                            style: GoogleFonts.cairo(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF9000FF),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              _buildStatCard(
                                label: 'النجوم',
                                value: '$stars',
                                iconWidget: const Icon(Icons.star_border_rounded, color: Color(0xFFffb703), size: 32),
                                bgColor: const Color(0xFFFFF9C4),
                              ),
                              const SizedBox(width: 8),
                              _buildStatCard(
                                label: 'ميداليات',
                                value: '$tasksCompleted',
                                iconWidget: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.emoji_events_outlined, color: Color(0xFF9000FF), size: 28),
                                    Container(
                                      margin: const EdgeInsets.only(top: 4),
                                      width: 16,
                                      height: 16,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFD87D4A),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Center(
                                        child: Icon(Icons.star, color: Colors.white, size: 10),
                                      ),
                                    ),
                                  ],
                                ),
                                bgColor: const Color(0xFFF3E8FF),
                              ),
                              const SizedBox(width: 8),
                              _buildStatCard(
                                label: 'المراحل',
                                value: '$tasksCompleted/$taskTotal',
                                iconWidget: const Icon(Icons.track_changes, color: Color(0xFF00C853), size: 32),
                                bgColor: const Color(0xFFE8F5E9),
                                valueColor: const Color(0xFF00C853),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // شبكة اختيار الأفاتار
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            'اختر صورتك المفضلة',
                            style: GoogleFonts.cairo(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF9000FF),
                            ),
                          ),
                          const SizedBox(height: 20),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.85,
                            ),
                            itemCount: avatars.length,
                            itemBuilder: (context, index) {
                              final isSelected = selectedAvatarIndex == index;
                              return GestureDetector(
                                onTap: () async {
                                  await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).set({
                                    'avatarIndex': index,
                                  }, SetOptions(merge: true));
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  decoration: BoxDecoration(
                                    color: isSelected ? const Color(0xFFF3E8FF) : Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: isSelected ? Border.all(color: const Color(0xFF9000FF), width: 2) : Border.all(color: Colors.transparent, width: 2),
                                    boxShadow: isSelected
                                        ? []
                                        : [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.03),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        avatars[index]['emoji']!,
                                        style: const TextStyle(fontSize: 28),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        avatars[index]['label']!,
                                        style: GoogleFonts.cairo(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: isSelected ? const Color(0xFF9000FF) : const Color(0xFF333333),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const PersonalInfoScreen()),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.arrow_back_ios, color: Color(0xFF00C853), size: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'معلوماتي الشخصية',
                                    style: GoogleFonts.cairo(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF333333),
                                    ),
                                  ),
                                  Text(
                                    'عدّل بياناتك',
                                    style: GoogleFonts.cairo(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            const SizedBox(width: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.edit, color: Color(0xFF9000FF), size: 24),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => _logout(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE53935),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                        elevation: 4,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.logout, color: Colors.white),
                          const SizedBox(width: 12),
                          Text(
                            'تسجيل الخروج',
                            style: GoogleFonts.cairo(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required Widget iconWidget,
    required Color bgColor,
    Color? valueColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            iconWidget,
            if (value.isNotEmpty) const SizedBox(height: 8),
            if (value.isNotEmpty)
              Text(
                value,
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: valueColor ?? const Color(0xFFffb703),
                  height: 1.0,
                ),
              ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}