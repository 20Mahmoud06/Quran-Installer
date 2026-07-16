import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import '../constants/hive_keys.dart';

import '../../features/reciters/domain/repositories/reciters_repository.dart';
import '../../features/reciters/data/repositories/reciters_repository_impl.dart';
import '../../features/reciters/cubit/reciters_cubit.dart';

import '../../features/surahs/domain/repositories/surahs_repository.dart';
import '../../features/surahs/data/repositories/surahs_repository_impl.dart';
import '../../features/surahs/cubit/surahs_cubit.dart';

import '../../features/downloader/domain/services/download_service.dart';
import '../../features/downloader/cubit/downloader_cubit.dart';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import '../../features/connectivity/cubit/connectivity_cubit.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // External
  final settingsBox = Hive.box(HiveKeys.settingsBox);
  sl.registerLazySingleton(() => settingsBox);
  
  sl.registerLazySingleton(() => Connectivity());
  sl.registerLazySingleton(() => InternetConnection());

  // Services
  sl.registerLazySingleton(() => DownloadService());

  // Repositories
  sl.registerLazySingleton<RecitersRepository>(
    () => RecitersRepositoryImpl(sl()),
  );
  
  sl.registerLazySingleton<SurahsRepository>(
    () => SurahsRepositoryImpl(),
  );

  // Blocs/Cubits
  sl.registerFactory(() => RecitersCubit(sl()));
  sl.registerFactory(() => SurahsCubit(sl()));
  sl.registerFactory(() => DownloaderCubit(downloadService: sl(), settingsBox: sl()));
  sl.registerFactory(() => ConnectivityCubit(connectivity: sl(), internetConnection: sl()));
}
