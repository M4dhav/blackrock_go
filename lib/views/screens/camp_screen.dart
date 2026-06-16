import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../models/camp.dart';
import '../../services/camp_service.dart';

class CampScreen extends StatelessWidget {
  const CampScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = Get.find<CampService>();
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Obx(() {
          if (service.camps.isEmpty) {
            return _NoCampView(service: service);
          }
          return _CampTabView(service: service);
        }),
      ),
    );
  }
}

// ── No Camp ───────────────────────────────────────────────────────────────────

class _NoCampView extends StatelessWidget {
  final CampService service;
  const _NoCampView({required this.service});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.fireplace_outlined, size: 64, color: Color(0xFFD4A017)),
            const SizedBox(height: 24),
            const Text(
              'No Camp Yet',
              style: TextStyle(
                fontFamily: 'Cinzel',
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Create your camp or scan a QR code to join one.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Cinzel',
                fontSize: 13,
                color: Color(0xFF666677),
                height: 1.6,
              ),
            ),
            const SizedBox(height: 36),
            _GoldButton(
              label: 'Create Camp',
              icon: Icons.add,
              onTap: () => _showCreateDialog(context, service),
            ),
            const SizedBox(height: 16),
            _OutlineButton(
              label: 'Scan Camp QR',
              icon: Icons.qr_code_scanner,
              onTap: () => _showScanner(context, service),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Tabs when in a camp ───────────────────────────────────────────────────────

class _CampTabView extends StatefulWidget {
  final CampService service;
  const _CampTabView({required this.service});

  @override
  State<_CampTabView> createState() => _CampTabViewState();
}

class _CampTabViewState extends State<_CampTabView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  int _campIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Camp get _camp => widget.service.camps[_campIndex];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        TabBar(
          controller: _tabs,
          indicatorColor: const Color(0xFFD4A017),
          labelColor: const Color(0xFFD4A017),
          unselectedLabelColor: const Color(0xFF666677),
          labelStyle: const TextStyle(fontFamily: 'Cinzel', fontSize: 12, letterSpacing: 1),
          tabs: const [
            Tab(text: 'MEMBERS'),
            Tab(text: 'SHARE'),
            Tab(text: 'KEYS'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabs,
            children: [
              _MembersTab(camp: _camp, service: widget.service),
              _QrShareTab(camp: _camp),
              _KeysTab(camp: _camp, service: widget.service),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Obx(() {
      final camps = widget.service.camps;
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
        child: Row(
          children: [
            const Icon(Icons.fireplace_outlined, color: Color(0xFFD4A017), size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: camps.length > 1
                  ? DropdownButton<int>(
                      value: _campIndex,
                      dropdownColor: const Color(0xFF0A0A14),
                      underline: const SizedBox.shrink(),
                      style: const TextStyle(
                        fontFamily: 'Cinzel',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      items: List.generate(
                        camps.length,
                        (i) => DropdownMenuItem(value: i, child: Text(camps[i].name)),
                      ),
                      onChanged: (i) => setState(() => _campIndex = i ?? 0),
                    )
                  : Text(
                      camps[_campIndex].name,
                      style: const TextStyle(
                        fontFamily: 'Cinzel',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
            _RoleBadge(camp: camps[_campIndex]),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.add_circle_outline, color: Color(0xFFD4A017)),
              tooltip: 'Join another camp',
              onPressed: () => _showScanner(context, widget.service),
            ),
          ],
        ),
      );
    });
  }
}

// ── Members Tab ───────────────────────────────────────────────────────────────

class _MembersTab extends StatelessWidget {
  final Camp camp;
  final CampService service;
  const _MembersTab({required this.camp, required this.service});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final members = service.camps
          .firstWhereOrNull((c) => c.id == camp.id)
          ?.members ?? [];

      if (members.isEmpty) {
        return const Center(
          child: Text(
            'No members yet.\nShare the camp QR to invite campers.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Cinzel',
              fontSize: 13,
              color: Color(0xFF555566),
              height: 1.7,
            ),
          ),
        );
      }

      return ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        itemCount: members.length,
        separatorBuilder: (_, __) => const Divider(color: Color(0xFF1A1A2A), height: 1),
        itemBuilder: (_, i) => _MemberTile(
          member: members[i],
          campRole: camp.role,
          onApprove: camp.role == CampRole.lead
              ? () => service.approveMember(camp.id, members[i].id)
              : null,
        ),
      );
    });
  }
}

