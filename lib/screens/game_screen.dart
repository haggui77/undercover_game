import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:undercover_game/audioplayers/sound_manager.dart';
import 'package:undercover_game/models/enums.dart';
import 'package:undercover_game/models/players.dart';
import 'package:undercover_game/screens/interrogation_vote_screen.dart';
import 'package:undercover_game/screens/mr_white_guess_screen.dart';
import 'package:undercover_game/screens/post_game_screen.dart';
import 'package:undercover_game/screens/verify_player_screen.dart';

class GameScreen extends StatefulWidget {
  final List<Player> players;
  final String civilianWord;
  final String spyWord;
  final Language language;

  const GameScreen({
    super.key,
    required this.players,
    required this.civilianWord,
    required this.spyWord,
    required this.language,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late List<Player> players;
  TieBreaker? tieBreaker;
  Phase get currentPhase =>
      tieBreaker != null ? Phase.interrogation : _currentPhase;
  Phase _currentPhase = Phase.describe;
  int currentIndex = 0;
  Map<Player, int> votes = {};
  Player? eliminatedThisRound;
  String? winner;
  Player? selectedPlayer;
  bool showConfirmButton = false;
  int roundsPlayed = 0;
  late List<Player> descriptionOrder;
  late List<Player> votingOrder;
  final Random random = Random();

  // Audio player for SFX
  final AudioPlayer _sfxPlayer = AudioPlayer();

  // Animation controllers
  late AnimationController _pulseController;
  late AnimationController _glowController;
  late AnimationController _celebrationController;

  @override
  void initState() {
    super.initState();
    players = widget.players;

    // Shuffle players for complete randomization
    players.shuffle(random);

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _celebrationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    // Initialize description order
    _shuffleDescriptionOrder();
  }

  void _shuffleDescriptionOrder() {
    final activePlayers = _getActivePlayers();
    descriptionOrder = List.from(activePlayers)..shuffle(random);
  }

  void _shuffleVotingOrder() {
    final activePlayers = _getActivePlayers();
    votingOrder = List.from(activePlayers)..shuffle(random);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _glowController.dispose();
    _celebrationController.dispose();
    super.dispose();
  }

  // Play SFX helper with haptic feedback
  Future<void> _playSfx(String fileName) async {
    HapticFeedback.lightImpact();
    await _sfxPlayer.play(AssetSource('audio/$fileName.mp3'));
  }

  List<Player> _getActivePlayers() {
    return players.where((p) => !p.eliminated).toList();
  }

  void _proceedAfterResults() {
    final remaining = _getActivePlayers();
    final numUndercover = remaining
        .where((p) => p.role != Role.civilian)
        .length;

    print(
      'Debug: Before proceed - roundsPlayed=$roundsPlayed, numUndercover=$numUndercover, remaining=${remaining.length}',
    ); // Debug print

    if (numUndercover == 0) {
      roundsPlayed++; // Increment for the completed round before ending
      winner = 'Civilians win!';
      setState(() {
        _currentPhase = Phase.gameOver;
      });
      print('Debug: Civilians win - final roundsPlayed=$roundsPlayed'); // Debug
    } else if (numUndercover >= remaining.length - 1) {
      roundsPlayed++; // Increment for the completed round before ending
      winner = 'Undercovers win!';
      setState(() {
        _currentPhase = Phase.gameOver;
      });
      print(
        'Debug: Undercovers win - final roundsPlayed=$roundsPlayed',
      ); // Debug
    } else {
      roundsPlayed++; // Increment for the NEXT round
      setState(() {
        _currentPhase = Phase.describe;
        currentIndex = 0;
        votes = {};
        eliminatedThisRound = null;
        selectedPlayer = null;
        showConfirmButton = false;
        _shuffleDescriptionOrder();
      });
      print(
        'Debug: Continuing to next round - roundsPlayed=$roundsPlayed',
      ); // Debug
    }
  }

  void _calculateResults() {
    if (votes.isEmpty) {
      eliminatedThisRound = null;
      setState(() {
        _currentPhase = Phase.results;
      });
      return;
    }

    final maxVotes = votes.values.reduce((a, b) => a > b ? a : b);
    final mostVoted = votes.entries
        .where((e) => e.value == maxVotes)
        .map((e) => e.key)
        .toList();

    if (mostVoted.length == 1 && maxVotes > 0) {
      eliminatedThisRound = mostVoted[0];

      if (eliminatedThisRound!.role == Role.civilian) {
        SoundManager.playCivilianEliminated();
      } else {
        SoundManager.playUndercoverEliminated();
      }

      if (eliminatedThisRound!.role == Role.mrWhite) {
        setState(() {
          _currentPhase = Phase.mrWhiteGuess;
        });
      } else {
        eliminatedThisRound!.eliminated = true;
        setState(() {
          _currentPhase = Phase.results;
        });
      }
    } else if (mostVoted.length > 1 && maxVotes > 0) {
      final voters = _getActivePlayers()
          .where((p) => !mostVoted.contains(p))
          .toList();
      setState(() {
        tieBreaker = TieBreaker(mostVoted, voters);
        tieBreaker!.selectRandomChallenge();
      });
      SoundManager.playInterrogation();
    } else {
      eliminatedThisRound = null;
      setState(() {
        _currentPhase = Phase.results;
      });
    }
  }

  void _handleMrWhiteGuess(String guess) {
    print('Handling Mr. White guess: $guess');
    if (guess.trim().toLowerCase() == widget.civilianWord.toLowerCase()) {
      print('Mr. White guessed correctly! Navigating to celebration.');
      SoundManager.playMrWhiteSuccess();
      winner = 'Undercovers win!';
      setState(() {
        _currentPhase = Phase.celebration;
      });
      _celebrationController.forward().then((_) {
        print('Celebration animation completed. Navigating to PostGameScreen.');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PostGameScreen(
              players: players,
              winner: winner ?? 'Game Over',
              civilianWord: widget.civilianWord,
              spyWord: widget.spyWord,
              roundsPlayed: roundsPlayed,
              totalPlayers: players.length,
              numSpies: players.where((p) => p.role == Role.spy).length,
              numMrWhites: players.where((p) => p.role == Role.mrWhite).length,
              language: widget.language,
            ),
          ),
        );
      });
    } else {
      print('Mr. White guessed incorrectly. Moving to results.');
      SoundManager.playMrWhiteFail();
      eliminatedThisRound!.eliminated = true;
      setState(() {
        _currentPhase = Phase.results;
      });
    }
  }

