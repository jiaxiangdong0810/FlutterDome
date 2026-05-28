// 环境配置模型，支持 Dart --dart-define 和 Android Flavor 两种方式
enum LogLevel { verbose, debug, info, warning, error }

class AppConfig {
  final String envName;
  final String apiBaseUrl;
  final bool enableDebugMenu;
  final LogLevel logLevel;

  const AppConfig({
    required this.envName,
    required this.apiBaseUrl,
    required this.enableDebugMenu,
    required this.logLevel,
  });

  static const AppConfig dev = AppConfig(
    envName: 'dev',
    apiBaseUrl: 'https://api.dev.example.com',
    enableDebugMenu: true,
    logLevel: LogLevel.verbose,
  );

  static const AppConfig staging = AppConfig(
    envName: 'staging',
    apiBaseUrl: 'https://api.staging.example.com',
    enableDebugMenu: true,
    logLevel: LogLevel.debug,
  );

  static const AppConfig prod = AppConfig(
    envName: 'prod',
    apiBaseUrl: 'https://api.example.com',
    enableDebugMenu: false,
    logLevel: LogLevel.error,
  );

  /// 自动检测当前环境：优先使用 Android Flavor 的 FLUTTER_FLAVOR，
  /// 回退到 --dart-define 传入的 ENV，默认 dev
  static AppConfig get current {
    const flavor = String.fromEnvironment('FLUTTER_FLAVOR');
    const dartEnv = String.fromEnvironment('ENV', defaultValue: 'dev');
    final env = flavor.isNotEmpty ? flavor : dartEnv;
    return switch (env) {
      'dev' => dev,
      'staging' => staging,
      'prod' => prod,
      _ => dev,
    };
  }
}
