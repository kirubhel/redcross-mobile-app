import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../config/api_config.dart';

class RecognitionScreen extends StatefulWidget {
  const RecognitionScreen({super.key});

  @override
  State<RecognitionScreen> createState() => _RecognitionScreenState();
}

class _RecognitionScreenState extends State<RecognitionScreen> {
  List<dynamic> _recognitions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecognitions();
  }

  Future<void> _loadRecognitions() async {
    try {
      final result = await ApiService.get(ApiConfig.recognitionUrl);
      if (result['success'] == true && mounted) {
        setState(() {
          _recognitions = result['data']['items'] ?? [];
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _loadRecognitions,
      child: _recognitions.isEmpty
          ? const Center(child: Text('No recognitions found'))
          : ListView.builder(
              itemCount: _recognitions.length,
              itemBuilder: (context, index) {
                final recognition = _recognitions[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: const Icon(Icons.emoji_events, color: Colors.amber),
                    title: Text(recognition['title'] ?? 'Untitled Recognition'),
                    subtitle: Text(recognition['description'] ?? ''),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  ),
                );
              },
            ),
    );
  }
}

