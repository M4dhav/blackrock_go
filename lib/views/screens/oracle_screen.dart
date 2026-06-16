import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../models/oracle_query.dart';
import '../../services/pythia_service.dart';

class OracleScreen extends StatefulWidget {
  const OracleScreen({super.key});

  @override
  State<OracleScreen> createState() => _OracleScreenState();
}

class _OracleScreenState extends State<OracleScreen>
    with TickerProviderStateMixin {
  final _pythia = Get.find<PythiaService>();
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  late final AnimationController _pulseController;
  late final AnimationController _glowController;
  late final Animation<double> _pulse;
  late final Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulse = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _glow = Tween<double>(begin: 12.0, end: 36.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _glowController.dispose();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _ask() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    _focusNode.unfocus();
    await _pythia.ask(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildOrb(),
            _buildStatusBanner(),
            Expanded(child: _buildQueryArea()),
            _buildInput(),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFFD4A017)),
            onPressed: () => Get.back(),
          ),
          const Spacer(),
          const Text(
            'PYTHIA',
            style: TextStyle(
              fontFamily: 'Cinzel',
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFFD4A017),
              letterSpacing: 6,
            ),
          ),
          const Spacer(),
          const SizedBox(width: 48), // balance back button
        ],
      ),
    );
  }

  Widget _buildOrb() {
    return Obx(() {
      final active = _pythia.activeQuery.value;
      final isPending = active?.isPending ?? false;
      final isReceived = active?.isComplete ?? false;

      final orbColor = isReceived
          ? const Color(0xFF4FC3F7)
          : isPending
              ? const Color(0xFFFFD700)
              : const Color(0xFF7B2FBE);

      return SizedBox(
        height: 200,
        child: Center(
          child: AnimatedBuilder(
            animation: Listenable.merge([_pulse, _glow]),
            builder: (_, __) {
              return Transform.scale(
                scale: isPending ? _pulse.value : 1.0,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        orbColor.withValues(alpha: 0.9),
                        orbColor.withValues(alpha: 0.3),
                        Colors.transparent,
                      ],
                      stops: const [0.3, 0.7, 1.0],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: orbColor.withValues(alpha: 0.6),
                        blurRadius: _glow.value,
                        spreadRadius: isPending ? 4 : 2,
                      ),
                    ],
                  ),
                  child: CustomPaint(
                    painter: _StarFieldPainter(orbColor),
                    child: Center(
                      child: Icon(
                        isPending ? Icons.hourglass_top_rounded : Icons.auto_awesome,
                        color: Colors.white.withValues(alpha: 0.9),
                        size: 40,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );
    });
  }

  Widget _buildStatusBanner() {
    return Obx(() {
      final active = _pythia.activeQuery.value;
      if (active == null) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Text(
            'Ask the oracle anything',
            style: TextStyle(
              fontFamily: 'Cinzel',
              fontSize: 13,
              color: Color(0xFF7C7C7C),
              letterSpacing: 2,
            ),
          ),
        );
      }

      final (msg, color) = switch (active.status) {
        OracleStatus.composing => ('Channeling...', const Color(0xFF9C27B0)),
        OracleStatus.sent => ('Sent to the mesh...', const Color(0xFFFFD700)),
        OracleStatus.waiting => ('The oracle deliberates...', const Color(0xFFFFD700)),
        OracleStatus.received => ('The oracle has spoken', const Color(0xFF4FC3F7)),
        OracleStatus.timeout => ('The oracle is silent', const Color(0xFF666666)),
      };

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          msg,
          style: TextStyle(
            fontFamily: 'Cinzel',
            fontSize: 13,
            color: color,
            letterSpacing: 2,
          ),
        ),
      );
    });
  }

  Widget _buildQueryArea() {
    return Obx(() {
      final active = _pythia.activeQuery.value;
      if (active?.isComplete == true) {
        return _buildResponse(active!);
      }
      if (_pythia.queryHistory.isEmpty) {
        return _buildEmptyState();
      }
      return _buildHistory();
    });
  }

  Widget _buildResponse(OracleQuery query) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '"${query.queryText}"',
            style: const TextStyle(
              fontFamily: 'Cinzel',
              fontSize: 13,
              color: Color(0xFF888888),
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF0D0D1A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF4FC3F7).withValues(alpha: 0.3)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4FC3F7).withValues(alpha: 0.08),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Text(
              query.responseText ?? '',
              style: const TextStyle(
                fontFamily: 'Cinzel',
                fontSize: 15,
                color: Colors.white,
                height: 1.7,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'via ${query.path.name.toUpperCase()} · ${query.waitTime.inSeconds}s',
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF444466),
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 24),
          if (_pythia.queryHistory.length > 1) ...[
            const Divider(color: Color(0xFF222233)),
            const SizedBox(height: 12),
            const Text(
              'PRIOR CONSULTATIONS',
              style: TextStyle(
                fontFamily: 'Cinzel',
                fontSize: 10,
                color: Color(0xFF555566),
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: 8),
            ..._pythia.queryHistory.skip(1).map(_buildHistoryTile),
          ],
        ],
      ),
    );
  }

  Widget _buildHistory() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: _pythia.queryHistory.length,
      itemBuilder: (_, i) => _buildHistoryTile(_pythia.queryHistory[i]),
    );
  }

  Widget _buildHistoryTile(OracleQuery q) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF0A0A14),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF222233)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              q.queryText,
              style: const TextStyle(
                fontFamily: 'Cinzel',
                fontSize: 12,
                color: Color(0xFF888888),
              ),
            ),
            if (q.responseText != null) ...[
              const SizedBox(height: 8),
              Text(
                q.responseText!,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFFCCCCDD),
                  height: 1.5,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'The oracle awaits your question.\nSpeak and the mesh shall carry your words.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Cinzel',
                fontSize: 14,
                color: Color(0xFF444455),
                height: 1.8,
              ),
            ),
            const SizedBox(height: 32),
            _buildSuggestion('What wisdom does the playa offer tonight?'),
            _buildSuggestion('Where should I wander next?'),
            _buildSuggestion('What is the nature of radical self-reliance?'),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestion(String text) {
    return GestureDetector(
      onTap: () {
        _controller.text = text;
        _focusNode.requestFocus();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF0A0A14),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF2D1F6E).withValues(alpha: 0.6)),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Cinzel',
            fontSize: 11,
            color: Color(0xFF7B68EE),
            height: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _buildInput() {
    return Obx(() {
      final isLoading = _pythia.activeQuery.value?.isPending ?? false;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF0D0D1A),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: const Color(0xFF3D1F8E).withValues(alpha: 0.6)),
                ),
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  enabled: !isLoading,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                  style: const TextStyle(
                    fontFamily: 'Cinzel',
                    color: Colors.white,
                    fontSize: 14,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Speak your question...',
                    hintStyle: TextStyle(
                      color: Color(0xFF444466),
                      fontFamily: 'Cinzel',
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: isLoading ? null : _ask,
              child: AnimatedBuilder(
                animation: _glowController,
                builder: (_, __) => Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const RadialGradient(
                      colors: [Color(0xFF9C27B0), Color(0xFF4A0072)],
                    ),
                    boxShadow: isLoading
                        ? [
                            BoxShadow(
                              color: const Color(0xFF9C27B0).withValues(alpha: 0.5),
                              blurRadius: _glow.value * 0.6,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    isLoading ? Icons.hourglass_empty_rounded : Icons.send_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

// Draws faint stars inside the orb
class _StarFieldPainter extends CustomPainter {
  final Color baseColor;
  _StarFieldPainter(this.baseColor);

  static final _rng = Random(42);
  static final _stars = List.generate(
    18,
    (_) => Offset(_rng.nextDouble(), _rng.nextDouble()),
  );

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;

    for (final star in _stars) {
      canvas.drawCircle(
        Offset(star.dx * size.width, star.dy * size.height),
        1.2,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
