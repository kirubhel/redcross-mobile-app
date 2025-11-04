import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../config/api_config.dart';

class CommunicationScreen extends StatefulWidget {
  const CommunicationScreen({super.key});

  @override
  State<CommunicationScreen> createState() => _CommunicationScreenState();
}

class _CommunicationScreenState extends State<CommunicationScreen> {
  List<dynamic> _communications = [];
  bool _isLoading = true;
  bool _showForm = false;

  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _contentController = TextEditingController();
  String _selectedType = 'email';
  String _selectedRecipients = 'all';

  @override
  void initState() {
    super.initState();
    _loadCommunications();
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _loadCommunications() async {
    try {
      final result = await ApiService.get(ApiConfig.communicationUrl);
      if (result['success'] == true && mounted) {
        setState(() {
          _communications = result['data']['items'] ?? [];
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendCommunication() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final result = await ApiService.post(ApiConfig.communicationUrl, {
        'type': _selectedType,
        'subject': _subjectController.text.trim(),
        'content': _contentController.text.trim(),
        'recipients': {'type': _selectedRecipients},
      });

      if (result['success'] == true && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Communication sent successfully!')),
        );
        setState(() {
          _showForm = false;
          _subjectController.clear();
          _contentController.clear();
        });
        _loadCommunications();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['error'] ?? 'Failed to send')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mass Communication'),
        actions: [
          IconButton(
            icon: Icon(_showForm ? Icons.close : Icons.add),
            onPressed: () => setState(() => _showForm = !_showForm),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_showForm) ...[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              DropdownButtonFormField<String>(
                                value: _selectedType,
                                decoration: const InputDecoration(labelText: 'Channel'),
                                items: const [
                                  DropdownMenuItem(value: 'email', child: Text('Email')),
                                  DropdownMenuItem(value: 'sms', child: Text('SMS')),
                                ],
                                onChanged: (value) {
                                  if (value != null) setState(() => _selectedType = value);
                                },
                              ),
                              const SizedBox(height: 16),
                              DropdownButtonFormField<String>(
                                value: _selectedRecipients,
                                decoration: const InputDecoration(labelText: 'Recipients'),
                                items: const [
                                  DropdownMenuItem(value: 'all', child: Text('All Users')),
                                  DropdownMenuItem(value: 'volunteers', child: Text('Volunteers')),
                                  DropdownMenuItem(value: 'members', child: Text('Members')),
                                  DropdownMenuItem(value: 'hubs', child: Text('Hubs')),
                                ],
                                onChanged: (value) {
                                  if (value != null) setState(() => _selectedRecipients = value);
                                },
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _subjectController,
                                decoration: const InputDecoration(labelText: 'Subject'),
                                validator: (value) =>
                                    value?.isEmpty ?? true ? 'Please enter subject' : null,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _contentController,
                                decoration: const InputDecoration(labelText: 'Message'),
                                maxLines: 5,
                                validator: (value) =>
                                    value?.isEmpty ?? true ? 'Please enter message' : null,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _sendCommunication,
                                child: const Text('Send Communication'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  const Text(
                    'Communication History',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _communications.isEmpty
                      ? const Center(child: Text('No communications sent yet'))
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _communications.length,
                          itemBuilder: (context, index) {
                            final comm = _communications[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                title: Text(comm['subject'] ?? 'No Subject'),
                                subtitle: Text(comm['content'] ?? ''),
                                trailing: Text(comm['status'] ?? ''),
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
    );
  }
}

