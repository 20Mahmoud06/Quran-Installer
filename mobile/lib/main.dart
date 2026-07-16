import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'core/constants/hive_keys.dart';
import 'features/home/cubit/app_settings_cubit.dart';
import 'core/di/injection.dart' as di;
import 'core/localization/app_localization.dart';
import 'features/reciters/cubit/reciters_cubit.dart';
import 'features/surahs/cubit/surahs_cubit.dart';
import 'features/downloader/cubit/downloader_cubit.dart';
import 'features/connectivity/cubit/connectivity_cubit.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'shared/widgets/premium_offline_banner.dart';
import 'package:flutter/services.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Hive.initFlutter();

  final settingsBox = await Hive.openBox(HiveKeys.settingsBox);

  await di.init();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AppSettingsCubit(settingsBox)),
        BlocProvider(create: (_) => di.sl<RecitersCubit>()..loadReciters()),
        BlocProvider(create: (_) => di.sl<SurahsCubit>()..loadSurahs()),
        BlocProvider(create: (_) => di.sl<DownloaderCubit>()),
        BlocProvider(create: (_) => di.sl<ConnectivityCubit>()),
      ],
      child: const QuranInstallerApp(),
    ),
  );
}

class QuranInstallerApp extends StatelessWidget {
  const QuranInstallerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return BlocBuilder<AppSettingsCubit, AppSettingsState>(
          builder: (context, appSettingsState) {
            final localization = AppLocalization(appSettingsState.language);
            return BlocListener<ConnectivityCubit, ConnectivityStatus>(
              listenWhen: (prev, curr) =>
                  (prev == ConnectivityStatus.connected && curr == ConnectivityStatus.disconnected) ||
                  (prev == ConnectivityStatus.disconnected && curr == ConnectivityStatus.connected),
              listener: (context, status) {
                final messenger = scaffoldMessengerKey.currentState;
                if (messenger == null) return;

                if (status == ConnectivityStatus.disconnected) {
                  messenger.showSnackBar(
                    SnackBar(content: Text(localization.tr('No internet connection. Downloads paused.', 'لا يوجد اتصال بالإنترنت. تم إيقاف التحميل.'))),
                  );
                  context.read<DownloaderCubit>().pauseAll();
                } else if (status == ConnectivityStatus.connected) {
                  messenger.showSnackBar(
                    SnackBar(content: Text(localization.tr('Internet restored. Downloads will resume.', 'تم استعادة الاتصال. سيتم استئناف التحميل.'))),
                  );
                  context.read<DownloaderCubit>().resumeAll();
                  context.read<DownloaderCubit>().retryFailedItems();
                }
              },
              child: AppLocalizationsProvider(
                localization: localization,
                child: Directionality(
                  textDirection: localization.textDirection,
                  child: MaterialApp.router(
                    scaffoldMessengerKey: scaffoldMessengerKey,
                    title: AppConstants.appName,
                    theme: AppTheme.lightTheme,
                    darkTheme: AppTheme.darkTheme,
                    themeMode: appSettingsState.themeMode,
                    routerConfig: AppRouter.router,
                    debugShowCheckedModeBanner: false,
                    builder: (context, child) {
                      return OfflineBuilder(
                        connectivityBuilder: (
                          BuildContext context,
                          List<ConnectivityResult> connectivity,
                          Widget widgetChild,
                        ) {
                          final bool connected = !connectivity.contains(ConnectivityResult.none);
                          return PremiumOfflineBanner(
                            connected: connected,
                            child: child ?? const SizedBox(),
                          );
                        },
                        child: child,
                      );
                    },
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
