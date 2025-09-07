import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:undercover_game/audioplayers/sound_manager.dart';
import 'package:undercover_game/models/enums.dart';
import 'package:undercover_game/models/players.dart';
import 'package:undercover_game/screens/role_reveal_screen.dart';
import 'package:undercover_game/screens/leaderboard_screen.dart';
import 'package:undercover_game/services/score_manager.dart';

class PostGameScreen extends StatefulWidget {
  final List<Player> players;
  final String winner;
  final String civilianWord;
  final String spyWord;
  final int roundsPlayed;
  final int totalPlayers;
  final int numSpies;
  final int numMrWhites;
  final Language language;

  const PostGameScreen({
    super.key,
    required this.players,
    required this.winner,
    required this.civilianWord,
    required this.spyWord,
    required this.roundsPlayed,
    required this.totalPlayers,
    required this.numSpies,
    required this.numMrWhites,
    required this.language,
  });

  @override
  State<PostGameScreen> createState() => _PostGameScreenState();
}

class _PostGameScreenState extends State<PostGameScreen>
    with TickerProviderStateMixin {
  bool _scoresSaved = false;
  late AnimationController _confettiController;
  late AnimationController _pulseController;
  bool _showStats = false;

  @override
  void initState() {
    super.initState();
    _confettiController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _saveScores();
    _confettiController.forward();
    _pulseController.repeat();

    // Show stats after a delay
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _showStats = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _saveScores() async {
    print('Saving game results');
    await ScoreManager.instance.saveGameResults(
      widget.players,
      widget.winner,
      widget.roundsPlayed,
    );
    if (mounted) {
      setState(() {
        _scoresSaved = true;
      });
    }
    print('Scores saved successfully');
  }

  void _startNewRound() {
    print('Starting new round');
    final resetPlayers = widget.players.map((p) {
      return Player(p.name, Role.civilian)..eliminated = false;
    }).toList();
    final playerNames = resetPlayers.map((p) => p.name).toList();

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            RoleRevealScreen(
              playerNames: playerNames,
              numSpies: widget.numSpies,
              numMrWhites: widget.numMrWhites,
              language: widget.language,
            ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
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
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  void _viewLeaderboard() {
    print('Navigating to LeaderboardScreen');
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const LeaderboardScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position:
                Tween<Offset>(
                  begin: const Offset(0.0, 1.0),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeInOutCubic,
                  ),
                ),
            child: FadeTransition(opacity: animation, child: child),
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  void _endSession() {
    print('Ending session');
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  Widget _buildGlassCard({required Widget child, double? height}) {
    return Container(
      height: height,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.15),
            Colors.white.withOpacity(0.05),
          ],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 30,
            spreadRadius: -10,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(padding: const EdgeInsets.all(24), child: child),
        ),
      ),
    );
  }

  Widget _buildModernButton({
    required String text,
    required IconData icon,
    required VoidCallback onTap,
    required Color primaryColor,
    bool enabled = true,
    bool isPrimary = false,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: enabled ? onTap : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: enabled
                  ? (isPrimary
                        ? LinearGradient(
                            colors: [
                              primaryColor,
                              primaryColor.withOpacity(0.8),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null)
                  : null,
              color: enabled
                  ? (isPrimary ? null : primaryColor.withOpacity(0.2))
                  : Colors.grey.withOpacity(0.3),
              border: Border.all(
                color: enabled
                    ? primaryColor.withOpacity(0.5)
                    : Colors.grey.withOpacity(0.3),
                width: 2,
              ),
              boxShadow: enabled && isPrimary
                  ? [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.4),
                        blurRadius: 20,
                        spreadRadius: 0,
                        offset: const Offset(0, 10),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: enabled
                      ? (isPrimary ? Colors.white : primaryColor)
                      : Colors.grey,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  text,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: enabled
                        ? (isPrimary ? Colors.white : primaryColor)
                        : Colors.grey,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingParticle(double size, Color color, Offset position) {
    return Positioned(
      left: position.dx,
      top: position.dy,
      child:
          Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withOpacity(0.6),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: size * 0.8,
                      spreadRadius: size * 0.2,
                    ),
                  ],
                ),
              )
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .scale(
                duration: (3000 + (size * 10).toInt()).ms,
                curve: Curves.easeInOut,
              )
              .then()
              .moveY(
                begin: 0,
                end: -50,
                duration: (4000 + (size * 15).toInt()).ms,
                curve: Curves.easeInOut,
              ),
    );
  }

  Widget _buildWinnerDisplay() {
    final isSpyWin =
        widget.winner.toLowerCase().contains('undercover') ||
        widget.winner.toLowerCase().contains('spy');
    final winnerColor = isSpyWin ? Colors.red : Colors.green;

    return Column(
      children: [
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Transform.scale(
              scale: 1.0 + (_pulseController.value * 0.1),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      winnerColor.withOpacity(0.3),
                      winnerColor.withOpacity(0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Icon(
                  isSpyWin ? Icons.psychology : Icons.shield,
                  size: 80,
                  color: winnerColor,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        Text(
              widget.winner,
              style: GoogleFonts.inter(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 1,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
            )
            .animate()
            .fadeIn(duration: 800.ms, curve: Curves.easeOut)
            .slideY(begin: 30, end: 0, duration: 800.ms, curve: Curves.easeOut),
      ],
    );
  }

  Widget _buildGameSummary() {
    return _buildGlassCard(
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: [
                      Colors.amber.withOpacity(0.3),
                      Colors.orange.withOpacity(0.3),
                    ],
                  ),
                ),
                child: const Icon(
                  Icons.summarize,
                  color: Colors.amber,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Game Summary',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildWordCard(
                  title: 'Civilian Word',
                  word: widget.civilianWord,
                  color: Colors.green,
                  icon: Icons.shield,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildWordCard(
                  title: 'Spy Word',
                  word: widget.spyWord,
                  color: Colors.red,
                  icon: Icons.psychology,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white.withOpacity(0.1),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStat('Rounds', widget.roundsPlayed.toString()),
                _buildStat('Players', widget.totalPlayers.toString()),
                _buildStat('Spies', widget.numSpies.toString()),
                _buildStat('Mr. White', widget.numMrWhites.toString()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWordCard({
    required String title,
    required String word,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [color.withOpacity(0.2), color.withOpacity(0.1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            word,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildPlayerPerformance() {
    if (!_showStats) return const SizedBox.shrink();

    return _buildGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue.withOpacity(0.3),
                      Colors.purple.withOpacity(0.3),
                    ],
                  ),
                ),
                child: const Icon(Icons.people, color: Colors.blue, size: 24),
              ),
              const SizedBox(width: 16),
              Text(
                'Player Performance',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...widget.players.asMap().entries.map((entry) {
            final index = entry.key;
            final player = entry.value;
            final won =
                (widget.winner.contains('Civilians') &&
                    player.role.name == 'civilian') ||
                (widget.winner.contains('Undercovers') &&
                    (player.role.name == 'spy' ||
                        player.role.name == 'mrWhite'));

            return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: won
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    border: Border.all(
                      color: won
                          ? Colors.green.withOpacity(0.3)
                          : Colors.red.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: won
                                ? [Colors.green, Colors.green.shade300]
                                : [Colors.red, Colors.red.shade300],
                          ),
                        ),
                        child: Icon(
                          won ? Icons.emoji_events : Icons.close,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              player.name,
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              player.role.name.toUpperCase(),
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withOpacity(0.7),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (player.eliminated)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.red.withOpacity(0.2),
                            border: Border.all(
                              color: Colors.red.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            'ELIMINATED',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.red,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                    ],
                  ),
                )
                .animate()
                .fadeIn(delay: (index * 100).ms, duration: 400.ms)
                .slideX(
                  begin: -50,
                  end: 0,
                  delay: (index * 100).ms,
                  duration: 400.ms,
                  curve: Curves.easeOut,
                );
          }).toList(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Game Over',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.1),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: const Icon(Icons.home, size: 20),
          ),
          onPressed: _endSession,
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0a0a23), Color(0xFF1a1a3a), Color(0xFF2a1a4a)],
          ),
        ),
        child: Stack(
          children: [
            // Floating particles
            _buildFloatingParticle(8, Colors.blue, const Offset(50, 100)),
            _buildFloatingParticle(6, Colors.purple, const Offset(300, 200)),
            _buildFloatingParticle(10, Colors.amber, const Offset(100, 400)),
            _buildFloatingParticle(4, Colors.green, const Offset(250, 500)),
            _buildFloatingParticle(7, Colors.red, const Offset(30, 600)),

            SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    _buildWinnerDisplay(),
                    const SizedBox(height: 32),
                    _buildGameSummary()
                        .animate()
                        .fadeIn(delay: 500.ms, duration: 600.ms)
                        .slideY(begin: 30, end: 0, delay: 500.ms),
                    const SizedBox(height: 24),

                    // Score saving status
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: (_scoresSaved ? Colors.green : Colors.orange)
                            .withOpacity(0.1),
                        border: Border.all(
                          color: (_scoresSaved ? Colors.green : Colors.orange)
                              .withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _scoresSaved ? Icons.check_circle : Icons.sync,
                            color: _scoresSaved ? Colors.green : Colors.orange,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _scoresSaved ? 'Scores Saved!' : 'Saving Scores...',
                            style: GoogleFonts.inter(
                              color: _scoresSaved
                                  ? Colors.green
                                  : Colors.orange,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 400.ms),

                    const SizedBox(height: 32),

                    // Action buttons
                    _buildModernButton(
                          text: 'PLAY AGAIN',
                          icon: Icons.refresh,
                          onTap: _startNewRound,
                          primaryColor: Colors.green,
                          isPrimary: true,
                        )
                        .animate()
                        .fadeIn(delay: 800.ms, duration: 400.ms)
                        .slideY(begin: 20, end: 0, delay: 800.ms),

                    const SizedBox(height: 16),

                    _buildModernButton(
                          text: 'VIEW LEADERBOARD',
                          icon: Icons.leaderboard,
                          onTap: _viewLeaderboard,
                          primaryColor: Colors.amber,
                          enabled: _scoresSaved,
                        )
                        .animate()
                        .fadeIn(delay: 900.ms, duration: 400.ms)
                        .slideY(begin: 20, end: 0, delay: 900.ms),

                    const SizedBox(height: 16),

                    _buildModernButton(
                          text: 'END SESSION',
                          icon: Icons.logout,
                          onTap: _endSession,
                          primaryColor: Colors.red,
                        )
                        .animate()
                        .fadeIn(delay: 1000.ms, duration: 400.ms)
                        .slideY(begin: 20, end: 0, delay: 1000.ms),

                    const SizedBox(height: 32),

                    if (_scoresSaved) _buildPlayerPerformance(),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
