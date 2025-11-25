import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../model/delivery_model.dart';
import '../components/delivery_card.dart'; // <-- your card

class DeliveriesSection extends StatefulWidget {
  const DeliveriesSection({super.key});

  @override
  State<DeliveriesSection> createState() => _DeliveriesSectionState();
}

class _DeliveriesSectionState extends State<DeliveriesSection> {
  final List<Delivery> _deliveries = [];
  final ScrollController _scrollController = ScrollController();

  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _fetchDeliveries();

    // Pagination listener
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_isLoading &&
          _hasMore) {
        _fetchDeliveries();
      }
    });
  }

  Future<void> _fetchDeliveries() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("auth_token") ?? "";

      final url = Uri.parse(
        "https://staging-gdtms-v2.skyward.com.ph/api/mbl/deliveries"
        "?active=true&per_page=10&page=$_currentPage",
      );

      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final List<dynamic> newData = decoded['data'];

        // Convert JSON → Delivery model
        List<Delivery> newDeliveries = newData
            .map((e) => Delivery.fromJson(e))
            .toList();

        setState(() {
          _deliveries.addAll(newDeliveries);
          _currentPage++;

          if (newDeliveries.length < 10) _hasMore = false;
        });
      } else {
        debugPrint("Failed: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error: $e");
    }

    setState(() => _isLoading = false);
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

    return ListView.builder(
      controller: _scrollController,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _deliveries.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _deliveries.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
            ),
          );
        }

        return DeliveryCard(delivery: _deliveries[index]);
      },
    );
  }
}
