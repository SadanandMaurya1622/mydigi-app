/// Suggestions read from a bill. Missing fields stay null for manual entry.
class ScannedBill {
  const ScannedBill({
    this.rawText = '',
    this.productName,
    this.brand,
    this.modelNumber,
    this.serialNumber,
    this.invoiceNumber,
    this.sellerName,
    this.purchaseDate,
    this.amount,
    this.amountIsBillTotal = false,
  });

  final String rawText;
  final String? productName;
  final String? brand;
  final String? modelNumber;
  final String? serialNumber;
  final String? invoiceNumber;
  final String? sellerName;
  final DateTime? purchaseDate;
  final double? amount;
  final bool amountIsBillTotal;

  int get fieldCount => [
    productName,
    brand,
    modelNumber,
    serialNumber,
    invoiceNumber,
    sellerName,
    purchaseDate,
    amount,
  ].where((value) => value != null).length;
}
