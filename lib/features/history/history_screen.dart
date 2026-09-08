import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/persistence/local_storage.dart';

/// History & Saved Calculations Screen.
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  bool _filterSavedOnly = false;

  @override
  Widget build(BuildContext context) {
    final history = _filterSavedOnly
        ? LocalStorageService.instance.getSavedBookmarked()
        : LocalStorageService.instance.getHistory();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Jobsite History & Logs'),
        actions: [
          IconButton(
            icon: Icon(
              _filterSavedOnly ? Icons.bookmark : Icons.bookmark_border,
              color: _filterSavedOnly ? AppColors.brandGold : AppColors.textSecondary,
            ),
            tooltip: 'Filter Bookmarked',
            onPressed: () => setState(() => _filterSavedOnly = !_filterSavedOnly),
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined, color: AppColors.textSecondary),
            tooltip: 'Clear History',
            onPressed: () async {
              await LocalStorageService.instance.clearHistory();
              setState(() {});
            },
          ),
        ],
      ),
      body: SafeArea(
        child: history.isEmpty
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.history_toggle_off_outlined, size: 48, color: AppColors.textMuted),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      _filterSavedOnly ? 'No saved bookmarks yet.' : 'No recent calculations yet.',
                      style: AppTypography.inputText.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    const Text(
                      'Calculations you run will appear here automatically.',
                      style: AppTypography.helperText,
                    ),
                  ],
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.lg),
                itemCount: history.length,
                separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.md),
                itemBuilder: (context, index) {
                  final item = history[index];
                  return _buildHistoryCard(item);
                },
              ),
      ),
    );
  }

  Widget _buildHistoryCard(SavedCalculation item) {
    Color categoryColor;
    switch (item.category) {
      case 'materials':
        categoryColor = AppColors.categoryMaterials;
        break;
      case 'roofing':
        categoryColor = AppColors.categoryRoofing;
        break;
      case 'stairs':
        categoryColor = AppColors.categoryStairs;
        break;
      case 'measurements':
        categoryColor = AppColors.categoryMeasurements;
        break;
      default:
        categoryColor = AppColors.brandGold;
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: categoryColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.title,
                        style: AppTypography.cardTitle.copyWith(fontSize: 15),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      item.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                      size: 20,
                      color: item.isBookmarked ? AppColors.brandGold : AppColors.textSecondary,
                    ),
                    onPressed: () async {
                      await LocalStorageService.instance.toggleBookmark(item.id);
                      setState(() {});
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy_outlined, size: 18, color: AppColors.textSecondary),
                    onPressed: () {
                      final text = '${item.title}\nResult: ${item.primaryResult}\n${item.subtitle}';
                      Clipboard.setData(ClipboardData(text: text));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Copied calculation to clipboard!'), duration: Duration(seconds: 1)),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(item.primaryResult, style: AppTypography.heroResult.copyWith(fontSize: 24, color: categoryColor)),
          const SizedBox(height: 4),
          Text(item.subtitle, style: AppTypography.helperText),
          if (item.details.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: item.details.map((d) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.bgElevated,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(d, style: AppTypography.helperText.copyWith(fontSize: 11)),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
