import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/dimensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/localization/app_localization.dart';
import '../../../shared/widgets/cards/custom_card.dart';
import '../../surahs/cubit/surahs_cubit.dart';

class SurahSection extends StatelessWidget {
  const SurahSection({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizationsProvider.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return CustomCard(
      glass: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.emeraldGreen, AppColors.forestGreen],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.menu_book_rounded, color: Colors.white, size: 16.sp),
              ),
              SizedBox(width: Dimensions.spaceMedium),
              Text(
                loc.selectSurahs,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: Dimensions.spaceMedium),
          _SurahSearchField(isDark: isDark, loc: loc),
          BlocBuilder<SurahsCubit, SurahsState>(
            builder: (context, state) {
              if (state is SurahsLoaded && state.selectedSurahs.isNotEmpty) {
                return Padding(
                  padding: EdgeInsets.only(top: Dimensions.spaceMedium),
                  child: Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: state.selectedSurahs
                        .map((surah) => Chip(
                              label: Text(surah.nameArabic),
                              onDeleted: () =>
                                  context.read<SurahsCubit>().toggleSurahSelection(surah),
                            ))
                        .toList(),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}

class _SurahSearchField extends StatefulWidget {
  final bool isDark;
  final AppLocalization loc;

  const _SurahSearchField({required this.isDark, required this.loc});

  @override
  State<_SurahSearchField> createState() => _SurahSearchFieldState();
}

class _SurahSearchFieldState extends State<_SurahSearchField> {
  TextEditingController? _searchController;
  FocusNode? _searchFocusNode;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.isDark ? AppColors.borderDark : AppColors.lightGreen.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
        border: widget.isDark ? null : Border.all(color: AppColors.borderLight, width: 1),
      ),
      child: Autocomplete<Surah>(
        displayStringForOption: (option) =>
            '${option.number}. ${option.nameArabic}',
        optionsBuilder: (textEditingValue) {
          context.read<SurahsCubit>().search(textEditingValue.text);
          return (context.read<SurahsCubit>().state as SurahsLoaded).filteredSurahs;
        },
        onSelected: (surah) {
          _searchFocusNode?.unfocus();
          context.read<SurahsCubit>().toggleSurahSelection(surah);
          context.read<SurahsCubit>().search('');
          _searchController?.clear();
        },
        fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
          _searchController = controller;
          _searchFocusNode = focusNode;
          return TextField(
            controller: controller,
            focusNode: focusNode,
            decoration: InputDecoration(
              hintText: widget.loc.searchSurah,
              hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: widget.isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
              prefixIcon: Icon(Icons.search,
                  color: widget.isDark ? AppColors.iconDark : AppColors.iconLight),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              fillColor: Colors.transparent,
              filled: true,
              contentPadding: EdgeInsets.symmetric(vertical: 14.h),
            ),
          );
        },
      ),
    );
  }
}
