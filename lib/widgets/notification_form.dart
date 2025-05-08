import 'package:flutter/material.dart';
import 'package:flutter_whatsapp_notification/services/twilio_service.dart';
import 'package:flutter_whatsapp_notification/services/google_drive_service.dart';
import 'package:flutter_whatsapp_notification/models/receipt_data.dart';

class NotificationForm extends StatefulWidget {
  final TwilioService twilioService;
  final GoogleDriveService googleDriveservice = GoogleDriveService(); 

  NotificationForm({
    Key? key,
    required this.twilioService,
  }) : super(key: key);

  @override
  State<NotificationForm> createState() => _NotificationFormState();
}

class _NotificationFormState extends State<NotificationForm> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController(text: '+60172586093');
  final _messageController = TextEditingController(text: 'Hello! This is a test notification.');
  final _dateController = TextEditingController(text: '12/1');
  final _timeController = TextEditingController(text: '3pm');

  bool _isLoading = false;
  String? _errorMessage;
  bool _isSuccess = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _messageController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  Future<void> _sendNotification() async {
  setState(() {
    _isLoading = true;
    _errorMessage = null;
    _isSuccess = false;
  });

  try {
    // Step 1: Use predefined dummy data for the receipt
    final receiptData = ReceiptData(
      receiptNumber: 'DUMMY12345',
      date: '2025-05-08',
      customerName: 'Jane Doe',
      items: [
        {'name': 'Product A', 'quantity': 2, 'price': 15.0},
        {'name': 'Product B', 'quantity': 1, 'price': 25.0},
        {'name': 'Product C', 'quantity': 3, 'price': 10.0},
      ],
      totalAmount: 95.0,
      paymentMethod: 'Cash',
    );

    // Step 2: Generate the PDF
    final pdfFile = await widget.twilioService.generateReceiptPdf(receiptData);

    // Step 3: Upload the PDF to Google Drive
    final String hostedPdfUrl = await widget.googleDriveservice.uploadPdfToGoogleDrive(pdfFile);

    // Step 4: Send the WhatsApp message with the hosted PDF link
    final result = await widget.twilioService.sendWhatsAppMessage(
      to: '+60172586093', // Dummy phone number
      message: 'Here is your receipt PDF!',
      pdfUrl: hostedPdfUrl,
    );

    setState(() {
      _isSuccess = result.success;
      _errorMessage = result.success ? null : (result.error ?? 'Failed to send message');
    });
  } catch (e) {
    setState(() {
      _errorMessage = e.toString();
    });
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Send WhatsApp Notification',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  hintText: '+1234567890',
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _dateController,
                      decoration: const InputDecoration(
                        labelText: 'Date',
                        hintText: 'MM/DD',
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _timeController,
                      decoration: const InputDecoration(
                        labelText: 'Time',
                        hintText: '3pm',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _messageController,
                decoration: const InputDecoration(
                  labelText: 'Message',
                  hintText: 'Enter your message here',
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a message';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red.shade800),
                  ),
                ),
              if (_isSuccess)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green.shade800, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Message sent successfully!',
                        style: TextStyle(color: Colors.green.shade800),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _sendNotification,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 8),
                          Text('Sending...'),
                        ],
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.send),
                          SizedBox(width: 8),
                          Text('Send Notification'),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
