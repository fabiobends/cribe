import 'base_repository.dart';
import '../../domain/models/counter_model.dart';

class CounterRepository extends BaseRepository {
  CounterModel _counter = const CounterModel(value: 0);

  CounterModel get counter => _counter;

  @override
  Future<void> initialize() async {
    // Initialize any resources if needed
  }

  @override
  Future<void> dispose() async {
    // Clean up any resources if needed
  }

  Future<void> increment() async {
    _counter = _counter.increment();
  }

  Future<void> decrement() async {
    _counter = _counter.decrement();
  }
}
