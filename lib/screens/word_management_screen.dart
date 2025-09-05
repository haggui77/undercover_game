import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:undercover_game/word_pairs.dart';
import 'package:undercover_game/models/enums.dart';

class WordManagementScreen extends StatefulWidget {
  const WordManagementScreen({super.key});

  @override
  State<WordManagementScreen> createState() => _WordManagementScreenState();
}

class _WordManagementScreenState extends State<WordManagementScreen>
    with TickerProviderStateMixin {
  final _civilianController = TextEditingController();
  final _spyController = TextEditingController();
  List<List<String>> _englishWordPairs = [];
  List<List<String>> _arabicWordPairs = [];
  final _formKey = GlobalKey<FormState>();
  Language _selectedLanguage = Language.english;

  @override
  void initState() {
    super.initState();
    _loadWordPairs();
  }

  Future<void> _loadWordPairs() async {
    final prefs = await SharedPreferences.getInstance();

    // Load English word pairs
    final englishWordPairsJson = prefs.getString('wordPairs_english');
    if (englishWordPairsJson != null) {
      final List<dynamic> decoded = jsonDecode(englishWordPairsJson);
      setState(() {
        _englishWordPairs = decoded
            .map((pair) => List<String>.from(pair))
            .toList();
      });
    } else {
      setState(() {
        _englishWordPairs = List.from(englishWordPairs);
      });
      await prefs.setString('wordPairs_english', jsonEncode(_englishWordPairs));
    }

    // Load Arabic word pairs
    final arabicWordPairsJson = prefs.getString('wordPairs_arabic');
    if (arabicWordPairsJson != null) {
      final List<dynamic> decoded = jsonDecode(arabicWordPairsJson);
      setState(() {
        _arabicWordPairs = decoded
            .map((pair) => List<String>.from(pair))
            .toList();
      });
    } else {
      setState(() {
        _arabicWordPairs = List.from(arabicWordPairs);
      });
      await prefs.setString('wordPairs_arabic', jsonEncode(_arabicWordPairs));
    }
  }

  Future<void> _saveWordPairs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('wordPairs_english', jsonEncode(_englishWordPairs));
    await prefs.setString('wordPairs_arabic', jsonEncode(_arabicWordPairs));
  }

  void _addWordPair() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        if (_selectedLanguage == Language.english) {
          _englishWordPairs.add([
            _civilianController.text.trim(),
            _spyController.text.trim(),
          ]);
        } else {
          _arabicWordPairs.add([
            _civilianController.text.trim(),
            _spyController.text.trim(),
          ]);
        }
        _civilianController.clear();
        _spyController.clear();
      });
      _saveWordPairs();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Word pair added successfully!',
            style: GoogleFonts.poppins(color: Colors.white),
          ),
          backgroundColor: Colors.green[600],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  void _editWordPair(int index) {
    final currentPairs = _selectedLanguage == Language.english
        ? _englishWordPairs
        : _arabicWordPairs;
    _civilianController.text = currentPairs[index][0];
    _spyController.text = currentPairs[index][1];
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
                backgroundColor: Colors.white.withOpacity(0.05),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.white.withOpacity(0.2)),
                ),
                title: Text(
                  'Edit Word Pair',
                  style: GoogleFonts.orbitron(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
                content: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: _civilianController,
                        style: GoogleFonts.poppins(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Civilian Word',
                          labelStyle: GoogleFonts.poppins(
                            color: Colors.white70,
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
                          errorStyle: GoogleFonts.poppins(color: Colors.red),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a civilian word';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _spyController,
                        style: GoogleFonts.poppins(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Spy Word',
                          labelStyle: GoogleFonts.poppins(
                            color: Colors.white70,
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
                          errorStyle: GoogleFonts.poppins(color: Colors.red),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a spy word';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.poppins(
                        color: Colors.blueAccent,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          if (_selectedLanguage == Language.english) {
                            _englishWordPairs[index] = [
                              _civilianController.text.trim(),
                              _spyController.text.trim(),
                            ];
                          } else {
                            _arabicWordPairs[index] = [
                              _civilianController.text.trim(),
                              _spyController.text.trim(),
                            ];
                          }
                          _civilianController.clear();
                          _spyController.clear();
                        });
                        _saveWordPairs();
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Word pair updated successfully!',
                              style: GoogleFonts.poppins(color: Colors.white),
                            ),
                            backgroundColor: Colors.green[600],
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                      }
                    },
                    child: Text(
                      'Save',
                      style: GoogleFonts.poppins(
                        color: Colors.green,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              )
              .animate()
              .fadeIn(duration: 300.ms)
              .scale(duration: 400.ms, curve: Curves.easeOut),
    );
  }

  void _deleteWordPair(int index) {
    setState(() {
      if (_selectedLanguage == Language.english) {
        _englishWordPairs.removeAt(index);
      } else {
        _arabicWordPairs.removeAt(index);
      }
    });
    _saveWordPairs();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Word pair deleted successfully!',
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        backgroundColor: Colors.red[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
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

  Widget _buildLanguageSelector() {
    return _buildCard(
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
                            colors: [Colors.indigoAccent, Colors.purpleAccent],
                          )
                        : LinearGradient(
                            colors: [
                              Colors.grey.withOpacity(0.3),
                              Colors.grey.withOpacity(0.2),
                            ],
                          ),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
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
                            colors: [Colors.indigoAccent, Colors.purpleAccent],
                          )
                        : LinearGradient(
                            colors: [
                              Colors.grey.withOpacity(0.3),
                              Colors.grey.withOpacity(0.2),
                            ],
                          ),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
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
  void dispose() {
    _civilianController.dispose();
    _spyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentPairs = _selectedLanguage == Language.english
        ? _englishWordPairs
        : _arabicWordPairs;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Manage Words',
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                          'Manage Word Pairs',
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
                    const SizedBox(height: 24),
                    _buildLanguageSelector()
                        .animate()
                        .fadeIn(duration: 400.ms)
                        .scale(duration: 400.ms, curve: Curves.easeOut),
                    const SizedBox(height: 24),
                    _buildCard(
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                TextFormField(
                                  controller: _civilianController,
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                  ),
                                  decoration: InputDecoration(
                                    labelText: 'Civilian Word',
                                    labelStyle: GoogleFonts.poppins(
                                      color: Colors.white70,
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
                                    errorStyle: GoogleFonts.poppins(
                                      color: Colors.red,
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Please enter a civilian word';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _spyController,
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                  ),
                                  decoration: InputDecoration(
                                    labelText: 'Spy Word',
                                    labelStyle: GoogleFonts.poppins(
                                      color: Colors.white70,
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
                                    errorStyle: GoogleFonts.poppins(
                                      color: Colors.red,
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Please enter a spy word';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                _buildGameButton(
                                  text: 'ADD WORD PAIR',
                                  icon: Icons.add,
                                  colors: [Colors.greenAccent, Colors.teal],
                                  onTap: _addWordPair,
                                ),
                              ],
                            ),
                          ),
                        )
                        .animate()
                        .fadeIn(duration: 400.ms)
                        .scale(duration: 400.ms, curve: Curves.easeOut),
                    const SizedBox(height: 24),
                    Text(
                      'Existing Word Pairs',
                      style: GoogleFonts.orbitron(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ).animate().fadeIn(duration: 400.ms),
                    const SizedBox(height: 16),
                    currentPairs.isEmpty
                        ? _buildCard(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16.0,
                                  ),
                                  child: Text(
                                    'No word pairs added yet!',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      color: Colors.white70,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              )
                              .animate()
                              .fadeIn(duration: 400.ms)
                              .scale(duration: 400.ms, curve: Curves.easeOut)
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: currentPairs.length,
                            itemBuilder: (context, index) {
                              final pair = currentPairs[index];
                              return _buildCard(
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Civilian: ${pair[0]}',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 16,
                                                  color: Colors.green[300],
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              Text(
                                                'Spy: ${pair[1]}',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 16,
                                                  color: Colors.red[300],
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.edit,
                                            color: Colors.white,
                                          ),
                                          onPressed: () => _editWordPair(index),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                          onPressed: () =>
                                              _deleteWordPair(index),
                                        ),
                                      ],
                                    ),
                                  )
                                  .animate()
                                  .fadeIn(duration: 300.ms)
                                  .scale(
                                    duration: 400.ms,
                                    curve: Curves.easeOut,
                                  );
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
}
