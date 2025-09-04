import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
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
  int roundsPlayed = 1;

  @override
  void initState() {
    super.initState();
    players = widget.players;
  }

  List<Player> _getActivePlayers() {
    return players.where((p) => !p.eliminated).toList();
  }

  void _proceedAfterResults() {
    final remaining = _getActivePlayers();
    final numUndercover = remaining
        .where((p) => p.role != Role.civilian)
        .length;

    if (numUndercover == 0) {
      winner = 'Civilians win!';
      setState(() {
        _currentPhase = Phase.gameOver;
      });
    } else if (numUndercover >= remaining.length - 1) {
      winner = 'Undercovers win!';
      setState(() {
        _currentPhase = Phase.gameOver;
      });
    } else {
      setState(() {
        _currentPhase = Phase.describe;
        currentIndex = 0;
        votes = {};
        eliminatedThisRound = null;
        selectedPlayer = null;
        showConfirmButton = false;
        roundsPlayed++;
      });
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
    } else {
      eliminatedThisRound = null;
      setState(() {
        _currentPhase = Phase.results;
      });
    }
  }

  void _handleMrWhiteGuess(String guess) {
    if (guess.trim().toLowerCase() == widget.civilianWord.toLowerCase()) {
      winner = 'Undercovers win!';
      setState(() {
        _currentPhase = Phase.gameOver;
      });
    } else {
      eliminatedThisRound!.eliminated = true;
      setState(() {
        _currentPhase = Phase.results;
      });
    }
  }

  void _completeInterrogation(Player? eliminatedPlayer) {
    if (eliminatedPlayer != null) {
      eliminatedThisRound = eliminatedPlayer;
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
                      spreadRadius: size * 0.25, // fixed here
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
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colors),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: colors.last.withOpacity(0.4),
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
    final activePlayers = _getActivePlayers();

    if (currentPhase == Phase.gameOver) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
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
            const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ],
        ),
      );
    }

    if (currentPhase == Phase.describe) {
      final random = Random();
      final descriptionOrder = List.from(activePlayers)..shuffle(random);
      return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: Text(
            'Description Phase',
            style: GoogleFonts.orbitron(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.info),
              tooltip: 'View Your Role',
              onPressed: _showVerifyPlayerScreen,
            ),
          ],
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
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                            'Describe in this order:',
                            style: GoogleFonts.orbitron(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 2,
                              shadows: [
                                Shadow(
                                  blurRadius: 25,
                                  color: Colors.indigoAccent.withOpacity(0.7),
                                ),
                              ],
                            ),
                          )
                          .animate()
                          .fadeIn(duration: 800.ms)
                          .scale(duration: 700.ms, curve: Curves.easeOutBack),
                      const SizedBox(height: 20),
                      _buildCard(
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: descriptionOrder.length,
                          itemBuilder: (context, index) {
                            final player = descriptionOrder[index];
                            return Container(
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.indigoAccent.withOpacity(0.2),
                                        Colors.purpleAccent.withOpacity(0.1),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.2),
                                    ),
                                  ),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: Colors.indigoAccent,
                                      child: Text(
                                        '${index + 1}',
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      player.name,
                                      style: GoogleFonts.poppins(
                                        fontSize: 18,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    trailing: Icon(
                                      Icons.mic,
                                      color: Colors.white.withOpacity(0.7),
                                    ),
                                  ),
                                )
                                .animate()
                                .fadeIn(duration: 300.ms)
                                .slideY(begin: 0.3, end: 0, duration: 400.ms);
                          },
                        ),
                      ),
                      const SizedBox(height: 30),
                      _buildGameButton(
                        text: 'GO TO VOTE',
                        icon: Icons.how_to_vote,
                        colors: [Colors.greenAccent, Colors.teal],
                        onTap: () {
                          setState(() {
                            _currentPhase = Phase.vote;
                            currentIndex = 0;
                            votes = {for (var p in activePlayers) p: 0};
                            selectedPlayer = null;
                            showConfirmButton = false;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } else if (currentPhase == Phase.vote) {
      final voter = activePlayers[currentIndex];
      return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: Text(
            "${voter.name}'s Vote",
            style: GoogleFonts.orbitron(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.info),
              tooltip: 'View Your Role',
              onPressed: _showVerifyPlayerScreen,
            ),
          ],
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
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                            'Select a player to eliminate:',
                            style: GoogleFonts.orbitron(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 2,
                              shadows: [
                                Shadow(
                                  blurRadius: 25,
                                  color: Colors.indigoAccent.withOpacity(0.7),
                                ),
                              ],
                            ),
                          )
                          .animate()
                          .fadeIn(duration: 800.ms)
                          .scale(duration: 700.ms, curve: Curves.easeOutBack),
                      const SizedBox(height: 20),
                      _buildCard(
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.8,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                              ),
                          itemCount: activePlayers.length,
                          itemBuilder: (context, index) {
                            final p = activePlayers[index];
                            final isVoter = p == voter;
                            final isSelected = selectedPlayer == p;

                            return GestureDetector(
                                  onTap: isVoter
                                      ? null
                                      : () {
                                          setState(() {
                                            selectedPlayer = isSelected
                                                ? null
                                                : p;
                                            showConfirmButton =
                                                selectedPlayer != null;
                                          });
                                        },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: isVoter
                                            ? [
                                                Colors.grey[600]!.withOpacity(
                                                  0.5,
                                                ),
                                                Colors.grey[800]!.withOpacity(
                                                  0.5,
                                                ),
                                              ]
                                            : isSelected
                                            ? [
                                                Colors.redAccent.withOpacity(
                                                  0.6,
                                                ),
                                                Colors.red[700]!.withOpacity(
                                                  0.6,
                                                ),
                                              ]
                                            : [
                                                Colors.indigoAccent.withOpacity(
                                                  0.2,
                                                ),
                                                Colors.purpleAccent.withOpacity(
                                                  0.1,
                                                ),
                                              ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: isSelected
                                            ? Colors.redAccent.withOpacity(0.4)
                                            : Colors.white.withOpacity(0.2),
                                        width: 1.5,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 12,
                                          offset: const Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        CircleAvatar(
                                          backgroundColor: isVoter || isSelected
                                              ? Colors.white.withOpacity(0.2)
                                              : Colors.indigoAccent,
                                          radius: 30,
                                          child: Text(
                                            p.name[0].toUpperCase(),
                                            style: GoogleFonts.poppins(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              color: isVoter || isSelected
                                                  ? Colors.white
                                                  : Colors.white,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          p.name,
                                          style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            fontWeight: isSelected
                                                ? FontWeight.bold
                                                : FontWeight.w500,
                                            color: isVoter || isSelected
                                                ? Colors.white
                                                : Colors.white.withOpacity(0.9),
                                          ),
                                        ),
                                        if (isVoter)
                                          Text(
                                            '(You)',
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              color: Colors.white.withOpacity(
                                                0.7,
                                              ),
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                )
                                .animate()
                                .fadeIn(duration: 300.ms)
                                .scale(duration: 400.ms, curve: Curves.easeOut);
                          },
                        ),
                      ),
                      const SizedBox(height: 30),
                      if (showConfirmButton)
                        _buildGameButton(
                          text: 'CONFIRM VOTE',
                          icon: Icons.check,
                          colors: [Colors.blueAccent, Colors.indigo],
                          onTap: () {
                            if (selectedPlayer != null) {
                              setState(() {
                                votes[selectedPlayer!] =
                                    votes[selectedPlayer!]! + 1;
                                currentIndex++;
                                selectedPlayer = null;
                                showConfirmButton = false;

                                if (currentIndex >= activePlayers.length) {
                                  _calculateResults();
                                }
                              });
                            }
                          },
                        ),
                    ],
                  ),
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
        appBar: AppBar(
          title: Text(
            'Results',
            style: GoogleFonts.orbitron(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.info),
              tooltip: 'View Your Role',
              onPressed: _showVerifyPlayerScreen,
            ),
          ],
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
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                            'Round Results',
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
                          )
                          .animate()
                          .fadeIn(duration: 800.ms)
                          .scale(duration: 700.ms, curve: Curves.easeOutBack),
                      const SizedBox(height: 20),
                      _buildCard(
                        child: Column(
                          children: [
                            if (eliminatedThisRound != null) ...[
                              Text(
                                '${eliminatedThisRound!.name} was eliminated!',
                                style: GoogleFonts.poppins(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ).animate().fadeIn(duration: 400.ms),
                              const SizedBox(height: 24),
                              Column(
                                children: [
                                  Icon(
                                    eliminatedThisRound!.role == Role.civilian
                                        ? Icons.people
                                        : eliminatedThisRound!.role == Role.spy
                                        ? Icons.visibility_off
                                        : Icons.help,
                                    size: 48,
                                    color:
                                        eliminatedThisRound!.role ==
                                            Role.civilian
                                        ? Colors.green
                                        : eliminatedThisRound!.role == Role.spy
                                        ? Colors.red
                                        : Colors.amber,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    eliminatedThisRound!.role.name
                                        .toUpperCase(),
                                    style: GoogleFonts.poppins(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color:
                                          eliminatedThisRound!.role ==
                                              Role.civilian
                                          ? Colors.green
                                          : eliminatedThisRound!.role ==
                                                Role.spy
                                          ? Colors.red
                                          : Colors.amber,
                                    ),
                                  ),
                                ],
                              ),
                            ] else
                              Text(
                                'No one was eliminated (tie or no votes)',
                                style: GoogleFonts.poppins(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ).animate().fadeIn(duration: 400.ms),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      _buildGameButton(
                        text: 'CONTINUE',
                        icon: Icons.arrow_forward,
                        colors: [Colors.greenAccent, Colors.teal],
                        onTap: _proceedAfterResults,
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
          Center(
            child: Text(
              'Unexpected state',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.white,
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
            Center(
              child:
                  Text(
                        'No suspects to interrogate!',
                        style: GoogleFonts.orbitron(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 2,
                          shadows: [
                            Shadow(
                              blurRadius: 25,
                              color: Colors.indigoAccent.withOpacity(0.7),
                            ),
                          ],
                        ),
                      )
                      .animate()
                      .fadeIn(duration: 800.ms)
                      .scale(duration: 700.ms, curve: Curves.easeOutBack),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Interrogation',
          style: GoogleFonts.orbitron(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 2,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.info),
            tooltip: 'View Your Role',
            onPressed: _showVerifyPlayerScreen,
          ),
        ],
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
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                          'FINAL INTERROGATION',
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
                        )
                        .animate()
                        .fadeIn(duration: 800.ms)
                        .scale(duration: 700.ms, curve: Curves.easeOutBack),
                    const SizedBox(height: 16),
                    Text(
                      'A tie has been reached! The suspects must prove their innocence.',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        color: Colors.white70,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(duration: 500.ms),
                    const SizedBox(height: 30),
                    _buildCard(
                      child: Column(
                        children: [
                          Text(
                            'SUSPECTS',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...tieBreaker!.tiedPlayers
                              .map(
                                (player) => Text(
                                  player.name,
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                ),
                              )
                              .toList(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildCard(
                      child: Text(
                        tieBreaker!.getChallengeDescription(),
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.amber[100],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 30),
                    _buildGameButton(
                      text: 'PROCEED TO VOTE',
                      icon: Icons.how_to_vote,
                      colors: [Colors.blueAccent, Colors.indigo],
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => InterrogationVoteScreen(
                              tieBreaker: tieBreaker!,
                              onComplete: _completeInterrogation,
                            ),
                          ),
                        );
                      },
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
}
