import 'package:cribe/core/logger/logger_mixins.dart';
import 'package:cribe/data/repositories/base_repository.dart';
import 'package:flutter/foundation.dart';

abstract class BaseViewModel extends ChangeNotifier with ViewModelLogger {
  final BaseRepository? repo;
  BaseViewModel({this.repo});

  bool _isLoading = false;
  bool _isSuccess = false;
  String? _error;

  bool get isLoading => _isLoading;
  bool get isSuccess => _isSuccess;
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

  void setSuccess(bool value) {
    if (_isSuccess != value) {
      _isSuccess = value;
      notifyListeners();
    }
  }
}
