import 'dart:math';
import 'package:flutter/material.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;

/// Playful empty state widget shown when a group has no expenses yet.
/// Displays a random emoji and encouraging message with smooth animations.
class GroupCardEmptyState extends StatefulWidget {
  final gen.AppLocalizations localizations;
  final ThemeData theme;

  const GroupCardEmptyState({
    super.key,
    required this.localizations,
    required this.theme,
  });

  @override
  State<GroupCardEmptyState> createState() => _GroupCardEmptyStateState();
}

class _GroupCardEmptyStateState extends State<GroupCardEmptyState>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;
  late final String _emoji;
  late final String _message;

  // Fun emojis for empty state - mix of travel, adventure, and money themes
  static const List<String> _emojis = [
    '✨',
    '🎒',
    '🗺️',
    '🎯',
    '🚀',
    '🌟',
    '💫',
    '🎉',
    '🌈',
    '🎨',
    '🧳',
    '🏖️',
    '⛰️',
    '🎪',
    '🎭',
  ];

  @override
  void initState() {
    super.initState();

    // Pick random emoji
    final random = Random();
    _emoji = _emojis[random.nextInt(_emojis.length)];

    // Generate creative message
    _message = _generateMessage(random);

    // Setup bounce animation
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.0,
          end: 1.15,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.15,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.elasticOut)),
        weight: 40,
      ),
    ]).animate(_controller);

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.forward();
  }

  String _generateMessage(Random random) {
    // Multiple playful messages - pick one at random
    final messages = [
      widget.localizations.emptyGroupState1, // "Il viaggio inizia qui!"
      widget
          .localizations
          .emptyGroupState2, // "Pronto a segnare la prima spesa?"
      widget.localizations.emptyGroupState3, // "Nessuna spesa... per ora!"
      widget.localizations.emptyGroupState4, // "Iniziamo questa avventura!"
      widget
          .localizations
          .emptyGroupState5, // "La prima spesa è sempre speciale"
    ];

    return messages[random.nextInt(messages.length)];
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Parses markdown-style **bold** text and returns a list of TextSpans
  List<TextSpan> _parseMessageWithBold(String message, TextStyle baseStyle) {
    final spans = <TextSpan>[];
    final regex = RegExp(r'\*\*(.*?)\*\*');
    int lastIndex = 0;

    for (final match in regex.allMatches(message)) {
      // Add regular text before bold
      if (match.start > lastIndex) {
        spans.add(
          TextSpan(
            text: message.substring(lastIndex, match.start),
            style: baseStyle,
          ),
        );
      }

      // Add bold text
      spans.add(
        TextSpan(
          text: match.group(1),
          style: baseStyle.copyWith(fontWeight: FontWeight.w700),
        ),
      );

      lastIndex = match.end;
    }

    // Add remaining text after last bold
    if (lastIndex < message.length) {
      spans.add(TextSpan(text: message.substring(lastIndex), style: baseStyle));
    }

    return spans;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Big animated emoji - desaturated 50% for subtle effect
                ColorFiltered(
                  colorFilter: const ColorFilter.matrix(<double>[
                    // Saturation matrix with value 0.5 (50% color retained)
                    0.6063, 0.3576, 0.0361, 0, 0, // Red channel
                    0.1063, 0.8576, 0.0361, 0, 0, // Green channel
                    0.1063, 0.3576, 0.5361, 0, 0, // Blue channel
                    0, 0, 0, 1, 0, // Alpha channel
                  ]),
                  child: Text(
                    _emoji,
                    style: const TextStyle(fontSize: 96, height: 1.0),
                  ),
                ),
                const SizedBox(height: 24),
                // Encouraging message with bold words
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    children: _parseMessageWithBold(
                      _message,
                      widget.theme.textTheme.bodyLarge?.copyWith(
                            fontSize: 20,
                            color: widget.theme.colorScheme.onSurface
                                .withValues(alpha: 0.7),
                            fontWeight: FontWeight.w500,
                            height: 1.4,
                          ) ??
                          const TextStyle(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
