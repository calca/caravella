import 'package:flutter/material.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import '../../../services/voice_input_service.dart';

class VoiceInputButton extends StatefulWidget {
  final Function(Map<String, dynamic>) onVoiceResult;
  final String? localeId;

  const VoiceInputButton({
    super.key,
    required this.onVoiceResult,
    this.localeId,
  });

  @override
  State<VoiceInputButton> createState() => _VoiceInputButtonState();
}

class _VoiceInputButtonState extends State<VoiceInputButton>
    with SingleTickerProviderStateMixin {
  final VoiceInputService _voiceService = VoiceInputService();
  bool _isListening = false;
  bool _isProcessing = false;
  bool _isAvailable = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _checkAvailability();
  }

  Future<void> _checkAvailability() async {
    final available = await _voiceService.isAvailable();
    if (mounted) {
      setState(() {
        _isAvailable = available;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _voiceService.cancel();
    super.dispose();
  }

  Future<void> _toggleListening() async {
    if (_isListening) {
      await _stopListening();
    } else {
      await _startListening();
    }
  }

  Future<void> _startListening() async {
    final gloc = gen.AppLocalizations.of(context);
    setState(() {
      _isListening = true;
      _isProcessing = false;
    });
    _animationController.repeat();

    await _voiceService.startListening(
      onResult: (text) async {
        if (mounted) {
          setState(() {
            _isListening = false;
            _isProcessing = true;
          });
          _animationController.stop();

          // Parse the voice text
          final parsedData = VoiceInputService.parseExpenseFromText(text);
          
          // Callback with parsed data
          widget.onVoiceResult(parsedData);

          // Reset state after a short delay
          await Future.delayed(const Duration(milliseconds: 500));
          if (mounted) {
            setState(() {
              _isProcessing = false;
            });
          }
        }
      },
      onError: (error) {
        if (mounted) {
          setState(() {
            _isListening = false;
            _isProcessing = false;
          });
          _animationController.stop();
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error == 'Voice recognition not available'
                  ? gloc.voice_input_not_available
                  : gloc.voice_input_error),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      },
      localeId: widget.localeId,
    );
  }

  Future<void> _stopListening() async {
    await _voiceService.stopListening();
    if (mounted) {
      setState(() {
        _isListening = false;
      });
      _animationController.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (!_isAvailable) {
      return const SizedBox.shrink();
    }

    return Tooltip(
      message: gloc.voice_input_button,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        child: IconButton(
          onPressed: _isProcessing ? null : _toggleListening,
          icon: _buildIcon(colorScheme),
          style: IconButton.styleFrom(
            backgroundColor: _isListening
                ? colorScheme.primaryContainer
                : colorScheme.surfaceContainerHighest,
            foregroundColor: _isListening
                ? colorScheme.onPrimaryContainer
                : colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(ColorScheme colorScheme) {
    if (_isProcessing) {
      return SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(
            colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    if (_isListening) {
      return AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Icon(
            Icons.mic,
            size: 24,
            color: colorScheme.onPrimaryContainer.withValues(
              alpha: 0.5 + (_animationController.value * 0.5),
            ),
          );
        },
      );
    }

    return const Icon(Icons.mic_none, size: 24);
  }
}
