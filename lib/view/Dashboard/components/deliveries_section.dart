import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../model/delivery_model.dart';
import '../components/delivery_card.dart';

class DeliveriesSection extends StatefulWidget {
  const DeliveriesSection({super.key});

  @override
  State<DeliveriesSection> createState() => _DeliveriesSectionState();
}

class _DeliveriesSectionState extends State<DeliveriesSection> {
  final List<Delivery> _deliveries = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _fetchDeliveries();
  }

  Future<void> _fetchDeliveries() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("auth_token") ?? "";

      final url = Uri.parse(
        "https://staging-gdtms-v2.skyward.com.ph/api/mbl/deliveries"
        "?active=true&per_page=5&page=$_currentPage",
      );

      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final List<dynamic> newData = decoded['data'];

        List<Delivery> newDeliveries = newData
            .map((e) => Delivery.fromJson(e))
            .toList();

        setState(() {
          _deliveries.clear();
          _deliveries.addAll(newDeliveries);
          _hasMore = newDeliveries.length == 5;
        });
      } else {
        debugPrint("Failed: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error: $e");
    }

    setState(() => _isLoading = false);
  }

  void _previousPage() {
    if (_currentPage > 1) {
      setState(() => _currentPage--);
      _fetchDeliveries();
    }
  }

  void _nextPage() {
    if (_hasMore) {
      setState(() => _currentPage++);
      _fetchDeliveries();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_deliveries.isEmpty && _isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
      );
    }

    if (_deliveries.isEmpty) {
      return const Center(child: Text("No deliveries found."));
    }

    return Column(
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _deliveries.length,
          itemBuilder: (context, index) {
            return DeliveryCard(delivery: _deliveries[index]);
          },
        ),
        const SizedBox(height: 1),

        // ------------------------ IMPROVED CENTERED PAGINATION ------------------------
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 12.0,
          ), // aligns with card edges
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Previous Button
                GestureDetector(
                  onTap: _currentPage > 1 && !_isLoading ? _previousPage : null,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentPage > 1 && !_isLoading
                          ? Colors.green.shade50
                          : Colors.grey.shade200,
                    ),
                    child: Icon(
                      Icons.arrow_left,
                      color: _currentPage > 1 && !_isLoading
                          ? Colors.green
                          : Colors.grey,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Page Number
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: Text(
                    "$_currentPage",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.green,
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Next Button
                GestureDetector(
                  onTap: _hasMore && !_isLoading ? _nextPage : null,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _hasMore && !_isLoading
                          ? Colors.green.shade50
                          : Colors.grey.shade200,
                    ),
                    child: Icon(
                      Icons.arrow_right,
                      color: _hasMore && !_isLoading
                          ? Colors.green
                          : Colors.grey,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
