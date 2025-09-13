import 'package:cribe/core/logger/logger_mixins.dart';

abstract class BaseRepository with RepositoryLogger {
  Future<void> init();
  Future<void> dispose();
}
