import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_whatsapp_notification/config/env.dart';


class TwilioResponse {
  final bool success;
  final String? sid;
  final String? error;

  TwilioResponse({
    required this.success,
    this.sid,
    this.error,
  });
}

class TwilioService {
  // Replace these with your actual Twilio credentials
  static const String accountSid = Env.twilioAccountSid; // Replace with your Twilio Account SID
  static const String authToken = Env.twilioAuthToken; // Replace with your Twilio Auth Token
  static const String twilioWhatsAppNumber = Env.twilioWhatsAppNumber; // Replace with your Twilio WhatsApp number

  // Generate a PDF file
Future<File> generatePdf(String message) async {
  final pdf = pw.Document();

  // Add a page with the message
  pdf.addPage(
    pw.Page(
      build: (pw.Context context) => pw.Center(
        child: pw.Text(
          message,
          // ignore: prefer_const_constructors
          style: pw.TextStyle(fontSize: 24),
        ),
      ),
    ),
  );

  // Save the PDF to a temporary directory
  final outputDir = await getTemporaryDirectory();
  final file = File('${outputDir.path}/message.pdf');
  await file.writeAsBytes(await pdf.save());
  return file;
}

  // Send WhatsApp message with PDF link
  Future<TwilioResponse> sendWhatsAppMessage({
    required String to,
    required String message,
    required String pdfUrl, // Public URL of the hosted PDF
  }) async {
    try {
      // Ensure the phone number is in the correct format
      String formattedTo = to;
      if (!formattedTo.startsWith('whatsapp:')) {
        formattedTo = 'whatsapp:$formattedTo';
      }

      // Twilio API URL
      final Uri uri = Uri.parse(
          'https://api.twilio.com/2010-04-01/Accounts/$accountSid/Messages.json');

      // Prepare request body
      final Map<String, String> body = {
        'From': 'whatsapp:$twilioWhatsAppNumber',
        'To': formattedTo,
        'Body': message,
        'MediaUrl': pdfUrl, // Hosted PDF URL
      };

      // Prepare authorization header
      final String basicAuth =
          'Basic ${base64Encode(utf8.encode('$accountSid:$authToken'))}';

      // Send request
      final response = await http.post(
        uri,
        headers: {
          'Authorization': basicAuth,
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: body,
      );

      // Handle response
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return TwilioResponse(
          success: true,
          sid: responseData['sid'],
        );
      } else {
        String errorMessage;
        try {
          final Map<String, dynamic> errorData = jsonDecode(response.body);
          errorMessage = errorData['message'] ?? 'Unknown error';
        } catch (e) {
          errorMessage = 'Error: ${response.statusCode} ${response.reasonPhrase}';
        }
        return TwilioResponse(
          success: false,
          error: errorMessage,
        );
      }
    } catch (e) {
      return TwilioResponse(
        success: false,
        error: e.toString(),
      );
    }
  }
}