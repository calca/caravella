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
  VoiceInputError? _lastError;
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
      _lastError = null;
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
          _lastError = error;
        });
      },
      onDone: () {
        // Safety net: the session ended without ever calling onResult or
        // onError (rare platform edge case). Return to idle instead of
        // leaving the mic pulsing forever.
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

  String _statusText(gen.AppLocalizations gloc) {
    switch (_lastError) {
      case VoiceInputError.notAvailable:
        return gloc.voice_input_not_available;
      case VoiceInputError.permissionDenied:
        return gloc.voice_input_permission_denied;
      case VoiceInputError.noSpeech:
        return gloc.voice_input_no_speech;
      case VoiceInputError.recognitionFailed:
        return gloc.voice_input_error;
      case null:
        return _isListening ? gloc.voice_input_listening : gloc.voice_input_hint;
    }
  }

  @override
  Widget build(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final hasError = _lastError != null;

    return GroupBottomSheetScaffold(
      title: gloc.voice_input_button,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          Center(child: _buildMicButton(colorScheme, gloc)),
          const SizedBox(height: 20),
          Center(
            child: Semantics(
              liveRegion: true,
              child: Text(
                _statusText(gloc),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: hasError
                      ? colorScheme.error
                      : colorScheme.onSurfaceVariant,
                  fontStyle: hasError ? FontStyle.normal : FontStyle.italic,
                  fontWeight: hasError ? FontWeight.w600 : FontWeight.normal,
                ),
                textAlign: TextAlign.center,
              ),
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

  Widget _buildMicButton(ColorScheme colorScheme, gen.AppLocalizations gloc) {
    if (_isProcessing) {
      return Semantics(
        label: gloc.voice_input_processing,
        child: SizedBox(
          width: 72,
          height: 72,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
          ),
        ),
      );
    }

    final hasError = _lastError != null;

    return Semantics(
      button: true,
      label: gloc.voice_input_button,
      value: _isListening ? gloc.voice_input_listening : gloc.voice_input_tap_to_speak,
      onTap: _toggleListening,
      child: ExcludeSemantics(
        child: AnimatedBuilder(
          animation: _pulseController,
          builder: (context, _) {
            final scale = _isListening
                ? (0.95 + _pulseController.value * 0.1)
                : 1.0;
            return GestureDetector(
              onTap: _toggleListening,
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isListening
                        ? colorScheme.primaryContainer
                        : hasError
                        ? colorScheme.errorContainer
                        : colorScheme.surfaceContainerHighest,
                    boxShadow: _isListening
                        ? [
                            BoxShadow(
                              color: colorScheme.primary.withValues(
                                alpha: 0.3,
                              ),
                              blurRadius: 16 + _pulseController.value * 8,
                              spreadRadius: 2 + _pulseController.value * 4,
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    _isListening
                        ? Icons.mic
                        : hasError
                        ? Icons.mic_off_outlined
                        : Icons.mic_none,
                    size: 36,
                    color: _isListening
                        ? colorScheme.onPrimaryContainer
                        : hasError
                        ? colorScheme.onErrorContainer
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
