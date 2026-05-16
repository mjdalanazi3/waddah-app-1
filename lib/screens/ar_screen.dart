import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_unity_widget/flutter_unity_widget.dart';
import 'feedback_screen.dart';

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
  UnityWidgetController? _unityWidgetController;
  bool _showUnity = false;
  bool _unityReady = false;
  bool _audioEnabled = false;
  bool _isSpeaking = false;
  late FlutterTts _flutterTts;

  static const Color primaryPurple = Color(0xFF9810FA);
  static const Color primaryGreen = Color(0xFF00C950);
  static const Color lightPurple = Color(0xFFEDE7F6);

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  void _initTts() {
    _flutterTts = FlutterTts();
    _flutterTts.setLanguage('ar-SA');
    _flutterTts.setSpeechRate(0.5);
    _flutterTts.setPitch(1.0);
    _flutterTts.setCompletionHandler(() {
      if (mounted) setState(() => _isSpeaking = false);
    });
  }

  Future<void> _toggleAudio() async {
    if (_isSpeaking) {
      await _flutterTts.stop();
      setState(() {
        _isSpeaking = false;
        _audioEnabled = false;
      });
    } else {
      setState(() {
        _audioEnabled = true;
        _isSpeaking = true;
      });
      await _flutterTts.speak(widget.instructions);
    }
  }

  @override
  void dispose() {
    _flutterTts.stop();
    _unityWidgetController?.dispose();
    super.dispose();
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.status;
    if (status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '✅ تم السماح بالوصول للكاميرا',
            style: GoogleFonts.cairo(),
            textAlign: TextAlign.right,
          ),
          backgroundColor: primaryGreen,
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      _showCameraPermissionDialog();
    }
  }

  Future<void> _handleStartGame() async {
    setState(() => _showUnity = true);
  }

  void _onUnityCreated(UnityWidgetController controller) {
    _unityWidgetController = controller;
    debugPrint('=== LOADING SCENE: ${widget.gameScene} ===');
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        controller.postMessage(
          'FlutterBridge',
          'LoadScene',
          widget.gameScene.toString(),
        );
      }
    });
  }

  // ✅ Called when Unity sends any message to Flutter
  void _onUnityMessage(message) {
    debugPrint('=== Unity message received: $message ===');
    if (message.toString() == 'gameComplete') {
      debugPrint('=== Game complete received! Ending game... ===');
      _endGame();
    }
  }

  void _showCameraPermissionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: primaryPurple,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_alt_rounded,
                      color: Colors.white, size: 36),
                ),
                const SizedBox(height: 16),
                Text(
                  'السماح بالوصول للكاميرا',
                  style: GoogleFonts.cairo(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A1A1A),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  'تحتاج تجربة الواقع المعزز إلى استخدام الكاميرا، هل تسمح بذلك؟',
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF666666),
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          final result = await Permission.camera.request();
                          if (result.isGranted) {
                            setState(() => _showUnity = true);
                          } else if (result.isPermanentlyDenied) {
                            openAppSettings();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryPurple,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                        ),
                        child: Text('نعم، السماح',
                            style: GoogleFonts.cairo(
                                fontSize: 15, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFDDDDDD)),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text('لا',
                            style: GoogleFonts.cairo(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF666666),
                            )),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _endGame() async {
    await _flutterTts.stop();
    const int arEarnedStars = 20;
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set({
          'stars': FieldValue.increment(arEarnedStars),
          'completedStages': {
            widget.moduleTitle: {'arCompleted': true}
          }
        }, SetOptions(merge: true));
      } catch (e) {
        debugPrint('Firebase error: $e');
      }
    }
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => FeedbackScreen(
            totalQuestions: 1,
            correctAnswers: 1,
            earnedStars: arEarnedStars,
            stageKey: widget.moduleTitle,
            stageTitle: widget.moduleTitle,
            source: FeedbackSource.arGame,
            arTaskTitle: widget.taskTitle,
            arInstructions: widget.instructions,
            arGameScene: widget.gameScene,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Show Unity fullscreen when game starts
    if (_showUnity) {
      return Scaffold(
        body: Stack(
          children: [
            UnityWidget(
              onUnityCreated: _onUnityCreated,
              onUnityMessage: _onUnityMessage, // ✅ listen for gameComplete
              useAndroidViewSurface: false,
              fullscreen: false,
            ),
            // End game button overlay
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: ElevatedButton(
                  onPressed: _endGame,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 14),
                    elevation: 0,
                  ),
                  child: Text(
                    'إنهاء اللعبة',
                    style: GoogleFonts.cairo(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            // Back button
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              right: 16,
              child: GestureDetector(
                onTap: () => setState(() {
                  _showUnity = false;
                  _unityReady = false;
                }),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.arrow_forward_ios_rounded,
                      color: primaryGreen, size: 20),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Normal AR screen UI
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
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
                  child: Center(
                    child: Image.asset(
                      'assets/UI/RoundLogo.png',
                      height: 90,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.train,
                              size: 60, color: primaryPurple),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'ألعاب الواقع المعزز',
                  style: GoogleFonts.cairo(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: primaryPurple,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(
                        left: 16, right: 16, bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Directionality(
                      textDirection: TextDirection.rtl,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 7),
                                decoration: BoxDecoration(
                                  color: lightPurple,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text('🚇',
                                        style: TextStyle(fontSize: 16)),
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
                            const SizedBox(height: 14),
                            Text(
                              widget.taskTitle,
                              style: GoogleFonts.cairo(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1A1A1A),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            // Camera preview placeholder
                            GestureDetector(
                              onTap: _showCameraPermissionDialog,
                              child: Container(
                                height: 180,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: const Color(0xFFBDBDBD),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.15),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                      ),
                                      Container(
                                        width: 72,
                                        height: 72,
                                        decoration: const BoxDecoration(
                                          color: primaryPurple,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                            Icons.camera_alt_rounded,
                                            color: Colors.white,
                                            size: 36),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: lightPurple,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                    color: primaryPurple.withOpacity(0.2)),
                              ),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.info_outline_rounded,
                                          color: primaryPurple, size: 22),
                                      const SizedBox(width: 8),
                                      Text('التعليمات',
                                          style: GoogleFonts.cairo(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: primaryPurple,
                                          )),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    widget.instructions,
                                    style: GoogleFonts.cairo(
                                      fontSize: 15,
                                      color: const Color(0xFF333333),
                                      height: 1.8,
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            GestureDetector(
                              onTap: _toggleAudio,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 14),
                                decoration: BoxDecoration(
                                  color: _audioEnabled
                                      ? primaryGreen.withOpacity(0.08)
                                      : const Color(0xFFF5F5F5),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: _audioEnabled
                                        ? primaryGreen
                                        : const Color(0xFFDDDDDD),
                                    width: 1.5,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Icon(
                                      _isSpeaking
                                          ? Icons.stop_circle_rounded
                                          : Icons.play_circle_rounded,
                                      color: _audioEnabled
                                          ? primaryGreen
                                          : const Color(0xFFAAAAAA),
                                      size: 28,
                                    ),
                                    Text(
                                      _isSpeaking
                                          ? 'جاري قراءة التعليمات...'
                                          : _audioEnabled
                                              ? 'اضغط لإيقاف السرد'
                                              : 'اضغط لسماع التعليمات',
                                      style: GoogleFonts.cairo(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: _audioEnabled
                                            ? primaryGreen
                                            : const Color(0xFF888888),
                                      ),
                                    ),
                                    Icon(
                                      _isSpeaking
                                          ? Icons.volume_up_rounded
                                          : Icons.volume_off_rounded,
                                      color: _audioEnabled
                                          ? primaryGreen
                                          : const Color(0xFFAAAAAA),
                                      size: 24,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: _handleStartGame,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryPurple,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(18)),
                                  elevation: 0,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.play_arrow_rounded,
                                        size: 28),
                                    const SizedBox(width: 8),
                                    Text('ابدأ اللعبة',
                                        style: GoogleFonts.cairo(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        )),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: OutlinedButton(
                                onPressed: _endGame,
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                      color: primaryGreen, width: 1.5),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(16)),
                                ),
                                child: Text('إنهاء اللعبة',
                                    style: GoogleFonts.cairo(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: primaryGreen,
                                    )),
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
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Icon(Icons.arrow_forward_ios_rounded,
                    color: primaryGreen, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}