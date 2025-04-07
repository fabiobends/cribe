import 'package:flutter_test/flutter_test.dart';
import 'package:cribe/domain/models/counter_model.dart';

void main() {
  group('CounterModel', () {
    test('should create a counter with initial value', () {
      const counter = CounterModel(value: 5);
      expect(counter.value, 5);
    });

    test('should increment counter value', () {
      const counter = CounterModel(value: 5);
      final incremented = counter.increment();
      expect(incremented.value, 6);
    });

    test('should decrement counter value', () {
      const counter = CounterModel(value: 5);
      final decremented = counter.decrement();
      expect(decremented.value, 4);
    });

    test('should create a copy with updated value', () {
      const counter = CounterModel(value: 5);
      final copy = counter.copyWith(value: 10);
      expect(copy.value, 10);
    });

    test('should maintain original value when creating a copy', () {
      const counter = CounterModel(value: 5);
      counter.copyWith(value: 10);
      expect(counter.value, 5);
    });

    test('should be equal when values are the same', () {
      const counter1 = CounterModel(value: 5);
      const counter2 = CounterModel(value: 5);
      expect(counter1, counter2);
    });

    test('should not be equal when values are different', () {
      const counter1 = CounterModel(value: 5);
      const counter2 = CounterModel(value: 6);
      expect(counter1, isNot(counter2));
    });
  });
}
