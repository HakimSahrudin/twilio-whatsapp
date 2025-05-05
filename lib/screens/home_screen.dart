import 'package:flutter/material.dart';
import 'package:flutter_whatsapp_notification/services/twilio_service.dart';
import 'package:flutter_whatsapp_notification/widgets/notification_form.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WhatsApp Notification Sender'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 16),
                Text(
                  'Send notifications to your WhatsApp with a single tap',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                NotificationForm(
                  twilioService: TwilioService(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
