import 'package:flutter/material.dart';
import '../../app_localizations.dart';
import '../../manager/group/add_new_expenses_group.dart';
import '../../state/locale_notifier.dart';
import '../../settings/settings_page.dart';

typedef RefreshCallback = void Function();

class HomeWelcomeSection extends StatelessWidget {
  final RefreshCallback? onTripAdded;
  const HomeWelcomeSection({super.key, this.onTripAdded});

  @override
  Widget build(BuildContext context) {
    final localeNotifier = LocaleNotifier.of(context);
    final loc = AppLocalizations(localeNotifier?.locale ?? 'it');
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
              theme.colorScheme.surface,
              theme.colorScheme
                  .surfaceContainerHighest, // Replace deprecated surfaceVariant
            ],
          )
        : LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.primaryContainer,
            ],
          );

    final titleColor =
        isDarkMode ? theme.colorScheme.onSurface : theme.colorScheme.onPrimary;

    final buttonBackgroundColor = isDarkMode
        ? theme.colorScheme.primaryContainer
        : theme.colorScheme.onPrimary;

    final buttonForegroundColor = isDarkMode
        ? theme.colorScheme.onPrimaryContainer
        : theme.colorScheme.primary;

    final settingsTextColor =
        isDarkMode ? theme.colorScheme.primary : theme.colorScheme.onPrimary;

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
                  child: Text(
                    loc.get('welcome_v3_title'),
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

              // Logo Section - occupando 1/3 dello spazio, centrato
              Expanded(
                flex: 2,
                child: Align(
                  alignment: Alignment
                      .center, // Centra sia orizzontalmente che verticalmente
                  child: SizedBox(
                    width:
                        screenWidth * 0.8, // 80% della larghezza dello schermo
                    child: Image.asset(
                      'assets/images/home/welcome/welcome-logo.png',
                      fit: BoxFit.contain, // Mantiene le proporzioni
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
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const SettingsPage(),
                            ),
                          );
                        },
                        child: Text(
                          loc.get('settings_tab').toUpperCase(),
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: settingsTextColor,
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    // Bottone principale "Avanti" sopra al bottone impostazioni
                    Positioned(
                      bottom: 60, // Posizionato sopra al bottone impostazioni
                      right: 0,
                      child: IconButton.filled(
                        onPressed: () async {
                          final result = await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  const AddNewExpensesGroupPage(),
                            ),
                          );
                          if (result == true && onTripAdded != null) {
                            onTripAdded!();
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
                        icon: Icon(
                          Icons.arrow_forward,
                          size: 32,
                        ),
                        tooltip: loc.get('welcome_v3_cta'),
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
