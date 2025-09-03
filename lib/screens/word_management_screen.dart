import 'dart:convert';
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

class _WordManagementScreenState extends State<WordManagementScreen> {
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
            style: GoogleFonts.poppins(),
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
      builder: (context) => AlertDialog(
        backgroundColor: Colors.indigo[900]!.withOpacity(0.95),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Edit Word Pair',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
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
                    color: Colors.white.withOpacity(0.7),
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
                style: GoogleFonts.poppins(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Spy Word',
                  labelStyle: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.7),
                  ),
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
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
          ElevatedButton(
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
                      style: GoogleFonts.poppins(),
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
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.indigo[800],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Save',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ).animate().fadeIn(duration: 300.ms).scale(duration: 400.ms),
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
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: Colors.red[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
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
      appBar: AppBar(
        title: Text('Manage Words', style: GoogleFonts.poppins()),
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
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add New Word Pair',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ).animate().fadeIn(duration: 400.ms),
                const SizedBox(height: 16),
                _buildLanguageSelector().animate().fadeIn(duration: 400.ms),
                const SizedBox(height: 16),
                Form(
                  key: _formKey,
                  child: Container(
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
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _civilianController,
                          style: GoogleFonts.poppins(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Civilian Word',
                            labelStyle: GoogleFonts.poppins(
                              color: Colors.white.withOpacity(0.7),
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
                          style: GoogleFonts.poppins(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Spy Word',
                            labelStyle: GoogleFonts.poppins(
                              color: Colors.white.withOpacity(0.7),
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
                        SizedBox(
                          width: double.infinity,
                          child:
                              ElevatedButton(
                                    onPressed: _addWordPair,
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      backgroundColor: Colors.white,
                                      foregroundColor: Colors.indigo[800],
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                    child: Text(
                                      'ADD WORD PAIR',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  )
                                  .animate()
                                  .fadeIn(duration: 400.ms)
                                  .scale(duration: 400.ms),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 400.ms).scale(duration: 400.ms),
                ),
                const SizedBox(height: 24),
                Text(
                  'Existing Word Pairs',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ).animate().fadeIn(duration: 400.ms),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: currentPairs.length,
                    itemBuilder: (context, index) {
                      final pair = currentPairs[index];
                      return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.blue[500]!.withOpacity(0.3),
                                  Colors.blue[800]!.withOpacity(0.3),
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
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                                width: 1.5,
                              ),
                            ),
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
                                          color: Colors.green[100],
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        'Spy: ${pair[1]}',
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          color: Colors.red[100],
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
                                  onPressed: () => _deleteWordPair(index),
                                ),
                              ],
                            ),
                          )
                          .animate()
                          .fadeIn(duration: 300.ms)
                          .scale(duration: 400.ms);
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
