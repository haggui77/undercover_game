import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:undercover_game/models/enums.dart';
import 'package:undercover_game/models/players.dart';

class RevealScreen extends StatelessWidget {
  final String name;
  final Role role;
  final String word;

  const RevealScreen({
    super.key,
    required this.name,
    required this.role,
    required this.word,
  });

  Color _getRoleColor() {
    switch (role) {
      case Role.civilian:
        return Colors.green;
      case Role.spy:
        return Colors.red;
      case Role.mrWhite:
        return Colors.amber;
    }
  }

  IconData _getRoleIcon() {
    switch (role) {
      case Role.civilian:
        return Icons.people;
      case Role.spy:
        return Icons.visibility_off;
      case Role.mrWhite:
        return Icons.help;
    }
  }

  @override
  Widget build(BuildContext context) {
    print(
      'RevealScreen built for player: $name, Role: $role, Word: $word',
    ); // Debug log
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Role', style: GoogleFonts.poppins()),
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
                  'Player: $name',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(24),
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
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Icon(_getRoleIcon(), size: 48, color: _getRoleColor()),
                      const SizedBox(height: 16),
                      Text(
                        role.name.toUpperCase(),
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: _getRoleColor(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        word,
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.indigo[800],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      'GOT IT',
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
}
