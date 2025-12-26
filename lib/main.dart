import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'l10n/vi.dart';
import 'features/clients/clients_list.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const DpfoVnApp());
}

class DpfoVnApp extends StatelessWidget {
  const DpfoVnApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Vi.t('app_title'),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('vi')],
      locale: const Locale('vi'),
      home: const ClientsListScreen(),
    );
  }
}
