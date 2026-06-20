import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/providers.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/formatting/currency_formatter.dart';
import '../../../../domain/entities/special_event.dart';

class EventsScreen extends ConsumerWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = S.of(context);
    final eventsAsync = ref.watch(specialEventsProvider);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.screenHorizontalPadding),
                child: Text(
                  l.eventsTitle,
                  style: const TextStyle(
                    fontFamily: AppConstants.fontPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
            eventsAsync.when(
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => SliverFillRemaining(
                child: Center(child: Text(e.toString())),
              ),
              data: (events) {
                if (events.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Text(
                        l.noEventsYet,
                        style: const TextStyle(
                          fontFamily: AppConstants.fontSecondary,
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: AppConstants.screenHorizontalPadding),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final event = events[index];
                        return _EventRow(event: event);
                      },
                      childCount: events.length,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/events/add'),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: AppColors.textPrimary),
      ),
    );
  }
}

class _EventRow extends StatelessWidget {
  final SpecialEvent event;

  const _EventRow({required this.event});

  @override
  Widget build(BuildContext context) {
    final l = S.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.cardSpacing),
      padding: const EdgeInsets.all(AppConstants.cardInternalPadding),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(AppConstants.cardSecondaryBorderRadius),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Icon(_categoryIcon(event.category), color: AppColors.secondary, size: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.name,
                  style: const TextStyle(
                    fontFamily: AppConstants.fontPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${CurrencyFormatter.format(event.amount)} • ${event.month}',
                  style: const TextStyle(
                    fontFamily: AppConstants.fontSecondary,
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (event.flexible)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                l.flexible,
                style: const TextStyle(
                  fontFamily: AppConstants.fontSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.warning,
                ),
              ),
            ),
        ],
      ),
    );
  }

  IconData _categoryIcon(EventCategory category) {
    switch (category) {
      case EventCategory.birthday:
        return Icons.cake_outlined;
      case EventCategory.travel:
        return Icons.flight_outlined;
      case EventCategory.repair:
        return Icons.build_outlined;
      case EventCategory.gift:
        return Icons.card_giftcard_outlined;
      case EventCategory.medical:
        return Icons.local_hospital_outlined;
      case EventCategory.purchase:
        return Icons.shopping_bag_outlined;
      case EventCategory.other:
        return Icons.event_outlined;
    }
  }
}
