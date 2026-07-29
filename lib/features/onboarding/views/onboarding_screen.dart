import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:memory_notes/app_router.dart';
import 'package:memory_notes/core/constants/hive_keys.dart';
import 'package:memory_notes/shared/effects/animated_gradient_text.dart';
import 'package:memory_notes/shared/effects/aurora_background.dart';

/// First-run intro: 3 animated pages with a PageView, dot indicator
/// and a Next / "Let's go" button. Shown once (flag in Hive).
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const List<_IntroPage> _pages = [
    _IntroPage(
      icon: Icons.edit_note_rounded,
      color: Color(0xFF7C4DFF),
      title: "Your brain's external drive",
      subtitle:
          'Capture thoughts, photos, voice notes and checklists — '
          'before they escape.',
    ),
    _IntroPage(
      icon: Icons.palette_rounded,
      color: Color(0xFF00E5FF),
      title: 'Make every note yours',
      subtitle:
          'Colors, checklists, audio and images. '
          'Boring notes are illegal here.',
    ),
    _IntroPage(
      icon: Icons.wifi_off_rounded,
      color: Color(0xFFFF5CA8),
      title: 'Works offline. Seriously.',
      subtitle:
          'No internet? No drama. Your notes live on your device '
          'and never leave without you.',
    ),
  ];

  final PageController _pageController = PageController();
  int _page = 0;

  bool get _isLastPage => _page == _pages.length - 1;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _next() {
    if (_isLastPage) {
      _finish();
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    }
  }

  Future<void> _finish() async {
    await Hive.box<dynamic>(
      HiveKeys.settingsBox,
    ).put(HiveKeys.seenOnboarding, true);
    if (mounted) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.notesList);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuroraBackground(
        child: SafeArea(
          child: Column(
            children: [
              // ── Skip ───────────────────────────────────────────────
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _finish,
                  child: const Text('Skip'),
                ),
              ),

              // ── Pages ──────────────────────────────────────────────
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pages.length,
                  onPageChanged: (i) => setState(() => _page = i),
                  itemBuilder:
                      (context, i) => _IntroPageView(
                        page: _pages[i],
                        // Rebuild key → replays the entrance animation
                        // each time this page becomes current.
                        active: i == _page,
                      ),
                ),
              ),

              // ── Dots + button ──────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                child: Row(
                  children: [
                    Row(
                      children: List.generate(
                        _pages.length,
                        (i) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOutCubic,
                          margin: const EdgeInsets.only(right: 6),
                          width: i == _page ? 26 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color:
                                i == _page
                                    ? _pages[_page].color
                                    : Colors.white.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    FilledButton(
                      onPressed: _next,
                      style: FilledButton.styleFrom(
                        backgroundColor: _pages[_page].color,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: Text(
                          _isLastPage ? "Let's go" : 'Next',
                          key: ValueKey(_isLastPage),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IntroPage {
  const _IntroPage({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
}

/// One intro page: big glowing icon, gradient headline, subtitle.
/// The icon pops in with an elastic scale every time [active] flips
/// back to true.
class _IntroPageView extends StatelessWidget {
  const _IntroPageView({required this.page, required this.active});

  final _IntroPage page;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Glowing icon that pops in.
          TweenAnimationBuilder<double>(
            key: ValueKey('${page.title}-$active'),
            tween: Tween(begin: 0, end: active ? 1 : 0),
            duration: const Duration(milliseconds: 700),
            curve: Curves.elasticOut,
            builder:
                (context, value, child) =>
                    Transform.scale(scale: value, child: child),
            child: Container(
              padding: const EdgeInsets.all(36),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: page.color.withValues(alpha: 0.12),
                border: Border.all(
                  color: page.color.withValues(alpha: 0.5),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: page.color.withValues(alpha: 0.4),
                    blurRadius: 60,
                    spreadRadius: 6,
                  ),
                ],
              ),
              child: Icon(page.icon, size: 84, color: page.color),
            ),
          ),
          const SizedBox(height: 48),

          // Gradient headline.
          AnimatedGradientText(
            page.title,
            style: theme.displaySmall ?? const TextStyle(fontSize: 34),
            colors: [page.color, Colors.white, page.color],
          ),
          const SizedBox(height: 16),

          Text(
            page.subtitle,
            textAlign: TextAlign.center,
            style: theme.bodyLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
