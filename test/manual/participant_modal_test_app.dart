import 'package:flutter/material.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;

/// Test app to verify participant list updates work correctly
///
/// Run with: flutter run test/manual/participant_modal_test_app.dart
void main() {
  runApp(const ParticipantModalTestApp());
}

class ParticipantModalTestApp extends StatelessWidget {
  const ParticipantModalTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Participant Modal Test',
      localizationsDelegates: gen.AppLocalizations.localizationsDelegates,
      supportedLocales: gen.AppLocalizations.supportedLocales,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const ParticipantModalTestPage(),
    );
  }
}

class ParticipantModalTestPage extends StatefulWidget {
  const ParticipantModalTestPage({super.key});

  @override
  State<ParticipantModalTestPage> createState() =>
      _ParticipantModalTestPageState();
}

class _ParticipantModalTestPageState extends State<ParticipantModalTestPage> {
  List<String> participants = ['Alice', 'Bob'];
  String? selectedParticipant;

  Future<void> _showParticipantModal() async {
    final result = await showSelectionBottomSheet<String>(
      context: context,
      items: participants,
      selected: selectedParticipant,
      itemLabel: (p) => p,
      sheetTitle: 'Select Participant',
      onAddItemInline: (name) async {
        // Simulate the real behavior - add to parent list
        setState(() {
          participants = [...participants, name];
        });
      },
      addItemHint: 'Participant name',
      addLabel: 'Add',
      cancelLabel: 'Cancel',
      addCategoryLabel: 'Add participant',
      alreadyExistsMessage: 'Participant already exists',
    );

    if (result != null) {
      setState(() {
        selectedParticipant = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Participant Modal Test'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Test the participant selection modal:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            const Text(
              'Current participants:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            ...participants.map(
              (p) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text('• $p'),
              ),
            ),
            const SizedBox(height: 16),

            if (selectedParticipant != null) ...[
              Text(
                'Selected: $selectedParticipant',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 16),
            ],

            ElevatedButton(
              onPressed: _showParticipantModal,
              child: const Text('Select Participant'),
            ),

            const SizedBox(height: 24),

            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Test Instructions:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text('1. Tap "Select Participant" to open the modal'),
                    Text('2. You should see Alice and Bob in the list'),
                    Text('3. Tap "Add participant" to add a new one'),
                    Text('4. Enter a name (e.g., "Charlie") and tap ✓'),
                    Text('5. ✅ The new participant is automatically selected'),
                    Text('6. ✅ The modal closes and shows the selection'),
                    Text(
                      '7. The new participant is now in the list for future use',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
