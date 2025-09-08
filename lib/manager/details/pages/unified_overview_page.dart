import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import '../../../data/model/expense_group.dart';
import 'tabs/general_overview_tab.dart';
import 'tabs/participants_overview_tab.dart';
import 'tabs/categories_overview_tab.dart';
import 'tabs/settlements_logic.dart';
import '../../group/widgets/section_header.dart';
import '../../../widgets/bottom_sheet_scaffold.dart';

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
      builder: (ctx) => GroupBottomSheetScaffold(
        title: gloc.share_label,
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
    // Settlements (shared compute)
    final settlements = computeSettlements(trip);
    if (settlements.isEmpty) {
      buffer.writeln(gloc.all_balanced);
    } else {
      buffer.writeln(gloc.settlement);
      for (final s in settlements) {
        buffer.writeln(
          '${s.from} -> ${s.to}: ${s.amount.toStringAsFixed(2)} $currency',
        );
      }
    }
    return buffer.toString();
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
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
              child: SectionHeader(
                title: widget.trip.title,
                description: gloc.overview,
                padding: EdgeInsets.zero,
                trailing: IconButton(
                  icon: const Icon(Icons.ios_share_rounded),
                  tooltip: gloc.share_label,
                  onPressed: _showShareOptions,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              // Symmetric horizontal padding so left/right match header (24px)
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: TabBar(
                isScrollable: true,
                // Center the group of tabs within available width
                tabAlignment: TabAlignment.center,
                tabs: [
                  Tab(text: gloc.settings_general),
                  Tab(text: gloc.participants),
                  Tab(text: gloc.categories),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: RepaintBoundary(
                  key: _captureKey,
                  child: TabBarView(
                    children: [
                      GeneralOverviewTab(trip: widget.trip),
                      ParticipantsOverviewTab(trip: widget.trip),
                      CategoriesOverviewTab(trip: widget.trip),
                    ],
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
