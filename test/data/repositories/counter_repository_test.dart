import 'package:flutter_test/flutter_test.dart';
import 'package:cribe/data/repositories/counter_repository.dart';
import 'package:cribe/domain/models/counter_model.dart';

void main() {
  late CounterRepository repository;

  setUp(() {
    repository = CounterRepository();
  });

  group('CounterRepository', () {
    test('should initialize with counter value of 0', () {
      expect(repository.counter.value, 0);
    });

    test('should increment counter value', () async {
      await repository.increment();
      expect(repository.counter.value, 1);
    });

    test('should decrement counter value', () async {
      await repository.decrement();
      expect(repository.counter.value, -1);
    });

    test('should increment counter multiple times', () async {
      await repository.increment();
      await repository.increment();
      await repository.increment();
      expect(repository.counter.value, 3);
    });

    test('should decrement counter multiple times', () async {
      await repository.decrement();
      await repository.decrement();
      await repository.decrement();
      expect(repository.counter.value, -3);
    });

    test('should increment and decrement counter', () async {
      await repository.increment();
      await repository.increment();
      await repository.decrement();
      expect(repository.counter.value, 1);
    });

    test('should return a CounterModel instance', () {
      expect(repository.counter, isA<CounterModel>());
    });
  });
}
