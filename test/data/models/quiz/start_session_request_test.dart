import 'package:cribe/data/models/quiz/start_session_request.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StartSessionRequest', () {
    test('should create StartSessionRequest from constructor', () {
      final request = StartSessionRequest(episodeId: 42);

      expect(request.episodeId, 42);
    });

    test('should convert StartSessionRequest to JSON', () {
      final request = StartSessionRequest(episodeId: 42);

      final json = request.toJson();

      expect(json['episode_id'], 42);
      expect(json.length, 1);
    });
  });
}
