import 'dart:developer';

import 'package:blackrock_go/controllers/meshtastic_node_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class QRScannerWidget extends StatelessWidget {
  const QRScannerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final MeshtasticNodeController meshtasticNodeController = Get.find();
    bool _detected = false;
    return MobileScanner(
      onDetect: (result) async {
        log(result.barcodes.first.rawValue ?? "NO QR");
        if (!_detected) {
          _detected = true;
          await meshtasticNodeController
              .configureChannels(result.barcodes.first.rawValue!);
          context.pop();
        }
      },
      onDetectError: (p0, p1) => log("Error: $p0"),
      overlayBuilder: (context, constraints) => Container(
        height: 70.w,
        width: 70.w,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.red,
            width: 2,
          ),
        ),
      ),
    );
  }
}
