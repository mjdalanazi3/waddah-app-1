import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_screen.dart';
import 'quiz_screen.dart';
import 'ar_screen.dart';
import 'node_progress_screen.dart';

enum FeedbackSource { quiz, arGame }

class FeedbackScreen extends StatelessWidget {
  final int totalQuestions;
  final int correctAnswers;
  final int earnedStars;
  final String stageKey;
  final String stageTitle;
  final FeedbackSource source;

  final String? arTaskTitle;
  final String? arInstructions;
  final int? arGameScene;

  const FeedbackScreen({
    super.key,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.earnedStars,
    required this.stageKey,
    required this.stageTitle,
    this.source = FeedbackSource.quiz,
    this.arTaskTitle,
    this.arInstructions,
    this.arGameScene,
  });

  @override
  Widget build(BuildContext context) {
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
          child: Column(
            children: [
              const SizedBox(height: 50),
              // Logo
              Image.asset(
                'assets/UI/RoundLogo.png',
                height: 100,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.stars_rounded,
                  size: 70,
                  color: Color(0xFF9000FF),
                ),
              ),

              const SizedBox(height: 20),

              // "أحسنت" Header
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🎉', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  Text(
                    'أحسنت!',
                    style: GoogleFonts.cairo(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF9000FF),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text('🎉', style: TextStyle(fontSize: 24)),
                ],
              ),

              const SizedBox(height: 30),

              // White container
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 350), // Limits width
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min, 
                      children: [
                        // Score
                        Text(
                          '$correctAnswers/$totalQuestions',
                          style: GoogleFonts.cairo(
                            fontSize: 56,
                            height: 1.1,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF7C3AED),
                          ),
                        ),
                        Text(
                          source == FeedbackSource.arGame ? 'نقاط صحيحة' : 'أسئلة صحيحة',
                          style: GoogleFonts.cairo(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Stars
                        Text(
                          '⭐ نجوم +$earnedStars',
                          style: GoogleFonts.cairo(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF10B981),
                          ),
                        ),

                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Divider(thickness: 1, height: 1),
                        ),

                        // Action Buttons
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              if (source == FeedbackSource.arGame) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ARScreen(
                                      moduleTitle: stageTitle,
                                      taskTitle: arTaskTitle ?? '',
                                      instructions: arInstructions ?? '',
                                      gameScene: arGameScene ?? 0,
                                    ),
                                  ),
                                );
                              } else {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => QuizScreen(
                                      stageKey: stageKey,
                                      stageTitle: stageTitle,
                                    ),
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF7C3AED),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                              elevation: 0,
                            ),
                            child: Text(
                              source == FeedbackSource.arGame ? 'إعادة اللعبة' : 'إعادة الاختبار',
                              style: GoogleFonts.cairo(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        
                          const SizedBox(height: 10),

                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => NodeProgressScreen(
                                      moduleTitle: stageTitle,
                                    ),
                                  ),
                                  (route) => false,
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                side: const BorderSide(color: Color(0xFF7C3AED), width: 1.5),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14)),
                                foregroundColor: const Color(0xFF7C3AED),
                              ),
                              child: Text(
                                'العودة للمرحلة',
                                style: GoogleFonts.cairo(
                                    fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),

                        const SizedBox(height: 10),

                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final user = FirebaseAuth.instance.currentUser;
                              final doc = await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(user?.uid)
                                  .get();

                              final username = doc.data()?['username'] ??
                                  user?.email?.split('@')[0] ??
                                  'مستخدم';

                              if (context.mounted) {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => HomeScreen(userName: username),
                                  ),
                                  (route) => false,
                                );
                              }
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: const BorderSide(color: Color(0xFFE2E8F0)),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                              foregroundColor: const Color(0xFF475569),
                            ),
                            icon: const Icon(Icons.home_rounded, size: 20),
                            label: Text(
                              'الرئيسية',
                              style: GoogleFonts.cairo(
                                  fontSize: 16, fontWeight: FontWeight.w600),
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
    );
  }
}