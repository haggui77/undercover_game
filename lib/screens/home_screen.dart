import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:undercover_game/screens/card_selection_screen.dart';
import 'package:undercover_game/screens/leaderboard_screen.dart';
import 'package:undercover_game/screens/word_management_screen.dart';
import 'package:undercover_game/widgets/custom_button.dart';
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
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildLanguageSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.15),
            Colors.white.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Language',
            style: GoogleFonts.poppins(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedLanguage = Language.english;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    gradient: _selectedLanguage == Language.english
                        ? LinearGradient(
                            colors: [Colors.indigo[600]!, Colors.indigo[800]!],
                          )
                        : null,
                    color: _selectedLanguage == Language.english
                        ? null
                        : Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    'English',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedLanguage = Language.arabic;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    gradient: _selectedLanguage == Language.arabic
                        ? LinearGradient(
                            colors: [Colors.indigo[600]!, Colors.indigo[800]!],
                          )
                        : null,
                    color: _selectedLanguage == Language.arabic
                        ? null
                        : Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    'العربية',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.5,
            colors: [Colors.indigo[700]!, Colors.indigo[900]!],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight:
                        MediaQuery.of(context).size.height -
                        MediaQuery.of(context).padding.top -
                        MediaQuery.of(context).padding.bottom,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Spacer(flex: 2),
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.indigo[600]!.withOpacity(0.7),
                                Colors.indigo[800]!.withOpacity(0.7),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Text(
                                'UNDERCOVER',
                                style: GoogleFonts.poppins(
                                  fontSize: 40,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: 3,
                                  shadows: [
                                    Shadow(
                                      blurRadius: 15.0,
                                      color: Colors.black.withOpacity(0.4),
                                      offset: const Offset(2.0, 2.0),
                                    ),
                                  ],
                                ),
                              ).animate().scale(
                                duration: 800.ms,
                                curve: Curves.easeOutBack,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Unmask the Deceivers!',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  color: Colors.white.withOpacity(0.9),
                                  fontStyle: FontStyle.italic,
                                ),
                              ).animate().fadeIn(delay: 200.ms),
                            ],
                          ),
                        ),
                        const Spacer(),
                        NumberSelector(
                          label: 'Total Players',
                          value: _totalPlayers,
                          min: 3,
                          max: 12,
                          onChanged: (value) {
                            setState(() {
                              _totalPlayers = value;
                              if (_numSpies + _numMrWhites >= _totalPlayers) {
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
                        ).animate().slideY(
                          begin: 0.5,
                          end: 0,
                          duration: 600.ms,
                        ),
                        const SizedBox(height: 20),
                        NumberSelector(
                          label: 'Spies',
                          value: _numSpies,
                          min: 0,
                          max: _totalPlayers - _numMrWhites - 1,
                          onChanged: (value) {
                            setState(() {
                              _numSpies = value;
                            });
                          },
                        ).animate().slideY(
                          begin: 0.5,
                          end: 0,
                          duration: 700.ms,
                        ),
                        const SizedBox(height: 20),
                        NumberSelector(
                          label: 'Mr. Whites',
                          value: _numMrWhites,
                          min: 0,
                          max: _totalPlayers - _numSpies - 1,
                          onChanged: (value) {
                            setState(() {
                              _numMrWhites = value;
                            });
                          },
                        ).animate().slideY(
                          begin: 0.5,
                          end: 0,
                          duration: 800.ms,
                        ),
                        const SizedBox(height: 20),
                        _buildLanguageSelector().animate().slideY(
                          begin: 0.5,
                          end: 0,
                          duration: 900.ms,
                        ),
                        const Spacer(),
                        CustomButton(
                          text: 'START GAME',
                          icon: Icons.play_arrow,
                          onPressed: () {
                            if (_numSpies + _numMrWhites >= _totalPlayers) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Spies + Mr. Whites must be less than total players.',
                                    style: GoogleFonts.poppins(),
                                  ),
                                  backgroundColor: Colors.red[600],
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              );
                              return;
                            }
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
                                        CardSelectionScreen(
                                          totalPlayers: _totalPlayers,
                                          numSpies: _numSpies,
                                          numMrWhites: _numMrWhites,
                                          language: _selectedLanguage,
                                        ),
                                transitionsBuilder:
                                    (
                                      context,
                                      animation,
                                      secondaryAnimation,
                                      child,
                                    ) {
                                      const begin = Offset(1.0, 0.0);
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
                          },
                          gradient: LinearGradient(
                            colors: [Colors.green[600]!, Colors.green[800]!],
                          ),
                        ).animate().fadeIn(delay: 900.ms).scale(duration: 600.ms),
                        const SizedBox(height: 16),
                        CustomButton(
                              text: 'LEADERBOARD',
                              icon: Icons.leaderboard,
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder:
                                        (
                                          context,
                                          animation,
                                          secondaryAnimation,
                                        ) => const LeaderboardScreen(),
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
                              },
                              gradient: LinearGradient(
                                colors: [
                                  Colors.amber[600]!,
                                  Colors.amber[800]!,
                                ],
                              ),
                            )
                            .animate()
                            .fadeIn(delay: 1000.ms)
                            .scale(duration: 600.ms),
                        const SizedBox(height: 16),
                        CustomButton(
                              text: 'MANAGE WORDS',
                              icon: Icons.edit_note,
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder:
                                        (
                                          context,
                                          animation,
                                          secondaryAnimation,
                                        ) => const WordManagementScreen(),
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
                              },
                              gradient: LinearGradient(
                                colors: [Colors.blue[600]!, Colors.blue[800]!],
                              ),
                            )
                            .animate()
                            .fadeIn(delay: 1100.ms)
                            .scale(duration: 600.ms),
                        const Spacer(flex: 2),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
