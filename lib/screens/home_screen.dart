import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:undercover_game/screens/card_selection_screen.dart';
import 'package:undercover_game/screens/leaderboard_screen.dart';
import 'package:undercover_game/screens/word_management_screen.dart';
import 'package:undercover_game/widgets/number_selector.dart';
import 'package:undercover_game/models/enums.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _totalPlayers = 5;
  int _numSpies = 1;
  int _numMrWhites = 1;
  Language _selectedLanguage = Language.english;
  bool _isSoundOn = true;
  bool _showSettings = false;

  // Animation controllers
  late AnimationController _particleController;
  late AnimationController _pulseController;
  late AnimationController _rotationController;

  // Audio players
  final AudioPlayer _bgmPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();

  // Background music list
  final List<String> _bgmList = [
    'audio/background_music_1.mp3',
    'audio/background_music_2.mp3',
    'audio/background_music_3.mp3',
    'audio/background_music_4.mp3',
    'audio/background_music_5.mp3',
    'audio/background_music_6.mp3',
    'audio/background_music_7.mp3',
  ];

  // Current background music index
  int _currentBgmIndex = 0;

  // Random number generator
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _selectRandomBgm();
    _playBackgroundMusic();
  }

  void _initializeAnimations() {
    _particleController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _pulseController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _rotationController = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    )..repeat();
  }

  void _selectRandomBgm() {
    _currentBgmIndex = _random.nextInt(_bgmList.length);
  }

  void _selectNextBgm() {
    _currentBgmIndex = (_currentBgmIndex + 1) % _bgmList.length;
  }

  Future<void> _playBackgroundMusic() async {
    if (_isSoundOn) {
      await _bgmPlayer.setSource(AssetSource(_bgmList[_currentBgmIndex]));
      await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
      await _bgmPlayer.resume();

      // Listen for when the current song completes to play the next one
      _bgmPlayer.onPlayerComplete.listen((event) {
        if (_isSoundOn) {
          _selectNextBgm();
          _playBackgroundMusic();
        }
      });
    }
  }

  Future<void> _stopBackgroundMusic() async {
    await _bgmPlayer.stop();
  }

  Future<void> _playButtonClickSound() async {
    if (_isSoundOn) {
      await _sfxPlayer.play(AssetSource('audio/button_click.mp3'));
    }
  }

  void _toggleSound() {
    setState(() {
      _isSoundOn = !_isSoundOn;
      if (_isSoundOn) {
        _playBackgroundMusic();
      } else {
        _stopBackgroundMusic();
      }
    });
    HapticFeedback.lightImpact();
  }

  @override
  void dispose() {
    _particleController.dispose();
    _pulseController.dispose();
    _rotationController.dispose();
    _bgmPlayer.dispose();
    _sfxPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Animated background
          _buildAnimatedBackground(size),

          // Particle system
          _buildParticleSystem(size),

          // Main content
          SafeArea(child: _buildMainContent(context)),

          // Top bar with settings
          _buildTopBar(context),

          // Created by text at bottom
          _buildCreatedByText(),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground(Size size) {
    return Stack(
      children: [
        // Base gradient
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF0a0a0a),
                Color(0xFF1a0a2e),
                Color(0xFF16213e),
                Color(0xFF0f0f23),
              ],
              stops: [0.0, 0.3, 0.7, 1.0],
            ),
          ),
        ),

        // Animated orbs
        AnimatedBuilder(
          animation: _rotationController,
          builder: (context, child) {
            return Stack(
              children: [
                _buildOrb(
                  size: size.width * 0.8,
                  color: const Color(0xFF6366f1),
                  opacity: 0.1,
                  offset: Offset(
                    size.width * 0.8 * cos(_rotationController.value * 2 * pi),
                    size.height * 0.3 +
                        size.height *
                            0.2 *
                            sin(_rotationController.value * 2 * pi),
                  ),
                ),
                _buildOrb(
                  size: size.width * 0.6,
                  color: const Color(0xFFa855f7),
                  opacity: 0.08,
                  offset: Offset(
                    size.width * 0.2 +
                        size.width *
                            0.3 *
                            cos(_rotationController.value * 2 * pi + pi),
                    size.height * 0.7 +
                        size.height *
                            0.15 *
                            sin(_rotationController.value * 2 * pi + pi),
                  ),
                ),
                _buildOrb(
                  size: size.width * 0.5,
                  color: const Color(0xFF06b6d4),
                  opacity: 0.06,
                  offset: Offset(
                    size.width * 0.1 +
                        size.width *
                            0.4 *
                            cos(_rotationController.value * 2 * pi + pi / 2),
                    size.height * 0.1 +
                        size.height *
                            0.3 *
                            sin(_rotationController.value * 2 * pi + pi / 2),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildOrb({
    required double size,
    required Color color,
    required double opacity,
    required Offset offset,
  }) {
    return Positioned(
      left: offset.dx - size / 2,
      top: offset.dy - size / 2,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withOpacity(opacity),
              color.withOpacity(opacity * 0.5),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildParticleSystem(Size size) {
    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, child) {
        return CustomPaint(
          size: size,
          painter: ParticlePainter(_particleController.value),
        );
      },
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      right: 16,
      child: Row(
        children: [
          _buildTopBarButton(
            icon: _isSoundOn ? Icons.volume_up : Icons.volume_off,
            onTap: _toggleSound,
          ),
          const SizedBox(width: 12),
          _buildTopBarButton(
            icon: Icons.settings,
            onTap: () => setState(() => _showSettings = !_showSettings),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBarButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        onTap();
        HapticFeedback.lightImpact();
      },
      child:
          Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              )
              .animate()
              .fadeIn(duration: 600.ms)
              .scale(delay: 200.ms, duration: 400.ms),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 40),

              // Title section
              _buildTitle(),

              const SizedBox(height: 60),

              // Settings panel
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOutCubic,
                height: _showSettings ? null : 0,
                child: AnimatedOpacity(
                  opacity: _showSettings ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: _buildSettingsPanel(),
                ),
              ),

              if (_showSettings) const SizedBox(height: 40),

              // Action buttons
              _buildActionButtons(context),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      children: [
        AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Transform.scale(
                  scale: 1.0 + (_pulseController.value * 0.05),
                  child: ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: [
                        const Color(0xFF6366f1),
                        const Color(0xFFa855f7),
                        const Color(0xFF06b6d4),
                      ],
                    ).createShader(bounds),
                    child: Text(
                      "UNDERCOVER",
                      style: GoogleFonts.orbitron(
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 6,
                        height: 1.0,
                      ),
                    ),
                  ),
                );
              },
            )
            .animate()
            .fadeIn(duration: 1200.ms)
            .slideY(
              begin: -0.3,
              end: 0,
              duration: 800.ms,
              curve: Curves.easeOutBack,
            ),

        const SizedBox(height: 16),

        Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.1),
                    Colors.white.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Text(
                "Unmask the Deceivers",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1,
                ),
              ),
            )
            .animate()
            .fadeIn(delay: 600.ms, duration: 800.ms)
            .slideY(begin: 0.3, end: 0, duration: 600.ms),
      ],
    );
  }

  Widget _buildSettingsPanel() {
    return ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Game Settings",
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Player settings
                  _buildEnhancedNumberSelector(
                    label: "Total Players",
                    value: _totalPlayers,
                    min: 3,
                    max: 12,
                    onChanged: (value) {
                      setState(() {
                        _totalPlayers = value;
                        if (_numSpies + _numMrWhites >= _totalPlayers) {
                          _numSpies = max(0, min(_numSpies, _totalPlayers - 1));
                          _numMrWhites = max(
                            0,
                            min(_numMrWhites, _totalPlayers - _numSpies - 1),
                          );
                        }
                      });
                      HapticFeedback.selectionClick();
                    },
                  ),

                  const SizedBox(height: 20),

                  _buildEnhancedNumberSelector(
                    label: "Spies",
                    value: _numSpies,
                    min: 0,
                    max: _totalPlayers - _numMrWhites - 1,
                    onChanged: (value) {
                      setState(() => _numSpies = value);
                      HapticFeedback.selectionClick();
                    },
                  ),

                  const SizedBox(height: 20),

                  _buildEnhancedNumberSelector(
                    label: "Mr. Whites",
                    value: _numMrWhites,
                    min: 0,
                    max: _totalPlayers - _numSpies - 1,
                    onChanged: (value) {
                      setState(() => _numMrWhites = value);
                      HapticFeedback.selectionClick();
                    },
                  ),

                  const SizedBox(height: 24),

                  // Language selection
                  Text(
                    "Language",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children:
                        {
                          "English": Language.english,
                          "العربية": Language.arabic,
                        }.entries.map((entry) {
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              child: _buildEnhancedLangChip(
                                entry.key,
                                entry.value,
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                ],
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideY(
          begin: -0.2,
          end: 0,
          duration: 500.ms,
          curve: Curves.easeOutCubic,
        );
  }

  Widget _buildEnhancedNumberSelector({
    required String label,
    required int value,
    required int min,
    required int max,
    required ValueChanged<int> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildControlButton(
              icon: Icons.remove,
              onTap: value > min ? () => onChanged(value - 1) : null,
            ),

            const SizedBox(width: 16),

            Container(
              width: 60,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  value.toString(),
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 16),

            _buildControlButton(
              icon: Icons.add,
              onTap: value < max ? () => onChanged(value + 1) : null,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback? onTap,
  }) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          gradient: enabled
              ? LinearGradient(
                  colors: [
                    const Color(0xFF6366f1).withOpacity(0.8),
                    const Color(0xFFa855f7).withOpacity(0.8),
                  ],
                )
              : null,
          color: enabled ? null : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: enabled
                ? Colors.white.withOpacity(0.3)
                : Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          color: enabled ? Colors.white : Colors.white.withOpacity(0.3),
          size: 20,
        ),
      ),
    );
  }

  Widget _buildEnhancedLangChip(String text, Language lang) {
    final bool selected = _selectedLanguage == lang;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedLanguage = lang);
        HapticFeedback.selectionClick();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: selected
              ? LinearGradient(
                  colors: [const Color(0xFF6366f1), const Color(0xFFa855f7)],
                )
              : null,
          color: selected ? null : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? Colors.white.withOpacity(0.4)
                : Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
          children: [
            // Start game button (main CTA)
            _buildEnhancedButton(
              text: "START GAME",
              icon: Icons.play_arrow_rounded,
              gradient: const LinearGradient(
                colors: [Color(0xFF10b981), Color(0xFF059669)],
              ),
              onTap: () {
                if (_numSpies + _numMrWhites >= _totalPlayers) {
                  _showErrorSnackBar(
                    context,
                    'Spies + Mr. Whites must be less than total players.',
                  );
                  return;
                }
                HapticFeedback.lightImpact();
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        CardSelectionScreen(
                          totalPlayers: _totalPlayers,
                          numSpies: _numSpies,
                          numMrWhites: _numMrWhites,
                          language: _selectedLanguage,
                        ),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                          return SlideTransition(
                            position:
                                Tween<Offset>(
                                  begin: const Offset(1.0, 0.0),
                                  end: Offset.zero,
                                ).animate(
                                  CurvedAnimation(
                                    parent: animation,
                                    curve: Curves.easeInOutCubic,
                                  ),
                                ),
                            child: child,
                          );
                        },
                  ),
                );
              },
              isMain: true,
            ),

            const SizedBox(height: 20),

            // Secondary buttons
            Row(
              children: [
                Expanded(
                  child: _buildEnhancedButton(
                    text: "LEADERBOARD",
                    icon: Icons.leaderboard_rounded,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFf59e0b), Color(0xFFd97706)],
                    ),
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LeaderboardScreen(),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(width: 5),

                Expanded(
                  child: _buildEnhancedButton(
                    text: "MANAGE",
                    icon: Icons.edit_note_rounded,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF3b82f6), Color(0xFF1d4ed8)],
                    ),
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const WordManagementScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Exit button
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.5,
              child: _buildEnhancedButton(
                text: "EXIT",
                icon: Icons.exit_to_app_rounded,
                gradient: const LinearGradient(
                  colors: [Color(0xFFef4444), Color(0xFFdc2626)],
                ),
                onTap: () {
                  _playButtonClickSound();
                  HapticFeedback.lightImpact();
                  _showExitDialog(context);
                },
              ),
            ),
          ],
        )
        .animate()
        .fadeIn(delay: 800.ms, duration: 600.ms)
        .slideY(
          begin: 0.3,
          end: 0,
          duration: 800.ms,
          curve: Curves.easeOutBack,
        );
  }

  Widget _buildEnhancedButton({
    required String text,
    required IconData icon,
    required Gradient gradient,
    required VoidCallback onTap,
    bool isMain = false,
  }) {
    return GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              vertical: isMain ? 20 : 16,
              horizontal: 16,
            ),
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: gradient.colors.last.withOpacity(0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: gradient.colors.first.withOpacity(0.2),
                  blurRadius: 25,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: isMain ? 24 : 20),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    text,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: isMain ? 18 : 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
        .animate()
        .shimmer(delay: 2000.ms, duration: 2000.ms)
        .then()
        .shimmer(delay: 3000.ms, duration: 2000.ms);
  }

  Widget _buildCreatedByText() {
    return Positioned(
      bottom: 16,
      left: 0,
      right: 0,
      child: Center(
        child: Text(
          "Created by Haggui",
          style: GoogleFonts.poppins(
            color: Colors.white.withOpacity(0.6),
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
        ).animate().fadeIn(delay: 1500.ms, duration: 1000.ms),
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
        ),
        backgroundColor: const Color(0xFFef4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
    HapticFeedback.heavyImpact();
  }

  void _showExitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: AlertDialog(
          backgroundColor: Colors.black.withOpacity(0.8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Exit Game?',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            'Are you sure you want to exit the game?',
            style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.8)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(
                  color: Colors.white.withOpacity(0.6),
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                SystemNavigator.pop();
              },
              child: Text(
                'Exit',
                style: GoogleFonts.poppins(
                  color: const Color(0xFFef4444),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ParticlePainter extends CustomPainter {
  final double animationValue;

  ParticlePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 1;

    // Draw floating particles
    for (int i = 0; i < 50; i++) {
      final x = (size.width * (i * 0.13 + animationValue * 0.5)) % size.width;
      final y = (size.height * (i * 0.17 + animationValue * 0.3)) % size.height;

      canvas.drawCircle(
        Offset(x, y),
        (sin(animationValue * 2 * pi + i) + 1) * 1.5,
        paint
          ..color = Colors.white.withOpacity(
            0.1 + 0.05 * sin(animationValue * 2 * pi + i),
          ),
      );
    }

    // Draw connecting lines
    paint.strokeWidth = 0.5;
    for (int i = 0; i < 20; i++) {
      final x1 = (size.width * (i * 0.23 + animationValue * 0.4)) % size.width;
      final y1 =
          (size.height * (i * 0.31 + animationValue * 0.6)) % size.height;
      final x2 =
          (size.width * ((i + 1) * 0.23 + animationValue * 0.4)) % size.width;
      final y2 =
          (size.height * ((i + 1) * 0.31 + animationValue * 0.6)) % size.height;

      if ((x2 - x1).abs() < size.width * 0.3 &&
          (y2 - y1).abs() < size.height * 0.3) {
        canvas.drawLine(
          Offset(x1, y1),
          Offset(x2, y2),
          paint..color = Colors.white.withOpacity(0.03),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
