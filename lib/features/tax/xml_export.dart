import 'package:flutter/services.dart' show rootBundle;
import 'package:xml/xml.dart';

import '../../data/models/client.dart';
import '../../data/models/tax_return.dart';

class XmlExport {
  /// Builds DPFOBv24 XML from a scrubbed eDane template.
  /// - Never throws on missing nodes
  /// - Auto-creates required XML paths
  /// - Fills numeric fields with 0.00 if empty (eDane-safe)
  static Future<String> buildDpfoBv24Xml({
    required Client client,
    required TaxReturnInput input,
    required TaxReturnResult result,
  }) async {
    final template =
        await rootBundle.loadString('assets/templates/dpfo_b_v24_template.xml');

    final doc = XmlDocument.parse(template);
    final root = doc.rootElement;

    // -------------------------------------------------------------------------
    // Helpers
    // -------------------------------------------------------------------------

    String money(num? v) => (v ?? 0).toStringAsFixed(2);
    String text(String? v) => (v ?? '').trim();

    /// Ensure XML path exists and return the final element
    XmlElement ensurePath(List<String> path) {
      XmlElement current = root;

      for (final tag in path) {
        final existing = current.children
            .whereType<XmlElement>()
            .cast<XmlElement?>()
            .firstWhere(
              (e) => e!.name.local == tag,
              orElse: () => null,
            );

        if (existing != null) {
          current = existing;
        } else {
          final created = XmlElement(XmlName(tag));
          current.children.add(created);
          current = created;
        }
      }
      return current;
    }

    /// Set text value at XML path (auto-create nodes)
    void setValue(List<String> path, String value) {
      final el = ensurePath(path);
      el.children
        ..clear()
        ..add(XmlText(value));
    }

    /// Safe setter for optional / version-dependent fields
    void trySet(List<String> path, String value) {
      try {
        setValue(path, value);
      } catch (_) {
        // ignore intentionally (template differences)
      }
    }

    // -------------------------------------------------------------------------
    // HLAVICKA – identification
    // -------------------------------------------------------------------------

    setValue(['hlavicka', 'rok'], input.year.toString());
    setValue(['hlavicka', 'dic'], text(client.dic));
    setValue(['hlavicka', 'meno'], text(client.firstName));
    setValue(['hlavicka', 'priezvisko'], text(client.lastName));
    setValue(['hlavicka', 'titul'], text(client.title));

    setValue(['hlavicka', 'ulica'], text(client.street));
    setValue(['hlavicka', 'obec'], text(client.city));
    setValue(['hlavicka', 'psc'], text(client.zip));
    setValue(['hlavicka', 'stat'], text(client.country));
    setValue(['hlavicka', 'cinnost'], text(client.naceText));

    // -------------------------------------------------------------------------
    // TELO – TABUĽKY (MVP SZČO §6)
    // -------------------------------------------------------------------------

    // Tabuľka 1 – príjmy / výdavky
    setValue(['telo', 'tabulka1', 't1r2', 's1'], money(input.income));
    setValue(['telo', 'tabulka1', 't1r2', 's2'], money(input.expense));

    // Zaplatené poistné (SP + ZP)
    setValue(
      ['telo', 'vydavkyPoistPar6ods11_ods1a2'],
      money(input.social + input.health),
    );

    // -------------------------------------------------------------------------
    // RIADKY – povinné výpočtové polia (eDane XSD-sensitive)
    // -------------------------------------------------------------------------

    trySet(['telo', 'r39'], money(input.income)); // Príjmy spolu
    trySet(['telo', 'r40'], money(input.expense)); // Výdavky spolu

    trySet(['telo', 'r47'], money(input.loss)); // Daňová strata
    trySet(['telo', 'r55'], money(result.baseBeforeNczd));
    trySet(['telo', 'r56'], money(result.taxBase));

    trySet(['telo', 'r116'], money(result.taxBase));
    trySet(['telo', 'r117'], money(result.tax)); // Daň
    trySet(['telo', 'r120'], money(result.tax)); // Daň spolu

    trySet(
      ['telo', 'r121'],
      money(input.prepayments + input.withholding),
    );

    trySet(
      ['telo', 'r142'],
      money(result.tax - (input.prepayments + input.withholding)),
    );

    // -------------------------------------------------------------------------
    // 2 % dane
    // -------------------------------------------------------------------------

    if (input.assign2pct) {
      trySet(['telo', 'icoPrijimatel'], text(input.receiverIco));
      trySet(['telo', 'r153'], money(result.twoPercent));
    } else {
      trySet(['telo', 'r153'], money(0));
    }

    // -------------------------------------------------------------------------
    // Bezpečnostné vyplnenie nulami (eDane to MILUJE)
    // -------------------------------------------------------------------------

    final mandatoryZeroFields = [
      'r118',
      'r119',
      'r122',
      'r123',
      'r124',
      'r125',
      'r130',
      'r140',
      'r141',
    ];

    for (final r in mandatoryZeroFields) {
      trySet(['telo', r], money(0));
    }

    // -------------------------------------------------------------------------
    // Výsledok
    // -------------------------------------------------------------------------

    return doc.toXmlString(pretty: true, indent: '  ');
  }
}
