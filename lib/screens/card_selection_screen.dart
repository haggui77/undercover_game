import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:undercover_game/models/enums.dart';
import 'package:undercover_game/models/players.dart';
import 'package:undercover_game/screens/game_screen.dart';
import 'package:undercover_game/screens/name_entry_screen.dart';
import 'package:undercover_game/screens/reveal_screen.dart';
import 'package:undercover_game/word_pairs.dart';

class CardSelectionScreen extends StatefulWidget {
  final int totalPlayers;
  final int numSpies;
  final int numMrWhites;
  final Language language;

  const CardSelectionScreen({
    super.key,
    required this.totalPlayers,
    required this.numSpies,
    required this.numMrWhites,
    required this.language,
  });

  @override
  State<CardSelectionScreen> createState() => _CardSelectionScreenState();
}

class _CardSelectionScreenState extends State<CardSelectionScreen>
    with TickerProviderStateMixin {
  late List<Role> cardRoles;
  late String civilianWord;
  late String spyWord;
  List<Player?> players = [];
  List<bool> taken = [];
  List<List<String>> wordPairs = [];

  @override
  void initState() {
    super.initState();
    _loadWordPairs();
    players = List.filled(widget.totalPlayers, null);
    taken = List.filled(widget.totalPlayers, false);
  }

  Future<void> _loadWordPairs() async {
    final prefs = await SharedPreferences.getInstance();
    final wordPairsJson = prefs.getString('wordPairs_${widget.language.name}');
    if (wordPairsJson != null) {
      final List<dynamic> decoded = jsonDecode(wordPairsJson);
      setState(() {
        wordPairs = decoded.map((pair) => List<String>.from(pair)).toList();
      });
    } else {
      setState(() {
        wordPairs = widget.language == Language.english
            ? englishWordPairs
            : arabicWordPairs;
      });
      await prefs.setString(
        'wordPairs_${widget.language.name}',
        jsonEncode(wordPairs),
      );
    }
    _setupGame();
  }

  void _setupGame() {
    final random = Random();
    final pair = wordPairs[random.nextInt(wordPairs.length)];
    civilianWord = pair[0];
    spyWord = pair[1];

    cardRoles = List.filled(
      widget.totalPlayers - widget.numSpies - widget.numMrWhites,
      Role.civilian,
      growable: true,
    );
    cardRoles.addAll(List.filled(widget.numSpies, Role.spy));
    cardRoles.addAll(List.filled(widget.numMrWhites, Role.mrWhite));
    cardRoles.shuffle();
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

  @override
  Widget build(BuildContext context) {
    int remaining = taken.where((t) => !t).length;
    if (remaining == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => GameScreen(
              players: players.whereType<Player>().toList(),
              civilianWord: civilianWord,
              spyWord: spyWord,
              language: widget.language,
            ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  const begin = Offset(1.0, 0.0);
                  const end = Offset.zero;
                  const curve = Curves.easeInOut;

                  var tween = Tween(
                    begin: begin,
                    end: end,
                  ).chain(CurveTween(curve: curve));
                  var offsetAnimation = animation.drive(tween);

                  return SlideTransition(
                    position: offsetAnimation,
                    child: child,
                  );
                },
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

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Choose a Card',
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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                          'Choose Your Card',
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
                      'Select a card to reveal your role',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        color: Colors.white70,
                        fontStyle: FontStyle.italic,
                      ),
                    ).animate().fadeIn(duration: 400.ms),
                    const SizedBox(height: 12),
                    Text(
                      '$remaining card${remaining > 1 ? 's' : ''} remaining',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ).animate().fadeIn(duration: 400.ms),
                    const SizedBox(height: 30),
                    _buildCard(
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.75,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                        itemCount: widget.totalPlayers,
                        itemBuilder: (context, index) {
                          if (taken[index]) {
                            return Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.grey[600]!.withOpacity(0.5),
                                        Colors.grey[800]!.withOpacity(0.5),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.2),
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
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.check_circle,
                                        color: Colors.white.withOpacity(0.8),
                                        size: 40,
                                      ),
                                      Text(
                                        'Taken',
                                        style: GoogleFonts.poppins(
                                          color: Colors.white.withOpacity(0.7),
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                                .animate()
                                .fadeIn(duration: 300.ms)
                                .scale(duration: 400.ms, curve: Curves.easeOut);
                          }
                          return GestureDetector(
                            onTap: () async {
                              final name = await Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder:
                                      (
                                        context,
                                        animation,
                                        secondaryAnimation,
                                      ) => const NameEntryScreen(),
                                  transitionsBuilder:
                                      (
                                        context,
                                        animation,
                                        secondaryAnimation,
                                        child,
                                      ) {
                                        const begin = Offset(0.0, 1.0);
                                        const end = Offset.zero;
                                        const curve = Curves.easeInOut;

                                        var tween = Tween(
                                          begin: begin,
                                          end: end,
                                        ).chain(CurveTween(curve: curve));
                                        var offsetAnimation = animation.drive(
                                          tween,
                                        );

                                        return SlideTransition(
                                          position: offsetAnimation,
                                          child: child,
                                        );
                                      },
                                ),
                              );
                              if (name != null &&
                                  name is String &&
                                  name.trim().isNotEmpty) {
                                final role = cardRoles[index];
                                await Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder:
                                        (
                                          context,
                                          animation,
                                          secondaryAnimation,
                                        ) => RevealScreen(
                                          name: name,
                                          role: role,
                                          word: _getWordForRole(role),
                                        ),
                                    transitionsBuilder:
                                        (
                                          context,
                                          animation,
                                          secondaryAnimation,
                                          child,
                                        ) {
                                          const begin = Offset(0.0, 1.0);
                                          const end = Offset.zero;
                                          const curve = Curves.easeInOut;

                                          var tween = Tween(
                                            begin: begin,
                                            end: end,
                                          ).chain(CurveTween(curve: curve));
                                          var offsetAnimation = animation.drive(
                                            tween,
                                          );

                                          return SlideTransition(
                                            position: offsetAnimation,
                                            child: child,
                                          );
                                        },
                                  ),
                                );
                                setState(() {
                                  players[index] = Player(name, role);
                                  taken[index] = true;
                                });
                              }
                            },
                            child:
                                Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
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
                                          color: Colors.white.withOpacity(0.2),
                                          width: 1.5,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.2,
                                            ),
                                            blurRadius: 12,
                                            offset: const Offset(0, 6),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.help_outline,
                                            size: 48,
                                            color: Colors.white.withOpacity(
                                              0.9,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Reveal Role',
                                            style: GoogleFonts.poppins(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                    .animate()
                                    .fadeIn(duration: 300.ms)
                                    .scale(
                                      duration: 400.ms,
                                      curve: Curves.easeOut,
                                    ),
                          );
                        },
                      ),
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

  String _getWordForRole(Role role) {
    switch (role) {
      case Role.civilian:
        return civilianWord;
      case Role.spy:
        return spyWord;
      case Role.mrWhite:
        return widget.language == Language.english
            ? 'No word - Guess from others!'
            : 'لا توجد كلمة - خمن من الآخرين!';
    }
  }
}
