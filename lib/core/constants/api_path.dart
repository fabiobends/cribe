class ApiPath {
  // Authentication endpoints
  static const String login = 'auth/login';
  static const String register = 'auth/register';
  static const String refreshToken = 'auth/refresh';

  // Podcast endpoints
  static const String podcasts = 'podcasts';

  static String podcastById(int id) => 'podcasts/$id';

  // transcript endpoints
  static String transcriptsStreamSse(int episodeId) =>
      'transcripts/stream/sse?episode_id=$episodeId';

  // Quiz endpoints
  static const String quizzes = 'quizzes';

  static String quizById(int sessionId) => 'quizzes/$sessionId';

  static String quizAnswersById(int sessionId) => 'quizzes/$sessionId/answers';

  static String quizStatusById(int sessionId) => 'quizzes/$sessionId/status';
}
