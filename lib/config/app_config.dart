// 环境配置模型，通过 Android Flavor 自动注入环境参数
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

  static const AppConfig prod = AppConfig(
    envName: 'prod',
    apiBaseUrl: 'https://api.example.com',
    enableDebugMenu: false,
    logLevel: LogLevel.error,
  );

  /// 通过 FLUTTER_APP_FLAVOR 自动识别当前环境（Flutter 3.16+ 自动注入）
  static AppConfig get current {
    const flavor = String.fromEnvironment('FLUTTER_APP_FLAVOR');
    return switch (flavor) {
      'prod' => prod,
      'dev' => dev,
      _ => dev,
    };
  }
}