  void _completeInterrogation(Player? eliminatedPlayer) {
    if (eliminatedPlayer != null) {
      eliminatedThisRound = eliminatedPlayer;

      if (eliminatedThisRound!.role == Role.civilian) {
        SoundManager.playCivilianEliminated();
      } else {
        SoundManager.playUndercoverEliminated();
      }

      if (eliminatedPlayer.role == Role.mrWhite) {
        setState(() {
          tieBreaker = null;
          _currentPhase = Phase.mrWhiteGuess;
        });
      } else {
        eliminatedPlayer.eliminated = true;
        setState(() {
          tieBreaker = null;
          _currentPhase = Phase.results;
        });
      }
    } else {
      eliminatedThisRound = null;
      setState(() {
        tieBreaker = null;
        _currentPhase = Phase.results;
      });
    }
  }

  void _showVerifyPlayerScreen() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            VerifyPlayerScreen(
              players: _getActivePlayers(),
              civilianWord: widget.civilianWord,
              spyWord: widget.spyWord,
              language: widget.language,
            ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
                .animate(
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
  }

  // Enhanced background with animated elements
  Widget _buildAnimatedBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1a1a2e), Color(0xFF16213e), Color(0xFF0f3460)],
        ),
      ),
      child: Stack(
        children: [
          // Animated floating orbs
          ...List.generate(
            6,
            (index) => Positioned(
              top: (index * 150.0) % MediaQuery.of(context).size.height,
              left: (index * 200.0) % MediaQuery.of(context).size.width,
              child: AnimatedBuilder(
                animation: _glowController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(
                      sin(_glowController.value * 2 * pi + index) * 30,
                      cos(_glowController.value * 2 * pi + index) * 20,
                    ),
                    child: Container(
                      width: 80 + (index * 10),
                      height: 80 + (index * 10),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            [
                              Colors.cyan,
                              Colors.blue,
                              Colors.purple,
                              Colors.pink,
                              Colors.orange,
                              Colors.green,
                            ][index].withOpacity(0.15),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Premium glass card design
  Widget _buildGlassCard({required Widget child, double blur = 20}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: -5,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(padding: const EdgeInsets.all(24), child: child),
        ),
      ),
    );
  }

  // Enhanced button with better animations
  Widget _buildEnhancedButton({
    required String text,
    required IconData icon,
    required VoidCallback onTap,
    bool isPrimary = true,
    bool isDestructive = false,
  }) {
    return GestureDetector(
          onTap: () {
            HapticFeedback.mediumImpact();
            onTap();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDestructive
                    ? [const Color(0xFFe74c3c), const Color(0xFFc0392b)]
                    : isPrimary
                    ? [const Color(0xFF667eea), const Color(0xFF764ba2)]
                    : [const Color(0xFF4facfe), const Color(0xFF00f2fe)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color:
                      (isDestructive
                              ? const Color(0xFFe74c3c)
                              : isPrimary
                              ? const Color(0xFF667eea)
                              : const Color(0xFF4facfe))
                          .withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Text(
                  text,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        )
        .animate()
        .shimmer(duration: 2000.ms, color: Colors.white.withOpacity(0.3))
        .then()
        .shake(duration: 1000.ms, hz: 0.5);
  }

  // Enhanced player card design
  Widget _buildPlayerCard({
    required Player player,
    required bool isSelected,
    required bool isDisabled,
    required VoidCallback? onTap,
    int? position,
  }) {
    return GestureDetector(
          onTap: isDisabled ? null : onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOutCubic,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFFe74c3c)
                    : isDisabled
                    ? Colors.grey.withOpacity(0.3)
                    : Colors.white.withOpacity(0.2),
                width: isSelected ? 2.5 : 1.5,
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDisabled
                    ? [
                        Colors.grey.withOpacity(0.1),
                        Colors.grey.withOpacity(0.05),
                      ]
                    : isSelected
                    ? [
                        const Color(0xFFe74c3c).withOpacity(0.2),
                        const Color(0xFFc0392b).withOpacity(0.1),
                      ]
                    : [
                        Colors.white.withOpacity(0.08),
                        Colors.white.withOpacity(0.04),
                      ],
              ),
              boxShadow: [
                BoxShadow(
                  color: isSelected
                      ? const Color(0xFFe74c3c).withOpacity(0.3)
                      : Colors.black.withOpacity(0.2),
                  blurRadius: isSelected ? 20 : 10,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: isDisabled
                            ? [Colors.grey, Colors.grey[600]!]
                            : isSelected
                            ? [const Color(0xFFe74c3c), const Color(0xFFc0392b)]
                            : [
                                const Color(0xFF667eea),
                                const Color(0xFF764ba2),
                              ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color:
                              (isSelected
                                      ? const Color(0xFFe74c3c)
                                      : const Color(0xFF667eea))
                                  .withOpacity(0.4),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Center(
                      child: position != null
                          ? Text(
                              '$position',
                              style: GoogleFonts.inter(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              player.name[0].toUpperCase(),
                              style: GoogleFonts.inter(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    player.name,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDisabled ? Colors.grey : Colors.white,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (isDisabled)
                    Text(
                      '(You)',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                ],
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(
          duration: 300.ms,
          delay: Duration(milliseconds: position != null ? position * 100 : 0),
        )
        .slideY(
          begin: 0.3,
          end: 0,
          duration: 400.ms,
          curve: Curves.easeOutCubic,
        );
  }

  // Enhanced app bar
  PreferredSizeWidget _buildEnhancedAppBar(String title) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.black.withOpacity(0.7),
              Colors.black.withOpacity(0.3),
            ],
          ),
        ),
      ),
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
      ),
      centerTitle: true,
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: IconButton(
            icon: const Icon(Icons.visibility, color: Colors.white),
            onPressed: _showVerifyPlayerScreen,
            tooltip: 'View Roles',
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final activePlayers = _getActivePlayers();

    if (currentPhase == Phase.gameOver) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        print('Game over phase triggered. Navigating to PostGameScreen.');
        SoundManager.playGameOver();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PostGameScreen(
              players: players,
              winner: winner ?? 'Game Over',
              civilianWord: widget.civilianWord,
              spyWord: widget.spyWord,
              roundsPlayed: roundsPlayed,
              totalPlayers: players.length,
              numSpies: players.where((p) => p.role == Role.spy).length,
              numMrWhites: players.where((p) => p.role == Role.mrWhite).length,
              language: widget.language,
            ),
          ),
        );
      });
      return Scaffold(
        body: Stack(
          children: [
            _buildAnimatedBackground(),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 3,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Preparing Results...',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    if (currentPhase == Phase.describe) {
      return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: _buildEnhancedAppBar('Description Phase'),
        body: Stack(
          children: [
            _buildAnimatedBackground(),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Text(
                          'Describe in Order',
                          style: GoogleFonts.inter(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 1,
                          ),
                        )
                        .animate()
                        .fadeIn(duration: 600.ms)
                        .scale(duration: 500.ms, curve: Curves.easeOutBack),
                    const SizedBox(height: 8),
                    Text(
                      'Each player describes their word',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: Colors.white70,
                        fontWeight: FontWeight.w400,
                      ),
                    ).animate().fadeIn(duration: 800.ms),
                    const SizedBox(height: 32),
                    Expanded(
                      child: _buildGlassCard(
                        child: GridView.builder(
                          physics: const BouncingScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.85,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                              ),
                          itemCount: descriptionOrder.length,
                          itemBuilder: (context, index) {
                            final player = descriptionOrder[index];
                            return _buildPlayerCard(
                              player: player,
                              isSelected: false,
                              isDisabled: false,
                              onTap: () {},
                              position: index + 1,
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildEnhancedButton(
                      text: 'Start Voting',
                      icon: Icons.how_to_vote,
                      onTap: () {
                        setState(() {
                          _currentPhase = Phase.vote;
                          currentIndex = 0;
                          votes = {for (var p in activePlayers) p: 0};
                          selectedPlayer = null;
                          showConfirmButton = false;
                          _shuffleVotingOrder();
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    } else if (currentPhase == Phase.vote) {
      final voter = votingOrder[currentIndex];
      return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: _buildEnhancedAppBar("${voter.name}'s Vote"),
        body: Stack(
          children: [
            _buildAnimatedBackground(),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Text(
                          'Who is suspicious?',
                          style: GoogleFonts.inter(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 1,
                          ),
                        )
                        .animate()
                        .fadeIn(duration: 600.ms)
                        .scale(duration: 500.ms, curve: Curves.easeOutBack),
                    const SizedBox(height: 8),
                    Text(
                      'Select a player to eliminate',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: Colors.white70,
                        fontWeight: FontWeight.w400,
                      ),
                    ).animate().fadeIn(duration: 800.ms),
                    const SizedBox(height: 32),
                    Expanded(
                      child: _buildGlassCard(
                        child: GridView.builder(
                          physics: const BouncingScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.8,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                              ),
                          itemCount: votingOrder.length,
                          itemBuilder: (context, index) {
                            final p = votingOrder[index];
                            final isVoter = p == voter;
                            final isSelected = selectedPlayer == p;

                            return _buildPlayerCard(
                              player: p,
                              isSelected: isSelected,
                              isDisabled: isVoter,
                              onTap: isVoter
                                  ? null
                                  : () {
                                      setState(() {
                                        selectedPlayer = isSelected ? null : p;
                                        showConfirmButton =
                                            selectedPlayer != null;
                                      });
                                    },
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (showConfirmButton)
                      _buildEnhancedButton(
                        text: 'Confirm Vote',
                        icon: Icons.check_circle,
                        isDestructive: true,
                        onTap: () {
                          if (selectedPlayer != null) {
                            SoundManager.playVoteSound();
                            setState(() {
                              votes[selectedPlayer!] =
                                  votes[selectedPlayer!]! + 1;
                              currentIndex++;
                              selectedPlayer = null;
                              showConfirmButton = false;

                              if (currentIndex >= votingOrder.length) {
                                _calculateResults();
                              }
                            });
                          }
                        },
                      )
                    else
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'Select a player to vote',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              color: Colors.white60,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    } else if (currentPhase == Phase.interrogation) {
      return _buildInterrogationScreen();
    } else if (currentPhase == Phase.mrWhiteGuess) {
      return MrWhiteGuessScreen(
        player: eliminatedThisRound!,
        onGuess: _handleMrWhiteGuess,
      );
    } else if (currentPhase == Phase.results) {
      return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: _buildEnhancedAppBar('Round Results'),
        body: Stack(
          children: [
            _buildAnimatedBackground(),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildGlassCard(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (eliminatedThisRound != null) ...[
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color:
                                    eliminatedThisRound!.role == Role.civilian
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color:
                                      eliminatedThisRound!.role == Role.civilian
                                      ? Colors.green.withOpacity(0.3)
                                      : Colors.red.withOpacity(0.3),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    eliminatedThisRound!.role == Role.civilian
                                        ? Icons.people
                                        : eliminatedThisRound!.role == Role.spy
                                        ? Icons.visibility_off
                                        : Icons.help,
                                    size: 64,
                                    color:
                                        eliminatedThisRound!.role ==
                                            Role.civilian
                                        ? Colors.green
                                        : eliminatedThisRound!.role == Role.spy
                                        ? Colors.red
                                        : Colors.amber,
                                  ).animate().scale(
                                    duration: 500.ms,
                                    curve: Curves.elasticOut,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    '${eliminatedThisRound!.name} Eliminated!',
                                    style: GoogleFonts.inter(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.center,
                                  ).animate().fadeIn(
                                    duration: 600.ms,
                                    delay: 200.ms,
                                  ),
                                  const SizedBox(height: 12),
                                  Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              eliminatedThisRound!.role ==
                                                  Role.civilian
                                              ? Colors.green.withOpacity(0.2)
                                              : eliminatedThisRound!.role ==
                                                    Role.spy
                                              ? Colors.red.withOpacity(0.2)
                                              : Colors.amber.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          border: Border.all(
                                            color:
                                                eliminatedThisRound!.role ==
                                                    Role.civilian
                                                ? Colors.green.withOpacity(0.5)
                                                : eliminatedThisRound!.role ==
                                                      Role.spy
                                                ? Colors.red.withOpacity(0.5)
                                                : Colors.amber.withOpacity(0.5),
                                          ),
                                        ),
                                        child: Text(
                                          eliminatedThisRound!.role.name
                                              .toUpperCase(),
                                          style: GoogleFonts.inter(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color:
                                                eliminatedThisRound!.role ==
                                                    Role.civilian
                                                ? Colors.green
                                                : eliminatedThisRound!.role ==
                                                      Role.spy
                                                ? Colors.red
                                                : Colors.amber,
                                            letterSpacing: 1,
                                          ),
                                        ),
                                      )
                                      .animate()
                                      .fadeIn(duration: 600.ms, delay: 400.ms)
                                      .scale(duration: 300.ms, delay: 400.ms),
                                ],
                              ),
                            ),
                          ] else ...[
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.grey.withOpacity(0.3),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.balance,
                                    size: 64,
                                    color: Colors.grey,
                                  ).animate().scale(
                                    duration: 500.ms,
                                    curve: Curves.elasticOut,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No Elimination',
                                    style: GoogleFonts.inter(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.center,
                                  ).animate().fadeIn(
                                    duration: 600.ms,
                                    delay: 200.ms,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'The vote resulted in a tie or no votes',
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      color: Colors.white70,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    textAlign: TextAlign.center,
                                  ).animate().fadeIn(
                                    duration: 600.ms,
                                    delay: 400.ms,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    _buildEnhancedButton(
                      text: 'Continue Game',
                      icon: Icons.arrow_forward,
                      onTap: _proceedAfterResults,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    } else if (currentPhase == Phase.celebration) {
      // Fallback navigation in case _handleMrWhiteGuess navigation fails
      WidgetsBinding.instance.addPostFrameCallback((_) {
        print(
          'Celebration phase build. Ensuring navigation to PostGameScreen.',
        );
        _celebrationController.forward().then((_) {
          print('Fallback navigation triggered.');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => PostGameScreen(
                players: players,
                winner: winner ?? 'Game Over',
                civilianWord: widget.civilianWord,
                spyWord: widget.spyWord,
                roundsPlayed: roundsPlayed,
                totalPlayers: players.length,
                numSpies: players.where((p) => p.role == Role.spy).length,
                numMrWhites: players
                    .where((p) => p.role == Role.mrWhite)
                    .length,
                language: widget.language,
              ),
            ),
          );
        });
      });
      return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: _buildEnhancedAppBar('Mr. White\'s Victory!'),
        body: Stack(
          children: [
            _buildAnimatedBackground(),
            SafeArea(
              child: Center(
                child: _buildGlassCard(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star, size: 80, color: Colors.amber)
                          .animate(
                            controller: _celebrationController,
                            autoPlay: true,
                          )
                          .scale(duration: 1000.ms, curve: Curves.elasticOut)
                          .rotate(begin: 0, end: 1, duration: 1000.ms),
                      const SizedBox(height: 24),
                      Text(
                            'Mr. White Guessed Correctly!',
                            style: GoogleFonts.inter(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 1,
                            ),
                            textAlign: TextAlign.center,
                          )
                          .animate()
                          .fadeIn(duration: 800.ms, delay: 200.ms)
                          .scale(duration: 800.ms, curve: Curves.easeOutBack),
                      const SizedBox(height: 16),
                      Text(
                        'Undercovers Win!',
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.amber,
                        ),
                        textAlign: TextAlign.center,
                      ).animate().fadeIn(duration: 800.ms, delay: 400.ms),
                      const SizedBox(height: 24),
                      // Animated confetti effect
                      Stack(
                        children: List.generate(20, (index) {
                          return Positioned(
                            top: Random().nextDouble() * 200 - 100,
                            left: Random().nextDouble() * 200 - 100,
                            child:
                                Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        color: [
                                          Colors.red,
                                          Colors.blue,
                                          Colors.yellow,
                                          Colors.green,
                                          Colors.purple,
                                        ][index % 5],
                                        shape: BoxShape.circle,
                                      ),
                                    )
                                    .animate(
                                      controller: _celebrationController,
                                      autoPlay: true,
                                    )
                                    .moveY(
                                      begin: -50,
                                      end: 50,
                                      duration: 1500.ms,
                                      delay: Duration(
                                        milliseconds: index * 100,
                                      ),
                                      curve: Curves.easeOut,
                                    )
                                    .fadeOut(
                                      duration: 1500.ms,
                                      delay: Duration(
                                        milliseconds: index * 100,
                                      ),
                                    ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          _buildAnimatedBackground(),
          Center(
            child: _buildGlassCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.amber),
                  const SizedBox(height: 16),
                  Text(
                    'Unexpected Game State',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please restart the game',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInterrogationScreen() {
    if (tieBreaker == null || tieBreaker!.tiedPlayers.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _completeInterrogation(null);
      });
      return Scaffold(
        body: Stack(
          children: [
            _buildAnimatedBackground(),
            Center(
              child: _buildGlassCard(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.search_off, size: 48, color: Colors.amber),
                    const SizedBox(height: 16),
                    Text(
                      'No Suspects Found',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildEnhancedAppBar('Interrogation Phase'),
      body: Stack(
        children: [
          _buildAnimatedBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                        'TIE BREAKER',
                        style: GoogleFonts.inter(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      )
                      .animate()
                      .fadeIn(duration: 600.ms)
                      .scale(duration: 500.ms, curve: Curves.easeOutBack),
                  const SizedBox(height: 8),
                  Text(
                    'Multiple players received the same votes',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: Colors.white70,
                      fontWeight: FontWeight.w400,
                    ),
                  ).animate().fadeIn(duration: 800.ms),
                  const SizedBox(height: 32),
                  _buildGlassCard(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.gavel, color: Colors.amber, size: 24),
                            const SizedBox(width: 12),
                            Text(
                              'SUSPECTS',
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: tieBreaker!.tiedPlayers.map((player) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFe74c3c),
                                    Color(0xFFc0392b),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFFe74c3c,
                                    ).withOpacity(0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Text(
                                player.name,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildGlassCard(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.psychology,
                              color: Colors.cyan,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'CHALLENGE',
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          tieBreaker!.getChallengeDescription(),
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w400,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildEnhancedButton(
                    text: 'Start Interrogation',
                    icon: Icons.play_arrow,
                    onTap: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  InterrogationVoteScreen(
                                    tieBreaker: tieBreaker!,
                                    onComplete: _completeInterrogation,
                                  ),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                                return SlideTransition(
                                  position:
                                      Tween<Offset>(
                                        begin: const Offset(1, 0),
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
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
