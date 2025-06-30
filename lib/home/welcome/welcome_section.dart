import 'package:flutter/material.dart';
import '../../app_localizations.dart';
import '../../trip/trip_add_page.dart';
import '../../state/locale_notifier.dart';
import '../../settings/settings_page.dart';

typedef RefreshCallback = void Function();

class WelcomeSection extends StatelessWidget {
  final RefreshCallback? onTripAdded;
  const WelcomeSection({super.key, this.onTripAdded});

  @override
  Widget build(BuildContext context) {
    final localeNotifier = LocaleNotifier.of(context);
    final loc = AppLocalizations(localeNotifier?.locale ?? 'it');
    final theme = Theme.of(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final mediaQuery = MediaQuery.of(context);
    final topPadding = mediaQuery.padding.top; // Status bar height
    final bottomPadding = mediaQuery.padding.bottom; // Navigation bar height

    return SizedBox(
      width: screenWidth,
      height:
          screenHeight, // Occupa tutta l'altezza dello schermo inclusi system UI
      child: Container(
        decoration: const BoxDecoration(
          color:
              Color(0xFF65CCED), // Background azzurro solo per WelcomeSection
          image: DecorationImage(
            image: AssetImage('assets/images/home/welcome/welcome-logo.png'),
            fit: BoxFit.contain,
            alignment: Alignment.center,
          ),
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
                      fontWeight: FontWeight.w700,
                      fontSize: 36,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
              ),

              // Spacer centrale - occupando 1/3 dello spazio (dove sta il logo)
              const Expanded(
                flex: 2,
                child: SizedBox(), // Spazio per il logo di background
              ),

              // Action Section - occupando 1/3 dello spazio
              Expanded(
                flex: 2,
                child: Stack(
                  children: [
                    // Bottone principale "Avanti" in basso a destra
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.onSurface,
                          shape: BoxShape.circle,
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(60),
                            onTap: () async {
                              final result = await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => TripAddPage(),
                                ),
                              );
                              if (result == true && onTripAdded != null) {
                                onTripAdded!();
                              }
                            },
                            child: Center(
                              child: Text(
                                loc.get('welcome_v3_cta'),
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: theme.colorScheme.surface,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
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
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            letterSpacing: 1.2,
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
