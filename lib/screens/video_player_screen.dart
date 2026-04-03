import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:video_player/video_player.dart';
import 'quiz_screen.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoTitle;
  final int starsReward;

  const VideoPlayerScreen({
    super.key,
    required this.videoTitle,
    required this.starsReward,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  bool _isCompleting = false;
  late VideoPlayerController _videoController;

  @override
  void initState() {
    super.initState();
    // Assuming the temporary video is named video.mp4 in assets
    _videoController = VideoPlayerController.asset('assets/video.mp4')
      ..initialize().then((_) {
        if (mounted) {
          setState(() {}); // Ensure the first frame is shown and play button appears
        }
      }).catchError((error) {
        debugPrint("Video load error: \$error");
      });
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  String get _stageKey {
    switch (widget.videoTitle) {
      case 'آداب المترو':
      case 'الدرس الأول: آداب المترو':
        return 'aedab';
      case 'كيف أتنقل':
      case 'الدرس الثاني: كيف أتنقل':
        return 'travel';
      case 'ماذا أفعل عند الضياع':
      case 'الدرس الثالث: ماذا أفعل عند الضياع':
        return 'lost';
      default:
        return 'aedab';
    }
  }

  List<String> get _guidelines {
    switch (_stageKey) {
      case 'travel':
        return [
          'التعرف على خطوط المترو عبر خريطة تطبيق وضاح.',
          'معرفة المحطة الحالية والوجهة قبل بدء الرحلة.',
          'متابعة المحطات ومعرفة أماكن الانتقال بين الخطوط',
        ];
      case 'lost':
        return [
          'حافظ على هدوئك إذا انفصلت عن ولي أمرك في المترو.',
          'ابق في مكان آمن واطلب المساعدة من موظف المترو.',
          'أخبر الموظف برقم ولي أمرك.',
        ];
      case 'aedab':
      default:
        return [
          'الالتزام بالانتظار المنظم وعدم المزاحمة',
          'إظهار الاحترام لكبار السن داخل المترو',
          'المحافظة على الهدوء والنظافة أثناء الرحلة',
        ];
    }
  }

  Future<void> _completeLessonAndGoToQuiz() async {
    if (_isCompleting) return;
    
    setState(() {
      _isCompleting = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
        await userDoc.set({
          'completedStages': {
            _stageKey: {
              'lessonCompleted': true,
              'lessonCompletedAt': FieldValue.serverTimestamp(),
            }
          }
        }, SetOptions(merge: true));
      }

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => QuizScreen(
              stageKey: _stageKey,
              stageTitle: widget.videoTitle,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isCompleting = false;
        });
        debugPrint('Firebase Write Error Bypassed: $e');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => QuizScreen(
              stageKey: _stageKey,
              stageTitle: widget.videoTitle,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final rules = _guidelines;

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
              // Top Bar with Back Button
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
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_forward, color: Color(0xFF9000FF)),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ],
                ),
              ),

              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  widget.videoTitle,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF9000FF),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Video Player Area
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.black, // Dark background
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: _videoController.value.isInitialized
                        ? Stack(
                            alignment: Alignment.center,
                            children: [
                              AspectRatio(
                                aspectRatio: _videoController.value.aspectRatio,
                                child: VideoPlayer(_videoController),
                              ),
                              // Play/Pause button
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _videoController.value.isPlaying
                                        ? _videoController.pause()
                                        : _videoController.play();
                                  });
                                },
                                child: Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.3),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    _videoController.value.isPlaying
                                        ? Icons.pause
                                        : Icons.play_arrow_rounded,
                                    color: Colors.white,
                                    size: 40,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : const Center(
                            child: CircularProgressIndicator(color: Color(0xFF00C853)),
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Steps Card
              Expanded(
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 24.0),
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
                    children: [
                      // Header: النقاط الأساسية
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.track_changes, color: Color(0xFFE53935)), // Red target icon mock
                          const SizedBox(width: 8),
                          Text(
                            'نقاط اساسية',
                            style: GoogleFonts.cairo(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // List of rules (Scrollable if needed)
                      Expanded(
                        child: ListView(


                          physics: const BouncingScrollPhysics(),
                          children: List.generate(rules.length, (index) {
                            return _buildStepPill(
                              number: '${index + 1}', 
                              text: rules[index],
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Reward Box
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF9C4), // Yellow
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFF00C853), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.star_rounded, color: Color(0xFFffb703), size: 36),
                      const SizedBox(width: 8),
                      Column(
                        children: [
                          Text(
                            'مكافأة الفيديو',
                            style: GoogleFonts.cairo(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                          Text(
                            '+${widget.starsReward} نجمة',
                            style: GoogleFonts.cairo(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                              color: const Color(0xFFD87D4A), // Deep orange string
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Complete Lesson Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: InkWell(
                  onTap: _isCompleting ? null : _completeLessonAndGoToQuiz,
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _isCompleting 
                          ? [Colors.grey, Colors.grey.shade400]
                          : [
                              const Color(0xFF00C853), // Green
                              const Color(0xFF9000FF), // Purple
                            ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: _isCompleting ? [] : [
                        BoxShadow(
                          color: const Color(0xFF9000FF).withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: _isCompleting 
                      ? const Center(
                          child: SizedBox(
                            width: 24, 
                            height: 24, 
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3)
                          )
                        )
                      : Text(
                          'إكمال الدرس',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.cairo(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              

              // const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
Widget _buildStepPill({required String number, required String text}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      color: const Color(0xFFE8F5E9),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: Text(
            text,
            textAlign: TextAlign.right,
            softWrap: true,
            style: GoogleFonts.cairo(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E293B),
            ),
          ),
        ),
        const SizedBox(width: 16),

        Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF00C853),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
}
