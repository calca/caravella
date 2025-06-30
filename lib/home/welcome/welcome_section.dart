import 'package:flutter/material.dart';
import '../../app_localizations.dart';
import '../../trip/trip_add_page.dart';
import '../../state/locale_notifier.dart';

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

    return Container(
      width: screenWidth,
      constraints: BoxConstraints(
        minHeight: screenHeight - 120,
      ),
      decoration: BoxDecoration(
        image: const DecorationImage(
          image: AssetImage('assets/images/home/welcome/welcome-logo.png'),
          fit: BoxFit.contain,
          alignment: Alignment.center,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Title Section
            Align(
              alignment: Alignment.topLeft,
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

            // Action Section
            Align(
              alignment: Alignment.centerRight,
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
          ],
        ),
      ),
    );
  }
}
