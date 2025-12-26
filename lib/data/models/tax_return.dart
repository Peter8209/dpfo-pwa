class TaxReturnInput {
  final int year;

  // “10 numeric inputs” (MVP)
  final double income;       // total income (e.g. §6)
  final double expense;      // total expense
  final double social;       // social contributions paid
  final double health;       // health contributions paid
  final double prepayments;  // tax prepayments paid
  final double loss;         // applied tax loss (optional)
  final double otherIncome;  // optional
  final double withholding;  // §43 optional

  final bool assign2pct;
  final String receiverIco;  // for 2%

  const TaxReturnInput({
    required this.year,
    required this.income,
    required this.expense,
    required this.social,
    required this.health,
    required this.prepayments,
    required this.loss,
    required this.otherIncome,
    required this.withholding,
    required this.assign2pct,
    required this.receiverIco,
  });
}

class TaxReturnResult {
  final double baseBeforeNczd;
  final double taxBase;
  final double tax;
  final double taxAfterPrepayments;
  final double twoPercent;

  const TaxReturnResult({
    required this.baseBeforeNczd,
    required this.taxBase,
    required this.tax,
    required this.taxAfterPrepayments,
    required this.twoPercent,
  });
}
