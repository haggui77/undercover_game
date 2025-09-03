import 'dart:math';
import 'package:undercover_game/models/enums.dart';

class Player {
  final String name;
  final Role role;
  bool eliminated;

  Player(this.name, this.role, {this.eliminated = false});
}

class TieBreaker {
  final List<Player> tiedPlayers;
  final List<Player> voters;
  InterrogationChallenge? currentChallenge;
  Map<Player, int> finalVotes = {};
  Player? selectedPlayer;
  int retryCount = 0;

  TieBreaker(this.tiedPlayers, this.voters);

  void selectRandomChallenge() {
    final random = Random();
    currentChallenge = InterrogationChallenge
        .values[random.nextInt(InterrogationChallenge.values.length)];
    retryCount++;
    finalVotes.clear();
  }

  String getChallengeDescription() {
    switch (currentChallenge!) {
      case InterrogationChallenge.secretPhrase:
        return "SECRET PHRASE: Convince others you know the secret word without saying it directly.";
      case InterrogationChallenge.finalPerformance:
        return "FINAL PERFORMANCE: Give a convincing speech about why you're loyal.";
    }
  }
}
