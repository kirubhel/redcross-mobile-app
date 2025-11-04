import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../services/api_service.dart';
import '../config/api_config.dart';
import '../utils/app_theme.dart';

class HubRequestScreen extends StatefulWidget {
  const HubRequestScreen({super.key});

  @override
  State<HubRequestScreen> createState() => _HubRequestScreenState();
}

class _HubRequestScreenState extends State<HubRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  int _step = 1; // 1: Hub Info, 2: Request Details
  bool _isLoading = false;
  String? _message;

  // Step 1: Hub Information
  final _organizationController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Step 2: Request Details
  final _titleController = TextEditingController();
  String _category = 'community';
  int _numberOfVolunteers = 1;
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _cityController = TextEditingController();
  final _regionController = TextEditingController();
  final _addressController = TextEditingController();
  String _priority = 'medium';
  String _genderPreference = 'any';
  final _ageMinController = TextEditingController();
  final _ageMaxController = TextEditingController();
  final _experienceController = TextEditingController();
  List<String> _requiredSkills = [];
  final _skillController = TextEditingController();

  @override
  void dispose() {
    _organizationController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _descriptionController.dispose();
    _titleController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _cityController.dispose();
    _regionController.dispose();
    _addressController.dispose();
    _ageMinController.dispose();
    _ageMaxController.dispose();
    _experienceController.dispose();
    _skillController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_step == 1) {
      if (!_formKey.currentState!.validate()) return;
      setState(() => _step = 2);
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      final hubData = {
        'name': _organizationController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'contactPerson': {
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'phone': _phoneController.text.trim(),
        },
        'description': _descriptionController.text.trim(),
        'organizationType': 'other',
        'status': 'pending',
      };

      final requestData = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'category': _category,
        'numberOfVolunteers': _numberOfVolunteers,
        'requiredSkills': _requiredSkills,
        'criteria': {
          if (_ageMinController.text.isNotEmpty)
            'ageMin': int.parse(_ageMinController.text),
          if (_ageMaxController.text.isNotEmpty)
            'ageMax': int.parse(_ageMaxController.text),
          'gender': _genderPreference,
          if (_experienceController.text.isNotEmpty)
            'experience': double.parse(_experienceController.text),
          'qualifications': [],
          'languages': [],
        },
        'location': {
          'city': _cityController.text.trim(),
          'region': _regionController.text.trim(),
          'address': _addressController.text.trim(),
        },
        if (_startDateController.text.isNotEmpty)
          'startDate': _startDateController.text,
        if (_endDateController.text.isNotEmpty)
          'endDate': _endDateController.text,
        'priority': _priority,
      };

      final result = await ApiService.post(
        '${ApiConfig.hubsUrl}/register-with-request',
        {
          'hubData': hubData,
          'requestData': requestData,
        },
      );

      if (result['success'] == true && mounted) {
        setState(() {
          _message = 'Request submitted successfully!';
          _isLoading = false;
        });
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) Navigator.of(context).pop();
        });
      } else {
        setState(() {
          _message = result['error'] ?? 'Submission failed';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _message = 'Error: $e';
        _isLoading = false;
      });
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
              ? 'የማዕከል በፈቃደኛ ጥያቄ'
              : isOromo
                  ? 'Hub hawaasa barbaachisu'
                  : 'Hub Volunteer Request',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Step Indicator
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color:
                            _step == 1 ? AppTheme.primaryRed : Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isAmharic
                            ? '1. የማዕከል መረጃ'
                            : isOromo
                                ? '1. Hub odeeffannoo'
                                : '1. Hub Information',
                        style: TextStyle(
                          color: _step == 1 ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color:
                            _step == 2 ? AppTheme.primaryRed : Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isAmharic
                            ? '2. የጥያቄ ዝርዝሮች'
                            : isOromo
                                ? '2. Gaaffii xiinxala'
                                : '2. Request Details',
                        style: TextStyle(
                          color: _step == 2 ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              if (_step == 1) ...[
                // Step 1: Hub Information
                Text(
                  isAmharic
                      ? 'የድርጅት መረጃ'
                      : isOromo
                          ? 'Odeeffannoo dhaabbataa'
                          : 'Organization Information',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _organizationController,
                  decoration: InputDecoration(
                    labelText: isAmharic
                        ? 'የድርጅት ስም'
                        : isOromo
                            ? 'Maqaa dhaabbataa'
                            : 'Organization Name',
                    prefixIcon: const Icon(Icons.business),
                  ),
                  validator: (value) => value?.isEmpty ?? true
                      ? 'Organization name is required'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: isAmharic
                        ? 'የግንኙነት ሰው'
                        : isOromo
                            ? 'Nama qunnamsiisa'
                            : 'Contact Person',
                    prefixIcon: const Icon(Icons.person),
                  ),
                  validator: (value) => value?.isEmpty ?? true
                      ? 'Contact person is required'
                      : null,
                ),
                const SizedBox(height: 16),
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
                    if (value == null || value.isEmpty)
                      return 'Email is required';
                    if (!value.contains('@'))
                      return 'Please enter a valid email';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
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
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Phone is required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: isAmharic
                        ? 'የድርጅት መግለጫ'
                        : isOromo
                            ? 'Ibsa dhaabbataa'
                            : 'Organization Description',
                  ),
                ),
              ] else ...[
                // Step 2: Request Details
                Text(
                  isAmharic
                      ? 'የበፈቃደኛ ጥያቄ ዝርዝሮች'
                      : isOromo
                          ? 'Gaaffii hawaasa xiinxala'
                          : 'Volunteer Request Details',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: isAmharic
                        ? 'የጥያቄ ርዕስ'
                        : isOromo
                            ? 'Mataa gaaffii'
                            : 'Request Title',
                    prefixIcon: const Icon(Icons.title),
                  ),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Title is required' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _category,
                  decoration: InputDecoration(
                    labelText: isAmharic
                        ? 'ዓይነት'
                        : isOromo
                            ? 'Gosa'
                            : 'Category',
                    prefixIcon: const Icon(Icons.category),
                  ),
                  items: [
                    DropdownMenuItem(
                        value: 'health',
                        child: Text(isAmharic
                            ? 'ጤና'
                            : isOromo
                                ? 'Fayyaa'
                                : 'Health')),
                    DropdownMenuItem(
                        value: 'education',
                        child: Text(isAmharic
                            ? 'ትምህርት'
                            : isOromo
                                ? 'Barumsa'
                                : 'Education')),
                    DropdownMenuItem(
                        value: 'disaster',
                        child: Text(isAmharic
                            ? 'የአደጋ ምላሽ'
                            : isOromo
                                ? 'Deebii balaa'
                                : 'Disaster Response')),
                    DropdownMenuItem(
                        value: 'community',
                        child: Text(isAmharic
                            ? 'ማህበረሰብ'
                            : isOromo
                                ? 'Hawaasa'
                                : 'Community')),
                    DropdownMenuItem(
                        value: 'technology',
                        child: Text(isAmharic
                            ? 'ቴክኖሎጂ'
                            : isOromo
                                ? 'Teknooloojii'
                                : 'Technology')),
                    DropdownMenuItem(
                        value: 'other',
                        child: Text(isAmharic
                            ? 'ሌላ'
                            : isOromo
                                ? 'Kan biraa'
                                : 'Other')),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => _category = value);
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: TextEditingController(
                      text: _numberOfVolunteers.toString()),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: isAmharic
                        ? 'የሚፈለጉ በፈቃደኛዎች ብዛት'
                        : isOromo
                            ? 'Lakkoofsi hawaasa barbaachisan'
                            : 'Number of Volunteers Needed',
                    prefixIcon: const Icon(Icons.people),
                  ),
                  onChanged: (value) {
                    setState(
                        () => _numberOfVolunteers = int.tryParse(value) ?? 1);
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _startDateController,
                        decoration: InputDecoration(
                          labelText: isAmharic
                              ? 'የመጀመሪያ ቀን'
                              : isOromo
                                  ? 'Guyyaa jalqaba'
                                  : 'Start Date',
                          suffixIcon: const Icon(Icons.calendar_today),
                        ),
                        readOnly: true,
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate:
                                DateTime.now().add(const Duration(days: 365)),
                          );
                          if (date != null) {
                            _startDateController.text =
                                date.toIso8601String().split('T')[0];
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _endDateController,
                        decoration: InputDecoration(
                          labelText: isAmharic
                              ? 'የመጨረሻ ቀን'
                              : isOromo
                                  ? 'Guyyaa xumura'
                                  : 'End Date',
                          suffixIcon: const Icon(Icons.calendar_today),
                        ),
                        readOnly: true,
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate:
                                DateTime.now().add(const Duration(days: 365)),
                          );
                          if (date != null) {
                            _endDateController.text =
                                date.toIso8601String().split('T')[0];
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _cityController,
                  decoration: InputDecoration(
                    labelText: isAmharic
                        ? 'ከተማ'
                        : isOromo
                            ? 'Magaalaa'
                            : 'City',
                    prefixIcon: const Icon(Icons.location_city),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _regionController,
                  decoration: InputDecoration(
                    labelText: isAmharic
                        ? 'ክልል'
                        : isOromo
                            ? 'Naannoo'
                            : 'Region',
                    prefixIcon: const Icon(Icons.map),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _priority,
                  decoration: InputDecoration(
                    labelText: isAmharic
                        ? 'ቅድሚያ'
                        : isOromo
                            ? 'Fo\'annoo'
                            : 'Priority',
                    prefixIcon: const Icon(Icons.priority_high),
                  ),
                  items: [
                    DropdownMenuItem(
                        value: 'low',
                        child: Text(isAmharic
                            ? 'ዝቅተኛ'
                            : isOromo
                                ? 'Gadi'
                                : 'Low')),
                    DropdownMenuItem(
                        value: 'medium',
                        child: Text(isAmharic
                            ? 'መካከለኛ'
                            : isOromo
                                ? 'Gidduu'
                                : 'Medium')),
                    DropdownMenuItem(
                        value: 'high',
                        child: Text(isAmharic
                            ? 'ከፍተኛ'
                            : isOromo
                                ? 'Olgura'
                                : 'High')),
                    DropdownMenuItem(
                        value: 'urgent',
                        child: Text(isAmharic
                            ? 'አስቸኳይ'
                            : isOromo
                                ? 'Gahaa'
                                : 'Urgent')),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => _priority = value);
                  },
                ),
                const SizedBox(height: 16),
                // Required Skills
                Text(
                  isAmharic
                      ? 'የሚያስፈልጉ ክህሎቶች'
                      : isOromo
                          ? 'Ogummaa barbaachisan'
                          : 'Required Skills',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _skillController,
                        decoration: InputDecoration(
                          hintText: isAmharic
                              ? 'ክህሎት ያክሉ'
                              : isOromo
                                  ? 'Ogummaa dabaluu'
                                  : 'Add skill',
                        ),
                        onFieldSubmitted: (value) {
                          if (value.trim().isNotEmpty) {
                            setState(() {
                              _requiredSkills.add(value.trim());
                              _skillController.clear();
                            });
                          }
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        if (_skillController.text.trim().isNotEmpty) {
                          setState(() {
                            _requiredSkills.add(_skillController.text.trim());
                            _skillController.clear();
                          });
                        }
                      },
                    ),
                  ],
                ),
                if (_requiredSkills.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: _requiredSkills.map((skill) {
                      return Chip(
                        label: Text(skill),
                        onDeleted: () {
                          setState(() => _requiredSkills.remove(skill));
                        },
                        deleteIcon: const Icon(Icons.close, size: 18),
                      );
                    }).toList(),
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _ageMinController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: isAmharic
                              ? 'አነስተኛ ዕድሜ'
                              : isOromo
                                  ? 'Umurii gadi fagoo'
                                  : 'Min Age',
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _ageMaxController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: isAmharic
                              ? 'ከፍተኛ ዕድሜ'
                              : isOromo
                                  ? 'Umurii ol\'aanaa'
                                  : 'Max Age',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _genderPreference,
                  decoration: InputDecoration(
                    labelText: isAmharic
                        ? 'የጾታ ምርጫ'
                        : isOromo
                            ? 'Filannoo saalaa'
                            : 'Gender Preference',
                    prefixIcon: const Icon(Icons.person_outline),
                  ),
                  items: [
                    DropdownMenuItem(
                        value: 'any',
                        child: Text(isAmharic
                            ? 'ማንኛውም'
                            : isOromo
                                ? 'Hunda'
                                : 'Any')),
                    DropdownMenuItem(
                        value: 'male',
                        child: Text(isAmharic
                            ? 'ወንድ'
                            : isOromo
                                ? 'Dhiira'
                                : 'Male')),
                    DropdownMenuItem(
                        value: 'female',
                        child: Text(isAmharic
                            ? 'ሴት'
                            : isOromo
                                ? 'Dhalaa'
                                : 'Female')),
                  ],
                  onChanged: (value) {
                    if (value != null)
                      setState(() => _genderPreference = value);
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _experienceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: isAmharic
                        ? 'የልምድ (አመታት)'
                        : isOromo
                            ? 'Kakkaba (waggaa)'
                            : 'Experience (years)',
                    prefixIcon: const Icon(Icons.work_history),
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Navigation Buttons
              Row(
                children: [
                  if (_step == 2)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => setState(() => _step = 1),
                        child: Text(isAmharic
                            ? 'ወደኋላ'
                            : isOromo
                                ? 'Deebi\'i'
                                : 'Back'),
                      ),
                    ),
                  if (_step == 2) const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleSubmit,
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : Text(
                              _step == 1
                                  ? (isAmharic
                                      ? 'ቀጣይ →'
                                      : isOromo
                                          ? 'Kan itti aanu →'
                                          : 'Next →')
                                  : (isAmharic
                                      ? 'ጥያቄ ላክ'
                                      : isOromo
                                          ? 'Gaaffii ergi'
                                          : 'Submit Request'),
                            ),
                    ),
                  ),
                ],
              ),

              if (_message != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _message!.contains('success')
                        ? Colors.green[50]
                        : Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _message!.contains('success')
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                  child: Text(
                    _message!,
                    style: TextStyle(
                      color: _message!.contains('success')
                          ? Colors.green[900]
                          : Colors.red[900],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
