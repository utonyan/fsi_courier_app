import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'dart:convert';
import '../scan_barcode/components/barcode_input.dart';
import '../scan_barcode/components/scan_overlay.dart';
import '../scan_barcode/components/confirm_barcode_dialog.dart';
import '../scan_barcode/components/scan_page_header.dart';
import '../Delivery_Details/delivery_details_page.dart';
import '../Dashboard/model/delivery_model.dart';
import 'package:http/http.dart' as http;

class ScanPackageBarcodePage extends StatefulWidget {
  const ScanPackageBarcodePage({super.key});

  @override
  State<ScanPackageBarcodePage> createState() => _ScanPackageBarcodePageState();
}

class _ScanPackageBarcodePageState extends State<ScanPackageBarcodePage>
    with SingleTickerProviderStateMixin {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  bool _isDialogOpen = false;
  bool _pauseDetection = false;
  bool _torchOn = false;
  String? _pendingBarcode;

  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) async {
    if (_pauseDetection || _isDialogOpen) return;

    final barcode = capture.barcodes.first.rawValue;
    if (barcode == null) return;

    setState(() {
      _pauseDetection = true;
      _isDialogOpen = true;
      _pendingBarcode = barcode;
    });
  }

  void _closeDialog() {
    setState(() {
      _isDialogOpen = false;
      _pauseDetection = false;
      _pendingBarcode = null;
    });
  }

  // ONLINE API
  void _acceptBarcode() async {
    if (_pendingBarcode == null) return;

    const bool isEmulator = true; // change to false if testing on real device
    final String baseUrl = isEmulator
        ? 'http://10.0.2.2:8001/api' // Android Emulator
        : 'http://10.10.10.198:8001/api'; // Your local PC IP (real device)

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/deliveries/${_pendingBarcode!}'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final delivery = Delivery.fromJson(data);

        _closeDialog();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DeliveryDetailsPage(delivery: delivery),
          ),
        );
      } else if (response.statusCode == 404) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("No delivery found for barcode $_pendingBarcode"),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Future.delayed(const Duration(milliseconds: 300), _closeDialog);
      } else {
        throw Exception("Unexpected status: ${response.statusCode}");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error connecting to server: $e"),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Future.delayed(const Duration(milliseconds: 300), _closeDialog);
    }
  }
  // lOCAL
  // void _acceptBarcode() async {
  // if (_pendingBarcode == null) return;

  // // Load deliveries from JSON (same as in DeliveriesSection)
  // final String response = await rootBundle.loadString(
  //   'assets/data/deliveries.json',
  // );
  // final List data = json.decode(response);
  // final List deliveries = data.map((e) => Delivery.fromJson(e)).toList();

  // // Find delivery with matching barcode
  // final delivery = deliveries.firstWhere(
  //   (d) => d.barcodeValue == _pendingBarcode,
  //   orElse: () => null,
  // );

  void _toggleFlash() async {
    await _controller.toggleTorch();
    setState(() => _torchOn = !_torchOn);
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    // 👇 Detect if keyboard is open
    final bool isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    // 👇 Pause detection (but keep camera running)
    if (isKeyboardOpen && !_pauseDetection) {
      _pauseDetection = true;
    } else if (!isKeyboardOpen && _pauseDetection && !_isDialogOpen) {
      _pauseDetection = false;
    }

    return WillPopScope(
      onWillPop: () async {
        if (isKeyboardOpen) {
          // 👇 Hide keyboard instead of popping page
          FocusScope.of(context).unfocus();
          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar: ScanPageHeader(
          torchOn: _torchOn,
          onBack: () async {
            if (isKeyboardOpen) {
              FocusScope.of(context).unfocus();
            } else {
              Navigator.pop(context);
            }
          },
          onToggleFlash: _toggleFlash,
          title: "Scan Barcode",
        ),
        body: Stack(
          children: [
            /// 📷 Camera feed
            MobileScanner(
              controller: _controller,
              onDetect: (capture) {
                if (!_pauseDetection) _onDetect(capture);
              },
              fit: BoxFit.cover,
            ),

            /// 🎯 Overlay box and scanning animation (hidden when keyboard active)
            if (!isKeyboardOpen)
              ScannerOverlay(animation: _animationController),

            /// ✍️ Manual input (hidden in landscape)
            if (!isLandscape) const BarcodeInput(),

            /// 🧩 Reusable “Confirm Barcode” dialog
            if (_isDialogOpen && _pendingBarcode != null)
              ConfirmBarcodeDialog(
                barcode: _pendingBarcode!,
                isLandscape: isLandscape,
                onCancel: _closeDialog,
              ),
          ],
        ),
      ),
    );
  }
}
