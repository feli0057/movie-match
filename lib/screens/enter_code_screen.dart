import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/device_id_service.dart';
import '../services/http_helper.dart';
import 'movie_matching_screen.dart';

class EnterCodeScreen extends StatefulWidget {
  const EnterCodeScreen({super.key});

  @override
  State<EnterCodeScreen> createState() => _EnterCodeScreenState();
}

class _EnterCodeScreenState extends State<EnterCodeScreen> {
  final TextEditingController _codeController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _submitCode() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final deviceID = await DeviceIdService.getDeviceID();
      final code = int.parse(_codeController.text);

      await HttpHelper.joinSession(deviceID, code);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const MovieMatchingScreen(),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        const errorMessage =
            'You may have entered the wrong code. Please try again.';

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text(
                'Invalid Code',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: const Text(errorMessage),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _codeController.clear();
                  },
                  child: const Text(
                    'Okay',
                    style: TextStyle(
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            );
          },
        );

        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Enter Code',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Enter the code shared by your friend',
                style: TextStyle(
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _codeController,
                keyboardType: TextInputType.number,
                maxLength: 4,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 64,
                    letterSpacing: 8,
                    fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  hintText: '0000',
                  hintStyle: const TextStyle(
                    color: Color(0xFFBDBDBD),
                  ),
                  counterText: '',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Colors.deepPurple,
                      width: 2,
                    ),
                  ),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a 4-digit code';
                  }
                  if (value.length != 4) {
                    return 'Code must be 4 digits';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitCode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    disabledBackgroundColor: Colors.grey,
                    textStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Start Movie Match'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
