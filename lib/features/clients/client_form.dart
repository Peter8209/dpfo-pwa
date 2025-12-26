import 'package:flutter/material.dart';

import '../../data/db.dart';
import '../../data/models/client.dart';
import '../../l10n/vi.dart';
import '../ocr/ocr_scan.dart';

class ClientFormScreen extends StatefulWidget {
  final Client? client;
  const ClientFormScreen({super.key, this.client});

  @override
  State<ClientFormScreen> createState() => _ClientFormScreenState();
}

class _ClientFormScreenState extends State<ClientFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _db = AppDb();

  late final TextEditingController firstName;
  late final TextEditingController lastName;
  late final TextEditingController title;
  late final TextEditingController dic;
  late final TextEditingController ico;
  late final TextEditingController rc;
  late final TextEditingController street;
  late final TextEditingController city;
  late final TextEditingController zip;
  late final TextEditingController country;
  late final TextEditingController naceText;
  late final TextEditingController iban;

  @override
  void initState() {
    super.initState();
    final c = widget.client;
    firstName = TextEditingController(text: c?.firstName ?? '');
    lastName = TextEditingController(text: c?.lastName ?? '');
    title = TextEditingController(text: c?.title ?? '');
    dic = TextEditingController(text: c?.dic ?? '');
    ico = TextEditingController(text: c?.ico ?? '');
    rc = TextEditingController(text: c?.rc ?? '');
    street = TextEditingController(text: c?.street ?? '');
    city = TextEditingController(text: c?.city ?? '');
    zip = TextEditingController(text: c?.zip ?? '');
    country = TextEditingController(text: c?.country ?? 'Slovensko');
    naceText = TextEditingController(text: c?.naceText ?? '');
    iban = TextEditingController(text: c?.iban ?? '');
  }

  @override
  void dispose() {
    for (final c in [firstName,lastName,title,dic,ico,rc,street,city,zip,country,naceText,iban]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _scanOcr() async {
    final res = await Navigator.of(context).push<OcrResult?>(
      MaterialPageRoute(builder: (_) => const OcrScanScreen()),
    );
    if (res == null) return;
    if (res.dic != null && res.dic!.isNotEmpty) dic.text = res.dic!;
    if (res.ico != null && res.ico!.isNotEmpty) ico.text = res.ico!;
    if (res.rc != null && res.rc!.isNotEmpty) rc.text = res.rc!;
    setState(() {});
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final c = Client(
      id: widget.client?.id,
      firstName: firstName.text.trim(),
      lastName: lastName.text.trim(),
      title: title.text.trim(),
      dic: dic.text.trim(),
      ico: ico.text.trim(),
      rc: rc.text.trim(),
      street: street.text.trim(),
      city: city.text.trim(),
      zip: zip.text.trim(),
      country: country.text.trim(),
      naceText: naceText.text.trim(),
      iban: iban.text.trim(),
    );
    final id = await _db.upsertClient(c);
    Navigator.of(context).pop(c.id == null ? c.copyWith(id: id) : c);
  }

  String? _req(String? v) => (v == null || v.trim().isEmpty) ? Vi.t('required') : null;

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.client != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? Vi.t('edit_client') : Vi.t('add_client')),
        actions: [
          IconButton(onPressed: _scanOcr, icon: const Icon(Icons.document_scanner)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text(Vi.t('client_card'), style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              TextFormField(controller: lastName, decoration: InputDecoration(labelText: Vi.t('last_name')), validator: _req),
              TextFormField(controller: firstName, decoration: InputDecoration(labelText: Vi.t('first_name')), validator: _req),
              TextFormField(controller: title, decoration: InputDecoration(labelText: Vi.t('title'))),
              TextFormField(controller: dic, decoration: InputDecoration(labelText: Vi.t('dic')), validator: _req),
              TextFormField(controller: ico, decoration: InputDecoration(labelText: Vi.t('ico')), validator: _req),
              TextFormField(controller: rc, decoration: InputDecoration(labelText: Vi.t('rc')), validator: _req),
              const SizedBox(height: 8),
              TextFormField(controller: street, decoration: InputDecoration(labelText: Vi.t('street')), validator: _req),
              TextFormField(controller: city, decoration: InputDecoration(labelText: Vi.t('city')), validator: _req),
              TextFormField(controller: zip, decoration: InputDecoration(labelText: Vi.t('zip')), validator: _req),
              TextFormField(controller: country, decoration: InputDecoration(labelText: Vi.t('country')), validator: _req),
              TextFormField(controller: naceText, decoration: InputDecoration(labelText: Vi.t('nace'))),
              TextFormField(controller: iban, decoration: InputDecoration(labelText: Vi.t('iban'))),
              const SizedBox(height: 16),
              FilledButton(onPressed: _save, child: Text(Vi.t('save'))),
            ],
          ),
        ),
      ),
    );
  }
}

extension _Copy on Client {
  Client copyWith({int? id}) => Client(
    id: id ?? this.id,
    firstName: firstName,
    lastName: lastName,
    title: title,
    dic: dic,
    ico: ico,
    rc: rc,
    street: street,
    city: city,
    zip: zip,
    country: country,
    naceText: naceText,
    iban: iban,
  );
}
