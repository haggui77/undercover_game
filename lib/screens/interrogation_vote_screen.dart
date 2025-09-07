import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:undercover_game/models/players.dart';

class InterrogationVoteScreen extends StatefulWidget {
  final TieBreaker tieBreaker;
  final Function(Player?) onComplete;

  const InterrogationVoteScreen({
    super.key,
    required this.tieBreaker,
    required this.onComplete,
  });

  @override
  State<InterrogationVoteScreen> createState() =>
      _InterrogationVoteScreenState();
}

class _InterrogationVoteScreenState extends State<InterrogationVoteScreen>
    with TickerProviderStateMixin {
  int currentVoterIndex = 0;
  Player? selectedPlayer;
  bool showTieResolution = false;
  List<Player> tiedCandidates = [];

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
        )
        .animate()
        .fadeIn(duration: 400.ms)
        .scale(duration: 400.ms, curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.tieBreaker.voters.isEmpty ||
        widget.tieBreaker.tiedPlayers.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onComplete(null);
        Navigator.pop(context);
      });
      return Scaffold(
        extendBodyBehindAppBar: true,
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
                  _buildCard(
                        child: Text(
                          'No voters or suspects available!',
                          style: GoogleFonts.orbitron(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .scale(duration: 400.ms, curve: Curves.easeOut),
            ),
          ],
        ),
      );
    }

    if (showTieResolution) {
      return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: Text(
            'Resolve Tie',
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
            onPressed: () => Navigator.pop(context),
            color: Colors.white,
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
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                            'Persistent Tie!',
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
                      const SizedBox(height: 16),
                      Text(
                        'The following players are tied with the most votes:',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          color: Colors.white70,
                        ),
                        textAlign: TextAlign.center,
                      ).animate().fadeIn(duration: 500.ms),
                      const SizedBox(height: 16),
                      _buildCard(
                            child: Column(
                              children: tiedCandidates
                                  .asMap()
                                  .entries
                                  .map(
                                    (entry) => Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8.0,
                                      ),
                                      child: Text(
                                        entry.value.name,
                                        style: GoogleFonts.poppins(
                                          fontSize: 18,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          )
                          .animate()
                          .fadeIn(duration: 400.ms)
                          .scale(duration: 400.ms, curve: Curves.easeOut),
                      const SizedBox(height: 32),
                      Text(
                        'Choose how to proceed:',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ).animate().fadeIn(duration: 400.ms),
                      const SizedBox(height: 24),
                      _buildGameButton(
                        text: "DON'T ELIMINATE ANY PLAYER",
                        icon: Icons.cancel,
                        colors: [Colors.blueAccent, Colors.indigo],
                        onTap: () {
                          widget.onComplete(null);
                          Navigator.pop(context);
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildGameButton(
                        text: 'RANDOMLY ELIMINATE',
                        icon: Icons.shuffle,
                        colors: [Colors.redAccent, Colors.red],
                        onTap: () {
                          final random = Random();
                          final eliminated =
                              tiedCandidates[random.nextInt(
                                tiedCandidates.length,
                              )];
                          widget.onComplete(eliminated);
                          Navigator.pop(context);
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

    final voter = widget.tieBreaker.voters[currentVoterIndex];
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
          color: Colors.white,
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
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    16,
                    kToolbarHeight + 16,
                    16,
                    16,
                  ),
                  child:
                      Text(
                            'Select a suspect to eliminate:',
                            style: GoogleFonts.orbitron(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 2,
                            ),
                          )
                          .animate()
                          .fadeIn(duration: 800.ms)
                          .scale(duration: 700.ms, curve: Curves.easeOutBack),
                ),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.8,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                    itemCount: widget.tieBreaker.tiedPlayers.length,
                    itemBuilder: (context, index) {
                      final player = widget.tieBreaker.tiedPlayers[index];
                      final isSelected = selectedPlayer == player;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedPlayer = isSelected ? null : player;
                          });
                        },
                        child:
                            _buildCard(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: isSelected
                                            ? [Colors.redAccent, Colors.red]
                                            : [
                                                Colors.indigoAccent.withOpacity(
                                                  0.2,
                                                ),
                                                Colors.purpleAccent.withOpacity(
                                                  0.2,
                                                ),
                                              ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: isSelected
                                            ? Colors.redAccent
                                            : Colors.white.withOpacity(0.2),
                                        width: isSelected ? 2 : 1,
                                      ),
                                    ),
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          CircleAvatar(
                                            backgroundColor: isSelected
                                                ? Colors.white.withOpacity(0.2)
                                                : Colors.indigo.withOpacity(
                                                    0.2,
                                                  ),
                                            child: Text(
                                              player.name[0].toUpperCase(),
                                              style: GoogleFonts.poppins(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: isSelected
                                                    ? Colors.white
                                                    : Colors.white70,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            player.name,
                                            style: GoogleFonts.poppins(
                                              fontSize: 16,
                                              fontWeight: isSelected
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                              color: isSelected
                                                  ? Colors.white
                                                  : Colors.white70,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                                .animate()
                                .fadeIn(duration: 300.ms)
                                .scale(duration: 400.ms, curve: Curves.easeOut),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _buildGameButton(
                    text: 'CONFIRM VOTE',
                    icon: Icons.how_to_vote,
                    colors: [Colors.blueAccent, Colors.indigo],
                    onTap: () {
                      if (selectedPlayer != null) {
                        widget.tieBreaker.finalVotes[selectedPlayer!] =
                            (widget.tieBreaker.finalVotes[selectedPlayer!] ??
                                0) +
                            1;

                        if (currentVoterIndex <
                            widget.tieBreaker.voters.length - 1) {
                          setState(() {
                            currentVoterIndex++;
                            selectedPlayer = null;
                          });
                        } else {
                          Player? eliminated;
                          if (widget.tieBreaker.finalVotes.isNotEmpty) {
                            final maxVotes = widget.tieBreaker.finalVotes.values
                                .reduce((a, b) => a > b ? a : b);
                            final candidates = widget
                                .tieBreaker
                                .finalVotes
                                .entries
                                .where((e) => e.value == maxVotes)
                                .map((e) => e.key)
                                .toList();

                            if (candidates.length == 1) {
                              eliminated = candidates[0];
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                widget.onComplete(eliminated);
                                Navigator.pop(context);
                              });
                            } else if (widget.tieBreaker.retryCount < 2) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Tie in votes! Starting a new interrogation round with challenge: ${widget.tieBreaker.getChallengeDescription()}',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                      ),
                                    ),
                                    backgroundColor: Colors.amber[700],
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                );
                              });
                              setState(() {
                                widget.tieBreaker.selectRandomChallenge();
                                currentVoterIndex = 0;
                                selectedPlayer = null;
                              });
                            } else {
                              setState(() {
                                showTieResolution = true;
                                tiedCandidates = candidates;
                              });
                            }
                          } else {
                            eliminated = null;
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              widget.onComplete(eliminated);
                              Navigator.pop(context);
                            });
                          }
                        }
                      }
                    },
                    enabled: selectedPlayer != null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
