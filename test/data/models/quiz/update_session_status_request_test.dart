import 'package:cribe/data/models/quiz/update_session_status_request.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UpdateSessionStatusRequest', () {
    test('should create UpdateSessionStatusRequest from constructor', () {
      final request = UpdateSessionStatusRequest(status: 'completed');

      expect(request.status, 'completed');
    });

    test('should convert UpdateSessionStatusRequest to JSON', () {
      final request = UpdateSessionStatusRequest(status: 'completed');

      final json = request.toJson();

      expect(json['status'], 'completed');
      expect(json.length, 1);
    });

    test('should handle different status values', () {
      final requestInProgress =
          UpdateSessionStatusRequest(status: 'in_progress');
      final requestCompleted = UpdateSessionStatusRequest(status: 'completed');

      expect(requestInProgress.status, 'in_progress');
      expect(requestCompleted.status, 'completed');
    });
  });
}
