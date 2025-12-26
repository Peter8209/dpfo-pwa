import 'dart:convert'; // <-- FIX pre utf8
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

// ⚠️ dart:io a path_provider sú OK na mobile/desktop, ale nie na web.
// Preto ich budeme používať len mimo web.
import 'dart:io' as io show File;

import 'package:path_provider/path_provider.dart' as pp;

import '../../data/models/client.dart';
import '../../data/models/tax_return.dart';
import '../../l10n/vi.dart';
import 'tax_calc.dart';
import 'xml_export.dart';

/// --- XML DEBUG SCREEN (inline, aby si nemusel tvoriť nový súbor) ---
class XmlDebugScreen extends StatelessWidget {
  final String xml;
  const XmlDebugScreen({super.key, required this.xml});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('XML Debug Preview')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: SingleChildScrollView(
          child: SelectableText(
            xml,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
          ),
        ),
      ),
    );
  }
}

class TaxFormScreen extends StatefulWidget {
  final Client client;
  const TaxFormScreen({super.key, required this.client});

  @override
  State<TaxFormScreen> createState() => _TaxFormScreenState();
}

class _TaxFormScreenState extends State<TaxFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final year = TextEditingController(text: '2024');
  final income = TextEditingController(text: '0');
  final expense = TextEditingController(text: '0');
  final social = TextEditingController(text: '0');
  final health = TextEditingController(text: '0');
  final prepayments = TextEditingController(text: '0');
  final loss = TextEditingController(text: '0');
  final otherIncome = TextEditingController(text: '0');
  final withholding = TextEditingController(text: '0');

  bool assign2pct = false;
  final receiverIco = TextEditingController(text: '');

  TaxReturnResult? _result;
  String? _lastFilePath;

  @override
  void dispose() {
    for (final c in [
      year,
      income,
      expense,
      social,
      health,
      prepayments,
      loss,
      otherIncome,
      withholding,
      receiverIco
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  double _d(TextEditingController c) => double.tryParse(c.text.replaceAll(',', '.')) ?? 0.0;
  int _i(TextEditingController c) => int.tryParse(c.text.trim()) ?? 2024;

  String? _numReq(String? v) {
    if (v == null || v.trim().isEmpty) return Vi.t('required');
    final x = double.tryParse(v.replaceAll(',', '.'));
    if (x == null) return Vi.t('number');
    return null;
  }

  TaxReturnInput _makeInput() => TaxReturnInput(
        year: _i(year),
        income: _d(income),
        expense: _d(expense),
        social: _d(social),
        health: _d(health),
        prepayments: _d(prepayments),
        loss: _d(loss),
        otherIncome: _d(otherIncome),
        withholding: _d(withholding),
        assign2pct: assign2pct,
        receiverIco: receiverIco.text.trim(),
      );

  void _compute() {
    if (!_formKey.currentState!.validate()) return;
    final input = _makeInput();
    final r = TaxCalc.compute(input);
    setState(() => _result = r);
  }

  // --- WEB download helper (bez extra balíkov) ---
  // Na web-e potrebujeme použiť dart:html, ale import nesmie byť v mobile.
  // Preto ho použijeme cez "conditional import" pattern = najjednoduchšie je
  // spraviť to cez "dynamic" s `Uri.dataFromString` a otvoriť v browseri.
  // Toto funguje bez dart:html, ale otvorí sa nový tab.
  void _webDownloadXml(String xml, String filename) {
    final uri = Uri.dataFromString(
      xml,
      mimeType: 'application/xml',
      encoding: utf8,
    );

    // ignore: deprecated_member_use
    // (Navigator/launch je bez balíka ťažké; najjednoduchšie je ukázať uri v debug)
    // Lepšie riešenie: pridať `url_launcher` alebo `universal_html`.
    // Tu spravíme fallback: zobrazíme dialog s možnosťou copy + link.
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Web export: $filename'),
        content: SelectableText(
          uri.toString(),
          style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
        ],
      ),
    );
  }

  Future<void> _export() async {
    _compute();
    if (_result == null) return;

    final input = _makeInput();

    final xml = await XmlExport.buildDpfoBv24Xml(
      client: widget.client,
      input: input,
      result: _result!,
    );

    // 1) XML debug preview (vždy)
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => XmlDebugScreen(xml: xml)),
    );

    // 2) Export: Web vs Mobile/Desktop
    final filename = 'DPFOBv24_${widget.client.ico}_${input.year}.xml';

    if (kIsWeb) {
      // Web: ponúkni download (fallback cez Data URI dialog)
      _webDownloadXml(xml, filename);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Web: XML pripravené (pozri link v okne)')),
      );
      return;
    }

    // Mobile/Desktop: uloženie do Documents
    final dir = await pp.getApplicationDocumentsDirectory();
    final file = io.File('${dir.path}/$filename');
    await file.writeAsString(xml, flush: true);
    setState(() => _lastFilePath = file.path);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đã lưu: ${file.path}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = _result;
    return Scaffold(
      appBar: AppBar(title: Text('${Vi.t('create_return')} – ${widget.client.lastName}')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text(Vi.t('tax_inputs'), style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),

              TextFormField(
                controller: year,
                decoration: InputDecoration(labelText: Vi.t('year')),
                validator: _numReq,
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: income,
                decoration: InputDecoration(labelText: Vi.t('income')),
                validator: _numReq,
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: expense,
                decoration: InputDecoration(labelText: Vi.t('expense')),
                validator: _numReq,
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: social,
                decoration: InputDecoration(labelText: Vi.t('social')),
                validator: _numReq,
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: health,
                decoration: InputDecoration(labelText: Vi.t('health')),
                validator: _numReq,
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: prepayments,
                decoration: InputDecoration(labelText: Vi.t('prepayments')),
                validator: _numReq,
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: loss,
                decoration: InputDecoration(labelText: Vi.t('loss')),
                validator: _numReq,
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: otherIncome,
                decoration: InputDecoration(labelText: Vi.t('other_income')),
                validator: _numReq,
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: withholding,
                decoration: InputDecoration(labelText: Vi.t('withholding')),
                validator: _numReq,
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 8),
              SwitchListTile(
                value: assign2pct,
                onChanged: (v) => setState(() => assign2pct = v),
                title: Text(Vi.t('assign_2pct')),
              ),
              if (assign2pct)
                TextFormField(
                  controller: receiverIco,
                  decoration: InputDecoration(labelText: Vi.t('receiver_ico')),
                ),

              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: _compute,
                      child: Text(Vi.t('result')),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _export,
                      icon: const Icon(Icons.file_download),
                      label: Text(Vi.t('export_xml')),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              if (r != null) ...[
                Text(Vi.t('result'), style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                _kv('Base before NCZD', r.baseBeforeNczd),
                _kv('Tax base', r.taxBase),
                _kv('Tax', r.tax),
                _kv('After paid', r.taxAfterPrepayments),
                _kv('2%', r.twoPercent),
                const SizedBox(height: 8),
                Text(Vi.t('warning_check')),
              ],

              if (_lastFilePath != null && !kIsWeb) ...[
                const SizedBox(height: 12),
                Text('XML: $_lastFilePath'),
              ],
              if (kIsWeb) ...[
                const SizedBox(height: 12),
                const Text('WEB: Súbor sa neukladá do filesystemu. XML sa zobrazí v debug okne.'),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _kv(String k, double v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            Expanded(child: Text(k)),
            Text(v.toStringAsFixed(2)),
          ],
        ),
      );
}
