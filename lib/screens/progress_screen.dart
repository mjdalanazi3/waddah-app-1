import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_screen.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Scaffold(body: Center(child: Text('يجب تسجيل الدخول')));
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFFF8F9FE),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final data = snapshot.data?.data() as Map<String, dynamic>?;
        final int stars = (data?['stars'] as int?) ?? 0;
        final String userName = (data?['displayName'] as String?) ?? 'ضيف';

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FE),
          body: Column(
            children: [
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color.fromRGBO(0, 166, 62, 1),
                      Color.fromRGBO(152, 16, 250, 1),
                    ],
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.only(
                        top: 12, left: 24, right: 24, bottom: 20),
                    child: Column(
                      children: [
                        // Back button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.arrow_forward,
                                    color: Color(0xFF00C853)),
                                onPressed: () {
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            HomeScreen(userName: userName)),
                                    (route) => false,
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        // Trophy icon
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.emoji_events,
                              color: Color(0xFFffb703), size: 40),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'نجومي وميدالياتي',
                          style: GoogleFonts.cairo(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'رائع يا $userName',
                          style: GoogleFonts.cairo(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Stars card
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '$stars',
                                    style: GoogleFonts.cairo(
                                      color: const Color(0xFF00C853),
                                      fontSize: 42,
                                      fontWeight: FontWeight.bold,
                                      height: 1.1,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.star_rounded,
                                      color: Color(0xFFffb703), size: 36),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'الوصول للتالي: ${stars < 50 ? 50 : stars < 100 ? 100 : stars < 200 ? 200 : "200+"} نجمة',
                                style: GoogleFonts.cairo(
                                  color: Colors.grey[600],
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Medals section ───────────────────────────────────────────
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                  child: Column(
                    children: [
                      // Title
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'ميدالياتي',
                            style: GoogleFonts.cairo(
                              color: const Color(0xFF9000FF),
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.emoji_events,
                              color: Color(0xFFffb703), size: 24),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Three medal cards evenly distributed
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildMedalCard(
                              title: 'ميدالية برونزية',
                              isLocked: stars < 50,
                              pointsLabel: '50+',
                              subText1: 'حصلت على 50+',
                              subText2: 'البداية - 99 نجمة',
                              activeBgColor: const Color(0xFFFFE0B2),
                              activeBorderColor: const Color(0xFFE65100),
                              activeIconBgColor: const Color(0xFFD87D4A),
                            ),
                            _buildMedalCard(
                              title: 'ميدالية فضية',
                              isLocked: stars < 100,
                              pointsLabel: '100+',
                              subText1: 'حصلت على 100+',
                              subText2: '100 - 199 نجمة',
                              activeBgColor: const Color(0xFFF1F5F9),
                              activeBorderColor: const Color(0xFF94A3B8),
                              activeIconBgColor: const Color(0xFF64748B),
                            ),
                            _buildMedalCard(
                              title: 'ميدالية ذهبية',
                              isLocked: stars < 200,
                              pointsLabel: '200+',
                              subText1: 'حصلت على 200+',
                              subText2: '200+ نجمة',
                              activeBgColor: const Color(0xFFFEF08A),
                              activeBorderColor: const Color(0xFFEAB308),
                              activeIconBgColor: const Color(0xFFF59E0B),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMedalCard({
    required String title,
    required bool isLocked,
    required String pointsLabel,
    required String subText1,
    required String subText2,
    required Color activeBgColor,
    required Color activeBorderColor,
    required Color activeIconBgColor,
  }) {
    final bgColor = isLocked ? const Color(0xFFF0F4F8) : activeBgColor;
    final borderColor = isLocked ? Colors.grey[300]! : activeBorderColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 2),
        boxShadow: isLocked
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ]
            : [
                BoxShadow(
                  color: borderColor.withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.cairo(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: isLocked
                        ? const Color(0xFF475569)
                        : const Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 6),
                if (!isLocked)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          pointsLabel,
                          style: GoogleFonts.cairo(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF00C853),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.star_rounded,
                            color: Color(0xFFffb703), size: 14),
                      ],
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.lock_outline,
                        color: Colors.grey, size: 14),
                  ),
                const SizedBox(height: 8),
                Text(
                  subText1,
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    color: isLocked
                        ? const Color(0xFF64748B)
                        : Colors.grey[700],
                    height: 1.3,
                  ),
                ),
                Text(
                  subText2,
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    color: isLocked
                        ? const Color(0xFF64748B)
                        : Colors.grey[700],
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // Icon
          if (isLocked)
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: const Icon(Icons.lock_outline,
                  color: Colors.grey, size: 26),
            )
          else
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.bottomLeft,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: activeIconBgColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(Icons.military_tech,
                        color: Colors.white, size: 32),
                  ),
                ),
                Positioned(
                  bottom: -1,
                  left: -1,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF9000FF),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Center(
                      child: Text(
                        '1',
                        style: GoogleFonts.cairo(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}