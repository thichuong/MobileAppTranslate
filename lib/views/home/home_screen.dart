import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:avatar_glow/avatar_glow.dart';
import '../../controllers/translate_controller.dart';
import '../vision/vision_detector_screen.dart';
import 'settings_screen.dart';
import 'widgets/language_selector.dart';

class HomeScreen extends GetView<TranslateController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Translate'),
        actions: [
          IconButton(
            onPressed: () => Get.to(() => const SettingsScreen()),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 1. Language Selector Row
            _buildLanguageSelectorRow(context),
            const SizedBox(height: 24),

            // 2. Input Card
            _buildInputCard(context),
            const SizedBox(height: 16),

            // 3. Quick Actions Row
            _buildActionsRow(context),
            const SizedBox(height: 24),

            // 4. Result Card
            _buildResultCard(context),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSelectorRow(BuildContext context) {
    return Obx(() => Row(
          children: [
            LanguageSelector(
              label: "From",
              selectedLanguage: controller.sourceLanguage.value,
              onSelected: (lang) => controller.sourceLanguage.value = lang,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: IconButton(
                onPressed: controller.swapLanguages,
                icon: Icon(Icons.swap_horiz_rounded,
                    color: Theme.of(context).colorScheme.primary),
                style: IconButton.styleFrom(
                  backgroundColor: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.1),
                ),
              ),
            ),
            LanguageSelector(
              label: "To",
              selectedLanguage: controller.targetLanguage.value,
              onSelected: (lang) => controller.targetLanguage.value = lang,
            ),
          ],
        ));
  }

  Widget _buildInputCard(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          TextField(
            controller: controller.textEditingController,
            maxLines: 5,
            minLines: 3,
            onChanged: (val) => controller.inputText.value = val,
            style: const TextStyle(fontSize: 18),
            decoration: const InputDecoration(
              hintText: "Enter text to translate...",
              fillColor: Colors.transparent,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: EdgeInsets.all(20),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 8, 8),
            child: Row(
              children: [
                Obx(() => Text(
                      "${controller.inputText.value.length} characters",
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: Colors.white38),
                    )),
                const Spacer(),
                Obx(() => controller.inputText.value.isNotEmpty
                    ? IconButton(
                        onPressed: controller.clearText,
                        icon: const Icon(Icons.clear_all_rounded, size: 20),
                      )
                    : const SizedBox.shrink()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Voice Action
        _buildActionButton(
          context,
          icon: Icons.mic_none_rounded,
          label: "Voice",
          onTap: controller.startVoiceTranslation,
          isGlowing: true,
        ),
        // Camera Action
        _buildActionButton(
          context,
          icon: Icons.camera_alt_outlined,
          label: "Scanner",
          onTap: () async {
            final granted = await controller.requestCameraPermission();
            if (granted) {
              Get.to(() => const VisionDetectorScreen());
            } else {
              Get.snackbar("Permission Denied",
                  "Camera access is required for vision features.");
            }
          },
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isGlowing = false,
  }) {
    final theme = Theme.of(context);

    return Column(
      children: [
        if (isGlowing)
          Obx(() => AvatarGlow(
                animate: controller
                    .isLoading.value, // Placeholder for recording state
                glowColor: theme.colorScheme.primary,
                duration: const Duration(milliseconds: 2000),
                repeat: true,
                child: IconButton.filledTonal(
                  onPressed: onTap,
                  icon: Icon(icon, size: 28),
                  padding: const EdgeInsets.all(16),
                ),
              ))
        else
          IconButton.filledTonal(
            onPressed: onTap,
            icon: Icon(icon, size: 28),
            padding: const EdgeInsets.all(16),
          ),
        const SizedBox(height: 8),
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildResultCard(BuildContext context) {
    final theme = Theme.of(context);

    return Obx(() {
      if (controller.translatedText.value.isEmpty &&
          !controller.isLoading.value) {
        return const SizedBox.shrink();
      }

      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary.withValues(alpha: 0.15),
              theme.colorScheme.secondary.withValues(alpha: 0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome_rounded,
                    size: 16, color: theme.colorScheme.secondary),
                const SizedBox(width: 8),
                Text(
                  "TRANSLATION",
                  style: theme.textTheme.labelSmall?.copyWith(
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.secondary,
                  ),
                ),
                const Spacer(),
                if (controller.isLoading.value)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              controller.translatedText.value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                _buildSmallActionBtn(Icons.copy_rounded, "Copy", () {
                  // Future: Clipboard
                  Get.snackbar("Copied", "Result copied to clipboard.");
                }),
                const SizedBox(width: 12),
                _buildSmallActionBtn(
                    Icons.volume_up_rounded, "Speak", controller.speakResult),
              ],
            ),
          ],
        ),
      ).animateIn();
    });
  }

  Widget _buildSmallActionBtn(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: Colors.white70),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}

extension AnimationExtension on Widget {
  Widget animateIn() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 400),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: this,
    );
  }
}
