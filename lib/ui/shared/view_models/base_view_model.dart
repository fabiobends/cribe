import 'package:cribe/core/logger/logger_mixins.dart';
import 'package:flutter/foundation.dart';

abstract class BaseViewModel extends ChangeNotifier with ViewModelLogger {
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  void setLoading(bool value) {
    if (_isLoading != value) {
      _isLoading = value;
      notifyListeners();
    }
  }

  void setError(String? value) {
    if (_error != value) {
      _error = value;
      notifyListeners();
    }
  }
}
