import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// Background with animated blobs
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

          /// Content
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // prevents stretching
                    children: [
                      const SizedBox(height: 20),

                      /// Game Title
                      Text(
                            "UNDERCOVER",
                            textAlign: TextAlign.center,
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

                      const SizedBox(height: 12),
                      Text(
                        "Unmask the Deceivers!",
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          color: Colors.white70,
                          fontStyle: FontStyle.italic,
                        ),
                      ).animate().fadeIn(delay: 400.ms),

                      const SizedBox(height: 30),

                      /// Player settings card
                      _buildCard(
                        child: Column(
                          children: [
                            NumberSelector(
                              label: "Total Players",
                              value: _totalPlayers,
                              min: 3,
                              max: 12,
                              onChanged: (value) {
                                setState(() {
                                  _totalPlayers = value;
                                  if (_numSpies + _numMrWhites >=
                                      _totalPlayers) {
                                    _numSpies = max(
                                      0,
                                      min(_numSpies, _totalPlayers - 1),
                                    );
                                    _numMrWhites = max(
                                      0,
                                      min(
                                        _numMrWhites,
                                        _totalPlayers - _numSpies - 1,
                                      ),
                                    );
                                  }
                                });
                              },
                            ),
                            const SizedBox(height: 14),
                            NumberSelector(
                              label: "Spies",
                              value: _numSpies,
                              min: 0,
                              max: _totalPlayers - _numMrWhites - 1,
                              onChanged: (value) {
                                setState(() => _numSpies = value);
                              },
                            ),
                            const SizedBox(height: 14),
                            NumberSelector(
                              label: "Mr. Whites",
                              value: _numMrWhites,
                              min: 0,
                              max: _totalPlayers - _numSpies - 1,
                              onChanged: (value) {
                                setState(() => _numMrWhites = value);
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      /// Language card
                      _buildCard(
                        child: Column(
                          children: [
                            Text(
                              "Language",
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildLangChip("English", Language.english),
                                _buildLangChip("العربية", Language.arabic),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      /// Buttons
                      _buildGameButton(
                        text: "START GAME",
                        icon: Icons.play_arrow,
                        colors: [Colors.greenAccent, Colors.teal],
                        onTap: () {
                          if (_numSpies + _numMrWhites >= _totalPlayers) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Spies + Mr. Whites must be less than total players.',
                                  style: GoogleFonts.poppins(),
                                ),
                                backgroundColor: Colors.redAccent,
                              ),
                            );
                            return;
                          }
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CardSelectionScreen(
                                totalPlayers: _totalPlayers,
                                numSpies: _numSpies,
                                numMrWhites: _numMrWhites,
                                language: _selectedLanguage,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildGameButton(
                        text: "LEADERBOARD",
                        icon: Icons.leaderboard,
                        colors: [Colors.orangeAccent, Colors.deepOrange],
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LeaderboardScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildGameButton(
                        text: "MANAGE WORDS",
                        icon: Icons.edit_note,
                        colors: [Colors.blueAccent, Colors.indigo],
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const WordManagementScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildGameButton(
                        text: "EXIT",
                        icon: Icons.exit_to_app,
                        colors: [
                          const Color.fromARGB(255, 255, 68, 68),
                          Colors.indigo,
                        ],
                        onTap: () {
                          SystemNavigator.pop();
                        },
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ====== UI HELPERS ======

  Widget _buildBlob(double size, Color color) {
    return IgnorePointer(
      ignoring: true, // purely decorative
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
                      blurRadius: size * 0.6, // soft blur
                      spreadRadius: size * 0.25, // expands the glow
                    ),
                  ],
                ),
              )
              // gentle breathing animation
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

  Widget _buildLangChip(String text, Language lang) {
    final bool selected = _selectedLanguage == lang;
    return GestureDetector(
      onTap: () => setState(() => _selectedLanguage = lang),
      child: AnimatedContainer(
        duration: 300.ms,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          gradient: selected
              ? LinearGradient(colors: [Colors.pinkAccent, Colors.purpleAccent])
              : null,
          color: selected ? null : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          text,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
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
}
