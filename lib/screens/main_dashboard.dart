import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'progress_screen.dart';
import 'map_viewer_screen.dart';
import 'profile_screen.dart';
import 'node_progress_screen.dart';

class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key});

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  int _currentIndex = 1; // Default to 'Home' (Middle tab)

  Widget _buildBody(Map<String, dynamic>? userData) {
    switch (_currentIndex) {
      case 0:
        return const Center(child: Text('الخريطة (Map Full View) Placeholder'));
      case 1:
        return MapScreen(userData: userData);
      case 2:
        return const ProgressScreen();
      default:
        return MapScreen(userData: userData);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
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

        return Scaffold(
          body: _buildBody(userData),
          backgroundColor: Colors.white,
          // Custom floating bottom navigation bar
          bottomNavigationBar: SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNavItem(
                    index: 0,
                    title: 'الخريطة',
                    icon: Icons.map_outlined,
                    color: const Color(0xFF00C853), // Green
                  ),
                  _buildNavItem(
                    index: 1,
                    title: '',
                    icon: Icons.home_outlined,
                    color: const Color(0xFF9d4edd), // Purple
                    isHome: true,
                  ),
                  _buildNavItem(
                    index: 2,
                    title: 'الميداليات',
                    icon: Icons.emoji_events_outlined,
                    color: const Color(0xFFffb703), // Yellow/Orange
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavItem({
    required int index,
    required String title,
    required IconData icon,
    required Color color,
    bool isHome = false,
  }) {
    final bool isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () {
        if (index == 0) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MapViewerScreen()),
          );
        } else {
          setState(() {
            _currentIndex = index;
          });
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: isHome
            ? const EdgeInsets.all(16)
            : const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isHome
              ? color
              : isSelected
                  ? color
                  : color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(isHome ? 20 : 16),
        ),
        child: isHome
            ? Icon(
                icon,
                color: Colors.white,
                size: 32,
              )
            : Row(
                children: [
                  Icon(
                    icon,
                    color: isSelected ? Colors.white : color,
                    size: 24,
                  ),
                  if (title.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: GoogleFonts.cairo(
                        color: isSelected ? Colors.white : color,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}

class MapScreen extends StatelessWidget {
  final Map<String, dynamic>? userData;

  const MapScreen({super.key, this.userData});

  @override
  Widget build(BuildContext context) {
    final stars = (userData?['stars'] as int?) ?? 0;
    final displayName = (userData?['displayName'] as String?) ?? FirebaseAuth.instance.currentUser?.displayName ?? 'ضيف';
    final completedStages = (userData?['completedStages'] as Map<String, dynamic>?) ?? {};
    final tasksCompleted = completedStages.length;
    final taskTotal = 3;
    final progressPercent = ((tasksCompleted / taskTotal) * 100).round();

    return Stack(
      children: [
        // Background Map Image
        Positioned.fill(
          child: Image.asset(
            'assets/dashboard_bg.png',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: const Color(0xFF81D4FA), // Light blue fallback sky color
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.map, size: 64, color: Colors.white54),
                      const SizedBox(height: 16),
                      Text(
                        'Map Background Placeholder',
                        style: GoogleFonts.cairo(color: Colors.white54),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // Semi-transparent overlay to make UI pop if needed (Optional)
        // Positioned.fill(
        //   child: Container(color: Colors.black.withOpacity(0.1)),
        // ),

        // Top HUD Bar
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.only(top: 50, left: 16, right: 16, bottom: 16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white70,
                  Colors.transparent,
                ],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Star/Points Counter
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 8),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star_rounded, color: Color(0xFFffb703), size: 28),
                      const SizedBox(width: 8),
                      Text(
                        '$stars',
                        style: GoogleFonts.cairo(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),

                // User Profile Pill
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ProfileScreen()),
                    );
                  },
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
                        Text(
                          displayName,
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
              ],
            ),
          ),
        ),

        // Interactive Nodes (Positioned roughly based on the design)
        
        // Node 1: Purple (Unlocked/Current)
        Positioned(
          right: MediaQuery.of(context).size.width * 0.1,
          top: MediaQuery.of(context).size.height * 0.42,
          child: GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NodeProgressScreen(nodeTitle: 'آداب المترو')),
            ),
            child: _buildMapNode(
              icon: Icons.play_arrow_rounded,
              number: '1',
              label: 'آداب المترو',
              color: const Color(0xFF9d4edd), // Purple
              isLocked: false,
            ),
          ),
        ),

        // Node 2: Blue (Locked until Stage 1 complete)
        Positioned(
          left: MediaQuery.of(context).size.width * 0.1,
          top: MediaQuery.of(context).size.height * 0.4,
          child: GestureDetector(
            onTap: () {
              if (completedStages.containsKey('aedab')) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NodeProgressScreen(nodeTitle: 'كيف أتنقل')),
                );
              }
            },
            child: _buildMapNode(
              icon: completedStages.containsKey('aedab') ? Icons.play_arrow_rounded : Icons.lock_outline,
              number: '2',
              label: 'كيف أتنقل',
              color: const Color(0xFF1565C0), // Blue
              isLocked: !completedStages.containsKey('aedab'),
              isSecondaryColorText: true, // Blue has white text inside blue pill
            ),
          ),
        ),

        // Node 3: Green (Locked until Stage 2 complete)
        Positioned(
          right: MediaQuery.of(context).size.width * 0.5,
          bottom: MediaQuery.of(context).size.height * 0.15, // Adjusting bottom padding explicitly
          child: GestureDetector(
            onTap: () {
              if (completedStages.containsKey('travel')) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NodeProgressScreen(nodeTitle: 'ماذا أفعل عند الضياع')),
                );
              }
            },
            child: _buildMapNode(
              icon: completedStages.containsKey('travel') ? Icons.play_arrow_rounded : Icons.lock_outline,
              number: '3',
              label: 'ماذا أفعل\nعند الضياع',
              color: const Color(0xFF2E7D32), // Dark Green
              isLocked: !completedStages.containsKey('travel'),
              isSecondaryColorText: true, // Green has white text inside green pill
              multilineLabel: true,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMapNode({
    IconData? icon,
    String? number,
    required String label,
    required Color color,
    required bool isLocked,
    bool isSecondaryColorText = false,
    bool multilineLabel = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // The Circle Node
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isLocked ? const Color(0xFF1E293B).withValues(alpha: 0.8) : color,
            border: Border.all(
              color: Colors.white,
              width: 4,
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: isLocked
                ? const Icon(Icons.lock_outline, color: Colors.white, size: 32)
                : Text(
                    number ?? '1',
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      height: 1,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 8),
        // The Label Pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: isLocked ? color : color, // Using the passed color for the pill
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
              height: multilineLabel ? 1.2 : null,
            ),
          ),
        ),
      ],
    );
  }
}
