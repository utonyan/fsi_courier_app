import 'package:flutter/material.dart';
import 'package:fsi_courier_app/view/scan_barcode/scan_barcode_page.dart';
import 'components/dashboard_header.dart';
import 'components/payout_card.dart';
import 'components/announcements.dart';
import 'components/deliveries_section.dart';
import 'components/dashboard_sidebar.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // Used to rebuild DeliveriesSection when refreshed
  Key _deliveriesKey = UniqueKey();

  Future<void> _refreshDashboard() async {
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      // Trigger a full reload of DeliveriesSection
      _deliveriesKey = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: const DashboardSidebar(),
      appBar: const DashboardHeader(),

      body: RefreshIndicator(
        onRefresh: _refreshDashboard,
        color: const Color(0xFF2E7D32),
        displacement: 30,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PayoutCard(),
              //const SizedBox(height: 16),
              //const SearchBarSection(),
              const SizedBox(height: 20),
              const AnnouncementsSection(),
              const SizedBox(height: 20),
              // 👇 Rebuild this widget when key changes
              DeliveriesSection(key: _deliveriesKey),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFFD2A679),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.qr_code_scanner),
        label: const Text(
          "Scan Barcode",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        onPressed: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => const ScanPackageBarcodePage(),
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
            ),
          );
        },
      ),
    );
  }
}
