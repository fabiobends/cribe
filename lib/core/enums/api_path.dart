enum ApiPath {
  login('auth/login'),
  register('auth/register'),
  refreshToken('auth/refresh-token');

  const ApiPath(this.path);

  final String path;
}
