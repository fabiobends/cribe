import 'package:cribe/core/logger/logger_mixins.dart';
import 'package:cribe/data/services/api_service.dart';

abstract class BaseRepository with RepositoryLogger {
  BaseRepository({this.apiService});
  final ApiService? apiService;
  Future<void> init();
  Future<void> dispose();
}
