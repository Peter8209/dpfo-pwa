import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'models/client.dart';

class AppDb {
  static final AppDb _instance = AppDb._();
  AppDb._();
  factory AppDb() => _instance;

  Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, 'dpfo_vn_app.db');
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, v) async {
        await db.execute('''
          CREATE TABLE clients (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            firstName TEXT NOT NULL,
            lastName TEXT NOT NULL,
            title TEXT NOT NULL,
            dic TEXT NOT NULL,
            ico TEXT NOT NULL,
            rc TEXT NOT NULL,
            street TEXT NOT NULL,
            city TEXT NOT NULL,
            zip TEXT NOT NULL,
            country TEXT NOT NULL,
            naceText TEXT NOT NULL,
            iban TEXT NOT NULL
          );
        ''');
      },
    );
    return _db!;
  }

  Future<List<Client>> listClients() async {
    final d = await db;
    final rows = await d.query('clients', orderBy: 'lastName ASC');
    return rows.map((m) => Client.fromMap(m)).toList();
  }

  Future<int> upsertClient(Client c) async {
    final d = await db;
    if (c.id == null) {
      return d.insert('clients', c.toMap());
    }
    return d.update('clients', c.toMap(), where: 'id = ?', whereArgs: [c.id]);
  }

  Future<int> deleteClient(int id) async {
    final d = await db;
    return d.delete('clients', where: 'id = ?', whereArgs: [id]);
  }
}
