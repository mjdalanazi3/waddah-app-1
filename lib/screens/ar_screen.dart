import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ARScreen extends StatefulWidget {
  final String moduleTitle;
  final String taskTitle;
  final String instructions;
  final int gameScene;

  const ARScreen({
    super.key,
    required this.moduleTitle,
    required this.taskTitle,
    required this.instructions,
    required this.gameScene,
  });

  @override
  State<ARScreen> createState() => _ARScreenState();
}

class _ARScreenState extends State<ARScreen> {
  static const _channel = MethodChannel('com.example.waddah_app/unity');
  bool _audioEnabled = false;

  static const Color primaryPurple = Color(0xFF9810FA);
  static const Color primaryGreen = Color(0xFF00C950);
  static const Color lightPurple = Color(0xFFE8D5F5);

  Future<void> _launchUnity() async {
    try {
      await _channel.invokeMethod('launchUnity', {
        'sceneIndex': widget.gameScene,
      });
    } catch (e) {
      debugPrint('Error launching Unity: $e');
    }
  }

  Future<void> _endGame() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({
        'completedStages': {
          widget.moduleTitle: {
            'arCompleted': true,
          }
        }
      }, SetOptions(merge: true));
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
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
                  // Top bar
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 16, right: 16, top: 8, bottom: 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 50),
                        Image.asset('assets/UI/RoundLogo.png', height: 120),
                        const SizedBox(width: 50),
                      ],
                    ),
                  ),

                  Text(
                    'ألعاب الواقع المعزز',
                    style: GoogleFonts.cairo(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: primaryPurple,
                    ),
                  ),
                  Text(
                    'استكشف يا مبدع',
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      color: primaryPurple,
                    ),
                  ),

                  const SizedBox(height: 4),

                  // White card
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(
                          left: 16, right: 16, bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Directionality(
                        textDirection: TextDirection.rtl,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Module title pill
                              Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: lightPurple,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text('🚇',
                                          style: TextStyle(fontSize: 14)),
                                      const SizedBox(width: 8),
                                      Text(
                                        widget.moduleTitle,
                                        style: GoogleFonts.cairo(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: primaryPurple,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 10),

                              // Task title
                              Text(
                                widget.taskTitle,
                                style: GoogleFonts.cairo(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF1A1A1A),
                                ),
                                textAlign: TextAlign.center,
                              ),

                              const SizedBox(height: 20),

                              // Instructions
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 20,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF8B4513),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'التعليمات',
                                          style: GoogleFonts.cairo(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: primaryPurple,
                                          ),
                                        ),
                                        Text(
                                          widget.instructions,
                                          style: GoogleFonts.cairo(
                                            fontSize: 14,
                                            color: const Color(0xFF444444),
                                            height: 1.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              const Spacer(),

                              // Audio toggle
                              SizedBox(
                                width: double.infinity,
                                height: 46,
                                child: ElevatedButton.icon(
                                  onPressed: () => setState(
                                      () => _audioEnabled = !_audioEnabled),
                                  iconAlignment: IconAlignment.end,
                                  icon: Icon(
                                    _audioEnabled
                                        ? Icons.volume_up
                                        : Icons.volume_off,
                                    size: 20,
                                  ),
                                  label: Text(
                                    _audioEnabled
                                        ? 'السرد الصوتي مفعّل'
                                        : 'السرد الصوتي مفعّل',
                                    style: GoogleFonts.cairo(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryGreen,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    elevation: 0,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 10),

                              // Launch Unity button
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton.icon(
                                  onPressed: _launchUnity,
                                  iconAlignment: IconAlignment.end,
                                  icon: const Icon(Icons.play_arrow_rounded,
                                      size: 24),
                                  label: Text(
                                    'ابدأ اللعبة',
                                    style: GoogleFonts.cairo(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryPurple,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 0,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 10),

                              // End game button
                              SizedBox(
                                width: double.infinity,
                                height: 46,
                                child: ElevatedButton(
                                  onPressed: _endGame,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryGreen,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: Text(
                                    'إنهاء اللعبة',
                                    style: GoogleFonts.cairo(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Return button
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: primaryGreen,
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}