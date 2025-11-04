import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';
import '../../services/api_service.dart';
import '../../config/api_config.dart';
import '../../models/form_field.dart' as custom;
import '../../utils/app_theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _isLoadingFields = true;
  String _selectedRole = 'volunteer';
  String? _selectedMembershipTypeId;

  List<custom.CustomFormField> _dynamicFields = [];
  List<dynamic> _membershipTypes = [];
  Map<String, dynamic> _dynamicFieldValues = {};
  Map<String, TextEditingController> _fieldControllers = {};

  @override
  void initState() {
    super.initState();
    _loadDynamicFields();
    _loadMembershipTypes();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _fieldControllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  Future<void> _loadMembershipTypes() async {
    try {
      final result = await ApiService.get(ApiConfig.membershipTypesUrl);
      if (result['success'] == true && mounted) {
        setState(() {
          _membershipTypes = result['data']['items'] ?? [];
        });
      }
    } catch (e) {
      // Ignore errors
    }
  }

  Future<void> _loadDynamicFields() async {
    try {
      setState(() => _isLoadingFields = true);

      final result = await ApiService.get(
        '${ApiConfig.formFieldsUrl}/${_selectedRole}',
      );

      if (result['success'] == true && mounted) {
        final fields = (result['data'] as List)
            .map((f) => custom.CustomFormField.fromJson(f))
            .where((f) => f.isActive)
            .toList();

        // Initialize controllers and values
        final newControllers = <String, TextEditingController>{};
        final newValues = <String, dynamic>{};

        for (final field in fields) {
          if (!_fieldControllers.containsKey(field.fieldKey)) {
            newControllers[field.fieldKey] = TextEditingController(
              text: field.defaultValue?.toString() ?? '',
            );
            newValues[field.fieldKey] = field.defaultValue?.toString() ?? '';
          }
        }

        setState(() {
          _dynamicFields = fields;
          _fieldControllers.addAll(newControllers);
          _dynamicFieldValues.addAll(newValues);
          _isLoadingFields = false;
        });
      } else {
        setState(() => _isLoadingFields = false);
      }
    } catch (e) {
      setState(() => _isLoadingFields = false);
    }
  }

  void _onRoleChanged(String? newRole) {
    if (newRole != null && newRole != _selectedRole) {
      // Dispose old controllers
      _fieldControllers.values.forEach((controller) => controller.dispose());
      _fieldControllers.clear();
      _dynamicFieldValues.clear();

      setState(() {
        _selectedRole = newRole;
        _selectedMembershipTypeId = null;
      });

      _loadDynamicFields();
    }
  }

  Widget _buildField(custom.CustomFormField field) {
    final controller = _fieldControllers[field.fieldKey] ??
        TextEditingController(
            text: _dynamicFieldValues[field.fieldKey]?.toString() ?? '');

    if (!_fieldControllers.containsKey(field.fieldKey)) {
      _fieldControllers[field.fieldKey] = controller;
    }

    switch (field.fieldType) {
      case 'textarea':
        return TextFormField(
          controller: controller,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: field.label,
            hintText: field.placeholder,
            helperText: field.description,
          ),
          validator: field.required
              ? (value) =>
                  value?.isEmpty ?? true ? '${field.label} is required' : null
              : null,
          onChanged: (value) {
            _dynamicFieldValues[field.fieldKey] = value;
          },
        );

      case 'select':
        return DropdownButtonFormField<String>(
          value: _dynamicFieldValues[field.fieldKey]?.toString(),
          decoration: InputDecoration(
            labelText: field.label,
            helperText: field.description,
          ),
          items: [
            DropdownMenuItem(
                value: '', child: Text(field.placeholder ?? 'Select...')),
            ...?field.options?.map((opt) => DropdownMenuItem(
                  value: opt['value'] ?? '',
                  child: Text(opt['label'] ?? ''),
                )),
          ],
          onChanged: (value) {
            setState(() {
              _dynamicFieldValues[field.fieldKey] = value;
            });
          },
          validator: field.required
              ? (value) => value == null || value.isEmpty
                  ? '${field.label} is required'
                  : null
              : null,
        );

      case 'checkbox':
        return CheckboxListTile(
          title: Text(field.label),
          subtitle: field.description != null ? Text(field.description!) : null,
          value: _dynamicFieldValues[field.fieldKey] == true ||
              _dynamicFieldValues[field.fieldKey] == 'true',
          onChanged: (value) {
            setState(() {
              _dynamicFieldValues[field.fieldKey] = value ?? false;
            });
          },
        );

      case 'date':
        return TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: field.label,
            hintText: field.placeholder,
            helperText: field.description,
            suffixIcon: const Icon(Icons.calendar_today),
          ),
          readOnly: true,
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
            );
            if (date != null) {
              controller.text = date.toIso8601String().split('T')[0];
              _dynamicFieldValues[field.fieldKey] =
                  date.toIso8601String().split('T')[0];
            }
          },
          validator: field.required
              ? (value) =>
                  value?.isEmpty ?? true ? '${field.label} is required' : null
              : null,
        );

      case 'number':
        return TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: field.label,
            hintText: field.placeholder,
            helperText: field.description,
          ),
          validator: field.required
              ? (value) =>
                  value?.isEmpty ?? true ? '${field.label} is required' : null
              : null,
          onChanged: (value) {
            _dynamicFieldValues[field.fieldKey] = value;
          },
        );

      case 'email':
        return TextFormField(
          controller: controller,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: field.label,
            hintText: field.placeholder,
            helperText: field.description,
            prefixIcon: const Icon(Icons.email),
          ),
          validator: field.required
              ? (value) {
                  if (value == null || value.isEmpty) {
                    return '${field.label} is required';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                }
              : null,
          onChanged: (value) {
            _dynamicFieldValues[field.fieldKey] = value;
          },
        );

      case 'tel':
        return TextFormField(
          controller: controller,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            labelText: field.label,
            hintText: field.placeholder,
            helperText: field.description,
            prefixIcon: const Icon(Icons.phone),
          ),
          validator: field.required
              ? (value) =>
                  value?.isEmpty ?? true ? '${field.label} is required' : null
              : null,
          onChanged: (value) {
            _dynamicFieldValues[field.fieldKey] = value;
          },
        );

      default:
        return TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: field.label,
            hintText: field.placeholder,
            helperText: field.description,
          ),
          validator: field.required
              ? (value) =>
                  value?.isEmpty ?? true ? '${field.label} is required' : null
              : null,
          onChanged: (value) {
            _dynamicFieldValues[field.fieldKey] = value;
          },
        );
    }
  }

  Map<String, dynamic> _groupFieldsBySection() {
    final grouped = <String, List<custom.CustomFormField>>{};
    for (final field in _dynamicFields) {
      final section = field.section ?? 'General';
      grouped.putIfAbsent(section, () => []).add(field);
    }
    return grouped;
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);
    final isAmharic = languageProvider.currentLanguage == 'am';
    final isOromo = languageProvider.currentLanguage == 'or';

    if (_selectedRole == 'member' && _selectedMembershipTypeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isAmharic
                ? 'እባክዎ የአባልነት አይነት ይምረጡ'
                : isOromo
                    ? 'Gosa hirmaata filadhu'
                    : 'Please select a membership type',
          ),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final formData = {
      'name': _nameController.text.trim(),
      'email': _emailController.text.trim(),
      'phone': _phoneController.text.trim(),
      'password': _passwordController.text,
      'role': _selectedRole,
      if (_selectedMembershipTypeId != null)
        'membershipTypeId': _selectedMembershipTypeId,
      ..._dynamicFieldValues,
    };

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.register(formData);

    if (success && mounted) {
      // If member, initiate payment after registration (matching client behavior)
      if (_selectedRole == 'member' && _selectedMembershipTypeId != null) {
        try {
          final selectedMembershipType = _membershipTypes.firstWhere(
            (type) =>
                type['_id'] == _selectedMembershipTypeId ||
                type['id'] == _selectedMembershipTypeId,
          );

          // Convert phone for payment format - match client logic
          // formData.phone.replace(/\+251\s?/, '').replace(/\s/g, '').replace(/^9/, '09')
          String phoneForPayment = _phoneController.text
              .replaceAll(
                  RegExp(r'\+251\s?'), '') // Remove +251 with optional space
              .replaceAll(' ', '') // Remove all spaces
              .trim();

          // Ensure phone starts with 0: if it starts with 9, replace with 09
          // If it doesn't start with 0 or 9, add 0 prefix
          if (phoneForPayment.isNotEmpty) {
            if (phoneForPayment.startsWith('9')) {
              phoneForPayment = '0$phoneForPayment';
            } else if (!phoneForPayment.startsWith('0')) {
              phoneForPayment = '0$phoneForPayment';
            }
          }

          final paymentResult = await ApiService.post(
            '${ApiConfig.paymentsUrl}/membership',
            {
              'membershipTypeId': _selectedMembershipTypeId,
              'amount': selectedMembershipType['amount'],
              'email': _emailController.text.trim(),
              'phone_number': phoneForPayment,
            },
          );

          // ApiService wraps response in 'data' field
          if (paymentResult['success'] == true &&
              paymentResult['data'] != null) {
            final responseData = paymentResult['data'];

            // Try multiple paths to get checkout URL
            final checkoutUrl = responseData['checkoutUrl'] ??
                responseData['response']?['data']?['checkout_url'] ??
                responseData['response']?['checkout_url'];

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
                  setState(() => _isLoading = false);
                  return; // Exit after redirecting to payment
                } else {
                  // Try with platform default mode as fallback
                  try {
                    final launched2 = await launchUrl(
                      uri,
                      mode: LaunchMode.platformDefault,
                    );
                    if (launched2) {
                      setState(() => _isLoading = false);
                      return;
                    }
                  } catch (e2) {
                    // Platform default also failed
                  }
                }
              } catch (launchError) {
                // URL launch failed - user is registered but payment failed
                if (kDebugMode) {
                  debugPrint('Error launching membership payment URL: $launchError');
                }
              }
            }
          }
        } catch (paymentError) {
          // User is registered but payment failed - they can pay later
          setState(() => _isLoading = false);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  isAmharic
                      ? 'በተሳካ ሁኔታ ተመዝግበዋል! የክፍያ ማምልከት አልተሳካም። ቆይቶ ሊክፈሉ ይችላሉ።'
                      : isOromo
                          ? 'Galmeessuu milkaa\'eera! Maallaqa qajoo hin milkaa\'e. Achiinii maallaqa kennuu ni danda\'a.'
                          : 'Registration successful! Payment initialization failed. You can pay later.',
                ),
              ),
            );
            Navigator.of(context).pop();
          }
          return;
        }
      }

      // For volunteers or if payment succeeds/not needed
      setState(() => _isLoading = false);
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isAmharic
                  ? 'በተሳካ ሁኔታ ተመዝግበዋል!'
                  : isOromo
                      ? 'Galmeessuu milkaa\'eera!'
                      : 'Registration successful!',
            ),
          ),
        );
      }
    } else {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isAmharic
                  ? 'ምዝገባ አልተሳካም። እባክዎ ይሞክሩ።'
                  : isOromo
                      ? 'Galmeessuu hin milkaa\'e. Mee yaali.'
                      : 'Registration failed. Please try again.',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isAmharic = languageProvider.currentLanguage == 'am';
    final isOromo = languageProvider.currentLanguage == 'or';

    final groupedFields = _groupFieldsBySection();

    return Scaffold(
      appBar: AppBar(
        title: Text(isAmharic
            ? 'ይመዝግቡ'
            : isOromo
                ? 'Galmeessi'
                : 'Register'),
      ),
      body: SafeArea(
        child: _isLoadingFields
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        isAmharic
                            ? 'አዲስ መለያ ይፍጠሩ'
                            : isOromo
                                ? 'Akkaawuntii haaraa hundeessi'
                                : 'Create New Account',
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 24),
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
                      // Role selection
                      DropdownButtonFormField<String>(
                        value: _selectedRole,
                        decoration: InputDecoration(
                          labelText: isAmharic
                              ? 'ተግባር'
                              : isOromo
                                  ? 'Hojii'
                                  : 'Role',
                          prefixIcon: const Icon(Icons.work),
                        ),
                        items: [
                          DropdownMenuItem(
                            value: 'volunteer',
                            child: Text(isAmharic
                                ? 'በፈቃደኛ'
                                : isOromo
                                    ? 'Hawwaasa'
                                    : 'Volunteer'),
                          ),
                          DropdownMenuItem(
                            value: 'member',
                            child: Text(isAmharic
                                ? 'አባል'
                                : isOromo
                                    ? 'Manguddoo'
                                    : 'Member'),
                          ),
                        ],
                        onChanged: _onRoleChanged,
                      ),
                      const SizedBox(height: 16),
                      // Membership Type (for members)
                      if (_selectedRole == 'member' &&
                          _membershipTypes.isNotEmpty) ...[
                        Text(
                          isAmharic
                              ? 'የአባልነት አይነት'
                              : isOromo
                                  ? 'Gosa maatii'
                                  : 'Membership Type',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        ..._membershipTypes.map((type) {
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: RadioListTile<String>(
                              title: Text(type['name'] ?? ''),
                              subtitle: Text(
                                '${type['amount'] ?? 0} ETB',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryRed,
                                ),
                              ),
                              value: type['_id'] ?? type['id'] ?? '',
                              groupValue: _selectedMembershipTypeId,
                              onChanged: (value) {
                                setState(
                                    () => _selectedMembershipTypeId = value);
                              },
                            ),
                          );
                        }),
                        const SizedBox(height: 16),
                      ],
                      // Password
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: isAmharic
                              ? 'የይለፍ ቃል'
                              : isOromo
                                  ? 'Iggita'
                                  : 'Password',
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword
                                ? Icons.visibility
                                : Icons.visibility_off),
                            onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return isAmharic
                                ? 'የይለፍ ቃል ያስገቡ'
                                : isOromo
                                    ? 'Iggita galchaa'
                                    : 'Please enter password';
                          }
                          if (value.length < 6) {
                            return isAmharic
                                ? 'የይለፍ ቃል ቢያንስ 6 ቁምፊዎች ይሁን'
                                : isOromo
                                    ? 'Iggita yoo xinnaan 6 dha'
                                    : 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      // Dynamic Fields
                      ...groupedFields.entries.map((entry) {
                        final section = entry.key;
                        final fields = entry.value;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (section != 'General') ...[
                              const SizedBox(height: 24),
                              Text(
                                section,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                            ],
                            ...fields.map((field) => Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: _buildField(field),
                                )),
                          ],
                        );
                      }),
                      const SizedBox(height: 24),
                      // Register button
                      ElevatedButton(
                        onPressed: _isLoading ? null : _handleRegister,
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
                                    ? 'ይመዝግቡ'
                                    : isOromo
                                        ? 'Galmeessi'
                                        : 'Register',
                                style: const TextStyle(fontSize: 16),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
