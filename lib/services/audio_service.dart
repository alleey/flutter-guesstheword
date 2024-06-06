import 'package:audioplayers/audioplayers.dart';

class AudioService {

  final _player = AudioPlayer()..setReleaseMode(ReleaseMode.stop);

  Future<AudioPlayer> play(String fileName) async {
    await _player.release();
    await _player.play(AssetSource(fileName));
    return _player;
  }

  Future<void> dispose() async {
    _player.dispose();
  }
}
