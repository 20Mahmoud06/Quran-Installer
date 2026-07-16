import 'package:flutter/material.dart';

class AppLocalization {
  final String languageCode;

  const AppLocalization(this.languageCode);

  bool get isArabic => languageCode == 'ar';
  TextDirection get textDirection => isArabic ? TextDirection.rtl : TextDirection.ltr;
  String tr(String en, String ar) => isArabic ? ar : en;

  String get appName => tr('Quran Installer', 'مثبّت القرآن');
  String get subtitle => tr('Download & manage your Quran audio', 'حمّل واستمع لسور القرآن بصوت قرّائك المفضلين');
  String get noInternet => tr('No Internet Connection', 'لا يوجد اتصال بالإنترنت');
  String get backOnline => tr('Back Online', 'تم استعادة الاتصال');
  String get downloadsPaused => tr('Downloads are paused', 'التحميل متوقف مؤقتاً');
  String get allRestored => tr('All services restored', 'تم استعادة جميع الخدمات');
  String get retry => tr('RETRY', 'إعادة المحاولة');

  String get chooseReciter => tr('Choose Reciter', 'اختر القارئ');
  String get searchReciter => tr("Search Reciter's name...", 'ابحث عن اسم القارئ...');
  String get fullQuran => tr('Full Quran', 'القرآن كاملاً');
  String get specificSurah => tr('Specific Surah', 'سورة محددة');

  String get selectSurahs => tr('Select Surahs', 'اختر السور');
  String get searchSurah => tr("Search Surah's name...", 'ابحث عن اسم السورة...');

  String get downloadLocation => tr('Download Location', 'مجلد التحميل');
  String get internalStorage => tr('Internal Storage', 'التخزين الداخلي');
  String get spaceRequired => tr('Space Required', 'المساحة المطلوبة');
  String get change => tr('Change', 'تغيير');
  String get system => tr('System', 'النظام');
  String get free => tr('Free', 'متاح');

  String get downloadQuran => tr('Download Quran', 'تحميل القرآن');
  String get downloadSurah => tr('Download Surah', 'تحميل السورة');
  String get downloading => tr('Downloading...', 'جارٍ التحميل...');

  String get activeDownload => tr('ACTIVE DOWNLOAD', 'جارٍ التحميل');
  String upNext(int count) => tr('UP NEXT ($count)', 'التالي ($count)');
  String get issues => tr('ISSUES', 'مشاكل');
  String get completed => tr('COMPLETED', 'مكتمل');
  String get progress => tr('Progress', 'التقدم');
  String get speed => tr('Speed', 'السرعة');
  String get remaining => tr('Remaining', 'المتبقي');
  String get paused => tr('PAUSED', 'متوقف');
  String get downloadingStatus => tr('DOWNLOADING', 'جارٍ التحميل');
  String get errorDownloading => tr('Error downloading', 'خطأ في التحميل');
  String get pending => tr('Pending', 'قيد الانتظار');
  String get noDownloads => tr('No downloads in queue', 'لا يوجد تحميلات في قائمة الانتظار');
  String get waitingForInternet => tr('Waiting for internet connection...', 'بانتظار الاتصال بالإنترنت...');
  String get resumeAuto => tr('Downloads will resume automatically when online.', 'سيتم استئناف التحميل تلقائياً عند الاتصال.');
  String get noReciter => tr('Please select a reciter', 'الرجاء اختيار قارئ');
  String get noSurah => tr('Please select at least one surah', 'الرجاء اختيار سورة على الأقل');

  String get insufficientStorage => tr('Insufficient Storage', 'مساحة تخزين غير كافية');
  String storageMsg(dynamic need, dynamic have) => tr(
    'You need at least $need GB. Available: $have GB.',
    'تحتاج إلى $need جيجابايت على الأقل. المتاح: $have جيجابايت.',
  );
  String get error => tr('Error', 'خطأ');
  String get ok => tr('OK', 'حسناً');
  String get cancel => tr('Cancel', 'إلغاء');
  String get done => tr('Done', 'تم');
  String get minimize => tr('Minimize', 'تصغير');

  String get alreadyDownloaded => tr('Already Downloaded!', 'تم التحميل مسبقاً!');
  String alreadyExists( existing,  total,  reciter) => tr(
    '$existing of $total files already exist for $reciter',
    '$existing من $total ملف موجودة مسبقاً للقارئ $reciter',
  );
  String get downloadAgain => tr('Download Again', 'تحميل مرة أخرى');

  String get downloadComplete => tr('Download Complete!', 'اكتمل التحميل!');
  String downloadSuccess(int count) =>
      tr('$count surahs downloaded successfully', 'تم تنزيل $count سورة بنجاح');
  String get downloadLocationText => tr('Location', 'الموقع');
  String get downloadPathDisplay => tr('Download/Quran_Downloads/', 'التنزيلات/Quran_Downloads/');

  String get home => tr('Home', 'الرئيسية');
  String get queue => tr('Queue', 'قائمة الانتظار');

  String get settings => tr('Settings', 'الإعدادات');
  String get about => tr('About', 'حول');
  String get sourceCode => tr('Source Code', 'الكود المصدري');
  String get reportIssue => tr('Report Issue', 'الإبلاغ عن مشكلة');
  String get license => tr('License', 'الرخصة');
  String get developer => tr('Developer', 'المطور');

  String get darkMode => tr('Dark Mode', 'الوضع المظلم');
  String get wifiOnly => tr('WiFi Only', 'واي فاي فقط');
  String get notifications => tr('Notifications', 'الإشعارات');
  String get autoRetry => tr('Auto Retry', 'إعادة المحاولة تلقائياً');
  String get language => tr('Language', 'اللغة');
  String get english => tr('English', 'الإنجليزية');
  String get arabic => tr('Arabic', 'العربية');
  String get defaultFolder => tr('Default Download Folder', 'مجلد التحميل الافتراضي');
  String get changeFolder => tr('Change download folder', 'تغيير مجلد التحميل');
  String get cancelAll => tr('Cancel All', 'إلغاء الكل');
  String get pauseAll => tr('Pause All', 'إيقاف الكل');
  String get resumeAll => tr('Resume All', 'استئناف الكل');
  String get clearAll => tr('Clear History', 'مسح السجل');
  String surahRemoved(String name) => tr('$name removed from list', 'تم إزالة $name من القائمة');
  String get allRemoved => tr('All surahs removed', 'تم إزالة جميع السور');
}

class AppLocalizationsProvider extends InheritedWidget {
  final AppLocalization localization;

  const AppLocalizationsProvider({
    super.key,
    required this.localization,
    required super.child,
  });

  static AppLocalization of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<AppLocalizationsProvider>();
    assert(provider != null, 'No AppLocalizationsProvider found in context');
    return provider!.localization;
  }

  @override
  bool updateShouldNotify(AppLocalizationsProvider oldWidget) {
    return localization.languageCode != oldWidget.localization.languageCode;
  }
}
