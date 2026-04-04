import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'feedback_screen.dart';

class QuizScreen extends StatefulWidget {
  final String stageKey;
  final String stageTitle;

  const QuizScreen({
    super.key,
    required this.stageKey,
    required this.stageTitle,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentIndex = 0;
  int _correctCount = 0;
  int? _selectedOption;
  bool _isAnswerRevealed = false;

  late final List<String> _stagePoints;
  late final List<Map<String, dynamic>> _questions;
final Map<String, Map<String, dynamic>> _stageData = {
  'aedab': {
    'points': [
      'الالتزام بالانتظار المنظم وعدم المزاحمة',
      'إظهار الاحترام لكبار السن داخل المترو',
      'المحافظة على الهدوء والنظافة أثناء الرحلة',
    ],
    'questions': [
      {
        'question': 'ماذا يجب أن تفعل إذا رأيت شخصاً كبيراً في السن واقفاً في المترو؟',
        'options': ['تجاهله', 'الوقوف بعيداً عنه', 'إعطاؤه المقعد'],
        'correct': 2,
      },
      {
        'question': 'ما التصرف الصحيح عند دخول المترو؟',
        'options': ['المزاحمة والدخول بسرعة', 'الانتظار في صف منظم', 'الركض داخل المحطة'],
        'correct': 1,
      },
    ],
  },

  'travel': {
    'points': [
      'التعرف على خطوط المترو عبر خريطة تطبيق وضاح.',
      'معرفة المحطة الحالية والوجهة قبل بدء الرحلة.',
      'متابعة المحطات ومعرفة أماكن الانتقال بين الخطوط',
    ],
    'questions': [
      {
        'question': 'ما أول خطوة لمعرفة طريقك في المترو؟',
        'options': ['ركوب أي قطار', 'فتح خريطة المترو', 'النزول في أي محطة'],
        'correct': 1,
      },
      {
        'question': 'ماذا يجب أن تفعل أثناء الرحلة في المترو؟',
        'options': ['متابعة اسم المحطة الحالية والمحطة التالية', 'تجاهل أسماء المحطات', 'تغيير القطار في كل محطة'],
        'correct': 0,
      },
    ],
  },

  'lost': {
    'points': [
      'حافظ على هدوئك إذا انفصلت عن ولي أمرك في المترو.',
      'ابق في مكان آمن واطلب المساعدة من موظف المترو.',
      'أخبر الموظف برقم ولي أمرك.',
    ],
    'questions': [
      {
        'question': 'إذا انفصلت عن ولي أمرك في المترو ماذا يجب أن تفعل؟',
        'options': ['تركض في المحطة وتبحث عنه', 'تبقى هادئًا وتطلب المساعدة من موظف', 'تصعد إلى قطار آخر'],
        'correct': 1,
      },
      {
        'question': 'أين يجب أن تنتظر إذا انفصلت عن ولي أمرك؟',
        'options': ['خارج المحطة', 'في القطار التالي', 'في مكانك أو قرب موظف المترو'],
        'correct': 2,
      },
    ],
  },
};
  int get earnedStars => _correctCount * 10;

  @override
  void initState() {
    super.initState();
    final stage = _stageData[widget.stageKey] ?? _stageData['aedab']!;
    _stagePoints = List<String>.from(stage['points'] as List<dynamic>);
    _questions = List<Map<String, dynamic>>.from(stage['questions'] as List<dynamic>);
  }

  void _selectOption(int index) {
    if (_isAnswerRevealed) return;
    setState(() {
      _selectedOption = index;
      _isAnswerRevealed = true;
      if (index == _questions[_currentIndex]['correct']) {
        _correctCount += 1;
      }
    });
  }

  Future<void> _saveQuizProgress() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
      await userDoc.set({
        'stars': FieldValue.increment(earnedStars),
        'completedStages': {
          widget.stageKey: {
            'correctAnswers': _correctCount,
            'totalQuestions': _questions.length,
            'earnedStars': earnedStars,
            'completedAt': FieldValue.serverTimestamp(),
          }
        }
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Firebase Write Error in Quiz bypassed: $e');
    }
  }

  Future<void> _nextQuestion() async {
    if (_selectedOption == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'يرجى اختيار أحد الخيارات أولاً',
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (_currentIndex == _questions.length - 1) {
      await _saveQuizProgress();
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => FeedbackScreen(
            totalQuestions: _questions.length,
            correctAnswers: _correctCount,
            earnedStars: earnedStars,
            stageKey: widget.stageKey,
            stageTitle: widget.stageTitle,
          ),
        ),
      );
      return;
    }

    setState(() {
      _currentIndex += 1;
      _selectedOption = null;
      _isAnswerRevealed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final question = _questions[_currentIndex];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFCCB6FF),
              Color(0xFFB4F5DD),
            ],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 16),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 25),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            )
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_forward, color: Color(0xFF00C853)),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: Colors.white,
                        child: Image.asset('assets/UI/RoundLogo.png', height: 48, width: 48, fit: BoxFit.contain),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'الاختبار',
                        style: GoogleFonts.cairo(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF7C33FF),
                        ),
                      ),
                    ],
                  ),
                ),

                // const SizedBox(height: 16),
                // Padding(
                //   padding: const EdgeInsets.symmetric(horizontal: 20.0),
                //   child: Container(
                //     width: double.infinity,
                //     decoration: BoxDecoration(
                //       color: Colors.white,
                //       borderRadius: BorderRadius.circular(24),
                //       boxShadow: [
                //         BoxShadow(
                //           color: Colors.black.withValues(alpha: 13),
                //           blurRadius: 10,
                //           offset: const Offset(0, 4),
                //         )
                //       ],
                //     ),
                //     child: Padding(
                //       padding: const EdgeInsets.all(16.0),
                //       child: Column(
                //         crossAxisAlignment: CrossAxisAlignment.end,
                //         children: [
                //           Text(
                //             'نقاط أساسية',
                //             textAlign: TextAlign.right,
                //             style: GoogleFonts.cairo(
                //               fontWeight: FontWeight.bold,
                //               fontSize: 18,
                //               color: const Color(0xFF1F2937),
                //             ),
                //           ),
                //           const SizedBox(height: 8),
                //           ..._stagePoints.map(
                //             (point) => Padding(
                //               padding: const EdgeInsets.symmetric(vertical: 4.0),
                //               child: Row(
                //                 children: [
                //                   const Icon(Icons.check_circle, color: Color(0xFF00C853), size: 18),
                //                   const SizedBox(width: 8),
                //                   Expanded(
                //                     child: Text(
                //                       point,
                //                       textAlign: TextAlign.right,
                //                       style: GoogleFonts.cairo(
                //                         fontSize: 14,
                //                         color: const Color(0xFF334155),
                //                         fontWeight: FontWeight.w600,
                //                       ),
                //                     ),
                //                   ),
                //                 ],
                //               ),
                //             ),
                //           ),
                //         ],
                //       ),
                //     ),
                //   ),
                // ),

                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 13),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            question['question'],
                            textAlign: TextAlign.right,
                            style: GoogleFonts.cairo(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1F2937),
                            ),
                          ),
                          const SizedBox(height: 14),
                          ...List.generate(3, (optionIndex) {
                            final isSelected = _selectedOption == optionIndex;
                            final isTargetCorrect = question['correct'] == optionIndex;
                            
                            // Determine colors and icons based on reveal state
                            Color borderColor = const Color(0xFFE2E8F0);
                            Color backgroundColor = Colors.white;
                            Color iconBgColor = const Color(0xFF94A3B8);
                            Widget? feedbackIcon;

                            if (_isAnswerRevealed) {
                              if (isTargetCorrect) {
                                // Correct option is always highlighted green when revealed
                                borderColor = const Color(0xFF22C55E);
                                backgroundColor = const Color(0xFFDCFCE7);
                                iconBgColor = const Color(0xFF22C55E);
                                feedbackIcon = const Icon(Icons.check_circle, color: Color(0xFF22C55E), size: 24);
                              } else if (isSelected) {
                                // Chosen wrong option is highlighted red
                                borderColor = const Color(0xFFEF4444);
                                backgroundColor = const Color(0xFFFEE2E2);
                                iconBgColor = const Color(0xFFEF4444);
                                feedbackIcon = const Icon(Icons.cancel, color: Color(0xFFEF4444), size: 24);
                              }
                            } else if (isSelected) {
                              // Before reveal, selected option has standard highlight (though selection is immediate)
                              borderColor = const Color(0xFF22C55E);
                              backgroundColor = const Color(0xFFEDE9FE);
                              iconBgColor = const Color(0xFF00C853);
                            }

                            return GestureDetector(
                              onTap: _isAnswerRevealed ? null : () => _selectOption(optionIndex),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                decoration: BoxDecoration(
                                  color: backgroundColor,
                                  border: Border.all(color: borderColor, width: 1.5),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    if (feedbackIcon != null) ...[
                                      feedbackIcon,
                                      const SizedBox(width: 12),
                                    ],
                                    Expanded(
                                      child: Text(
                                        question['options'][optionIndex],
                                        textAlign: TextAlign.right,
                                        style: GoogleFonts.cairo(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF1F2937),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    CircleAvatar(
                                      radius: 14,
                                      backgroundColor: iconBgColor,
                                      child: Text(
                                        ['أ', 'ب', 'ج'][optionIndex],
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ),

                const Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                  child: ElevatedButton(
                    onPressed: _nextQuestion,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00C853),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      minimumSize: const Size.fromHeight(52),
                    ),
                    child: Text(
                      _currentIndex == _questions.length - 1 ? 'إنهاء الاختبار' : 'السؤال التالي',
                      style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  ),
),
      ),
    );
  }
}
