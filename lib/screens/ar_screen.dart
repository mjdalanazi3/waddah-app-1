import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:camera/camera.dart';

class ARScreen extends StatefulWidget {
  final String moduleTag;
  final String taskTitle;
  final String instructions;
  final int current;
  final int total;

  const ARScreen({
    super.key,
    required this.moduleTag,
    required this.taskTitle,
    required this.instructions,
    required this.current,
    required this.total,
  });

  @override
  State<ARScreen> createState() => _ARScreenState();
}

class _ARScreenState extends State<ARScreen> {
  bool _audioEnabled = false;
  late int _current;
  late int _total;
  CameraController? _cameraController;
  bool _cameraActive = false;
  bool _cameraInitializing = false;

  static const Color primaryPurple = Color(0xFF9810FA);
  static const Color primaryGreen = Color(0xFF00C950);
  static const Color lightPurple = Color(0xFFE8D5F5);

  @override
  void initState() {
    super.initState();
    _current = widget.current;
    _total = widget.total;
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _initCamera() async {
    if (!mounted) return;
    setState(() {
      _cameraInitializing = true;
      _cameraActive = false;
    });

    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (mounted) setState(() => _cameraInitializing = false);
        return;
      }

      final controller = CameraController(
        cameras.first,
        ResolutionPreset.low,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await controller.initialize();

      if (mounted) {
        setState(() {
          _cameraController = controller;
          _cameraActive = true;
          _cameraInitializing = false;
        });
      } else {
        await controller.dispose();
      }
    } catch (e) {
      // Silently fail — camera works on real device, not emulator
      if (mounted) {
        setState(() {
          _cameraInitializing = false;
          _cameraActive = false;
        });
      }
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
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    color: Colors.white,
                    size: 36,
                  ),
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
                    fontSize: 16,
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
                        onPressed: () {
                          Navigator.pop(context);
                          _initCamera();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryPurple,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                        ),
                        child: Text(
                          'نعم، السماح',
                          style: GoogleFonts.cairo(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFDDDDDD)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(
                          'لا',
                          style: GoogleFonts.cairo(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF666666),
                          ),
                        ),
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

  Widget _buildCameraView() {
    if (_cameraInitializing) {
      return Container(
        decoration: BoxDecoration(
          color: const Color(0xFF222222),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 12),
              Text(
                'جاري تشغيل الكاميرا...',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      );
    }

    if (_cameraActive &&
        _cameraController != null &&
        _cameraController!.value.isInitialized) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: CameraPreview(_cameraController!),
      );
    }

    // Default — tap to open camera
    return GestureDetector(
      onTap: _showCameraPermissionDialog,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF222222),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: primaryPurple.withOpacity(0.85),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.camera_alt_rounded,
              color: Colors.white,
              size: 40,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main content
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

                  // Title
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
                              // Module tag
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
                                        widget.moduleTag,
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

                              // Progress counter + bar
                              Text(
                                '$_current من $_total',
                                style: GoogleFonts.cairo(
                                  fontSize: 14,
                                  color: const Color(0xFF888888),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 4),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: LinearProgressIndicator(
                                  value: 0,
                                  backgroundColor: const Color(0xFFEEEEEE),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      primaryPurple),
                                  minHeight: 8,
                                ),
                              ),

                              const SizedBox(height: 8),

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

                              const SizedBox(height: 10),

                              // Camera view
                              Expanded(child: _buildCameraView()),

                              const SizedBox(height: 10),

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

                              const SizedBox(height: 10),

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
                                        : 'السرد الصوتي مفعل',
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

                              // Bottom buttons
                              Directionality(
                                textDirection: TextDirection.rtl,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () {},
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: primaryPurple,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(14),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 14),
                                          elevation: 0,
                                        ),
                                        child: Text(
                                          'التالي',
                                          style: GoogleFonts.cairo(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () {},
                                        style: OutlinedButton.styleFrom(
                                          side: BorderSide(
                                              color: primaryPurple, width: 2),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(14),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 14),
                                        ),
                                        child: Text(
                                          'حاول مرة أخرى',
                                          style: GoogleFonts.cairo(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: primaryPurple,
                                          ),
                                        ),
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
                  ),
                ],
              ),
            ),
          ),

          // Return button always on top
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