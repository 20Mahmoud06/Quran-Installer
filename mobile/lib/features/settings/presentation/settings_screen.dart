import 'package:flutter/material.dart';
import '../../../core/theme/dimensions.dart';
import '../../../core/routing/routes.dart';
import '../../../core/localization/app_localization.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../home/cubit/app_settings_cubit.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizationsProvider.of(context);
    return GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
      appBar: AppBar(
        title: Text(loc.settings),
      ),
      body: BlocBuilder<AppSettingsCubit, AppSettingsState>(
        builder: (context, state) {
          final cubit = context.read<AppSettingsCubit>();

          return ListView(
            children: [
              _SectionHeader(title: loc.tr('General', 'عام')),
              SwitchListTile(
                title: Text(loc.darkMode),
                secondary: const Icon(Icons.dark_mode_outlined),
                value: state.themeMode == ThemeMode.dark,
                onChanged: (_) => cubit.toggleTheme(),
              ),
              ListTile(
                leading: const Icon(Icons.language),
                title: Text(loc.language),
                trailing: DropdownButton<String>(
                  value: state.language,
                  items: [
                    DropdownMenuItem(value: 'en', child: Text(loc.english)),
                    DropdownMenuItem(value: 'ar', child: Text(loc.arabic)),
                  ],
                  onChanged: (val) {
                    if (val != null) cubit.setLanguage(val);
                  },
                ),
              ),
              const Divider(),
              _SectionHeader(title: loc.tr('Downloads', 'التنزيلات')),
              SwitchListTile(
                title: Text(loc.wifiOnly),
                secondary: const Icon(Icons.wifi),
                value: state.wifiOnly,
                onChanged: (val) => cubit.toggleWifiOnly(val),
              ),
              SwitchListTile(
                title: Text(loc.autoRetry),
                secondary: const Icon(Icons.autorenew),
                value: state.autoRetry,
                onChanged: (val) => cubit.toggleAutoRetry(val),
              ),
              const Divider(),
              _SectionHeader(title: loc.tr('Notifications', 'الإشعارات')),
              SwitchListTile(
                title: Text(loc.notifications),
                secondary: const Icon(Icons.notifications_outlined),
                value: state.notificationsEnabled,
                onChanged: (val) => cubit.toggleNotifications(val),
              ),
              const Divider(),
              _SectionHeader(title: loc.tr('Data Management', 'إدارة البيانات')),
              ListTile(
                leading: const Icon(Icons.history),
                title: Text(loc.tr('Clear History', 'مسح السجل')),
                onTap: () async {
                  await cubit.clearHistory();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.tr('History cleared', 'تم مسح السجل'))));
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: Text(loc.tr('Clear Cache', 'مسح الذاكرة المؤقتة')),
                onTap: () async {
                  await cubit.clearCache();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.tr('Cache cleared', 'تم المسح'))));
                },
              ),
              ListTile(
                leading: const Icon(Icons.restore),
                title: Text(loc.tr('Reset Settings', 'إعادة تعيين الإعدادات'), style: const TextStyle(color: Colors.red)),
                onTap: () async {
                  await cubit.resetSettings();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.tr('Settings reset', 'تم إعادة التعيين'))));
                },
              ),
              const Divider(),
              _SectionHeader(title: loc.tr('Other', 'أخرى')),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: Text(loc.about),
                onTap: () => context.push(Routes.about),
              ),
            ],
          );
        },
      ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Dimensions.spaceMedium,
        vertical: Dimensions.spaceSmall,
      ),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
