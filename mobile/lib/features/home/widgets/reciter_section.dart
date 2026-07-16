import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/dimensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/localization/app_localization.dart';
import '../../../shared/widgets/cards/custom_card.dart';
import '../../reciters/cubit/reciters_cubit.dart';

class ReciterSection extends StatelessWidget {
  final ValueChanged<Reciter> onReciterSelected;

  const ReciterSection({super.key, required this.onReciterSelected});

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
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.emeraldGreen, AppColors.forestGreen],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.mic_rounded, color: Colors.white, size: 16.sp),
              ),
              SizedBox(width: Dimensions.spaceMedium),
              Text(
                loc.chooseReciter,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: Dimensions.spaceMedium),
          BlocBuilder<RecitersCubit, RecitersState>(
            builder: (context, state) {
              if (state is RecitersLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is RecitersLoaded) {
                return Container(
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.borderDark : AppColors.lightGreen.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
                    border: isDark ? null : Border.all(color: AppColors.borderLight, width: 1),
                  ),
                  child: Autocomplete<Reciter>(
                    displayStringForOption: (option) => option.name,
                    optionsBuilder: (textEditingValue) {
                      context.read<RecitersCubit>().search(textEditingValue.text);
                      return (context.read<RecitersCubit>().state as RecitersLoaded).filteredReciters;
                    },
                    onSelected: (reciter) {
                      onReciterSelected(reciter);
                      context.read<RecitersCubit>().addRecent(reciter.name);
                    },
                    fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
                      return TextField(
                        controller: controller,
                        focusNode: focusNode,
                        decoration: InputDecoration(
                          hintText: loc.searchReciter,
                          hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                              ),
                          prefixIcon: Icon(Icons.search,
                              color: isDark ? AppColors.iconDark : AppColors.iconLight),
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
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}
