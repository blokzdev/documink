/// Route paths for the app. Keep in one place so screens and tests share them.
class Routes {
  const Routes._();

  static const home = '/';
  static const unlock = '/unlock';
  static const scan = '/scan';
  static const paste = '/paste';
  static const import = '/import';
  static const newProject = '/projects/new';
  static const chat = '/chat';
  static const vault = '/vault';
  static const settings = '/settings';
  static const auditLog = '/settings/audit';

  /// Document detail, e.g. `/document/<id>`.
  static String document(String id) => '/document/$id';
  static const documentPattern = '/document/:id';
}
