import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/language_provider.dart';
import '../services/api_service.dart';
import '../config/api_config.dart';
import '../utils/app_theme.dart';

class DonationScreen extends StatefulWidget {
  const DonationScreen({super.key});

  @override
  State<DonationScreen> createState() => _DonationScreenState();
}

class _DonationScreenState extends State<DonationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _amountController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isLoading = false;


  String? _selectedAmount;

  final List<int> _presetAmounts = [50, 100, 200, 500, 1000, 2000];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _amountController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _handleDonate() async {
    if (!_formKey.currentState!.validate()) return;

    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);
    final isAmharic = languageProvider.currentLanguage == 'am';
    final isOromo = languageProvider.currentLanguage == 'or';

    setState(() => _isLoading = true);

    try {
      // Collect form data
      final name = _nameController.text.trim();
      final email = _emailController.text.trim();
      final phone = _phoneController.text.trim();
      final amount = _amountController.text.trim();
      final message = _messageController.text.trim();
      
      if (kDebugMode) {
        debugPrint('🔄 DONATION PROCESS STARTED');
        debugPrint('📝 Form Data: Name=$name, Email=$email, Amount=$amount');
      }

      // Convert phone from +251 9XX XXX XXXX to 09XXXXXXXX format for payment
      // Match client: formData.phone.replace(/\+251\s?/, '').replace(/\s/g, '').replace(/^9/, '09')
      String phoneForPayment = phone
          .replaceAll(
              RegExp(r'\+251\s?'), '') // Remove +251 with optional space
          .replaceAll(' ', '') // Remove all spaces
          .trim();

      print('📱 Phone Processing:');
      print('   After removing +251: $phoneForPayment');

      // Ensure phone starts with 0: if it starts with 9, replace with 09
      // If it doesn't start with 0 or 9, add 0 prefix
      if (phoneForPayment.isNotEmpty) {
        if (phoneForPayment.startsWith('9')) {
          phoneForPayment = '0$phoneForPayment';
          print('   Starts with 9, added 0 prefix: $phoneForPayment');
        } else if (!phoneForPayment.startsWith('0')) {
          phoneForPayment = '0$phoneForPayment';
          print(
              '   Doesn\'t start with 0 or 9, added 0 prefix: $phoneForPayment');
        } else {
          print('   Already starts with 0: $phoneForPayment');
        }
      } else {
        print('   ⚠️ Phone number is empty!');
      }

      // Match client: payment data structure
      final paymentData = {
        'first_name': name,
        'amount': double.parse(amount),
        'email': email,
        'phone_number': phoneForPayment,
        'title': 'ERCS Donation',
        'return_url':
            'https://redcross-cleint.vercel.app/donation/success', // Client return URL
        'description': message.isNotEmpty
            ? message
            : 'Donation to Ethiopian Red Cross Society',
        'currency': 'ETB',
      };

      final apiUrl = '${ApiConfig.paymentsUrl}/donation';
      
      if (kDebugMode) {
        debugPrint('🌐 API Endpoint: $apiUrl');
      }

      final result = await ApiService.post(
        apiUrl,
        paymentData,
      );

      if (kDebugMode) {
        debugPrint('📥 API Response: Success=${result['success']}');
      }

      if (mounted) {
        // Check if API call was successful
        if (result['success'] == true && result['data'] != null) {
          // ApiService wraps response in 'data' field
          // Server returns: { response: data.response, transactionId, checkoutUrl: ... }
          final responseData = result['data'];

          // Try multiple paths to get checkout URL
          final checkoutUrl1 = responseData['checkoutUrl'];
          final checkoutUrl2 =
              responseData['response']?['data']?['checkout_url'];
          final checkoutUrl3 = responseData['response']?['checkout_url'];
          final checkoutUrl4 = responseData['data']?['checkout_url'];

          final checkoutUrl =
              checkoutUrl1 ?? checkoutUrl2 ?? checkoutUrl3 ?? checkoutUrl4;

          if (kDebugMode) {
            debugPrint('✅ Extracted checkout URL: $checkoutUrl');
          }

          if (checkoutUrl != null &&
              checkoutUrl.toString().isNotEmpty &&
              checkoutUrl != 'null') {
            try {
              final uri = Uri.parse(checkoutUrl.toString());

              // Skip canLaunchUrl check - it's unreliable on Android
              // Just try to launch the URL directly
              final launched = await launchUrl(
                uri,
                mode: LaunchMode.externalApplication,
              );

              if (launched) {
                if (kDebugMode) {
                  debugPrint('✅ Payment URL launched successfully!');
                }
                return; // Successfully launched
              } else {
                // Try with platform default mode as fallback
                try {
                  final launched2 = await launchUrl(
                    uri,
                    mode: LaunchMode.platformDefault,
                  );
                  if (launched2) {
                    if (kDebugMode) {
                      debugPrint('✅ Payment URL launched with platform default mode!');
                    }
                    return;
                  }
                } catch (e2) {
                  if (kDebugMode) {
                    debugPrint('❌ Platform default mode failed: $e2');
                  }
                }

                if (kDebugMode) {
                  debugPrint('❌ Could not launch URL');
                }
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isAmharic
                            ? 'ክፍያ ዩአርኤል ሊከፈት አልቻለም'
                            : isOromo
                                ? 'URL maallaqaa banamuu hin dandeenye'
                                : 'Cannot open payment URL',
                      ),
                      duration: const Duration(seconds: 5),
                    ),
                  );
                }
              }
            } catch (e) {
              if (kDebugMode) {
                debugPrint('❌ ERROR launching URL: $e');
              }
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isAmharic
                          ? 'ክፍያ ዩአርኤል ስህተት: ${e.toString()}'
                          : isOromo
                              ? 'Dogoggora URL maallaqaa: ${e.toString()}'
                              : 'Payment URL error: ${e.toString()}',
                    ),
                  ),
                );
              }
            }
          } else {
            // Checkout URL not found in response
            if (kDebugMode) {
              debugPrint('❌ Checkout URL not found in response');
            }

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isAmharic
                        ? 'የክፍያ ዩአርኤል አልተገኘም'
                        : isOromo
                            ? 'URL maallaqaa hin argamne'
                            : 'Payment URL not found in response',
                  ),
                  duration: const Duration(seconds: 5),
                ),
              );
            }
          }
        } else {
          // API call failed - show error message
          final errorMessage = result['error'] ??
              result['data']?['error'] ??
              result['data']?['details'] ??
              result['message'] ??
              'Payment initialization failed';

          if (kDebugMode) {
            debugPrint('❌ API call failed: $errorMessage');
          }

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  errorMessage.toString(),
                ),
                duration: const Duration(seconds: 5),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('💥 EXCEPTION: ${e.runtimeType} - $e');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isAmharic = languageProvider.currentLanguage == 'am';
    final isOromo = languageProvider.currentLanguage == 'or';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isAmharic
              ? 'ልገሳ ያድርጉ'
              : isOromo
                  ? 'Kenneessaa'
                  : 'Make a Donation',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo - matching login screen style
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.primaryRed, width: 4),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/logo.jpg',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.favorite,
                            color: AppTheme.primaryRed,
                            size: 50,
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                isAmharic
                    ? 'የልገሳ መረጃ'
                    : isOromo
                        ? 'Odeeffannoo kenneessaa'
                        : 'Donation Information',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              // Name
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: isAmharic
                      ? 'ሙሉ ስም'
                      : isOromo
                          ? 'Maqaan guutuu'
                          : 'Full Name',
                  prefixIcon: const Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return isAmharic
                        ? 'ስም ያስገቡ'
                        : isOromo
                            ? 'Maqaa galchaa'
                            : 'Please enter name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Email
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: isAmharic
                      ? 'ኢሜይል'
                      : isOromo
                          ? 'Imeeli'
                          : 'Email',
                  prefixIcon: const Icon(Icons.email),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return isAmharic
                        ? 'ኢሜይል ያስገቡ'
                        : isOromo
                            ? 'Imeeli galchaa'
                            : 'Please enter email';
                  }
                  if (!value.contains('@')) {
                    return isAmharic
                        ? 'ትክክለኛ ኢሜይል ያስገቡ'
                        : isOromo
                            ? 'Imeeli sirrii galchaa'
                            : 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Phone
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: isAmharic
                      ? 'ስልክ'
                      : isOromo
                          ? 'Bilbila'
                          : 'Phone',
                  prefixIcon: const Icon(Icons.phone),
                  prefixText: '+251 ',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return isAmharic
                        ? 'ስልክ ያስገቡ'
                        : isOromo
                            ? 'Bilbila galchaa'
                            : 'Please enter phone';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Amount presets
              Text(
                isAmharic
                    ? 'የልገሳ መጠን (ብር)'
                    : isOromo
                        ? 'Lakkoofsi kenneessaa (Birr)'
                        : 'Donation Amount (ETB)',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _presetAmounts.map((amount) {
                  final isSelected = _selectedAmount == amount.toString();
                  return ChoiceChip(
                    label: Text('$amount ETB'),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedAmount = selected ? amount.toString() : null;
                        _amountController.text =
                            selected ? amount.toString() : '';
                      });
                    },
                    selectedColor: AppTheme.primaryRed,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              // Custom amount
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: isAmharic
                      ? 'ብዙ መጠን'
                      : isOromo
                          ? 'Lakkoofsa adda taasisaa'
                          : 'Custom Amount',
                  prefixIcon: const Icon(Icons.attach_money),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return isAmharic
                        ? 'መጠን ያስገቡ'
                        : isOromo
                            ? 'Lakkoofsi galchaa'
                            : 'Please enter amount';
                  }
                  if (double.tryParse(value) == null ||
                      double.parse(value) <= 0) {
                    return isAmharic
                        ? 'ትክክለኛ መጠን ያስገቡ'
                        : isOromo
                            ? 'Lakkoofsi sirrii galchaa'
                            : 'Please enter a valid amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Message
              TextFormField(
                controller: _messageController,
                decoration: InputDecoration(
                  labelText: isAmharic
                      ? 'መልእክት (አማራጭ)'
                      : isOromo
                          ? 'Ergaa (kan fudhatan)'
                          : 'Message (Optional)',
                  prefixIcon: const Icon(Icons.message),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              // Donate button
              ElevatedButton(
                onPressed: _isLoading ? null : _handleDonate,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : Text(
                        isAmharic
                            ? 'ወደ ክፍያ ይቀጥሉ'
                            : isOromo
                                ? 'Maallaqa itti fufi'
                                : 'Continue to Payment',
                        style: const TextStyle(fontSize: 16),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
