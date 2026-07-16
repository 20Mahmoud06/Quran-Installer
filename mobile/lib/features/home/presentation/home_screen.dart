import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/dimensions.dart';
import '../../../core/localization/app_localization.dart';
import '../../reciters/cubit/reciters_cubit.dart';
import '../../surahs/cubit/surahs_cubit.dart';
import '../../downloader/cubit/downloader_cubit.dart';
import '../widgets/premium_confirm_dialog.dart';
import '../widgets/home_header.dart';
import '../widgets/reciter_section.dart';
import '../widgets/mode_toggle.dart';
import '../widgets/download_complete_dialog.dart';
import '../widgets/error_dialog.dart';
import '../widgets/home_page_content.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onNavigateToQueue;

  const HomeScreen({super.key, this.onNavigateToQueue});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  Reciter? _selectedReciter;
  bool _isFullQuran = true;
  bool _downloadsRunning = false;

  late final PageController _pageControllerquran;
  late AnimationController _staggerController;
  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;
  late Animation<double> _reciterFade;
  late Animation<Offset> _reciterSlide;
  late Animation<double> _contentFade;
  late Animation<Offset> _contentSlide;

  @override
  void initState() {
    super.initState();

    _pageControllerquran = PageController(initialPage: 0);

    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _headerFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _staggerController,
        curve: const Interval(0, 0.3, curve: Curves.easeOut),
      ),
    );
    _headerSlide = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _staggerController,
      curve: const Interval(0, 0.3, curve: Curves.easeOutCubic),
    ));

    _reciterFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _staggerController,
        curve: const Interval(0.15, 0.45, curve: Curves.easeOut),
      ),
    );
    _reciterSlide = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _staggerController,
      curve: const Interval(0.15, 0.45, curve: Curves.easeOutCubic),
    ));

    _contentFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _staggerController,
        curve: const Interval(0.3, 0.6, curve: Curves.easeOut),
      ),
    );
    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _staggerController,
      curve: const Interval(0.3, 0.6, curve: Curves.easeOutCubic),
    ));

    _staggerController.forward();

    if (context.read<RecitersCubit>().state is RecitersInitial) {
      context.read<RecitersCubit>().loadReciters();
    }
    if (context.read<SurahsCubit>().state is SurahsInitial) {
      context.read<SurahsCubit>().loadSurahs();
    }
  }

  @override
  void dispose() {
    _pageControllerquran.dispose();
    _staggerController.dispose();
    super.dispose();
  }

  void _onToggleTab(int index) {
    setState(() => _isFullQuran = index == 0);
    _pageControllerquran.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DownloaderCubit, DownloaderState>(
      listenWhen: (prev, curr) {
        if (!_downloadsRunning) return false;
        if (curr is! DownloaderReady) return false;
        return curr.queue.every((e) =>
            e.status == DownloadStatus.completed ||
            e.status == DownloadStatus.failed ||
            e.status == DownloadStatus.canceled);
      },
      listener: (context, state) {
        _downloadsRunning = false;
        final completed = (state as DownloaderReady).queue
            .where((e) => e.status == DownloadStatus.completed).length;
        showDialog(
          context: context,
          builder: (_) => DownloadCompleteDialog(completedCount: completed),
        );
      },
      child: GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: ListView(
            padding: EdgeInsets.fromLTRB(
              Dimensions.spaceMedium,
              Dimensions.spaceMedium,
              Dimensions.spaceMedium,
              60.h,
            ),
            children: [
              FadeTransition(
                opacity: _headerFade,
                child: SlideTransition(
                  position: _headerSlide,
                  child: const HomeHeader(),
                ),
              ),
              SizedBox(height: Dimensions.spaceMedium),
              FadeTransition(
                opacity: _reciterFade,
                child: SlideTransition(
                  position: _reciterSlide,
                  child: ReciterSection(
                    onReciterSelected: (reciter) {
                      setState(() => _selectedReciter = reciter);
                    },
                  ),
                ),
              ),
              SizedBox(height: Dimensions.spaceLarge),
              FadeTransition(
                opacity: _contentFade,
                child: SlideTransition(
                  position: _contentSlide,
                  child: ModeToggle(
                    isFullQuran: _isFullQuran,
                    onToggle: _onToggleTab,
                  ),
                ),
              ),
              SizedBox(height: Dimensions.spaceMedium),
              FadeTransition(
                opacity: _contentFade,
                child: SlideTransition(
                  position: _contentSlide,
                  child: HomePageContent(
                    isFullQuran: _isFullQuran,
                    pageController: _pageControllerquran,
                    onPageChanged: (index) => setState(() => _isFullQuran = index == 0),
                    onDownloadTap: _onDownloadTap,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }

  Future<void> _onDownloadTap() async {
    final context = this.context;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final loc = AppLocalizationsProvider.of(context);
    if (_selectedReciter == null) {
      _showError(loc.noReciter);
      return;
    }

    List<Surah> surahsToDownload = [];
    if (_isFullQuran) {
      final surahsState = context.read<SurahsCubit>().state;
      if (surahsState is SurahsLoaded) {
        surahsToDownload = surahsState.allSurahs;
      }
    } else {
      final surahsState = context.read<SurahsCubit>().state;
      if (surahsState is SurahsLoaded) {
        surahsToDownload = surahsState.selectedSurahs;
      }
    }

    if (surahsToDownload.isEmpty) {
      _showError(_isFullQuran ? loc.error : loc.noSurah);
      return;
    }

    final downloaderState = context.read<DownloaderCubit>().state;
    double freeSpaceMB = 0.0;
    if (downloaderState is DownloaderReady) {
      freeSpaceMB = downloaderState.freeSpaceMB;
    }

    final requiredSpaceMB = surahsToDownload.length * 2.0;

    if (freeSpaceMB > 0 && freeSpaceMB < requiredSpaceMB) {
      _showError(
          '${loc.insufficientStorage}\n${loc.storageMsg(requiredSpaceMB, freeSpaceMB)}');
      return;
    }

    final cubit = context.read<DownloaderCubit>();

    int existingCount = 0;
    for (var surah in surahsToDownload) {
      final taskId = '${_selectedReciter!.name}_${surah.number}';
      if (await cubit.isTaskCompleted(taskId)) {
        existingCount++;
      }
    }

    bool forceRedownload = false;
    if (existingCount > 0) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (_) => PremiumConfirmDialog(
          isDark: isDark,
          reciterName: _selectedReciter!.name,
          existingCount: existingCount,
          totalCount: surahsToDownload.length,
        ),
      );
      if (confirmed != true) return;
      forceRedownload = true;
    }

    unawaited(cubit.startDownload(
      reciter: _selectedReciter!,
      surahs: surahsToDownload,
      isFullQuran: _isFullQuran,
      forceRedownload: forceRedownload,
    ));

    setState(() => _downloadsRunning = true);

    widget.onNavigateToQueue?.call();
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (_) => ErrorDialog(message: message),
    );
  }
}
