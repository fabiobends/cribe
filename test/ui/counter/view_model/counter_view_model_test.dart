import 'package:flutter_test/flutter_test.dart';
import 'package:cribe/data/repositories/counter_repository.dart';
import 'package:cribe/domain/models/counter_model.dart';
import 'package:cribe/ui/counter/view_model/counter_view_model.dart';

// Create a mock repository class for testing
class MockCounterRepository extends CounterRepository {
  int _mockValue = 0;
  bool _shouldThrowError = false;
  String _errorMessage = 'Test error';

  @override
  CounterModel get counter => CounterModel(value: _mockValue);

  void setMockValue(int value) {
    _mockValue = value;
  }

  void setShouldThrowError(bool shouldThrow, {String? errorMessage}) {
    _shouldThrowError = shouldThrow;
    if (errorMessage != null) {
      _errorMessage = errorMessage;
    }
  }

  @override
  Future<void> increment() async {
    if (_shouldThrowError) {
      throw Exception(_errorMessage);
    }
    _mockValue++;
  }

  @override
  Future<void> decrement() async {
    if (_shouldThrowError) {
      throw Exception(_errorMessage);
    }
    _mockValue--;
  }
}

void main() {
  late CounterViewModel viewModel;
  late MockCounterRepository mockRepository;

  setUp(() {
    mockRepository = MockCounterRepository();
    viewModel = CounterViewModel(mockRepository);
  });

  group('CounterViewModel', () {
    test('should initialize with counter value of 0', () {
      expect(viewModel.count, 0);
    });

    test('should increment counter value', () async {
      // Setup
      mockRepository.setMockValue(0);

      // Act
      await viewModel.increment();

      // Assert
      expect(viewModel.count, 1);
    });

    test('should decrement counter value', () async {
      // Setup
      mockRepository.setMockValue(0);

      // Act
      await viewModel.decrement();

      // Assert
      expect(viewModel.count, -1);
    });

    test('should set loading state during increment', () async {
      // Setup
      mockRepository.setMockValue(1);

      // Act
      final future = viewModel.increment();

      // Assert loading state is true during operation
      expect(viewModel.isLoading, isTrue);

      // Wait for the operation to complete
      await future;

      // Assert loading state is false after operation
      expect(viewModel.isLoading, isFalse);
    });

    test('should set loading state during decrement', () async {
      // Setup
      mockRepository.setMockValue(-1);

      // Act
      final future = viewModel.decrement();

      // Assert loading state is true during operation
      expect(viewModel.isLoading, isTrue);

      // Wait for the operation to complete
      await future;

      // Assert loading state is false after operation
      expect(viewModel.isLoading, isFalse);
    });

    test('should handle errors during increment', () async {
      // Setup
      mockRepository.setShouldThrowError(true);

      // Act
      await viewModel.increment();

      // Assert
      expect(viewModel.error, isNotNull);
      expect(viewModel.error, contains('Test error'));
    });

    test('should handle errors during decrement', () async {
      // Setup
      mockRepository.setShouldThrowError(true);

      // Act
      await viewModel.decrement();

      // Assert
      expect(viewModel.error, isNotNull);
      expect(viewModel.error, contains('Test error'));
    });
  });
}
