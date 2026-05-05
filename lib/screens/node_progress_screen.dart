import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'main_dashboard.dart'; 
import 'video_player_screen.dart';
import 'quiz_screen.dart';
import 'ar_screen.dart';

class NodeProgressScreen extends StatefulWidget {
  final String moduleTitle;
  
  const NodeProgressScreen({
    super.key,
    required this.moduleTitle,
  });

  @override
  State<NodeProgressScreen> createState() => _NodeProgressScreenState();
}

class _NodeProgressScreenState extends State<NodeProgressScreen> {
  String _arTaskTitle(String title) {
    switch (title) {
      case 'آداب المترو':
        return 'تصرف بشكل صحيح في المترو';
      case 'كيف أتنقل':
        return 'ابحث عن محطتك الصحيحة';
      case 'ماذا أفعل عند الضياع':
        return 'ابحث عن موظف المترو';
      default:
        return 'ابدأ التجربة';
    }
  }

  String _arInstructions(String title) {
    switch (title) {
      case 'آداب المترو':
        return 'وجّه الكاميرا نحو المشهد وحدد التصرف الصحيح داخل المترو';
      case 'كيف أتنقل':
        return 'وجّه الكاميرا نحو خريطة المترو وحدد المحطة الصحيحة للوصول إلى وجهتك';
      case 'ماذا أفعل عند الضياع':
        return 'وجّه الكاميرا وابحث عن موظف المترو واطلب منه المساعدة';
      default:
        return 'وجّه الكاميرا وابدأ التجربة';
    }
  }

  int _gameSceneFromTitle(String title) {
    switch (title) {
      case 'كيف أتنقل':
        return 0;
      case 'ماذا أفعل عند الضياع':
        return 1;
      default:
        return 0;
    }
  }

