import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/dimensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/localization/app_localization.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizationsProvider.of(context);
    return GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
      appBar: AppBar(
        title: Text(loc.about),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(Dimensions.spaceMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: Dimensions.spaceLarge),
            Icon(
              Icons.menu_book_rounded,
              size: 100,
              color: AppColors.emeraldGreen,
            ),
            SizedBox(height: Dimensions.spaceMedium),
            Text(
              AppConstants.appName,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${loc.tr('Version', 'الإصدار')} ${AppConstants.appVersion}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: Dimensions.spaceLarge),
            Text(
              AppConstants.appDescription,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            SizedBox(height: Dimensions.spaceLarge),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: Text(loc.developer),
              subtitle: const Text(AppConstants.developer),
            ),
            ListTile(
              leading: const Icon(Icons.code),
              title: Text(loc.sourceCode),
              subtitle: const Text('GitHub'),
              trailing: const Icon(Icons.open_in_new, size: 16),
              onTap: () => launchUrl(Uri.parse(AppConstants.githubLink)),
            ),
            ListTile(
              leading: const Icon(Icons.bug_report_outlined),
              title: Text(loc.reportIssue),
              subtitle: const Text('GitHub Issues'),
              trailing: const Icon(Icons.open_in_new, size: 16),
              onTap: () => launchUrl(Uri.parse('${AppConstants.githubLink}/issues')),
            ),
            ListTile(
              leading: const Icon(Icons.description_outlined),
              title: Text(loc.license),
              subtitle: const Text('MIT License'),
              onTap: () {
                showLicensePage(
                  context: context,
                  applicationName: AppConstants.appName,
                  applicationVersion: AppConstants.appVersion,
                );
              },
            ),
          ],
        ),
        ),
      ),
    );
  }
}
