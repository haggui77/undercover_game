import 'dart:convert';
import 'package:undercover_game/models/score.dart';
import 'package:undercover_game/models/players.dart';
import 'package:undercover_game/models/enums.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScoreManager {
  static const String _gameHistoryKey = 'game_history';
  static const String _playerStatsKey = 'player_stats';

  static ScoreManager? _instance;
  static ScoreManager get instance {
    _instance ??= ScoreManager._internal();
    return _instance!;
  }

  ScoreManager._internal();

  Future<void> saveGameResults(
    List<Player> players,
    String winner,
    int roundsPlayed,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    // Determine who won based on winner string
    bool civiliansWon = winner.contains('Civilians');
    bool undercoversWon = winner.contains('Undercovers');

    List<GameResult> gameResults = [];
    for (Player player in players) {
      bool playerWon = false;

      if (civiliansWon && player.role == Role.civilian) {
        playerWon = true;
      } else if (undercoversWon &&
          (player.role == Role.spy || player.role == Role.mrWhite)) {
        playerWon = true;
      }

      gameResults.add(
        GameResult(
          playerName: player.name,
          role: player.role,
          won: playerWon,
          eliminated: player.eliminated,
          roundsPlayed: roundsPlayed,
          gameDate: DateTime.now(),
        ),
      );
    }

    // Save game history
    List<String> history = prefs.getStringList(_gameHistoryKey) ?? [];
    for (GameResult result in gameResults) {
      history.add(jsonEncode(result.toJson()));
    }
    await prefs.setStringList(_gameHistoryKey, history);

    // Update player stats
    await _updatePlayerStats(gameResults);
  }

  Future<void> _updatePlayerStats(List<GameResult> gameResults) async {
    final prefs = await SharedPreferences.getInstance();
    Map<String, PlayerStats> allStats = await getAllPlayerStats();

    for (GameResult result in gameResults) {
      if (!allStats.containsKey(result.playerName)) {
        allStats[result.playerName] = PlayerStats(result.playerName);
      }
      allStats[result.playerName]!.addGameResult(result);
    }

    // Save updated stats
    Map<String, String> statsJson = {};
    allStats.forEach((name, stats) {
      statsJson[name] = jsonEncode(stats.toJson());
    });

    await prefs.setString(_playerStatsKey, jsonEncode(statsJson));
  }

  Future<Map<String, PlayerStats>> getAllPlayerStats() async {
    final prefs = await SharedPreferences.getInstance();
    String? statsString = prefs.getString(_playerStatsKey);

    if (statsString == null) return {};

    Map<String, dynamic> statsJson = jsonDecode(statsString);
    Map<String, PlayerStats> playerStats = {};

    statsJson.forEach((name, statString) {
      playerStats[name] = PlayerStats.fromJson(jsonDecode(statString));
    });

    return playerStats;
  }

  Future<List<GameResult>> getGameHistory() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList(_gameHistoryKey) ?? [];

    return history
        .map((gameString) => GameResult.fromJson(jsonDecode(gameString)))
        .toList();
  }

  Future<List<PlayerStats>> getLeaderboard() async {
    Map<String, PlayerStats> allStats = await getAllPlayerStats();
    List<PlayerStats> leaderboard = allStats.values.toList();

    // Sort by total points descending
    leaderboard.sort((a, b) => b.totalPoints.compareTo(a.totalPoints));

    return leaderboard;
  }

  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_gameHistoryKey);
    await prefs.remove(_playerStatsKey);
  }

  Future<PlayerStats?> getPlayerStats(String playerName) async {
    Map<String, PlayerStats> allStats = await getAllPlayerStats();
    return allStats[playerName];
  }
}
