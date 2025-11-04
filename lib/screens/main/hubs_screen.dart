import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../config/api_config.dart';

class HubsScreen extends StatefulWidget {
  const HubsScreen({super.key});

  @override
  State<HubsScreen> createState() => _HubsScreenState();
}

class _HubsScreenState extends State<HubsScreen> {
  List<dynamic> _hubs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHubs();
  }

  Future<void> _loadHubs() async {
    try {
      final result = await ApiService.get(ApiConfig.hubsUrl);
      if (result['success'] == true && mounted) {
        setState(() {
          _hubs = result['data']['items'] ?? [];
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
      onRefresh: _loadHubs,
      child: _hubs.isEmpty
          ? const Center(child: Text('No hubs found'))
          : ListView.builder(
              itemCount: _hubs.length,
              itemBuilder: (context, index) {
                final hub = _hubs[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(hub['name'] ?? 'Unnamed Hub'),
                    subtitle: Text(hub['location'] ?? ''),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  ),
                );
              },
            ),
    );
  }
}

