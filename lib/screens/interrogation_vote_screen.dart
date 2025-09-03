import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
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

class _InterrogationVoteScreenState extends State<InterrogationVoteScreen> {
  int currentVoterIndex = 0;
  Player? selectedPlayer;
  bool showTieResolution = false;
  List<Player> tiedCandidates = [];

  @override
  Widget build(BuildContext context) {
    if (widget.tieBreaker.voters.isEmpty ||
        widget.tieBreaker.tiedPlayers.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onComplete(null);
        Navigator.pop(context);
      });
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.indigo[800]!, Colors.indigo[500]!],
            ),
          ),
          child: const Center(
            child: Text(
              'No voters or suspects available!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      );
    }

    if (showTieResolution) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Resolve Tie'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        extendBodyBehindAppBar: true,
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.indigo[800]!, Colors.indigo[500]!],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Persistent Tie!',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'The following players are tied with the most votes:',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white.withOpacity(0.8),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: tiedCandidates
                          .map(
                            (player) => Text(
                              player.name,
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Choose how to proceed:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        widget.onComplete(null);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.indigo[800],
                      ),
                      child: const Text(
                        "DON'T ELIMINATE ANY PLAYER",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        final random = Random();
                        final eliminated =
                            tiedCandidates[random.nextInt(
                              tiedCandidates.length,
                            )];
                        widget.onComplete(eliminated);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.red[600],
                        foregroundColor: Colors.white,
                      ),
                      child: const Text(
                        'RANDOMLY ELIMINATE',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final voter = widget.tieBreaker.voters[currentVoterIndex];
    return Scaffold(
      appBar: AppBar(
        title: Text("${voter.name}'s Vote"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.indigo[800]!, Colors.indigo[500]!],
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                16,
                kToolbarHeight + 16,
                16,
                16,
              ),
              child: Text(
                'Select a suspect to eliminate:',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                    child: Card(
                      elevation: isSelected ? 8 : 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: isSelected
                              ? LinearGradient(
                                  colors: [Colors.red[300]!, Colors.red[600]!],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : LinearGradient(
                                  colors: [
                                    Colors.white.withOpacity(0.9),
                                    Colors.grey[200]!,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                backgroundColor: isSelected
                                    ? Colors.white.withOpacity(0.2)
                                    : Colors.indigo.withOpacity(0.2),
                                child: Text(
                                  player.name[0].toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.indigo[800],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                player.name,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: selectedPlayer != null
                      ? () {
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
                              final maxVotes = widget
                                  .tieBreaker
                                  .finalVotes
                                  .values
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
                                WidgetsBinding.instance.addPostFrameCallback((
                                  _,
                                ) {
                                  widget.onComplete(eliminated);
                                  Navigator.pop(context);
                                });
                              } else if (widget.tieBreaker.retryCount < 2) {
                                WidgetsBinding.instance.addPostFrameCallback((
                                  _,
                                ) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Tie in votes! Starting a new interrogation round with challenge: ${widget.tieBreaker.getChallengeDescription()}',
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
                      : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.indigo[800],
                  ),
                  child: const Text(
                    'CONFIRM VOTE',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
