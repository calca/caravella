import 'package:flutter/material.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import '../../../services/voice_input_service.dart';

/// A bottom sheet for voice capture that follows the standard Caravella sheet
/// style. The user starts and stops listening by tapping the mic button.
class VoiceCaptureBottomSheet extends StatefulWidget {
  final List<String> participantNames;
  final String? localeId;
  final void Function(Map<String, dynamic> result) onVoiceResult;

  const VoiceCaptureBottomSheet({
    super.key,
    required this.participantNames,
    required this.onVoiceResult,
    this.localeId,
  });

  /// Convenience method to show the bottom sheet.
  static Future<void> show({
    required BuildContext context,
    required List<String> participantNames,
    required void Function(Map<String, dynamic>) onVoiceResult,
    String? localeId,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => VoiceCaptureBottomSheet(
        participantNames: participantNames,
        onVoiceResult: onVoiceResult,
        localeId: localeId,
      ),
    );
  }

  @override
  State<VoiceCaptureBottomSheet> createState() =>
      _VoiceCaptureBottomSheetState();
}

class _VoiceCaptureBottomSheetState extends State<VoiceCaptureBottomSheet>
    with SingleTickerProviderStateMixin {
  final VoiceInputService _voiceService = VoiceInputService();
  bool _isListening = false;
  bool _isProcessing = false;
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    // Start listening as soon as the bottom sheet is visible.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _startListening();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _voiceService.cancel();
    super.dispose();
  }

  Future<void> _toggleListening() async {
    if (_isListening) {
      await _voiceService.stopListening();
      _pulseController.stop();
      if (mounted) setState(() => _isListening = false);
      return;
    }

    await _startListening();
  }

  Future<void> _startListening() async {
    if (_isListening || _isProcessing) return;

    if (!mounted) return;
    setState(() {
      _isListening = true;
      _isProcessing = false;
    });
    _pulseController.repeat(reverse: true);

    await _voiceService.startListening(
      localeId: widget.localeId,
      onResult: (text) async {
        if (!mounted) return;
        _pulseController.stop();
        setState(() {
          _isListening = false;
          _isProcessing = true;
        });

        final parsed = VoiceInputService.parseExpenseFromText(
          text,
          participantNames: widget.participantNames,
        );

        await Future.delayed(const Duration(milliseconds: 300));
        if (!mounted) return;

        widget.onVoiceResult(parsed);
        Navigator.of(context).pop();
      },
      onError: (error) {
        if (!mounted) return;
        _pulseController.stop();
        setState(() {
          _isListening = false;
          _isProcessing = false;
        });
      },
    );
  }

  Future<void> _cancel() async {
    await _voiceService.cancel();
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return GroupBottomSheetScaffold(
      title: gloc.voice_input_button,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          Center(child: _buildMicButton(colorScheme)),
          const SizedBox(height: 20),
          Center(
            child: Text(
              _isListening ? gloc.voice_input_listening : gloc.voice_input_hint,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(onPressed: _cancel, child: Text(gloc.cancel)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMicButton(ColorScheme colorScheme) {
    if (_isProcessing) {
      return SizedBox(
        width: 72,
        height: 72,
        child: CircularProgressIndicator(
          strokeWidth: 3,
          valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
        ),
      );
    }

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, _) {
        final scale = _isListening
            ? (0.95 + _pulseController.value * 0.1)
            : 1.0;
        return GestureDetector(
          onTap: _isProcessing ? null : _toggleListening,
          child: Transform.scale(
            scale: scale,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isListening
                    ? colorScheme.primaryContainer
                    : colorScheme.surfaceContainerHighest,
                boxShadow: _isListening
                    ? [
                        BoxShadow(
                          color: colorScheme.primary.withValues(alpha: 0.3),
                          blurRadius: 16 + _pulseController.value * 8,
                          spreadRadius: 2 + _pulseController.value * 4,
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                _isListening ? Icons.mic : Icons.mic_none,
                size: 36,
                color: _isListening
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        );
      },
    );
  }
}
