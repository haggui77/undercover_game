import 'package:flutter/material.dart';
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

class _VerifyPlayerScreenState extends State<VerifyPlayerScreen> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Verify Your Identity', style: GoogleFonts.poppins()),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Enter Your Name to View Your Role',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: _controller,
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 18),
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: 'Your Name',
                    labelStyle: GoogleFonts.poppins(
                      color: Colors.white.withOpacity(0.7),
                    ),
                    prefixIcon: const Icon(Icons.person, color: Colors.white70),
                    errorText: _errorMessage,
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.15),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onSubmitted: (value) => _verifyPlayer(),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _verifyPlayer,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.indigo[800],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      'VERIFY',
                      style: GoogleFonts.poppins(
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
