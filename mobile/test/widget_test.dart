import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

import 'package:quran_downloader/main.dart';
import 'package:quran_downloader/core/constants/hive_keys.dart';
import 'package:quran_downloader/features/home/cubit/app_settings_cubit.dart';

void main() {
  late Directory tempDir;
  late Box settingsBox;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('quran_downloader_test_');
    Hive.init(tempDir.path);
    settingsBox = await Hive.openBox(HiveKeys.settingsBox);
  });

  tearDownAll(() async {
    await settingsBox.close();
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  testWidgets('app root builds successfully', (WidgetTester tester) async {
    await tester.pumpWidget(
      BlocProvider(
        create: (_) => AppSettingsCubit(settingsBox),
        child: const QuranInstallerApp(),
      ),
    );

    expect(find.byType(QuranInstallerApp), findsOneWidget);
  });
}
