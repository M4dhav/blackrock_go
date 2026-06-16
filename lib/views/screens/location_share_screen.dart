import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../models/location_link.dart';
import '../../services/location_link_service.dart';

class LocationShareScreen extends StatelessWidget {
  const LocationShareScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: Obx(() {
                final service = Get.find<LocationLinkService>();
                if (service.activeLinks.isEmpty) {
                  return _EmptyState();
                }
                return _LinkList(links: service.activeLinks);
              }),
            ),
            _buildActions(context),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF4FC3F7)),
            onPressed: () => Get.back(),
          ),
          const Expanded(
            child: Text(
              'PLAYA LINKS',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Cinzel',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4FC3F7),
                letterSpacing: 4,
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: _ActionButton(
              label: 'Share My Location',
              icon: Icons.qr_code,
              color: const Color(0xFF4FC3F7),
              onTap: () => _showMyQr(context),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _ActionButton(
              label: 'Scan Someone\'s QR',
              icon: Icons.qr_code_scanner,
              color: const Color(0xFFD4A017),
              onTap: () => _showScanner(context),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: const Color(0xFF4FC3F7).withValues(alpha: 0.4),
            ),
            const SizedBox(height: 24),
            const Text(
              'No active links',
              style: TextStyle(
                fontFamily: 'Cinzel',
                fontSize: 18,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Share your location with someone you meet on the playa. Fully encrypted, automatically expires.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Cinzel',
                fontSize: 12,
                color: Color(0xFF555566),
                height: 1.7,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Link List ─────────────────────────────────────────────────────────────────

class _LinkList extends StatelessWidget {
  final RxList<LocationLink> links;
  const _LinkList({required this.links});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: links.length,
      itemBuilder: (_, i) => _LinkTile(link: links[i]),
    );
  }
}

class _LinkTile extends StatelessWidget {
  final LocationLink link;
  const _LinkTile({required this.link});

  @override
  Widget build(BuildContext context) {
    final remaining = link.remaining;
    final hrs = remaining.inHours;
    final mins = remaining.inMinutes % 60;
    final timeStr = hrs > 0 ? '${hrs}h ${mins}m left' : '${mins}m left';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A14),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: link.isActive
              ? const Color(0xFF4FC3F7).withValues(alpha: 0.3)
              : const Color(0xFF333344),
        ),
      ),
      child: Row(
        children: [
          _DirectionIcon(link: link),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  link.peerDisplayName ?? link.peerNodeId,
                  style: const TextStyle(
                    fontFamily: 'Cinzel',
                    fontSize: 15,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.timer_outlined, size: 12, color: Color(0xFF666677)),
                    const SizedBox(width: 4),
                    Text(
                      timeStr,
                      style: const TextStyle(fontSize: 11, color: Color(0xFF666677)),
                    ),
                    if (link.peerLat != null) ...[
                      const SizedBox(width: 12),
                      const Icon(Icons.location_on, size: 12, color: Color(0xFF4FC3F7)),
                      const SizedBox(width: 2),
                      Text(
                        '${link.peerLat!.toStringAsFixed(4)}, ${link.peerLon!.toStringAsFixed(4)}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF4FC3F7),
                          fontFamily: 'Courier',
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Color(0xFF664444), size: 20),
            tooltip: 'Revoke link',
            onPressed: () => _confirmRevoke(context),
          ),
        ],
      ),
    );
  }

  void _confirmRevoke(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF0A0A14),
        title: const Text('Revoke Link?', style: TextStyle(color: Colors.white)),
        content: Text(
          'Stop sharing location with ${link.peerDisplayName ?? link.peerNodeId}?',
          style: const TextStyle(color: Color(0xFF888899)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF666677))),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Get.find<LocationLinkService>().revoke(link.id);
            },
            child: const Text('Revoke', style: TextStyle(color: Color(0xFFCC4444))),
          ),
        ],
      ),
    );
  }
}

class _DirectionIcon extends StatelessWidget {
  final LocationLink link;
  const _DirectionIcon({required this.link});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;

    if (link.amSharing && link.theySharing) {
      icon = Icons.swap_horiz;
      color = const Color(0xFF4FC3F7);
    } else if (link.amSharing) {
      icon = Icons.arrow_upward;
      color = const Color(0xFFD4A017);
    } else {
      icon = Icons.arrow_downward;
      color = const Color(0xFF4CAF50);
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }
}

// ── Dialogs ───────────────────────────────────────────────────────────────────

void _showMyQr(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: const Color(0xFF0A0A14),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _MyQrSheet(),
  );
}

