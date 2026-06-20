import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../app/providers.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../domain/entities/audit_entry.dart';

/// Provider que lee los audit logs de la base de datos local
final auditLogsProvider = StreamProvider<List<AuditEntry>>((ref) {
  return ref.watch(repositoryProvider).watchAuditLogs();
});

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = S.of(context);
    final logsAsync = ref.watch(auditLogsProvider);

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppConstants.screenHorizontalPadding,
                16,
                AppConstants.screenHorizontalPadding,
                8,
              ),
              child: Text(
                l.historyTitle,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
          ),
          logsAsync.when(
            data: (logs) {
              if (logs.isEmpty) {
                return SliverToBoxAdapter(child: _EmptyHistory(l: l));
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _TimelineEntry(
                    entry: logs[index],
                    isFirst: index == 0,
                    isLast: index == logs.length - 1,
                  ),
                  childCount: logs.length,
                ),
              );
            },
            loading: () => const SliverToBoxAdapter(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => SliverToBoxAdapter(
              child: Center(
                child: Text(
                  e.toString(),
                  style: const TextStyle(color: AppColors.danger),
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}

class _TimelineEntry extends StatelessWidget {
  final AuditEntry entry;
  final bool isFirst;
  final bool isLast;

  const _TimelineEntry({
    required this.entry,
    required this.isFirst,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final l = S.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.screenHorizontalPadding,
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 32,
              child: Column(
                children: [
                  if (!isFirst)
                    Expanded(
                      child: Container(
                        width: 2,
                        color: AppColors.cardBorder,
                      ),
                    )
                  else
                    const Expanded(child: SizedBox()),
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _actionColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 2,
                        color: AppColors.cardBorder,
                      ),
                    )
                  else
                    const Expanded(child: SizedBox()),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(_actionIcon, size: 16, color: _actionColor),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            entry.entity,
                            style: const TextStyle(
                              fontFamily: AppConstants.fontPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Text(
                          _actionLabel(l),
                          style: TextStyle(
                            fontFamily: AppConstants.fontSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _actionColor,
                          ),
                        ),
                      ],
                    ),
                    if (entry.description != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        entry.description!,
                        style: const TextStyle(
                          fontFamily: AppConstants.fontSecondary,
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                    const SizedBox(height: 6),
                    Text(
                      _formatDate(entry.createdAt),
                      style: const TextStyle(
                        fontFamily: AppConstants.fontSecondary,
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _actionLabel(S l) {
    switch (entry.action) {
      case 'created':
        return l.created;
      case 'updated':
        return l.updated;
      case 'deleted':
        return l.deleted;
      default:
        return entry.action;
    }
  }

  Color get _actionColor {
    switch (entry.action) {
      case 'created':
        return AppColors.success;
      case 'updated':
        return AppColors.warning;
      case 'deleted':
        return AppColors.danger;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData get _actionIcon {
    switch (entry.action) {
      case 'created':
        return Icons.add_circle_outline_rounded;
      case 'updated':
        return Icons.edit_rounded;
      case 'deleted':
        return Icons.remove_circle_outline_rounded;
      default:
        return Icons.info_outline_rounded;
    }
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day/$month/$year · $hour:$minute';
  }
}

class _EmptyHistory extends StatelessWidget {
  final S l;
  const _EmptyHistory({required this.l});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.screenHorizontalPadding),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          children: [
            const Icon(Icons.history_rounded, size: 40, color: AppColors.textSecondary),
            const SizedBox(height: 12),
            Text(
              l.noHistoryYet,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: AppConstants.fontSecondary,
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
