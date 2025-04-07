import '../../core/base/base_view_model.dart';
import '../../../data/repositories/counter_repository.dart';
import '../../../domain/models/counter_model.dart';

class CounterViewModel extends BaseViewModel {
  final CounterRepository _repository;
  CounterModel _counter = const CounterModel(value: 0);

  CounterViewModel(this._repository);

  CounterModel get counter => _counter;
  int get count => _counter.value;

  Future<void> increment() async {
    setLoading(true);
    try {
      await _repository.increment();
      _counter = _repository.counter;
      notifyListeners();
    } catch (e) {
      setError(e.toString());
    } finally {
      setLoading(false);
    }
  }

  Future<void> decrement() async {
    setLoading(true);
    try {
      await _repository.decrement();
      _counter = _repository.counter;
      notifyListeners();
    } catch (e) {
      setError(e.toString());
    } finally {
      setLoading(false);
    }
  }
}
