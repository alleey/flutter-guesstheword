import 'dart:developer';

import 'package:audioplayers/audioplayers.dart';

class AudioService {

  final _player = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  bool _muted = false;

  void mute(bool value) {
    _muted = !value;
    log("Audio sounds muted = $_muted");
  }

  Future<AudioPlayer> play(String fileName) async {
    await _player.release();
    if (!_muted) {
      await _player.play(AssetSource(fileName));
    }
    return _player;
  }

  Future<void> dispose() async {
    _player.dispose();
  }
}
