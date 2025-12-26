import '../../data/models/tax_return.dart';

/// NOTE:
/// This is an MVP calculator for a common SZČO scenario.
/// Slovak DPFO-B has many branches; expand as needed.
/// You can also override/adjust constants yearly.
class TaxCalc {
  // 2024 threshold (example). Replace with correct values if needed for your exact case.
  // We'll keep it configurable; default is often used threshold for 25% bracket.
  static const double bracketThreshold = 47537.98;
  static const double rateLow = 0.19;
  static const double rateHigh = 0.25;

  // Minimal NCZD placeholder (set to 0 by default in MVP; add real formula later).
  static double nczdForYear(int year, double taxBaseBeforeNczd) {
    // TODO: Implement exact NCZD formula for given year (Finančná správa / zákon).
    return 0.0;
  }

  static TaxReturnResult compute(TaxReturnInput i) {
    final deductions = i.social + i.health;
    final baseBeforeNczd = (i.income + i.otherIncome) - i.expense - deductions - i.loss;
    final basePos = baseBeforeNczd < 0 ? 0.0 : baseBeforeNczd;

    final nczd = nczdForYear(i.year, basePos);
    final taxBase = (basePos - nczd) < 0 ? 0.0 : (basePos - nczd);

    // progressive tax
    double tax;
    if (taxBase <= bracketThreshold) {
      tax = taxBase * rateLow;
    } else {
      tax = bracketThreshold * rateLow + (taxBase - bracketThreshold) * rateHigh;
    }

    // after prepayments and withholding
    final paid = i.prepayments + i.withholding;
    final taxAfterPaid = tax - paid;

    final twoPercent = i.assign2pct ? (tax > 0 ? (tax * 0.02) : 0.0) : 0.0;

    return TaxReturnResult(
      baseBeforeNczd: baseBeforeNczd,
      taxBase: taxBase,
      tax: tax,
      taxAfterPrepayments: taxAfterPaid,
      twoPercent: twoPercent,
    );
  }
}
