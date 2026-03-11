import 'package:flutter/material.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:get/get.dart';

class LanguageSelector extends StatelessWidget {
  final String label;
  final TranslateLanguage selectedLanguage;
  final Function(TranslateLanguage) onSelected;

  const LanguageSelector({
    super.key,
    required this.label,
    required this.selectedLanguage,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => _showLanguagePicker(context),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.08),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _getLanguageName(selectedLanguage),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 20,
                  color: Colors.white54,
                ),
              ],
            ),
          ],
        ),
      ),
    ).expanded();
  }

  void _showLanguagePicker(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.only(top: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Select $label Language",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: TranslateLanguage.values.length,
                itemBuilder: (context, index) {
                  final lang = TranslateLanguage.values[index];
                  final isSelected = lang == selectedLanguage;

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                    title: Text(
                      _getLanguageName(lang),
                      style: TextStyle(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Colors.white70,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(Icons.check_circle_rounded,
                            color: Theme.of(context).colorScheme.primary)
                        : null,
                    onTap: () {
                      onSelected(lang);
                      Get.back();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  String _getLanguageName(TranslateLanguage lang) {
    // Basic formatting: "english" -> "English"
    String name = lang.toString().split('.').last;
    return name[0].toUpperCase() + name.substring(1);
  }
}

extension ExplandedExtension on Widget {
  Widget expanded() => Expanded(child: this);
}
