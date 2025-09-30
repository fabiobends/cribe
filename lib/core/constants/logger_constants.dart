enum LogLevel {
  debug(0),
  info(1),
  warn(2),
  error(3);

  const LogLevel(this.severity);
  final int severity;
}

enum LogFilter {
  all,
  debug,
  info,
  warn,
  error,
  none,
}

enum EntityType {
  viewModel,
  screen,
  service,
  repository,
  model,
  provider,
  unknown,
}
