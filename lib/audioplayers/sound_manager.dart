import 'package:audioplayers/audioplayers.dart';

class SoundManager {
  static final AudioPlayer _player = AudioPlayer();

  static Future<void> playVoteSound() async {
    await _player.play(AssetSource('sounds/vote.mp3'));
  }

  static Future<void> playCivilianEliminated() async {
    await _player.play(AssetSource('sounds/civilian_eliminated.mp3'));
  }

  static Future<void> playUndercoverEliminated() async {
    await _player.play(AssetSource('sounds/undercover_eliminated.mp3'));
  }

  static Future<void> playMrWhiteSuccess() async {
    await _player.play(AssetSource('sounds/mr_white_success.mp3'));
  }

  static Future<void> playMrWhiteFail() async {
    await _player.play(AssetSource('sounds/mr_white_fail.mp3'));
  }

  static Future<void> playGameOver() async {
    await _player.play(AssetSource('sounds/game_over.mp3'));
  }

  static Future<void> playButtonClick() async {
    await _player.play(AssetSource('sounds/button_click.mp3'));
  }

  static Future<void> playInterrogation() async {
    await _player.play(AssetSource('sounds/interrogation.mp3'));
  }

  static Future<void> dispose() async {
    await _player.dispose();
  }
}
