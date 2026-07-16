import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/dimensions.dart';
import 'storage_section.dart';
import 'surah_section.dart';
import 'download_button.dart';

class HomePageContent extends StatelessWidget {
  final bool isFullQuran;
  final PageController pageController;
  final ValueChanged<int> onPageChanged;
  final VoidCallback onDownloadTap;

  const HomePageContent({
    super.key,
    required this.isFullQuran,
    required this.pageController,
    required this.onPageChanged,
    required this.onDownloadTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: isFullQuran ? 600.h : 700.h,
      child: PageView(
        controller: pageController,
        onPageChanged: onPageChanged,
        physics: const ClampingScrollPhysics(),
        children: [
          _buildFullQuranView(),
          _buildSpecificSurahView(),
        ],
      ),
    );
  }

  Widget _buildFullQuranView() {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      children: [
        const StorageSection(),
        SizedBox(height: Dimensions.spaceSmall),
        DownloadButton(
          isFullQuran: true,
          onDownloadTap: onDownloadTap,
        ),
      ],
    );
  }

  Widget _buildSpecificSurahView() {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      children: [
        const SurahSection(),
        SizedBox(height: Dimensions.spaceSmall),
        const StorageSection(),
        SizedBox(height: Dimensions.spaceSmall),
        DownloadButton(
          isFullQuran: false,
          onDownloadTap: onDownloadTap,
        ),
      ],
    );
  }
}
