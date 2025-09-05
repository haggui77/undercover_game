import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  // Animation controllers
  late AnimationController _pulseController;
  late AnimationController _glowController;
  late AnimationController _cardSelectController;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadWordPairs();
    players = List.filled(widget.totalPlayers, null);
    taken = List.filled(widget.totalPlayers, false);
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _cardSelectController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _glowController.dispose();
    _cardSelectController.dispose();
    super.dispose();
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

  // Enhanced app bar
  PreferredSizeWidget _buildEnhancedAppBar() {
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
        'Choose Your Card',
        style: GoogleFonts.inter(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
      ),
      centerTitle: true,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  // Enhanced card widget
  Widget _buildCard({
    required int index,
    required bool isTaken,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
          onTap: isTaken
              ? null
              : () {
                  HapticFeedback.mediumImpact();
                  _cardSelectController.forward().then((_) {
                    _cardSelectController.reverse();
                  });
                  if (onTap != null) onTap();
                },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isTaken
                    ? Colors.grey.withOpacity(0.3)
                    : Colors.white.withOpacity(0.3),
                width: 1.5,
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isTaken
                    ? [
                        Colors.grey.withOpacity(0.1),
                        Colors.grey.withOpacity(0.05),
                      ]
                    : [
                        const Color(0xFF667eea).withOpacity(0.2),
                        const Color(0xFF764ba2).withOpacity(0.1),
                      ],
              ),
              boxShadow: [
                BoxShadow(
                  color: isTaken
                      ? Colors.black.withOpacity(0.2)
                      : const Color(0xFF667eea).withOpacity(0.3),
                  blurRadius: isTaken ? 10 : 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Container(
              height: 180,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: isTaken
                            ? [Colors.grey, Colors.grey[600]!]
                            : [
                                const Color(0xFF667eea),
                                const Color(0xFF764ba2),
                              ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color:
                              (isTaken ? Colors.grey : const Color(0xFF667eea))
                                  .withOpacity(0.4),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Icon(
                      isTaken ? Icons.check_circle : Icons.touch_app,
                      color: Colors.white,
                      size: isTaken ? 28 : 32,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    isTaken ? 'Taken' : 'Card ${index + 1}',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isTaken ? Colors.grey : Colors.white,
                    ),
                  ),
                  if (!isTaken) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Tap to reveal',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.white60,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(
          duration: 300.ms,
          delay: Duration(milliseconds: index * 50),
        )
        .slideY(
          begin: 0.3,
          end: 0,
          duration: 400.ms,
          curve: Curves.easeOutCubic,
        );
  }

  // Game stats widget
  Widget _buildGameStats() {
    int remaining = taken.where((t) => !t).length;
    int selectedCards = taken.where((t) => t).length;

    return _buildGlassCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem(
            icon: Icons.people,
            label: 'Total Players',
            value: '${widget.totalPlayers}',
            color: Colors.blue,
          ),
          Container(height: 40, width: 1, color: Colors.white.withOpacity(0.2)),
          _buildStatItem(
            icon: Icons.visibility_off,
            label: 'Spies',
            value: '${widget.numSpies}',
            color: Colors.red,
          ),
          Container(height: 40, width: 1, color: Colors.white.withOpacity(0.2)),
          _buildStatItem(
            icon: Icons.help,
            label: 'Mr. White',
            value: '${widget.numMrWhites}',
            color: Colors.amber,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
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
            color: Colors.white60,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  // Progress indicator
  Widget _buildProgressIndicator() {
    int remaining = taken.where((t) => !t).length;
    double progress = (widget.totalPlayers - remaining) / widget.totalPlayers;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Text(
                '${widget.totalPlayers - remaining}/${widget.totalPlayers}',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: Colors.white.withOpacity(0.1),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF667eea).withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (remaining > 0) ...[
            const SizedBox(height: 12),
            Text(
              '$remaining card${remaining > 1 ? 's' : ''} remaining',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.white60,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ],
      ),
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
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                            ),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: const Icon(
                            Icons.rocket_launch,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Starting Game...',
                          style: GoogleFonts.inter(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'All players have selected their cards',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: 200,
                          child: LinearProgressIndicator(
                            backgroundColor: Colors.white.withOpacity(0.2),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFF667eea),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildEnhancedAppBar(),
      body: Stack(
        children: [
          _buildAnimatedBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 5),
                  Text(
                        'Select Your Role',
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 1,
                        ),
                      )
                      .animate()
                      .fadeIn(duration: 600.ms)
                      .scale(duration: 500.ms, curve: Curves.easeOutBack),
                  const SizedBox(height: 4),
                  Text(
                    'Each player must choose a card to reveal their role',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.white70,
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(duration: 800.ms),
                  const SizedBox(height: 24),
                  _buildGameStats().animate().fadeIn(
                    duration: 800.ms,
                    delay: 200.ms,
                  ),
                  const SizedBox(height: 20),
                  _buildProgressIndicator().animate().fadeIn(
                    duration: 800.ms,
                    delay: 400.ms,
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: _buildGlassCard(
                      child: GridView.builder(
                        physics: const BouncingScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount:
                              MediaQuery.of(context).size.width > 600 ? 3 : 2,
                          childAspectRatio: 0.8,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: widget.totalPlayers,
                        itemBuilder: (context, index) {
                          return _buildCard(
                            index: index,
                            isTaken: taken[index],
                            onTap: taken[index]
                                ? null
                                : () async {
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
                                              return SlideTransition(
                                                position:
                                                    Tween<Offset>(
                                                      begin: const Offset(0, 1),
                                                      end: Offset.zero,
                                                    ).animate(
                                                      CurvedAnimation(
                                                        parent: animation,
                                                        curve: Curves
                                                            .easeInOutCubic,
                                                      ),
                                                    ),
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
                                                return SlideTransition(
                                                  position:
                                                      Tween<Offset>(
                                                        begin: const Offset(
                                                          0,
                                                          1,
                                                        ),
                                                        end: Offset.zero,
                                                      ).animate(
                                                        CurvedAnimation(
                                                          parent: animation,
                                                          curve: Curves
                                                              .easeInOutCubic,
                                                        ),
                                                      ),
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
                          );
                        },
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
