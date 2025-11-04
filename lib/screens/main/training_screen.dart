import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../config/api_config.dart';

class TrainingScreen extends StatefulWidget {
  const TrainingScreen({super.key});

  @override
  State<TrainingScreen> createState() => _TrainingScreenState();
}

class _TrainingScreenState extends State<TrainingScreen> {
  List<dynamic> _trainings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTrainings();
  }

  Future<void> _loadTrainings() async {
    try {
      final result = await ApiService.get(ApiConfig.trainingUrl);
      if (result['success'] == true && mounted) {
        setState(() {
          _trainings = result['data']['items'] ?? [];
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
      onRefresh: _loadTrainings,
      child: _trainings.isEmpty
          ? const Center(child: Text('No trainings found'))
          : ListView.builder(
              itemCount: _trainings.length,
              itemBuilder: (context, index) {
                final training = _trainings[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(training['title'] ?? 'Untitled Training'),
                    subtitle: Text(training['description'] ?? ''),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  ),
                );
              },
            ),
    );
  }
}

