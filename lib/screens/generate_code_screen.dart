import 'package:flutter/material.dart';
import '../services/device_id_service.dart';
import '../services/http_helper.dart';

class GenerateCodeScreen extends StatefulWidget {
  const GenerateCodeScreen({super.key});

  @override
  State<GenerateCodeScreen> createState() => GenerateCodeScreenState();
}

class GenerateCodeScreenState extends State<GenerateCodeScreen> {
  bool isLoading = true;
  String? code;
  String? error;

  @override
  void initState() {
    super.initState();
    generateCode();
  }

  Future<void> generateCode() async {
    try {
      final deviceID = await DeviceIDservice.getDeviceID();
      final response = await HttpHelper.startSession(deviceID);

      if (mounted) {
        setState(() {
          code = response['data']['code'].toString();
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          error = 'Failed to generate code. Please try again.';
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Generate Code',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading) ...[
              const Center(
                child: CircularProgressIndicator(
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 16),
              const Text('Generating your code...'),
            ] else if (error != null) ...[
              Text(
                error!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isLoading = true;
                      error = null;
                    });
                    generateCode();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Try Again'),
                ),
              ),
            ] else ...[
              const Text(
                'Share this code with your friend',
                style: TextStyle(
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 48,
                  vertical: 24,
                ),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  code!,
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Navigate to movie selection screen
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Start Matching'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
