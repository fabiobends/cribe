import 'base_repository.dart';

class CounterRepository extends BaseRepository {
  int _count = 0;

  int get count => _count;

  @override
  Future<void> initialize() async {
    // Initialize any resources if needed
  }

  @override
  Future<void> dispose() async {
    // Clean up any resources if needed
  }

  Future<void> increment() async {
    _count++;
  }

  Future<void> decrement() async {
    _count--;
  }
}