class _MemberTile extends StatelessWidget {
  final CampMember member;
  final CampRole campRole;
  final VoidCallback? onApprove;
  const _MemberTile({required this.member, required this.campRole, this.onApprove});

  @override
  Widget build(BuildContext context) {
    final isOnline = member.lastSeen != null &&
        DateTime.now().difference(member.lastSeen!).inMinutes < 5;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
      leading: Stack(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFF1A1A2A),
            child: Text(
              (member.displayName ?? member.nodeId).substring(0, 1).toUpperCase(),
              style: const TextStyle(
                fontFamily: 'Cinzel',
                color: Color(0xFFD4A017),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (isOnline)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.greenAccent,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black, width: 1.5),
                ),
              ),
            ),
        ],
      ),
      title: Text(
        member.displayName ?? member.nodeId,
        style: const TextStyle(
          fontFamily: 'Cinzel',
          color: Colors.white,
          fontSize: 14,
        ),
      ),
      subtitle: Text(
        member.nodeId,
        style: const TextStyle(
          fontSize: 11,
          color: Color(0xFF555566),
          fontFamily: 'Courier',
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (member.role == CampRole.lead)
            const Icon(Icons.star, size: 14, color: Color(0xFFD4A017)),
          if (member.locationOptIn)
            const Padding(
              padding: EdgeInsets.only(left: 6),
              child: Icon(Icons.location_on, size: 14, color: Color(0xFF4FC3F7)),
            ),
          if (onApprove != null && member.publicKey != null)
            IconButton(
              icon: const Icon(Icons.check_circle_outline, color: Color(0xFF4CAF50)),
              tooltip: 'Send keys',
              onPressed: onApprove,
            ),
        ],
      ),
    );
  }
}

// ── QR Share Tab ──────────────────────────────────────────────────────────────

class _QrShareTab extends StatelessWidget {
  final Camp camp;
  const _QrShareTab({required this.camp});

  @override
  Widget build(BuildContext context) {
    final qrData = camp.toQrPayload();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Text(
            'Share this QR to invite campers',
            style: TextStyle(
              fontFamily: 'Cinzel',
              fontSize: 13,
              color: Color(0xFF888899),
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: QrImageView(
              data: qrData,
              version: QrVersions.auto,
              size: 240,
              backgroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            camp.name.toUpperCase(),
            style: const TextStyle(
              fontFamily: 'Cinzel',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFFD4A017),
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Slot ${camp.meshtasticSlot} · ${camp.members.length} members',
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF666677),
            ),
          ),
          const SizedBox(height: 32),
          const Divider(color: Color(0xFF1A1A2A)),
          const SizedBox(height: 16),
          const Text(
            'The app group key is NOT in this QR.\nIt is delivered privately after the camp lead approves your join request.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: Color(0xFF444455),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Keys Tab ──────────────────────────────────────────────────────────────────

class _KeysTab extends StatelessWidget {
  final Camp camp;
  final CampService service;
  const _KeysTab({required this.camp, required this.service});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _keyRow('Channel PSK', '${camp.channelPsk.length * 8}-bit AES (Meshtastic transport)'),
          const SizedBox(height: 16),
          _keyRow('App Group Key', 'AES-256-GCM (message content — encrypted)'),
          const SizedBox(height: 16),
          _keyRow('Location Key', 'AES-256-GCM (position data only — encrypted)'),
          const SizedBox(height: 32),
          if (camp.role == CampRole.lead) ...[
            const Text(
              'DANGER ZONE',
              style: TextStyle(
                fontFamily: 'Cinzel',
                fontSize: 10,
                color: Color(0xFF664444),
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: 12),
            _OutlineButton(
              label: 'Leave Camp',
              icon: Icons.exit_to_app,
              color: const Color(0xFFCC4444),
              onTap: () => _confirmLeave(context),
            ),
          ],
        ],
      ),
    );
  }

