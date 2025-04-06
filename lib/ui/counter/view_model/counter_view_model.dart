import '../../core/base/base_view_model.dart';
import '../../../data/repositories/counter_repository.dart';

class CounterViewModel extends BaseViewModel {
  final CounterRepository _repository;
  int _count = 0;

  CounterViewModel(this._repository);

  int get count => _count;

  Future<void> increment() async {
    setLoading(true);
    try {
      await _repository.increment();
      _count = _repository.count;
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
      _count = _repository.count;
      notifyListeners();
    } catch (e) {
      setError(e.toString());
    } finally {
      setLoading(false);
    }
  }
}
