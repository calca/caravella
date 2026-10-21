import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import '../../manager/group/pages/group_creation_wizard_page.dart';
import '../../settings/pages/settings_page.dart';

typedef RefreshCallback = Future<void> Function();

/// First start (or no group left): the whale on the app's gradient, edge to
/// edge, with a line on what the app does, a wide "Start" button opening the
/// creation wizard and a round settings button (language, theme, restoring a
/// backup) at the top.
class HomeWelcomeSection extends StatefulWidget {
  final RefreshCallback? onTripAdded;
  const HomeWelcomeSection({super.key, this.onTripAdded});

  @override
  State<HomeWelcomeSection> createState() => _HomeWelcomeSectionState();
}

class _HomeWelcomeSectionState extends State<HomeWelcomeSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _contentFadeAnimation;
  late Animation<double> _backgroundFadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    // Content enters first
    _contentFadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.55, curve: Curves.easeOutCubic),
    );

    // Background enters last with a soft fade-in
    _backgroundFadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.35, 1.0, curve: Curves.easeOutCubic),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const GroupCreationWizardPage(fromWelcome: true),
      ),
    );
    if (result is String && widget.onTripAdded != null) {
      await widget.onTripAdded!();
    }
  }

  void _openSettings() => Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (context) => const SettingsPage()));

  @override
  Widget build(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);
    final theme = Theme.of(context);
    final s = theme.colorScheme;
    final isDarkMode = theme.brightness == Brightness.dark;

    final backgroundGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [s.primaryFixedDim, isDarkMode ? s.onPrimaryFixed : s.primary],
    );
    final onBackground = isDarkMode ? s.onSurface : s.onPrimary;
    final buttonBackground = isDarkMode ? s.primary : s.onPrimary;
    final buttonForeground = isDarkMode ? s.onPrimary : s.primary;

    return AppSystemUI(
      // Edge to edge, light icons over the gradient.
      navigationBarColor: Colors.transparent,
      forceStatusBarLight: true,
      forceNavigationBarLight: true,
      child: Stack(
        children: [
          Positioned.fill(
            child: FadeTransition(
              key: const ValueKey('welcome_background_fade'),
              opacity: _backgroundFadeAnimation,
              child: DecoratedBox(
                decoration: BoxDecoration(gradient: backgroundGradient),
              ),
            ),
          ),
          Positioned.fill(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: FadeTransition(
                        opacity: _contentFadeAnimation,
                        child: Semantics(
                          key: const ValueKey('settings_button_semantics'),
                          button: true,
                          label: gloc.settings_tab,
                          excludeSemantics: true,
                          child: Material(
                            color: onBackground.withValues(alpha: 0.18),
                            shape: const CircleBorder(),
                            child: IconButton(
                              icon: const Icon(Icons.settings_outlined),
                              color: onBackground,
                              tooltip: gloc.settings_tab,
                              onPressed: _openSettings,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Align(
                        alignment: Alignment.bottomLeft,
                        child: FadeTransition(
                          key: const ValueKey('welcome_title_fade'),
                          opacity: _contentFadeAnimation,
                          child: Text(
                            gloc.welcome_v3_title,
                            style: theme.textTheme.headlineLarge?.copyWith(
                              fontSize: 36,
                              height: 1.2,
                              color: onBackground,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: FadeTransition(
                        opacity: _contentFadeAnimation,
                        child: Center(
                          child: FractionallySizedBox(
                            widthFactor: 0.8,
                            child: Semantics(
                              key: const ValueKey('welcome_logo_semantics'),
                              label: gloc.welcome_logo_semantic,
                              image: true,
                              hint: gloc.welcome_v3_title,
                              child: Image.asset(
                                'assets/images/home/welcome/welcome-logo.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    FadeTransition(
                      opacity: _contentFadeAnimation,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Text(
                              gloc.welcome_tagline,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: onBackground.withValues(alpha: 0.92),
                                height: 1.4,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Semantics(
                              key: const ValueKey('forward_button_semantics'),
                              button: true,
                              label: gloc.welcome_v3_cta,
                              excludeSemantics: true,
                              child: FilledButton(
                                onPressed: _start,
                                style: FilledButton.styleFrom(
                                  backgroundColor: buttonBackground,
                                  foregroundColor: buttonForeground,
                                  minimumSize: const Size.fromHeight(56),
                                  shape: const StadiumBorder(),
                                  elevation: 0,
                                ),
                                child: Text(
                                  gloc.welcome_v3_cta,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: buttonForeground,
                                    fontWeight: FontWeight.w700,
                                  ),
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
          ),
        ],
      ),
    );
  }
}