  Widget _keyRow(String label, String desc) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A14),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF1A1A2A)),
      ),
      child: Row(
        children: [
          const Icon(Icons.key, color: Color(0xFFD4A017), size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'Cinzel',
                    fontSize: 13,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF555566),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.lock, color: Color(0xFF4CAF50), size: 16),
        ],
      ),
    );
  }

  void _confirmLeave(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF0A0A14),
        title: const Text('Leave Camp?', style: TextStyle(color: Colors.white)),
        content: const Text(
          'This will delete all camp keys from your device.',
          style: TextStyle(color: Color(0xFF888899)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF666677))),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              service.leaveCamp(camp.id);
            },
            child: const Text('Leave', style: TextStyle(color: Color(0xFFCC4444))),
          ),
        ],
      ),
    );
  }
}

// ── Shared widgets ────────────────────────────────────────────────────────────

class _RoleBadge extends StatelessWidget {
  final Camp camp;
  const _RoleBadge({required this.camp});

  @override
  Widget build(BuildContext context) {
    final isLead = camp.role == CampRole.lead;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: (isLead ? const Color(0xFFD4A017) : const Color(0xFF1A3A5C)).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isLead ? const Color(0xFFD4A017) : const Color(0xFF4FC3F7),
          width: 0.8,
        ),
      ),
      child: Text(
        isLead ? 'LEAD' : 'MEMBER',
        style: TextStyle(
          fontFamily: 'Cinzel',
          fontSize: 10,
          color: isLead ? const Color(0xFFD4A017) : const Color(0xFF4FC3F7),
          letterSpacing: 1,
        ),
      ),
    );
  }
}

class _GoldButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _GoldButton({required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFB8860B), Color(0xFFD4A017), Color(0xFFFFC425)],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.black, size: 20),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Cinzel',
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OutlineButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color color;
  const _OutlineButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.color = const Color(0xFF4FC3F7),
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.6)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Cinzel',
                fontSize: 14,
                color: color,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Dialogs ───────────────────────────────────────────────────────────────────

void _showCreateDialog(BuildContext context, CampService service) {
  final nameCtrl = TextEditingController();
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: const Color(0xFF0A0A14),
      title: const Text(
        'Name Your Camp',
        style: TextStyle(fontFamily: 'Cinzel', color: Colors.white),
      ),
      content: TextField(
        controller: nameCtrl,
        autofocus: true,
        style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(
          hintText: 'e.g. Camp Dusty Phoenix',
          hintStyle: TextStyle(color: Color(0xFF444455)),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF444466)),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFD4A017)),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: Color(0xFF666677))),
        ),
        TextButton(
          onPressed: () async {
            final name = nameCtrl.text.trim();
            if (name.isEmpty) return;
            Navigator.pop(context);
            await service.createCamp(name);
          },
          child: const Text('Create', style: TextStyle(color: Color(0xFFD4A017))),
        ),
      ],
    ),
  );
}

void _showScanner(BuildContext context, CampService service) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => _QrScannerPage(
        onScanned: (json) async {
          Navigator.pop(context);
          final nameCtrl = TextEditingController();
          await showDialog(
            context: context,
            builder: (_) => AlertDialog(
              backgroundColor: const Color(0xFF0A0A14),
              title: const Text(
                'Your Name on the Playa',
                style: TextStyle(fontFamily: 'Cinzel', color: Colors.white),
              ),
              content: TextField(
                controller: nameCtrl,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Display name (optional)',
                  hintStyle: TextStyle(color: Color(0xFF444455)),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF444466)),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFD4A017)),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: Color(0xFF666677))),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    await service.initJoinFromQr(json, nameCtrl.text.trim());
                  },
                  child: const Text('Join', style: TextStyle(color: Color(0xFFD4A017))),
                ),
              ],
            ),
          );
        },
      ),
    ),
  );
}

class _QrScannerPage extends StatelessWidget {
  final void Function(String json) onScanned;
  const _QrScannerPage({required this.onScanned});

  @override
  Widget build(BuildContext context) {
    bool done = false;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: const Color(0xFFD4A017),
        title: const Text(
          'Scan Camp QR',
          style: TextStyle(fontFamily: 'Cinzel', fontSize: 16),
        ),
      ),
      body: MobileScanner(
        onDetect: (capture) {
          if (done) return;
          final raw = capture.barcodes.firstOrNull?.rawValue;
          if (raw == null) return;
          try {
            jsonDecode(raw); // validate JSON
            done = true;
            onScanned(raw);
          } catch (_) {}
        },
      ),
    );
  }
}
