import 'package:flutter_test/flutter_test.dart';
import 'package:mydigi_app/services/bill_details_parser.dart';

void main() {
  final parser = BillDetailsParser();

  test(
    'extracts real labelled fields and grand total with Indian decimals',
    () {
      final bill = parser.parse('''
STAR ELECTRONICS
Tax Invoice
Invoice No: INV-2026/42
Invoice Date: 12/09/2026
Product Name: Samsung Double Door Refrigerator
Brand: Samsung
Model No.: RT28
Serial No: SN123456
Subtotal: 25,000.00
CGST: 2,250.00
SGST: 2,250.00
Grand Total: Rs. 29,500.50
Cash: 30,000.00
Change: 499.50
''');
      expect(bill.productName, 'Samsung Double Door Refrigerator');
      expect(bill.brand, 'Samsung');
      expect(bill.modelNumber, 'RT28');
      expect(bill.serialNumber, 'SN123456');
      expect(bill.invoiceNumber, 'INV-2026/42');
      expect(bill.purchaseDate, DateTime(2026, 9, 12));
      expect(bill.amount, 29500.50);
      expect(bill.amountIsBillTotal, isTrue);
      expect(bill.sellerName, 'STAR ELECTRONICS');
    },
  );

  test('reads next-line values and avoids treating quantity as total', () {
    final bill = parser.parse('''
Invoice #
A-004
Date: 2026-09-12
Total Qty: 2
Total
INR 1,23,450.75
''');
    expect(bill.invoiceNumber, 'A-004');
    expect(bill.amount, 123450.75);
    expect(bill.purchaseDate, DateTime(2026, 9, 12));
  });

  test('does not use tax, subtotal, phone, or an invalid date as values', () {
    final bill = parser.parse('''
TAX INVOICE
Phone: 9876543210
GST: 29ABCDE1234F1Z5
Subtotal: 1000
Tax: 180
Invoice Date: 31/02/2026
Product Name:
Brand:
Model:
''');
    expect(bill.amount, isNull);
    expect(bill.productName, isNull);
    expect(bill.brand, isNull);
    expect(bill.purchaseDate, isNull);
  });

  test(
    'single table item can fill description; multiple items need review',
    () {
      final bill = parser.parse('''
Item Description Qty Rate Amount
1 Samsung Refrigerator 1 25000.00 25000.00
Grand Total: 29500.00
''');
      expect(bill.productName, 'Samsung Refrigerator');
      expect(bill.brand, 'Samsung');
      expect(bill.amountIsBillTotal, isTrue);
      final multi = parser.parse('''
Description Qty Rate Amount
1 Samsung Refrigerator 1 25000.00 25000.00
2 LG Television 1 30000.00 30000.00
Grand Total: 55000.00
''');
      expect(multi.productName, isNull);
      expect(multi.amount, 55000);
      expect(multi.amountIsBillTotal, isTrue);
    },
  );

  test('explicit product price takes priority over whole-bill total', () {
    final bill = parser.parse(
      'Product Price: ₹1,250.75\nGrand Total: 5,000.00\nDate: 12 Sep 2026',
    );
    expect(bill.amount, 1250.75);
    expect(bill.amountIsBillTotal, isFalse);
    expect(bill.productName, isNull);
    expect(bill.purchaseDate, DateTime(2026, 9, 12));
  });

  test('empty image text produces no invented data', () {
    expect(parser.parse('').fieldCount, 0);
  });

  test(
    'reads a GST invoice table with HSN codes and quantity before total',
    () {
      final bill = parser.parse('''
STAR ELECTRONICS
Tax Invoice
Invoice No: GST/42
Date: 12/09/2026
Sl No Description of Goods HSN/SAC Quantity Rate per Amount
1 LG Refrigerator GL-D201 841810 1 Nos 16900.00 Nos 16900.00
CGST 9% 1521.00
SGST 9% 1521.00
Total 1 Nos ₹19,942.00
''');
      expect(bill.productName, 'LG Refrigerator GL-D201');
      expect(bill.brand, 'LG');
      expect(bill.invoiceNumber, 'GST/42');
      expect(bill.amount, 19942.00);
      expect(bill.amountIsBillTotal, isTrue);
    },
  );

  test('handles invoice date on the same row and parenthesized currency', () {
    final bill = parser.parse(
      'Invoice No: A-42  Date: 12/09/2026\nGrand Total (Rs.): 1,234.50',
    );
    expect(bill.invoiceNumber, 'A-42');
    expect(bill.purchaseDate, DateTime(2026, 9, 12));
    expect(bill.amount, 1234.50);
  });

  test(
    'manual currency and decimals parse without silent zero or truncation',
    () {
      for (final value in [
        '1250.75',
        '1,250.75',
        '₹1,250.75',
        'Rs. 1,250.75',
        '  INR 1,250.75  ',
      ]) {
        expect(BillDetailsParser.parseAmount(value), 1250.75);
      }
      expect(BillDetailsParser.parseAmount('0'), 0);
      expect(BillDetailsParser.parseAmount('₹१२५०.७५'), 1250.75);
      for (final value in [
        '',
        'abc',
        'NaN',
        'Infinity',
        '-250',
        '1.2.3',
        '12,34,',
        '50,50',
        '500 200',
      ]) {
        expect(BillDetailsParser.parseAmount(value), isNull);
      }
    },
  );
}
