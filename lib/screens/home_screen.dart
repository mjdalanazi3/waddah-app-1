import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'node_progress_screen.dart';
import 'map_viewer_screen.dart';
import 'progress_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatelessWidget {
  final String userName;
  const HomeScreen({super.key, required this.userName});

  static const Color primaryPurple = Color(0xFF9810FA);
  static const Color primaryGreen = Color(0xFF00A63E);
  static const Color darkNavy = Color(0xFF155DFC);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          final data = snapshot.data?.data() as Map<String, dynamic>?;
          final int stars = (data?['stars'] as int?) ?? 0;
          final completedStages =
              (data?['completedStages'] as Map<String, dynamic>?) ?? {};
          final bool aedabArDone =
              (completedStages['آداب المترو'] as Map<String, dynamic>?)?['arCompleted'] == true;
          final bool travelArDone =
              (completedStages['كيف أتنقل'] as Map<String, dynamic>?)?['arCompleted'] == true;

          return Stack(
            children: [
              // Background color
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(color: const Color(0xFF5191FD)),
              ),

              // Background image
              Positioned(
                bottom: 90,
                left: 0,
                right: 0,
                child: SizedBox(
                  width: 366,
                  height: 740,
                  child: Image.asset(
                    'assets/UI/HomePage.png',
                    width: 366,
                    height: 740,
                    fit: BoxFit.fill,
                  ),
                ),
              ),

              // Top bar
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Round logo (left)
                        Image.asset('assets/UI/RoundLogo.png', height: 120),

                        // Stars counter
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: const [
                                BoxShadow(color: Colors.black12, blurRadius: 8),
                              ],
                              border: Border.all(color: const Color(0xFFe0aaff), width: 1.5),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.star_rounded,
                                    color: Color(0xFFffb703), size: 20),
                                const SizedBox(width: 4),
                                Text(
                                  '$stars',
                                  style: GoogleFonts.cairo(
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF9d4edd),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        // Username pill
                        Flexible(
                          child: GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const ProfileScreen()),
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: const [
                                  BoxShadow(color: Colors.black12, blurRadius: 8),
                                ],
                                border: Border.all(
                                    color: const Color(0xFFe0aaff), width: 1.5),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '👋 مرحباً',
                                    style: GoogleFonts.cairo(
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF9d4edd),
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      userName,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: GoogleFonts.cairo(
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF9d4edd),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // آداب المترو — always unlocked
              Positioned(
                top: size.height * 0.47,
                right: size.width * 0.10,
                child: GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NodeProgressScreen(
                          moduleTitle: 'آداب المترو'),
                    ),
                  ),
                  child: _buildLevelButton(
                    label: 'آداب المترو',
                    isLocked: false,
                    color: primaryPurple,
                    number: '١',
                  ),
                ),
              ),

              // كيف أتنقل — unlocked when aedab AR done
              Positioned(
                top: size.height * 0.47,
                left: size.width * 0.10,
                child: GestureDetector(
                  onTap: aedabArDone
                      ? () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const NodeProgressScreen(
                                  moduleTitle: 'كيف أتنقل'),
                            ),
                          )
                      : null,
                  child: _buildLevelButton(
                    label: 'كيف أتنقل',
                    isLocked: !aedabArDone,
                    color: const Color(0xFF5191FD),
                    number: '٢',
                  ),
                ),
              ),

              // ماذا أفعل عند الضياع — unlocked when travel AR done
              Positioned(
                top: size.height * 0.67,
                left: size.width * 0.28,
                child: GestureDetector(
                  onTap: travelArDone
                      ? () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const NodeProgressScreen(
                                  moduleTitle: 'ماذا أفعل عند الضياع'),
                            ),
                          )
                      : null,
                  child: _buildLevelButton(
                    label: 'ماذا أفعل\nعند الضياع',
                    isLocked: !travelArDone,
                    color: const Color(0xFF2E7D32),
                    number: '٣',
                  ),
                ),
              ),

              // Bottom navigation bar
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  width: double.infinity,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 12,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const MapViewerScreen()),
                          ),
                          child: _buildNavItem(
                            icon: Icons.map_outlined,
                            label: 'الخريطة',
                            color: primaryGreen,
                          ),
                        ),
                        _buildNavItem(
                          icon: Icons.home_outlined,
                          label: '',
                          color: primaryPurple,
                          isHome: true,
                        ),
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const ProgressScreen()),
                          ),
                          child: _buildNavItem(
                            icon: Icons.emoji_events_outlined,
                            label: 'الميداليات',
                            color: const Color(0xFFFFC107),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLevelButton({
    required String label,
    required bool isLocked,
    required Color color,
    required String number,
  }) {
    return Opacity(
      opacity: isLocked ? 0.6 : 1.0,
      child: Column(
        children: [
          Container(
            width: 67,
            height: 67,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: isLocked
                      ? Colors.black.withOpacity(0.2)
                      : color.withOpacity(0.5),
                  blurRadius: isLocked ? 4 : 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: isLocked
                  ? const Icon(Icons.lock, color: Colors.white, size: 30)
                  : Text(
                      number,
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.ltr,
                      style: GoogleFonts.cairo(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: isLocked
                      ? Colors.black.withOpacity(0.15)
                      : color.withOpacity(0.4),
                  blurRadius: isLocked ? 4 : 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
              style: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required Color color,
    bool isHome = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: isHome ? 44 : 36),
        if (label.isNotEmpty)
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 14,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          )
        else
          const SizedBox(height: 18),
      ],
    );
  }
}