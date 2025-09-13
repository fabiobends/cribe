import 'package:cribe/core/logger/logger_mixins.dart';

abstract class BaseService with ServiceLogger {
  Future<void> init();
  Future<void> dispose();
}
