import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
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

  @override
  void initState() {
    super.initState();
    _saveScores();
  }

  Future<void> _saveScores() async {
    print('Saving game results'); // Debug log
    await ScoreManager.instance.saveGameResults(
      widget.players,
      widget.winner,
      widget.roundsPlayed,
    );
    setState(() {
      _scoresSaved = true;
    });
    print('Scores saved successfully'); // Debug log
  }

  void _startNewRound() {
    print('Starting new round'); // Debug log
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
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(position: offsetAnimation, child: child);
        },
      ),
    );
    print('Navigated to RoleRevealScreen'); // Debug log
  }

  void _viewLeaderboard() {
    print('Navigating to LeaderboardScreen'); // Debug log
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const LeaderboardScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(position: offsetAnimation, child: child);
        },
      ),
    );
  }

  void _endSession() {
    print('Ending session'); // Debug log
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  Widget _buildBlob(double size, Color color) {
    return IgnorePointer(
      ignoring: true,
      child:
          Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withOpacity(0.25),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.6),
                      blurRadius: size * 0.6,
                      spreadRadius: size * 0.25,
                    ),
                  ],
                ),
              )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(duration: 4.seconds, curve: Curves.easeInOut),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 20,
            spreadRadius: -5,
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildGameButton({
    required String text,
    required IconData icon,
    required List<Color> colors,
    required VoidCallback onTap,
    bool enabled = true,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: enabled ? colors : [Colors.grey, Colors.grey],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: (enabled ? colors.last : Colors.grey).withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
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
          style: GoogleFonts.orbitron(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 2,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _endSession,
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.2,
                colors: [Color(0xFF0f172a), Color(0xFF020617)],
              ),
            ),
          ),
          Positioned(
            top: -100,
            left: -100,
            child: _buildBlob(250, Colors.indigoAccent.withOpacity(0.3)),
          ),
          Positioned(
            bottom: -120,
            right: -80,
            child: _buildBlob(300, Colors.purpleAccent.withOpacity(0.25)),
          ),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                        widget.winner,
                        style: GoogleFonts.orbitron(
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 4,
                          shadows: [
                            Shadow(
                              blurRadius: 25,
                              color: Colors.indigoAccent.withOpacity(0.7),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      )
                      .animate()
                      .fadeIn(duration: 800.ms)
                      .scale(duration: 700.ms, curve: Curves.easeOutBack),
                  const SizedBox(height: 32),
                  _buildCard(
                        child: Column(
                          children: [
                            Icon(
                              Icons.emoji_events,
                              size: 64,
                              color: Colors.amber,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Game Summary',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Column(
                                  children: [
                                    Text(
                                      'Civilian Word',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: Colors.white.withOpacity(0.8),
                                      ),
                                    ),
                                    Text(
                                      widget.civilianWord,
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Text(
                                      'Spy Word',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: Colors.white.withOpacity(0.8),
                                      ),
                                    ),
                                    Text(
                                      widget.spyWord,
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Rounds Played: ${widget.roundsPlayed}',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      )
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .scale(duration: 400.ms, curve: Curves.easeOut),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _scoresSaved
                            ? Icons.check_circle
                            : Icons.hourglass_empty,
                        color: _scoresSaved ? Colors.green : Colors.orange,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _scoresSaved ? 'Scores saved!' : 'Saving scores...',
                        style: GoogleFonts.poppins(
                          color: _scoresSaved ? Colors.green : Colors.orange,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ).animate().fadeIn(duration: 400.ms),
                  const SizedBox(height: 32),
                  _buildGameButton(
                        text: 'ANOTHER ROUND',
                        icon: Icons.refresh,
                        colors: [Colors.greenAccent, Colors.teal],
                        onTap: _startNewRound,
                      )
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .scale(duration: 400.ms, curve: Curves.easeOut),
                  const SizedBox(height: 16),
                  _buildGameButton(
                        text: 'VIEW LEADERBOARD',
                        icon: Icons.leaderboard,
                        colors: [Colors.amber, Colors.amberAccent],
                        onTap: _viewLeaderboard,
                        enabled: _scoresSaved,
                      )
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .scale(duration: 400.ms, curve: Curves.easeOut),
                  const SizedBox(height: 16),
                  _buildGameButton(
                        text: 'END SESSION',
                        icon: Icons.home,
                        colors: [Colors.blueAccent, Colors.indigo],
                        onTap: _endSession,
                      )
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .scale(duration: 400.ms, curve: Curves.easeOut),
                  const SizedBox(height: 24),
                  if (_scoresSaved)
                    _buildCard(
                          child: Column(
                            children: [
                              Text(
                                'Player Performance',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                height: 200,
                                child: ListView(
                                  physics: const BouncingScrollPhysics(),
                                  children: widget.players.map((player) {
                                    final won =
                                        (widget.winner.contains('Civilians') &&
                                            player.role.name == 'civilian') ||
                                        (widget.winner.contains(
                                              'Undercovers',
                                            ) &&
                                            (player.role.name == 'spy' ||
                                                player.role.name == 'mrWhite'));

                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 4,
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            won
                                                ? Icons.emoji_events
                                                : Icons.close,
                                            color: won
                                                ? Colors.amber
                                                : Colors.red,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              player.name,
                                              style: GoogleFonts.poppins(
                                                color: Colors.white.withOpacity(
                                                  0.9,
                                                ),
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                          if (player.eliminated)
                                            Icon(
                                              Icons.remove_circle,
                                              color: Colors.red,
                                              size: 16,
                                            ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          ),
                        )
                        .animate()
                        .fadeIn(duration: 400.ms)
                        .scale(duration: 400.ms, curve: Curves.easeOut),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
