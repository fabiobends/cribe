import 'package:cribe/data/services/base_service.dart';
import 'package:just_audio/just_audio.dart';

class PlayerService extends BaseService {
  final AudioPlayer _audioPlayer;

  PlayerService({AudioPlayer? audioPlayer})
      : _audioPlayer = audioPlayer ?? AudioPlayer();

  AudioPlayer get audioPlayer => _audioPlayer;

  @override
  Future<void> init() async {
    logger.info('PlayerService initialized');
  }

  @override
  Future<void> dispose() async {
    logger.info('PlayerService disposing');
    await _audioPlayer.dispose();
  }

  Future<void> setAudioUrl(String url) async {
    try {
      logger.info('Setting audio URL: $url');
      await _audioPlayer.setUrl(url);
      logger.info('Audio URL set successfully');
    } catch (e) {
      logger.error('Failed to set audio URL', error: e);
      rethrow;
    }
  }

  Future<void> play() async {
    try {
      logger.info('Playing audio');
      await _audioPlayer.play();
    } catch (e) {
      logger.error('Failed to play audio', error: e);
      rethrow;
    }
  }

  Future<void> pause() async {
    try {
      logger.info('Pausing audio');
      await _audioPlayer.pause();
    } catch (e) {
      logger.error('Failed to pause audio', error: e);
      rethrow;
    }
  }

  Future<void> seek(Duration position) async {
    try {
      logger.info('Seeking to position: $position');
      await _audioPlayer.seek(position);
    } catch (e) {
      logger.error('Failed to seek audio', error: e);
      rethrow;
    }
  }

  Future<void> stop() async {
    try {
      logger.info('Stopping audio');
      await _audioPlayer.stop();
    } catch (e) {
      logger.error('Failed to stop audio', error: e);
      rethrow;
    }
  }

  Stream<Duration?> get positionStream => _audioPlayer.positionStream;
  Stream<Duration?> get durationStream => _audioPlayer.durationStream;
  Stream<PlayerState> get playerStateStream => _audioPlayer.playerStateStream;

  Duration? get duration => _audioPlayer.duration;
  Duration get position => _audioPlayer.position;
  bool get playing => _audioPlayer.playing;
}
