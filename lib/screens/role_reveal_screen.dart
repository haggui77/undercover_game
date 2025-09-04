import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:undercover_game/models/enums.dart';
import 'package:undercover_game/models/players.dart';
import 'package:undercover_game/screens/game_screen.dart';
import 'package:undercover_game/screens/reveal_screen.dart';
import 'package:undercover_game/word_pairs.dart';

class RoleRevealScreen extends StatefulWidget {
  final List<String> playerNames;
  final int numSpies;
  final int numMrWhites;
  final Language language;

  const RoleRevealScreen({
    super.key,
    required this.playerNames,
    required this.numSpies,
    required this.numMrWhites,
    required this.language,
  });

  @override
  State<RoleRevealScreen> createState() => _RoleRevealScreenState();
}

class _RoleRevealScreenState extends State<RoleRevealScreen> {
  late List<Role> cardRoles;
  late String civilianWord;
  late String spyWord;
  late List<Player> players;
  List<bool> viewed = [];
  List<List<String>> wordPairs = [];

  @override
  void initState() {
    super.initState();
    print('Initializing RoleRevealScreen'); // Debug log
    players = widget.playerNames
        .map((name) => Player(name, Role.civilian))
        .toList();
    viewed = List.filled(widget.playerNames.length, false);
    _loadWordPairs();
  }

  Future<void> _loadWordPairs() async {
    print(
      'Loading word pairs for language: ${widget.language.name}',
    ); // Debug log
    final prefs = await SharedPreferences.getInstance();
    final wordPairsJson = prefs.getString('wordPairs_${widget.language.name}');

    if (wordPairsJson != null) {
      try {
        final List<dynamic> decoded = jsonDecode(wordPairsJson);
        wordPairs = decoded.map((pair) => List<String>.from(pair)).toList();
      } catch (e) {
        print('Error decoding word pairs: $e'); // Debug log
        wordPairs = widget.language == Language.english
            ? englishWordPairs
            : arabicWordPairs;
      }
    } else {
      wordPairs = widget.language == Language.english
          ? englishWordPairs
          : arabicWordPairs;
      await prefs.setString(
        'wordPairs_${widget.language.name}',
        jsonEncode(wordPairs),
      );
    }

    if (wordPairs.isEmpty) {
      print('Warning: Word pairs list is empty'); // Debug log
      wordPairs = [
        ['default_civilian', 'default_spy'],
      ]; // Fallback to avoid crash
    }

    setState(() {
      _setupGame();
    });
  }

  void _setupGame() {
    print('Setting up game'); // Debug log
    final random = Random();
    final pair = wordPairs[random.nextInt(wordPairs.length)];
    civilianWord = pair[0];
    spyWord = pair[1];

    final totalPlayers = widget.playerNames.length;
    cardRoles = List.filled(
      totalPlayers - widget.numSpies - widget.numMrWhites,
      Role.civilian,
      growable: true,
    );
    cardRoles.addAll(List.filled(widget.numSpies, Role.spy));
    cardRoles.addAll(List.filled(widget.numMrWhites, Role.mrWhite));
    cardRoles.shuffle();
    print('Assigned roles: $cardRoles'); // Debug log
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

  @override
  Widget build(BuildContext context) {
    int remaining = viewed.where((v) => !v).length;
    if (remaining == 0) {
      print('All players viewed roles, navigating to GameScreen'); // Debug log
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Assign roles to players
        for (int i = 0; i < players.length; i++) {
          players[i] = Player(players[i].name, cardRoles[i]);
        }
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => GameScreen(
              players: players,
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
        body: Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 1.5,
              colors: [Colors.indigo[700]!, Colors.indigo[900]!],
            ),
          ),
          child: const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Reveal Your Role', style: GoogleFonts.poppins()),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            print('Back button pressed, exiting RoleRevealScreen'); // Debug log
            Navigator.pop(context);
          },
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.5,
            colors: [Colors.indigo[700]!, Colors.indigo[900]!],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tap your name to reveal your role',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '$remaining players remaining',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                    itemCount: widget.playerNames.length,
                    itemBuilder: (context, index) {
                      final name = widget.playerNames[index];
                      if (viewed[index]) {
                        return Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          color: Colors.grey[700],
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.check_circle,
                                  color: Colors.white,
                                  size: 40,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  name,
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      return GestureDetector(
                        onTap: () async {
                          final role = cardRoles[index];
                          print(
                            'Player $name tapped, navigating to RevealScreen',
                          ); // Debug log
                          await Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      RevealScreen(
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
                            viewed[index] = true;
                            print('Marked $name as viewed'); // Debug log
                          });
                        },
                        child: Card(
                          elevation: 6,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.blue[400]!, Colors.blue[700]!],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue[900]!.withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.help_outline,
                                    size: 48,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    name,
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
