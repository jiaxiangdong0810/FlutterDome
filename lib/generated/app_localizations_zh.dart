// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get pageTitle => '国际化演示';

  @override
  String currentLocale(String locale) {
    return '当前语言：$locale';
  }

  @override
  String greeting(String name) {
    return '你好，$name！';
  }

  @override
  String itemCount(int count) {
    return '你有 $count 条消息';
  }

  @override
  String get switchToEn => '切换到英文';

  @override
  String get switchToZh => '切换到中文';

  @override
  String get demoDescription =>
      '本页面演示 flutter gen-l10n 的使用。翻译内容定义在 .arb 文件中，运行 flutter gen-l10n 后生成 Dart 代码。';
}
