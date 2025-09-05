import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import '../../../data/model/expense_group.dart';
import '../tabs/unified_overview_tab.dart';
import '../../group/widgets/section_header.dart';

/// Overview & statistics page with share (text/image) capability.
class UnifiedOverviewPage extends StatefulWidget {
  final ExpenseGroup trip;
  const UnifiedOverviewPage({super.key, required this.trip});

  @override
  State<UnifiedOverviewPage> createState() => _UnifiedOverviewPageState();
}

class _UnifiedOverviewPageState extends State<UnifiedOverviewPage> {
  final GlobalKey _captureKey = GlobalKey();
  bool _sharing = false;

  Future<void> _showShareOptions() async {
    final gloc = gen.AppLocalizations.of(context);
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.text_snippet_outlined),
              title: Text(gloc.share_text_label),
              onTap: () async {
                Navigator.of(ctx).pop();
                await _shareText();
              },
            ),
            ListTile(
              leading: const Icon(Icons.image_outlined),
              title: Text(gloc.share_image_label),
              onTap: () async {
                Navigator.of(ctx).pop();
                await _shareImage();
              },
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }

  String _buildTextSummary(gen.AppLocalizations gloc) {
    final buffer = StringBuffer();
    final trip = widget.trip;
    buffer.writeln(trip.title);
    buffer.writeln('');
    buffer.writeln(gloc.overview);
    buffer.writeln('');
    final currency = trip.currency;
    // Totals per participant
    buffer.writeln(gloc.expenses_by_participant);
    for (final p in trip.participants) {
      final total = trip.expenses
          .where((e) => e.paidBy.name == p.name)
          .fold<double>(0, (s, e) => s + (e.amount ?? 0));
      buffer.writeln('- ${p.name}: ${total.toStringAsFixed(2)} $currency');
    }
    buffer.writeln('');
    // Settlements (duplicate minimal algorithm from tab)
    final settlements = _calculateSettlements(trip);
    if (settlements.isEmpty) {
      buffer.writeln(gloc.all_balanced);
    } else {
      buffer.writeln(gloc.settlement);
      for (final s in settlements) {
        buffer.writeln(
          '${s['from']} -> ${s['to']}: ${(s['amount'] as double).toStringAsFixed(2)} $currency',
        );
      }
    }
    return buffer.toString();
  }

  List<Map<String, dynamic>> _calculateSettlements(ExpenseGroup trip) {
    if (trip.participants.length < 2 || trip.expenses.isEmpty) return [];
    final balances = <String, double>{};
    final totalExpenses = trip.expenses.fold<double>(
      0.0,
      (sum, e) => sum + (e.amount ?? 0.0),
    );
    final fairShare = totalExpenses / trip.participants.length;
    for (final p in trip.participants) {
      balances[p.name] = 0.0;
    }
    for (final e in trip.expenses) {
      if (e.amount != null) {
        balances[e.paidBy.name] = (balances[e.paidBy.name] ?? 0) + e.amount!;
      }
    }
    for (final p in trip.participants) {
      balances[p.name] = (balances[p.name] ?? 0) - fairShare;
    }
    final creditors = <MapEntry<String, double>>[];
    final debtors = <MapEntry<String, double>>[];
    balances.forEach((k, v) {
      if (v > 0.01) {
        creditors.add(MapEntry(k, v));
      } else if (v < -0.01) {
        debtors.add(MapEntry(k, -v));
      }
    });
    creditors.sort((a, b) => b.value.compareTo(a.value));
    debtors.sort((a, b) => b.value.compareTo(a.value));
    final settlements = <Map<String, dynamic>>[];
    var ci = 0;
    var di = 0;
    while (ci < creditors.length && di < debtors.length) {
      final c = creditors[ci];
      final d = debtors[di];
      final amount = c.value < d.value ? c.value : d.value;
      settlements.add({'from': d.key, 'to': c.key, 'amount': amount});
      creditors[ci] = MapEntry(c.key, c.value - amount);
      debtors[di] = MapEntry(d.key, d.value - amount);
      if (creditors[ci].value < 0.01) ci++;
      if (debtors[di].value < 0.01) di++;
    }
    return settlements;
  }

  Future<void> _shareText() async {
    if (_sharing) return;
    _sharing = true;
    final gloc = gen.AppLocalizations.of(context);
    try {
      final summary = _buildTextSummary(gloc);
      await SharePlus.instance.share(ShareParams(text: summary));
    } catch (_) {
      // swallow errors silently or add toast if available
    } finally {
      _sharing = false;
    }
  }

  Future<void> _shareImage() async {
    if (_sharing) return;
    _sharing = true;
    try {
      final boundary =
          _captureKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) {
        _sharing = false;
        return;
      }
      final ui.Image img = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        _sharing = false;
        return;
      }
      final bytes = byteData.buffer.asUint8List();
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/overview_${widget.trip.id}.png');
      await file.writeAsBytes(bytes);
      await SharePlus.instance.share(
        ShareParams(files: [XFile(file.path)], text: widget.trip.title),
      );
    } catch (_) {
      // optionally handle error
    } finally {
      _sharing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.trip.title, overflow: TextOverflow.ellipsis),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: SectionHeader(
              title: gloc.overview,
              description: gloc.expenses_by_participant,
              padding: EdgeInsets.zero,
              trailing: IconButton(
                icon: const Icon(Icons.ios_share_rounded),
                tooltip: gloc.share_label,
                onPressed: _showShareOptions,
              ),
            ),
          ),
          Expanded(
            child: RepaintBoundary(
              key: _captureKey,
              child: UnifiedOverviewTab(trip: widget.trip),
            ),
          ),
        ],
      ),
    );
  }
}
