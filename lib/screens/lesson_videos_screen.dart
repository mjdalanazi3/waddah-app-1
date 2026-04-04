import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'main_dashboard.dart';
import 'video_player_screen.dart';

class LessonVideosScreen extends StatelessWidget {
  final String moduleTitle;

  const LessonVideosScreen({super.key, required this.moduleTitle});

  @override
  Widget build(BuildContext context) {
    final String userName = FirebaseAuth.instance.currentUser?.displayName ?? 'userName';

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE9D4FF), // Light purple
              Color(0xFFB9F8CF), // Light mint green
            ],
            stops: [0.0, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header Area
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                  children: [
                    // Top Row: Home Button (Left) -> Avatar Circle (Center) -> Back Button (Right)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Back Button
                        Container(
                          width: 48,
                          height: 48,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.arrow_forward, color: Color(0xFF00C853)),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),

                        // Avatar Circle
                        Container(
                          width: 80,
                          height: 80,
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(40),
                            child: Image.asset(
                              'assets/UI/RoundLogo.png', // Fallback
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.train, size: 40, color: Color(0xFF9000FF)),
                            ),
                          ),
                        ),

                        // Home Button
                        GestureDetector(
                          onTap: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (context) => const MainDashboard()),
                              (route) => false,
                            );
                          },
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: const BoxDecoration(
                              color: Color(0xFF9000FF),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.home_outlined, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Titles
                    Text(
                      'الدروس التعليمية',
                      style: GoogleFonts.cairo(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF9000FF),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'تعلم مع الفيديوهات يا',
                          style: GoogleFonts.cairo(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF9000FF),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          userName,
                          style: GoogleFonts.cairo(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Videos List
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                  children: [
                    // Video 1
                    _buildVideoCard(
                      context: context,
                      title: moduleTitle,
                      duration: '1:30',
                      stars: '35',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VideoPlayerScreen(
                              videoTitle: moduleTitle,
                              starsReward: 35,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoCard({
    required BuildContext context,
    required String title,
    String subtitle="",
    required String duration,
    required String stars,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             // Center & Right content (Title, Subtitle, Info Row)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      title,
                      textAlign: TextAlign.right,
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      textAlign: TextAlign.right,
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Bottom Row: Stars and Duration
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Stars Block
                        Row(
                          children: [
                            Text(
                              stars,
                              style: GoogleFonts.cairo(
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFFffb703),
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.star_border_rounded, color: Color(0xFFffb703), size: 18),
                          ],
                        ),
                        const SizedBox(width: 16),
                        // Duration Block
                        Row(
                          children: [
                            Text(
                              duration,
                              style: GoogleFonts.cairo(
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1E293B),
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.movie_creation_outlined, color: Color(0xFF1E293B), size: 16),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Left Thumbnail Box (Visual Left in LTR setup, so we place it last in our manual RTL setup row)
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFFB755FF), // Purple solid color for now as seen in image
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFB755FF).withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(Icons.play_arrow_rounded, color: Colors.white, size: 48),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
