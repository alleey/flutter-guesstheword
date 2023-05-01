

import 'package:audioplayers/audioplayers.dart';

class AudioService {

  final player = AudioPlayer()..setReleaseMode(ReleaseMode.stop);

  Future<AudioPlayer> play(String fileName) async {
    await player.release();
    await player.play(AssetSource(fileName));
    return player;
  }

  Future<void> dispose() async {
    player.dispose();
  }
}
