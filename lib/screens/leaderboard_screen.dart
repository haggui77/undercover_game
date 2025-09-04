import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:undercover_game/models/score.dart';
import 'package:undercover_game/models/enums.dart';
import 'package:undercover_game/services/score_manager.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with TickerProviderStateMixin {
  List<PlayerStats> leaderboard = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLeaderboard();
  }

  Future<void> _loadLeaderboard() async {
    final stats = await ScoreManager.instance.getLeaderboard();
    setState(() {
      leaderboard = stats;
      isLoading = false;
    });
  }

  Future<void> _clearAllData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white.withOpacity(0.8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: const Color.fromARGB(255, 255, 0, 0).withOpacity(0.2),
          ),
        ),
        title: Text(
          'Clear All Data',
          style: GoogleFonts.orbitron(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color.fromARGB(255, 255, 0, 0),
          ),
        ),
        content: Text(
          'Are you sure you want to clear all scores and game history? This action cannot be undone.',
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: const Color.fromARGB(255, 0, 0, 0),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(
                color: Colors.blueAccent,
                fontSize: 16,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Clear',
              style: GoogleFonts.poppins(color: Colors.red, fontSize: 16),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ScoreManager.instance.clearAllData();
      await _loadLeaderboard();
    }
  }

  Color _getRoleColor(Role role) {
    switch (role) {
      case Role.civilian:
        return Colors.green;
      case Role.spy:
        return Colors.red;
      case Role.mrWhite:
        return Colors.amber;
    }
  }

  IconData _getRankIcon(int rank) {
    switch (rank) {
      case 1:
        return Icons.emoji_events;
      case 2:
        return Icons.military_tech;
      case 3:
        return Icons.workspace_premium;
      default:
        return Icons.person;
    }
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey[400]!;
      case 3:
        return Colors.brown[300]!;
      default:
        return Colors.blue;
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

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Leaderboard',
          style: GoogleFonts.orbitron(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 2,
          ),
        ),
        backgroundColor: const Color.fromARGB(0, 218, 21, 21),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: _clearAllData,
            color: Colors.white,
          ),
        ],
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
            child: isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ).animate().fadeIn(duration: 400.ms),
                  )
                : leaderboard.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.emoji_events_outlined,
                          size: 64,
                          color: Colors.white.withOpacity(0.5),
                        ).animate().fadeIn(duration: 400.ms),
                        const SizedBox(height: 16),
                        Text(
                          'No games played yet!',
                          style: GoogleFonts.orbitron(
                            fontSize: 24,
                            color: Colors.white.withOpacity(0.8),
                            letterSpacing: 2,
                          ),
                        ).animate().fadeIn(duration: 400.ms),
                        const SizedBox(height: 8),
                        Text(
                          'Play some games to see the leaderboard',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.6),
                          ),
                        ).animate().fadeIn(duration: 400.ms),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(24.0),
                          child:
                              Text(
                                    'HALL OF FAME',
                                    style: GoogleFonts.orbitron(
                                      fontSize: 34,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 4,
                                      shadows: [
                                        Shadow(
                                          blurRadius: 25,
                                          color: Colors.indigoAccent
                                              .withOpacity(0.7),
                                        ),
                                      ],
                                    ),
                                  )
                                  .animate()
                                  .fadeIn(duration: 800.ms)
                                  .scale(
                                    duration: 700.ms,
                                    curve: Curves.easeOutBack,
                                  ),
                        ),
                        _buildCard(
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(16),
                            itemCount: leaderboard.length,
                            itemBuilder: (context, index) {
                              final player = leaderboard[index];
                              final rank = index + 1;

                              return GestureDetector(
                                    onTap: () => _showPlayerDetails(player),
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 16),
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: rank <= 3
                                              ? [
                                                  _getRankColor(
                                                    rank,
                                                  ).withOpacity(0.3),
                                                  _getRankColor(
                                                    rank,
                                                  ).withOpacity(0.1),
                                                ]
                                              : [
                                                  Colors.indigoAccent
                                                      .withOpacity(0.2),
                                                  Colors.purpleAccent
                                                      .withOpacity(0.1),
                                                ],
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: rank <= 3
                                              ? _getRankColor(rank)
                                              : Colors.white.withOpacity(0.2),
                                          width: rank <= 3 ? 2 : 1,
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
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 50,
                                            height: 50,
                                            decoration: BoxDecoration(
                                              color: _getRankColor(rank),
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: _getRankColor(
                                                    rank,
                                                  ).withOpacity(0.3),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ],
                                            ),
                                            child: Icon(
                                              _getRankIcon(rank),
                                              color: Colors.white,
                                              size: rank <= 3 ? 28 : 24,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      player.name,
                                                      style:
                                                          GoogleFonts.poppins(
                                                            fontSize: 20,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors.white,
                                                          ),
                                                    ),
                                                    Text(
                                                      '#$rank',
                                                      style:
                                                          GoogleFonts.poppins(
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color:
                                                                _getRankColor(
                                                                  rank,
                                                                ),
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 4),
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.star,
                                                      color: Colors.amber,
                                                      size: 16,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      '${player.totalPoints} pts',
                                                      style:
                                                          GoogleFonts.poppins(
                                                            fontSize: 16,
                                                            color: Colors.white
                                                                .withOpacity(
                                                                  0.9,
                                                                ),
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                    ),
                                                    const SizedBox(width: 16),
                                                    Icon(
                                                      Icons.games,
                                                      color: Colors.white
                                                          .withOpacity(0.7),
                                                      size: 16,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      '${player.gamesPlayed ~/ 2} games',
                                                      style:
                                                          GoogleFonts.poppins(
                                                            fontSize: 13,
                                                            color: Colors.white
                                                                .withOpacity(
                                                                  0.7,
                                                                ),
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 4),
                                                Row(
                                                  children: [
                                                    Text(
                                                      'Win Rate: ${player.winRate.toStringAsFixed(1)}%',
                                                      style:
                                                          GoogleFonts.poppins(
                                                            fontSize: 13,
                                                            color: Colors
                                                                .green[300],
                                                          ),
                                                    ),
                                                    const SizedBox(width: 15),
                                                    Text(
                                                      'Survival: ${player.survivalRate.toStringAsFixed(1)}%',
                                                      style:
                                                          GoogleFonts.poppins(
                                                            fontSize: 13,
                                                            color: Colors
                                                                .blue[300],
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
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
                        ).animate().fadeIn(duration: 400.ms),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  void _showPlayerDetails(PlayerStats player) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: [Color(0xFF0f172a), Color(0xFF020617)],
          ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Stack(
          children: [
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
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ).animate().fadeIn(duration: 400.ms),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Text(
                      player.name,
                      style: GoogleFonts.orbitron(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ).animate().fadeIn(duration: 400.ms),
                  ),
                  const SizedBox(height: 24),
                  _buildCard(
                        child: _buildStatCard(
                          'Total Points',
                          '${player.totalPoints}',
                          Icons.star,
                          Colors.amber,
                        ),
                      )
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .scale(duration: 400.ms, curve: Curves.easeOut),
                  const SizedBox(height: 16),
                  _buildCard(
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                'Games',
                                '${player.gamesPlayed ~/ 2}',
                                Icons.games,
                                Colors.blue,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildStatCard(
                                'Wins',
                                '${player.gamesWon ~/ 2}',
                                Icons.emoji_events,
                                Colors.green,
                              ),
                            ),
                          ],
                        ),
                      )
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .scale(duration: 400.ms, curve: Curves.easeOut),
                  const SizedBox(height: 16),
                  _buildCard(
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                'Win Rate',
                                '${player.winRate.toStringAsFixed(1)}%',
                                Icons.trending_up,
                                Colors.green,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildStatCard(
                                'Survival',
                                '${player.survivalRate.toStringAsFixed(1)}%',
                                Icons.shield,
                                Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      )
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .scale(duration: 400.ms, curve: Curves.easeOut),
                  const SizedBox(height: 24),
                  Text(
                    'Role Performance',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ).animate().fadeIn(duration: 400.ms),
                  const SizedBox(height: 16),
                  ...Role.values.map((role) {
                    final count = player.roleCount[role] ?? 0;
                    final wins = player.roleWins[role] ?? 0;
                    final rate = count > 0
                        ? ((wins ~/ 2) / (count ~/ 2) * 100)
                        : 0;
                    return _buildCard(
                          child: Row(
                            children: [
                              Icon(
                                role == Role.civilian
                                    ? Icons.people
                                    : role == Role.spy
                                    ? Icons.visibility_off
                                    : Icons.help,
                                color: _getRoleColor(role),
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      role.name.toUpperCase(),
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: _getRoleColor(role),
                                      ),
                                    ),
                                    Text(
                                      'Played: ${count ~/ 2} | Wins: ${wins ~/ 2} | Rate: ${rate.toStringAsFixed(1)}%',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: Colors.white.withOpacity(0.8),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )
                        .animate()
                        .fadeIn(duration: 400.ms)
                        .scale(duration: 400.ms, curve: Curves.easeOut);
                  }).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
