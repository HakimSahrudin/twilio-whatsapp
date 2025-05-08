class ReceiptData {
  final String receiptNumber;
  final String date;
  final String customerName;
  final List<Map<String, dynamic>> items; // Each item has name, quantity, and price
  final double totalAmount;
  final String paymentMethod;

  ReceiptData({
    required this.receiptNumber,
    required this.date,
    required this.customerName,
    required this.items,
    required this.totalAmount,
    required this.paymentMethod,
  });
}