import '../models/scanned_bill.dart';

/// Conservative label-based extraction: no sample products or invented values.
class BillDetailsParser {
  static final _label = RegExp(
    r'^(?:invoice|bill|receipt|date|brand|model|serial|s/n|product|item|description|seller|sold by|total|grand|net|amount|tax|gst|cgst|sgst|igst|sub\s*total|phone|address|warranty|qty|quantity)\b',
    caseSensitive: false,
  );

  ScannedBill parse(String text) {
    final lines = text
        .replaceAll('\r', '\n')
        // Receipts often print invoice number and date on the same row.
        .replaceAll(
          RegExp(
            r'[\t ]+(?=(?:invoice\s*date|date|dated|brand|model\s*(?:no\.?|number)?|serial\s*(?:no\.?|number)?)\s*[:#])',
            caseSensitive: false,
          ),
          '\n',
        )
        .split('\n')
        .map((line) => line.replaceAll(RegExp(r'[\t ]+'), ' ').trim())
        .where((line) => line.isNotEmpty)
        .toList();

    String? valueFor(
      String labels, {
      bool nextLine = true,
      bool Function(String)? accept,
    }) {
      final pattern = RegExp(
        '^\\s*(?:$labels)(?=\\s|[:#.-]|\$)\\s*[:#.-]?\\s*(.*)\$',
        caseSensitive: false,
      );
      for (var i = 0; i < lines.length; i++) {
        final match = pattern.firstMatch(lines[i]);
        if (match == null) continue;
        final value = match.group(1)!.trim();
        if (value.isNotEmpty) {
          if (accept == null || accept(value)) return value;
          continue;
        }
        if (nextLine &&
            i + 1 < lines.length &&
            !_label.hasMatch(lines[i + 1])) {
          if (accept == null || accept(lines[i + 1])) return lines[i + 1];
        }
      }
      return null;
    }

    final name = valueFor(
      r'product\s*(?:name|description)|item\s*name|description(?:\s+of\s+(?:goods|product))?|product(?!\s*price)',
    );
    final brand = valueFor(r'brand(?:\s+name)?|manufacturer');
    final model = valueFor(r'model(?:\s*(?:number|no\.?))?');
    final serial = valueFor(r'serial(?:\s*(?:number|no\.?))?|s/n');
    final invoice = valueFor(
      r'(?:tax\s+)?(?:invoice|bill|receipt)\s*(?:number|no\.?|#)',
    );
    final dateText = valueFor(
      r'(?:invoice|bill|purchase|receipt)\s*date|dated|date',
    );

    // A grand/net total takes precedence over subtotals, tax, cash tendered,
    // change, and balance due. Never just take the largest number on a receipt.
    double? total;
    for (final labels in [
      r'grand\s*total|net\s*(?:amount|total|payable)|total\s*(?:amount\s*)?(?:payable|paid)|amount\s*(?:payable|paid)',
      r'(?:invoice|bill)\s*(?:total|amount)|total\s*amount|total',
    ]) {
      final candidate = valueFor(
        labels,
        accept: (value) => _amountFromLabel(value) != null,
      );
      total = _amountFromLabel(candidate);
      if (total != null) break;
    }
    final price = _amountFromLabel(
      valueFor(
        r'(?:purchase|product|item|unit)\s*price',
        accept: (value) => _amountFromLabel(value) != null,
      ),
    );

    // Only use a single, unambiguous table description as a product name.
    final productName = _cleanDescription(name) ?? _singleTableItem(lines);
    return ScannedBill(
      rawText: text,
      productName: productName,
      brand: brand ?? _brandIn(productName),
      modelNumber: model,
      serialNumber: serial,
      invoiceNumber: invoice
          ?.split(RegExp(r'\s+(?:date|dated)\b', caseSensitive: false))
          .first
          .trim(),
      sellerName:
          valueFor(
            r'sold\s*by|seller(?:\s*name)?|store(?:\s*name)?|merchant',
          ) ??
          _sellerHeading(lines),
      purchaseDate: dateText == null ? null : _date(dateText),
      amount: price ?? total,
      amountIsBillTotal: price == null && total != null,
    );
  }

  /// Also accepts amounts pasted/typed with Indian grouping and currency.
  static double? parseAmount(String input) {
    final value = _latinDigits(input.trim())
        .replaceAll(RegExp(r'^(?:₹|INR|Rs\.?)\s*', caseSensitive: false), '')
        .replaceAll(RegExp(r'\s*(?:/-|INR|₹)$', caseSensitive: false), '')
        .trim();
    if (!RegExp(
      r'^(?:\d+|\d{1,3}(?:,\d{3})+|\d{1,2}(?:,\d{2})*,\d{3})(?:\.\d{1,2})?$',
    ).hasMatch(value)) {
      return null;
    }
    final number = double.tryParse(value.replaceAll(',', ''));
    return number != null && number.isFinite && number >= 0 ? number : null;
  }

