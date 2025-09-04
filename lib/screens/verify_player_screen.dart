import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:undercover_game/models/enums.dart';
import 'package:undercover_game/models/players.dart';
import 'package:undercover_game/screens/reveal_screen.dart';

class VerifyPlayerScreen extends StatefulWidget {
  final List<Player> players;
  final String civilianWord;
  final String spyWord;
  final Language language;

  const VerifyPlayerScreen({
    super.key,
    required this.players,
    required this.civilianWord,
    required this.spyWord,
    required this.language,
  });

  @override
  State<VerifyPlayerScreen> createState() => _VerifyPlayerScreenState();
}

class _VerifyPlayerScreenState extends State<VerifyPlayerScreen>
    with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  String? _errorMessage;

  String _getWordForRole(Role role) {
    switch (role) {
      case Role.civilian:
        return widget.civilianWord;
      case Role.spy:
        return widget.spyWord;
      case Role.mrWhite:
        return widget.language == Language.english
            ? 'No word - Guess from others!'
            : 'لا توجد كلمة - خمن من الآخرين!';
    }
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
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Verify Your Identity',
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                          'Verify Your Identity',
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
                    const SizedBox(height: 32),
                    _buildCard(
                          child: TextField(
                            controller: _controller,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                            textCapitalization: TextCapitalization.words,
                            decoration: InputDecoration(
                              labelText: 'Your Name',
                              labelStyle: GoogleFonts.poppins(
                                color: Colors.white70,
                              ),
                              prefixIcon: const Icon(
                                Icons.person,
                                color: Colors.white70,
                              ),
                              errorText: _errorMessage,
                              errorStyle: GoogleFonts.poppins(
                                color: Colors.red,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.white.withOpacity(0.2),
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Colors.indigoAccent,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Colors.red,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Colors.red,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onSubmitted: (value) => _verifyPlayer(),
                          ),
                        )
                        .animate()
                        .fadeIn(duration: 400.ms)
                        .scale(duration: 400.ms, curve: Curves.easeOut),
                    const SizedBox(height: 32),
                    _buildGameButton(
                          text: 'VERIFY',
                          icon: Icons.arrow_forward,
                          colors: [Colors.greenAccent, Colors.teal],
                          onTap: _verifyPlayer,
                        )
                        .animate()
                        .fadeIn(duration: 400.ms)
                        .scale(duration: 400.ms, curve: Curves.easeOut),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _verifyPlayer() {
    final name = _controller.text.trim();
    print('Verifying player: "$name"'); // Debug log
    if (name.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your name';
      });
      print('Error: Empty name entered'); // Debug log
      return;
    }

    final player = widget.players.firstWhere(
      (p) => p.name.trim().toLowerCase() == name.toLowerCase(),
      orElse: () => Player('__INVALID__', Role.civilian),
    );

    if (player.name == '__INVALID__') {
      setState(() {
        _errorMessage = 'Player not found. Please check your name.';
      });
      print('Error: Player "$name" not found'); // Debug log
      return;
    }

    print('Player verified: ${player.name}, Role: ${player.role}'); // Debug log
    Navigator.pop(context); // Pop VerifyPlayerScreen
    print('Navigating to RevealScreen for player: ${player.name}'); // Debug log
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => RevealScreen(
            name: player.name,
            role: player.role,
            word: _getWordForRole(player.role),
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
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
