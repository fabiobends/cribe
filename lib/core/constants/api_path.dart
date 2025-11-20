class ApiPath {
  // Authentication endpoints
  static const String login = 'auth/login';
  static const String register = 'auth/register';
  static const String refreshToken = 'auth/refresh';

  // Podcast endpoints
  static const String podcasts = 'podcasts';

  static String podcastById(int id) => 'podcasts/$id';
}
