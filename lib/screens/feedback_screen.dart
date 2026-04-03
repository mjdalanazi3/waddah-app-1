import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'main_dashboard.dart';
import 'quiz_screen.dart';

class FeedbackScreen extends StatelessWidget {
  final int totalQuestions;
  final int correctAnswers;
  final int earnedStars;
  final String stageKey;
  final String stageTitle;

  const FeedbackScreen({
    super.key,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.earnedStars,
    required this.stageKey,
    required this.stageTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            Center(
              child: Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 3)),
                  ],
                ),
                child: const Icon(Icons.celebration_rounded, color: Color(0xFF9000FF), size: 36),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'أحسنت!',
              style: GoogleFonts.cairo(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF8B5CF6),
              ),
            ),
            
            const SizedBox(height: 20),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: const LinearGradient(
                      colors: [Color(0xFFEDE9FE), Color(0xFFE8FDF3)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 13),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 18),
                  child: Column(
                    children: [
                      Text(
                        '$correctAnswers/$totalQuestions',
                        style: GoogleFonts.cairo(
                          fontSize: 56,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF7C3AED),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'أسئلة صحيحة',
                        style: GoogleFonts.cairo(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF334155),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'نجوم +$earnedStars⭐',
                        style: GoogleFonts.cairo(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF10B981),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Divider(thickness: 1.2),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                side: const BorderSide(color: Color(0xFFCBD5E1)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              child: Text(
                                'رجوع',
                                style: GoogleFonts.cairo(fontSize: 16, color: const Color(0xFF1F2937)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(builder: (context) => const MainDashboard()),
                                (route) => false,
                              ),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                side: const BorderSide(color: Color(0xFFCBD5E1)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              child: Text(
                                'العودة للرئيسية',
                                style: GoogleFonts.cairo(fontSize: 16, color: const Color(0xFF1F2937)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => QuizScreen(
                                stageKey: stageKey,
                                stageTitle: stageTitle,
                              ),
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7C3AED),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: Text(
                            'إعادة اللعب',
                            style: GoogleFonts.cairo(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white, 
                            ),
                            )
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
    );
  }
}