  String _stageKeyFromTitle(String title) {
    switch (title) {
      case 'آداب المترو':
        return 'aedab';
      case 'كيف أتنقل':
        return 'travel';
      case 'ماذا أفعل عند الضياع':
        return 'lost';
      default:
        return 'aedab';
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final String userName = currentUser?.displayName ?? '';
    final stageKey = _stageKeyFromTitle(widget.moduleTitle);

    if (currentUser == null) {
      return const Scaffold(body: Center(child: Text('يجب تسجيل الدخول')));
    }

    final userDocStream = FirebaseFirestore.instance.collection('users').doc(currentUser.uid).snapshots();

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: userDocStream,
      builder: (context, snapshot) {
        Map<String, dynamic>? userData;
        if (snapshot.hasData && snapshot.data!.data() != null) {
          userData = snapshot.data!.data();
        }

        final int stars = (userData?['stars'] as int?) ?? 0;
        final completedStages = (userData?['completedStages'] as Map<String, dynamic>?) ?? {};
        final stageData = completedStages[stageKey] as Map<String, dynamic>? ?? {};
        final bool lessonCompleted = stageData['lessonCompleted'] == true;
        final bool quizCompleted = stageData.containsKey('correctAnswers');

        return Scaffold(
          body: LayoutBuilder(
            builder: (context, constraints) {
              return Container(
                width: double.infinity,
                // minHeight ensures the gradient covers the whole screen
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
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
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        // Top Right Back Button
                        Padding(
                          padding: const EdgeInsets.only(right: 24.0, top: 16.0),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Container(
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
                          ),
                        ),

                        // Header: Avatar Circle and User Pill
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Column(
                            children: [
                              SizedBox(
                                width: 120,
                                height: 120,
                                child: Image.asset(
                                  'assets/UI/RoundLogo.png',
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.train, size: 50, color: Color(0xFF9000FF)),
                                ),
                              ),
                              const SizedBox(height: 24),

                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(30),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.05),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFF9C4), 
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        children: [
                                          Text(
                                            '$stars',
                                            style: GoogleFonts.cairo(
                                              fontWeight: FontWeight.bold,
                                              color: const Color(0xFFE65100),
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          const Icon(Icons.star_border_rounded, color: Color(0xFFffb703), size: 18),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          userName,
                                          style: GoogleFonts.cairo(
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFF9000FF),
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'مرحباً',
                                          style: GoogleFonts.cairo(
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFF9000FF),
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          width: 32,
                                          height: 32,
                                          decoration: const BoxDecoration(
                                            color: Color(0xFFF3E8FF),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Center(
                                            child: Text('👦', style: TextStyle(fontSize: 18)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

                        // White Content Card: fits content while floating
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Container(
                            padding: const EdgeInsets.all(24.0),
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
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.menu_book_rounded, color: Color(0xFF9000FF), size: 28),
                                    const SizedBox(width: 12),
                                    Text(
                                      widget.moduleTitle,
                                      style: GoogleFonts.cairo(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF1E293B),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),

                                ListView(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => VideoPlayerScreen(
                                            videoTitle: widget.moduleTitle,
                                            starsReward: 35,
                                          )),
                                        );
                                      },
                                      child: _buildTaskItem(
                                        number: '١',
                                        title: 'الدرس',
                                        subtitle: lessonCompleted ? 'مكتمل ✓' : 'متاح ✓',
                                        icon: Icons.chrome_reader_mode_outlined,
                                        iconBgColor: const Color(0xFFE8F5E9),
                                        iconColor: const Color(0xFF00C853),
                                        pillColor: const Color(0xFF9000FF),
                                        cardBgColor: Colors.white,
                                        borderColor: const Color(0xFFF1F5F9),
                                        isLocked: false,
                                        subtitleColor: const Color(0xFF00C853),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    GestureDetector(
                                      onTap: () {
                                        if (!lessonCompleted) {
                                          _showLockedDialog(context, isQuiz: true);
                                        } else {
                                          final stageKey = _stageKeyFromTitle(widget.moduleTitle);
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => QuizScreen(
                                                stageKey: stageKey,
                                                stageTitle: widget.moduleTitle,
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                      child: _buildTaskItem(
                                        number: '٢',
                                        title: 'الاختبار',
                                        subtitle: lessonCompleted ? 'ابدأ الآن' : 'مقفل 🔒',
                                        icon: lessonCompleted ? Icons.help_outline_rounded : Icons.lock_outline,
                                        iconBgColor: lessonCompleted ? const Color(0xFFE8F5E9) : const Color(0xFFF1F5F9),
                                        iconColor: lessonCompleted ? const Color(0xFF00C853) : const Color(0xFF94A3B8),
                                        pillColor: lessonCompleted ? const Color(0xFF00C853) : const Color(0xFF94A3B8),
                                        cardBgColor: lessonCompleted ? Colors.white : const Color(0xFFF8FAF9),
                                        borderColor: lessonCompleted 
                                          ? const Color(0xFF00C853).withValues(alpha: 0.25)
                                          : const Color(0xFFE2E8F0).withValues(alpha: 0.5),
                                        isLocked: !lessonCompleted,
                                        subtitleColor: lessonCompleted ? const Color(0xFF00C853) : const Color(0xFF94A3B8),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    GestureDetector(
                                      onTap: () {
                                        if (!quizCompleted) {
                                          _showLockedDialog(context, isQuiz: false);
                                        } else {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => ARScreen(
                                                moduleTitle: widget.moduleTitle,
                                                taskTitle: _arTaskTitle(widget.moduleTitle),
                                                instructions: _arInstructions(widget.moduleTitle),
                                                gameScene: _gameSceneFromTitle(widget.moduleTitle),
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                      child: _buildTaskItem(
                                        number: '٣',
                                        title: 'لعبة الواقع\nالافتراضي',
                                        subtitle: quizCompleted ? 'ابدأ الآن 🎮' : 'مقفل 🔒',
                                        icon: quizCompleted ? Icons.smartphone_rounded : Icons.lock_outline,
                                        iconBgColor: quizCompleted ? const Color(0xFFEDE9FE) : const Color(0xFFF1F5F9),
                                        iconColor: quizCompleted ? const Color(0xFF9000FF) : const Color(0xFF94A3B8),
                                        pillColor: quizCompleted ? const Color(0xFF9000FF) : const Color(0xFFB794F6),
                                        cardBgColor: quizCompleted ? Colors.white : const Color(0xFFF8FAF9),
                                        borderColor: quizCompleted
                                            ? const Color(0xFF9000FF).withValues(alpha: 0.25)
                                            : const Color(0xFFE2E8F0).withValues(alpha: 0.5),
                                        isLocked: !quizCompleted,
                                        subtitleColor: quizCompleted ? const Color(0xFF9000FF) : const Color(0xFF94A3B8),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 32), 
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildTaskItem({
    required String number,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required Color pillColor,
    required Color cardBgColor,
    required Color borderColor,
    required bool isLocked,
    required Color subtitleColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor, width: 2),
        boxShadow: isLocked
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: iconColor, size: 32),
          ),
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
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isLocked ? const Color(0xFF64748B) : const Color(0xFF1E293B),
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    textAlign: TextAlign.right,
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: subtitleColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: pillColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLockedDialog(BuildContext context, {required bool isQuiz}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32.0),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(32),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10.0,
                  offset: Offset(0.0, 10.0),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min, 
              children: <Widget>[
                const Icon(
                  Icons.lock_rounded,
                  size: 80,
                  color: Color(0xFF00A63E), 
                ),
                const SizedBox(height: 24.0),
                Text(
                  isQuiz ? 'الاختبار مغلق!' : 'قريباً',
                  style: GoogleFonts.cairo(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 16.0),
                Text(
                  isQuiz 
                    ? 'يجب عليك إكمال الدرس للوصول إلى الاختبار'
                    : 'هذه الميزة ستكون متاحة قريباً',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 32.0),
                InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF9000FF), 
                          Color(0xFF00C853), 
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00C853).withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      'فهمت!',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}