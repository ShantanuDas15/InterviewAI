// lib/widgets/call_button.dart
import 'package:flutter/material.dart';
import 'package:interviewai_frontend/providers/vapi_provider.dart';
import 'call_ring_painter.dart';

class CallButton extends StatefulWidget {
  final CallState callState;
  final VoidCallback onPressed;

  const CallButton({
    super.key,
    required this.callState,
    required this.onPressed,
  });

  @override
  State<CallButton> createState() => _CallButtonState();
}

class _CallButtonState extends State<CallButton> with TickerProviderStateMixin {
  late final AnimationController _ringController;
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _pulseController =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 800),
          reverseDuration: const Duration(milliseconds: 800),
        )..addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            _pulseController.reverse();
          } else if (status == AnimationStatus.dismissed) {
            _pulseController.forward();
          }
        });

    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _updateAnimation();
  }

  @override
  void didUpdateWidget(covariant CallButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.callState != widget.callState) {
      _updateAnimation();
    }
  }

  void _updateAnimation() {
    switch (widget.callState) {
      case CallState.inProgress:
        _ringController.stop();
        _pulseController.forward();
        break;
      case CallState.starting:
        _ringController.repeat();
        _pulseController.stop();
        break;
      default:
        _ringController.stop();
        _pulseController.stop();
    }
  }

  @override
  void dispose() {
    _ringController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: CallRingPainter(animation: _ringController),
      child: ScaleTransition(
        scale: _pulseAnimation,
        child: Material(
          color: _getButtonColor(),
          shape: const CircleBorder(),
          elevation: 8.0,
          shadowColor: _getButtonColor().withValues(alpha: 0.5),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: widget.onPressed,
            child: Container(
              width: 100,
              height: 100,
              alignment: Alignment.center,
              child: _getButtonIcon(),
            ),
          ),
        ),
      ),
    );
  }

  Color _getButtonColor() {
    switch (widget.callState) {
      case CallState.inProgress:
        return Colors.red.shade700;
      case CallState.starting:
        return Colors.blue.shade700;
      case CallState.error:
        return Colors.orange.shade700;
      default:
        return Colors.grey.shade800;
    }
  }

  Widget _getButtonIcon() {
    switch (widget.callState) {
      case CallState.inProgress:
        return const Icon(Icons.call_end, color: Colors.white, size: 40);
      case CallState.starting:
        return const SizedBox(
          width: 30,
          height: 30,
          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
        );
      case CallState.error:
        return const Icon(Icons.refresh, color: Colors.white, size: 40);
      default:
        return const Icon(Icons.call_end, color: Colors.white, size: 40);
    }
  }
}
