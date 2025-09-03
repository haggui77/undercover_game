import 'package:undercover_game/models/enums.dart';

class GameResult {
  final String playerName;
  final Role role;
  final bool won;
  final bool eliminated;
  final int roundsPlayed;
  final DateTime gameDate;

  GameResult({
    required this.playerName,
    required this.role,
    required this.won,
    required this.eliminated,
    required this.roundsPlayed,
    required this.gameDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'playerName': playerName,
      'role': role.name,
      'won': won,
      'eliminated': eliminated,
      'roundsPlayed': roundsPlayed,
      'gameDate': gameDate.toIso8601String(),
    };
  }

  factory GameResult.fromJson(Map<String, dynamic> json) {
    return GameResult(
      playerName: json['playerName'],
      role: Role.values.firstWhere((e) => e.name == json['role']),
      won: json['won'],
      eliminated: json['eliminated'],
      roundsPlayed: json['roundsPlayed'],
      gameDate: DateTime.parse(json['gameDate']),
    );
  }
}

class PlayerStats {
  final String name;
  int gamesPlayed = 0;
  int gamesWon = 0;
  int timesEliminated = 0;
  int totalRoundsPlayed = 0;
  Map<Role, int> roleCount = {Role.civilian: 0, Role.spy: 0, Role.mrWhite: 0};
  Map<Role, int> roleWins = {Role.civilian: 0, Role.spy: 0, Role.mrWhite: 0};

  PlayerStats(this.name);

  double get winRate => gamesPlayed > 0 ? (gamesWon / gamesPlayed) * 100 : 0;
  double get survivalRate => gamesPlayed > 0
      ? ((gamesPlayed - timesEliminated) / gamesPlayed) * 100
      : 0;
  double get averageRoundsPerGame =>
      gamesPlayed > 0 ? totalRoundsPlayed / gamesPlayed : 0;

  void addGameResult(GameResult result) {
    gamesPlayed++;
    if (result.won) gamesWon++;
    if (result.eliminated) timesEliminated++;
    totalRoundsPlayed += result.roundsPlayed;
    roleCount[result.role] = (roleCount[result.role] ?? 0) + 1;
    if (result.won) {
      roleWins[result.role] = (roleWins[result.role] ?? 0) + 1;
    }
  }

  int get totalPoints {
    // Scoring system:
    // Win = 100 points
    // Survival = 25 points
    // Bonus for role-specific performance
    int points = gamesWon * 100;
    points += (gamesPlayed - timesEliminated) * 25;

    // Bonus points for spy/mrWhite wins (harder roles)
    points += (roleWins[Role.spy] ?? 0) * 50;
    points += (roleWins[Role.mrWhite] ?? 0) * 75;

    return points;
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'gamesPlayed': gamesPlayed,
      'gamesWon': gamesWon,
      'timesEliminated': timesEliminated,
      'totalRoundsPlayed': totalRoundsPlayed,
      'roleCount': roleCount.map((key, value) => MapEntry(key.name, value)),
      'roleWins': roleWins.map((key, value) => MapEntry(key.name, value)),
    };
  }

  factory PlayerStats.fromJson(Map<String, dynamic> json) {
    final stats = PlayerStats(json['name']);
    stats.gamesPlayed = json['gamesPlayed'];
    stats.gamesWon = json['gamesWon'];
    stats.timesEliminated = json['timesEliminated'];
    stats.totalRoundsPlayed = json['totalRoundsPlayed'];

    final roleCountMap = Map<String, int>.from(json['roleCount']);
    stats.roleCount = roleCountMap.map(
      (key, value) =>
          MapEntry(Role.values.firstWhere((e) => e.name == key), value),
    );

    final roleWinsMap = Map<String, int>.from(json['roleWins']);
    stats.roleWins = roleWinsMap.map(
      (key, value) =>
          MapEntry(Role.values.firstWhere((e) => e.name == key), value),
    );

    return stats;
  }
}
