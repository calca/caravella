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
    final topPadding = mediaQuery.padding.top; // Status bar height
    final bottomPadding = mediaQuery.padding.bottom; // Navigation bar height

    return SizedBox(
      width: screenWidth,
      height:
          screenHeight, // Occupa tutta l'altezza dello schermo inclusi system UI
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.primary, // Usa il colore primario del tema
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
                  child: Semantics(
                    header: true,
                    label: loc.get('welcome_v3_title'),
                    child: Text(
                      loc.get('welcome_v3_title'),
                      style: theme.textTheme.headlineLarge?.copyWith(
                        fontSize: 36,
                        height: 1.2,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
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
                    // Bottone principale "Avanti" in basso a destra
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: theme.colorScheme
                              .onPrimary, // Contrasta con il background primary
                          shape: BoxShape.circle,
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(60),
                            onTap: () async {
                              final result = await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      AddNewExpensesGroupPage(),
                                ),
                              );
                              if (result == true && onTripAdded != null) {
                                onTripAdded!();
                              }
                            },
                            child: Semantics(
                              button: true,
                              label: loc.get('welcome_v3_cta'),
                              hint: 'Tocca per creare un nuovo gruppo di spese',
                              child: Center(
                                child: Text(
                                  loc.get('welcome_v3_cta'),
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    color: theme.colorScheme
                                        .primary, // Usa il primary come colore del testo
                                  ),
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
                            color: theme.colorScheme
                                .onPrimary, // Contrasta con il background primary
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