class _MyQrSheet extends StatefulWidget {
  @override
  State<_MyQrSheet> createState() => _MyQrSheetState();
}

class _MyQrSheetState extends State<_MyQrSheet> {
  final _nameCtrl = TextEditingController();
  int _durationMinutes = 120;
  bool _bidirectional = true;
  String? _qrData;
  bool _generating = false;

  static const _durations = [
    (label: '1 hour', minutes: 60),
    (label: '2 hours', minutes: 120),
    (label: 'Tonight', minutes: 480),
    (label: 'Full day', minutes: 1440),
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    setState(() => _generating = true);
    final result = await Get.find<LocationLinkService>().generateQr(
      myDisplayName: _nameCtrl.text.trim().isEmpty ? null : _nameCtrl.text.trim(),
      durationMinutes: _durationMinutes,
      bidirectional: _bidirectional,
    );
    setState(() {
      _qrData = result.qrJson;
      _generating = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_qrData != null) {
      return _QrDisplay(qrData: _qrData!, duration: _durationMinutes);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Share Your Location',
            style: TextStyle(
              fontFamily: 'Cinzel',
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _nameCtrl,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Your name on the playa (optional)',
              labelStyle: TextStyle(color: Color(0xFF666677), fontFamily: 'Cinzel', fontSize: 13),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF333344))),
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF4FC3F7))),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'DURATION',
            style: TextStyle(
              fontFamily: 'Cinzel',
              fontSize: 10,
              color: Color(0xFF555566),
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: _durations.map((d) => ChoiceChip(
              label: Text(d.label),
              selected: _durationMinutes == d.minutes,
              onSelected: (_) => setState(() => _durationMinutes = d.minutes),
              selectedColor: const Color(0xFF4FC3F7).withValues(alpha: 0.2),
              backgroundColor: const Color(0xFF111122),
              labelStyle: TextStyle(
                fontFamily: 'Cinzel',
                fontSize: 12,
                color: _durationMinutes == d.minutes
                    ? const Color(0xFF4FC3F7)
                    : const Color(0xFF666677),
              ),
              side: BorderSide(
                color: _durationMinutes == d.minutes
                    ? const Color(0xFF4FC3F7)
                    : const Color(0xFF333344),
              ),
            )).toList(),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Bidirectional (they share with you too)',
                  style: TextStyle(
                    fontFamily: 'Cinzel',
                    fontSize: 12,
                    color: Color(0xFF888899),
                  ),
                ),
              ),
              Switch(
                value: _bidirectional,
                onChanged: (v) => setState(() => _bidirectional = v),
                activeThumbColor: const Color(0xFF4FC3F7),
                activeTrackColor: const Color(0xFF4FC3F7).withValues(alpha: 0.3),
              ),
            ],
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _generating ? null : _generate,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4FC3F7),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _generating
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(
                      'Generate QR',
                      style: TextStyle(fontFamily: 'Cinzel', fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QrDisplay extends StatelessWidget {
  final String qrData;
  final int duration;
  const _QrDisplay({required this.qrData, required this.duration});

  @override
  Widget build(BuildContext context) {
    final hrs = duration ~/ 60;
    final mins = duration % 60;
    final label = hrs > 0 ? '${hrs}h${mins > 0 ? ' ${mins}m' : ''}' : '${mins}m';

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: QrImageView(
              data: qrData,
              version: QrVersions.auto,
              size: 220,
              backgroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Valid for 5 minutes · Shares for $label',
            style: const TextStyle(
              fontFamily: 'Cinzel',
              fontSize: 12,
              color: Color(0xFF666677),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Encrypted end-to-end · No server · Playa only',
            style: TextStyle(
              fontSize: 10,
              color: Color(0xFF444455),
            ),
          ),
        ],
      ),
    );
  }
}

void _showScanner(BuildContext context) {
  bool done = false;
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          foregroundColor: const Color(0xFF4FC3F7),
          title: const Text('Scan Playa Link', style: TextStyle(fontFamily: 'Cinzel', fontSize: 16)),
        ),
        body: MobileScanner(
          onDetect: (capture) async {
            if (done) return;
            final raw = capture.barcodes.firstOrNull?.rawValue;
            if (raw == null) return;
            try {
              jsonDecode(raw);
              done = true;
              if (!context.mounted) return;
              Navigator.pop(context);
              await Get.find<LocationLinkService>().acceptFromQr(raw);
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Location link established'),
                  backgroundColor: Color(0xFF0A3A5C),
                ),
              );
            } catch (_) {}
          },
        ),
      ),
    ),
  );
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'Cinzel',
                  fontSize: 11,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
