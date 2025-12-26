import 'package:flutter/material.dart';

import '../../data/db.dart';
import '../../data/models/client.dart';
import '../../l10n/vi.dart';
import '../tax/tax_form.dart';
import 'client_form.dart';

class ClientsListScreen extends StatefulWidget {
  const ClientsListScreen({super.key});

  @override
  State<ClientsListScreen> createState() => _ClientsListScreenState();
}

class _ClientsListScreenState extends State<ClientsListScreen> {
  final _db = AppDb();

  Future<void> _openForm({Client? client}) async {
    final saved = await Navigator.of(context).push<Client?>(
      MaterialPageRoute(builder: (_) => ClientFormScreen(client: client)),
    );
    if (saved != null) setState(() {});
  }

  Future<void> _delete(Client c) async {
    if (c.id == null) return;
    await _db.deleteClient(c.id!);
    setState(() {});
  }

  Future<void> _createReturn(Client c) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => TaxFormScreen(client: c)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(Vi.t('clients'))),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<Client>>(
        future: _db.listClients(),
        builder: (context, snap) {
          // 🔄 NAČÍTAVANIE
          if (snap.connectionState == ConnectionState.waiting) {
            return _emptyHint(
              context,
              icon: Icons.hourglass_top,
              text: 'Đang tải dữ liệu...\n\n'
                  'Nhấn dấu + để tạo tờ khai thuế loại B',
            );
          }

          // ❌ CHYBA
          if (snap.hasError) {
            return _emptyHint(
              context,
              icon: Icons.error_outline,
              text: 'Lỗi khi tải dữ liệu.\n'
                  'Vui lòng thử lại.',
            );
          }

          final items = snap.data ?? [];

          // 📭 ŽIADNI KLIENTI
          if (items.isEmpty) {
            return _emptyHint(
              context,
              icon: Icons.description_outlined,
              text: 'Chưa có tờ khai nào.\n\n'
                  '👉 Nhấn dấu + để tạo tờ khai thuế loại B',
            );
          }

          // ✅ ZOZNAM KLIENTOV
          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final c = items[i];
              return ListTile(
                title: Text('${c.lastName} ${c.firstName}'),
                subtitle: Text('DIČ: ${c.dic} | IČO: ${c.ico}'),
                onTap: () => _createReturn(c),
                trailing: PopupMenuButton<String>(
                  onSelected: (v) {
                    if (v == 'edit') _openForm(client: c);
                    if (v == 'del') _delete(c);
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(value: 'edit', child: Text(Vi.t('edit_client'))),
                    PopupMenuItem(value: 'del', child: Text(Vi.t('delete'))),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 🧾 PRÁZDNY STAV / NÁVOD PRE POUŽÍVATEĽA
  // ---------------------------------------------------------------------------
  Widget _emptyHint(BuildContext context,
      {required IconData icon, required String text}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 72, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              text,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }
}
