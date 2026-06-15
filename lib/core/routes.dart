/// Route paths for the app. Keep in one place so screens and tests share them.
class Routes {
  const Routes._();

  static const home = '/';
  static const unlock = '/unlock';

  /// First-run "Meet Mink" Tier-4 onboarding step (Phase 11b).
  static const onboarding = '/onboarding/ai';
  static const scan = '/scan';
  static const paste = '/paste';
  static const import = '/import';
  static const newProject = '/projects/new';
  static const newProjectWizard = '/projects/new/wizard';
  static const projects = '/projects';

  /// Project detail, e.g. `/projects/<id>`.
  static String projectDetail(String id) => '/projects/$id';
  static const projectDetailPattern = '/projects/:id';

  static const chat = '/chat';
  static const vault = '/vault';
  static const settings = '/settings';
  static const aiSettings = '/settings/ai';
  static const auditLog = '/settings/audit';
  static const customEntities = '/settings/custom-entities';
  static const customEntityForm = '/settings/custom-entities/edit';

  /// Document detail, e.g. `/document/<id>`.
  static String document(String id) => '/document/$id';
  static const documentPattern = '/document/:id';
}