  static double? _amountFromLabel(String? value) {
    if (value == null) return null;
    final normalized = value
        .replaceFirst(
          RegExp(r'^\s*\((?:INR|Rs\.?|₹)\)\s*:?\s*', caseSensitive: false),
          '',
        )
        .trim();
    final amount = parseAmount(normalized);
    if (amount != null) return amount;
    // Some GST invoices show total quantity before the money column.
    final quantityThenAmount = RegExp(
      r'^\d+(?:\.\d+)?\s*(?:nos\.?|pcs\.?|units?|sets?)\s+(.+)$',
      caseSensitive: false,
    ).firstMatch(normalized);
    return quantityThenAmount == null
        ? null
        : parseAmount(quantityThenAmount[1]!);
  }

  static String _latinDigits(String text) => text.replaceAllMapped(
    RegExp('[०-९]'),
    (match) => (match[0]!.codeUnitAt(0) - '०'.codeUnitAt(0)).toString(),
  );

  static DateTime? _date(String input) {
    final value = _latinDigits(input);
    var match = RegExp(
      r'\b(\d{4})[-/.](\d{1,2})[-/.](\d{1,2})\b',
    ).firstMatch(value);
    if (match != null) {
      return _validDate(
        int.parse(match[1]!),
        int.parse(match[2]!),
        int.parse(match[3]!),
      );
    }
    match = RegExp(
      r'\b(\d{1,2})[-/.](\d{1,2})[-/.](\d{4}|\d{2})\b',
    ).firstMatch(value);
    if (match != null) {
      var year = int.parse(match[3]!);
      if (year < 100) year += 2000;
      return _validDate(year, int.parse(match[2]!), int.parse(match[1]!));
    }
    match = RegExp(
      r'\b(\d{1,2})[\s-]+([a-z]{3,9})[\s,-]+(\d{4})\b',
      caseSensitive: false,
    ).firstMatch(value);
    if (match == null) return null;
    const months = [
      'jan',
      'feb',
      'mar',
      'apr',
      'may',
      'jun',
      'jul',
      'aug',
      'sep',
      'oct',
      'nov',
      'dec',
    ];
    final month = months.indexOf(match[2]!.toLowerCase().substring(0, 3)) + 1;
    return _validDate(int.parse(match[3]!), month, int.parse(match[1]!));
  }

  static DateTime? _validDate(int year, int month, int day) {
    final date = DateTime(year, month, day);
    return year >= 1900 &&
            date.year == year &&
            date.month == month &&
            date.day == day
        ? date
        : null;
  }

  static String? _cleanDescription(String? value) {
    if (value == null ||
        RegExp(
          r'\b(?:qty|quantity|hsn|rate|amount)\b',
          caseSensitive: false,
        ).hasMatch(value)) {
      return null;
    }
    return value;
  }

  static String? _singleTableItem(List<String> lines) {
    final header = lines.indexWhere(
      (line) =>
          RegExp(
            r'\b(?:description|item|particulars)\b',
            caseSensitive: false,
          ).hasMatch(line) &&
          RegExp(
            r'\b(?:qty|quantity|rate|amount)\b',
            caseSensitive: false,
          ).hasMatch(line),
    );
    if (header < 0) return null;
    final hasHsn = RegExp(
      r'\bhsn(?:/sac)?\b',
      caseSensitive: false,
    ).hasMatch(lines[header]);
    const money = r'(?:₹\s*)?\d[\d,]*(?:\.\d{1,2})?';
    const unit = r'(?:nos\.?|pcs\.?|units?|sets?|each)';
    final rowPattern = RegExp(
      r'^(?:\d+[.)]?\s+)?(.+?[a-zA-Z].*?)\s+' +
          (hasHsn ? r'\d{4,8}\s+' : '') +
          r'\d+(?:\.\d+)?\s+(?:' +
          unit +
          r'\s+)?' +
          money +
          r'\s+(?:' +
          unit +
          r'\s+)?' +
          money +
          r'$',
      caseSensitive: false,
    );
    final items = <String>[];
    for (final line in lines.skip(header + 1)) {
      if (RegExp(
        r'^(?:sub\s*total|total|grand|net|cgst|sgst|igst|tax|discount)\b',
        caseSensitive: false,
      ).hasMatch(line)) {
        break;
      }
      // Require a description followed by at least two numeric table cells.
      final row = rowPattern.firstMatch(line);
      if (row != null) items.add(row[1]!.trim());
    }
    return items.length == 1 ? items.single : null;
  }

  static String? _brandIn(String? name) {
    if (name == null) return null;
    return RegExp(
      r'\b(?:Samsung|LG|Sony|Apple|Whirlpool|Haier|Godrej|Panasonic|Voltas|Daikin|Bosch|Philips|Lenovo|Dell|HP|Asus|Acer|OnePlus|Vivo|Oppo|Xiaomi|Realme|IFB|Bajaj|Havells)\b',
      caseSensitive: false,
    ).firstMatch(name)?[0];
  }

  static String? _sellerHeading(List<String> lines) {
    for (final line in lines.take(3)) {
      if (_label.hasMatch(line)) continue;
      if (RegExp(r'\d|[:/@]').hasMatch(line)) continue;
      if (RegExp(
        r'\b(?:cash|original|duplicate|customer|copy|thank|welcome)\b',
        caseSensitive: false,
      ).hasMatch(line)) {
        continue;
      }
      if (line.length >= 3 &&
          line.length <= 80 &&
          RegExp('[a-zA-Z]').hasMatch(line)) {
        return line;
      }
    }
    return null;
  }
}
