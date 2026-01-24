import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import '../../manager/group/pages/group_creation_wizard_page.dart';
import '../../settings/pages/settings_page.dart';

typedef RefreshCallback = void Function();

class HomeWelcomeSection extends StatefulWidget {
  final RefreshCallback? onTripAdded;
  const HomeWelcomeSection({super.key, this.onTripAdded});

  @override
  State<HomeWelcomeSection> createState() => _HomeWelcomeSectionState();
}

class _HomeWelcomeSectionState extends State<HomeWelcomeSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _titleAnimation;
  late Animation<double> _logoAnimation;
  late Animation<double> _buttonAnimation;
  late Animation<double> _settingsAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    // Staggered animations with smooth curves
    _titleAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
    );

    _logoAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 0.6, curve: Curves.easeOut),
    );

    _buttonAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.5, 0.9, curve: Curves.easeOut),
    );

    _settingsAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _restoreSystemUIColors() {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            isDarkMode ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDarkMode ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: theme.colorScheme.surface,
        systemNavigationBarIconBrightness:
            isDarkMode ? Brightness.light : Brightness.dark,
      ),
    );
  }

  Future<void> _restoreSystemUIColorsAsync() async {
    _restoreSystemUIColors();
    // Small delay to ensure system UI is updated before navigation
    await Future.delayed(const Duration(milliseconds: 50));
  }

  @override
  Widget build(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);
    final theme = Theme.of(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final mediaQuery = MediaQuery.of(context);
    final topPadding = mediaQuery.padding.top;
    final bottomPadding = mediaQuery.padding.bottom;

    // Adaptive color scheme for welcome screen
    final isDarkMode = theme.brightness == Brightness.dark;

    // Beautiful gradient backgrounds
    final backgroundGradient = isDarkMode
        ? LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primaryFixedDim,
              theme
                  .colorScheme
                  .onPrimaryFixed, // Replace deprecated surfaceVariant
            ],
          )
        : LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primaryFixedDim,
              theme.colorScheme.primary,
            ],
          );

    final titleColor = isDarkMode
        ? theme.colorScheme.onSurface
        : theme.colorScheme.onPrimary;

    final buttonBackgroundColor = isDarkMode
        ? theme.colorScheme.primary
        : theme.colorScheme.onPrimary;

    final buttonForegroundColor = isDarkMode
        ? theme.colorScheme.onPrimaryContainer
        : theme.colorScheme.primary;

    final settingsTextColor = isDarkMode
        ? theme.colorScheme.onPrimary
        : theme.colorScheme.onPrimary;

    // Calculate the end color of the gradient for navigation bar
    final navigationBarColor = isDarkMode
        ? theme.colorScheme.onPrimaryFixed
        : theme.colorScheme.primary;

    // Set system UI overlay style to match gradient
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDarkMode
            ? Brightness.light
            : Brightness.light,
        statusBarBrightness: isDarkMode ? Brightness.dark : Brightness.dark,
        systemNavigationBarColor: navigationBarColor,
        systemNavigationBarIconBrightness: isDarkMode
            ? Brightness.light
            : Brightness.light,
      ),
    );

    return SizedBox(
      width: screenWidth,
      height: screenHeight,
      child: Container(
        decoration: BoxDecoration(
          gradient: backgroundGradient, // Use gradient instead of solid color
        ),
        child: Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: topPadding + 16, // Status bar + padding aggiuntivo
            bottom: bottomPadding + 16, // Navigation bar + padding aggiuntivo
          ),
          child: Column(
            children: [
              // Title Section - occupando 1/3 dello spazio verticale
              Expanded(
                flex: 2,
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: FadeTransition(
                    opacity: _titleAnimation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(-0.3, 0),
                        end: Offset.zero,
                      ).animate(_titleAnimation),
                      child: Text(
                        gloc.welcome_v3_title,
                        style: theme.textTheme.headlineLarge?.copyWith(
                          fontSize: 36,
                          height: 1.2,
                          color: titleColor, // Use adaptive title color
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ),
                ),
              ),

              // Logo Section - occupando 1/3 dello spazio, centrato
              Expanded(
                flex: 2,
                child: Align(
                  alignment: Alignment
                      .center, // Centra sia orizzontalmente che verticalmente
                  child: FadeTransition(
                    opacity: _logoAnimation,
                    child: ScaleTransition(
                      scale: Tween<double>(
                        begin: 0.8,
                        end: 1.0,
                      ).animate(_logoAnimation),
                      child: SizedBox(
                        width:
                            screenWidth *
                            0.8, // 80% della larghezza dello schermo
                        child: Semantics(
                          key: const ValueKey('welcome_logo_semantics'),
                          // Keep word 'logo' so test finder (contains 'logo') succeeds
                          label: gloc.welcome_logo_semantic,
                          image: true,
                          // Provide a descriptive hint for screen readers
                          hint: gloc.welcome_v3_title,
                          child: Image.asset(
                            'assets/images/home/welcome/welcome-logo.png',
                            fit: BoxFit.contain, // Mantiene le proporzioni
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Action Section - occupando 1/3 dello spazio
              Expanded(
                flex: 2,
                child: Stack(
                  children: [
                    // Bottone "Impostazioni" in basso a sinistra
                    Positioned(
                      bottom: 0,
                      left: 0,
                      child: FadeTransition(
                        opacity: _settingsAnimation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.5),
                            end: Offset.zero,
                          ).animate(_settingsAnimation),
                          child: Semantics(
                            key: const ValueKey('settings_button_semantics'),
                            button: true,
                            // Short predictable label containing 'settings'
                            label: gloc.settings_tab,
                            child: TextButton(
                              onPressed: () async {
                                // Restore system UI colors before navigation
                                await _restoreSystemUIColorsAsync();
                                if (!context.mounted) return;
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const SettingsPage(),
                                  ),
                                );
                              },
                              child: Text(
                                gloc.settings_tab.toUpperCase(),
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: settingsTextColor,
                                  letterSpacing: 1.2,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Bottone principale "Avanti" sopra al bottone impostazioni
                    Positioned(
                      bottom: 60, // Posizionato sopra al bottone impostazioni
                      right: 0,
                      child: FadeTransition(
                        opacity: _buttonAnimation,
                        child: ScaleTransition(
                          scale: Tween<double>(
                            begin: 0.5,
                            end: 1.0,
                          ).animate(_buttonAnimation),
                          child: Semantics(
                            key: const ValueKey('forward_button_semantics'),
                            button: true,
                            label: gloc.welcome_v3_cta,
                            child: IconButton.filled(
                              onPressed: () async {
                                // Restore system UI colors before navigation
                                await _restoreSystemUIColorsAsync();
                                if (!context.mounted) return;
                                final result = await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const GroupCreationWizardPage(
                                          fromWelcome: true,
                                        ),
                                  ),
                                );
                                if (result != null) {
                                  if (result is String) {
                                    // User wants to go to group
                                    if (widget.onTripAdded != null) {
                                      widget.onTripAdded!();
                                    }
                                  }
                                }
                              },
                              style: IconButton.styleFrom(
                                backgroundColor: buttonBackgroundColor,
                                foregroundColor: buttonForegroundColor,
                                minimumSize: const Size(120, 120),
                                maximumSize: const Size(120, 120),
                                shape: const CircleBorder(),
                                elevation: isDarkMode
                                    ? 2
                                    : 0, // Subtle elevation in dark mode
                              ),
                              icon: const Icon(Icons.arrow_forward, size: 32),
                              tooltip: gloc.welcome_v3_cta,
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
    );
  }
}
