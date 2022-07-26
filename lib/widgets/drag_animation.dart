/// Created by RongCheng on 2022/7/26.
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_drag_animation/widgets/notification.dart';

class DragAnimation extends StatefulWidget {
  const DragAnimation({
    Key? key,
    this.onClosing,
    required this.child,
    this.onDragStart,
    this.onDragEnd,
    this.onAnimationFinish,
    required this.animationController,
    required this.fadeAnimationController,
  }) : super(key: key);
  final Function? onClosing;
  final Widget child;
  final Function? onDragStart;
  final ValueChanged<Offset>? onDragEnd;
  final Function? onAnimationFinish;
  final AnimationController animationController;
  final AnimationController fadeAnimationController;
  @override
  State<DragAnimation> createState() => _DragAnimationState();
}

class _DragAnimationState extends State<DragAnimation> with SingleTickerProviderStateMixin{

  final ValueNotifier<double> _scaleNotifier = ValueNotifier<double>(1.0);
  final ValueNotifier<Offset> _offsetNotifier = ValueNotifier<Offset>(Offset.zero);
  final double midDy = MediaQueryData.fromWindow(window).size.height / 2;

  // 是否是往下拖拽
  bool _isBottomDir = false;

  late AnimationController _resetController;
  late Animation _resetAnimation;

  double _lastScale = 0;
  Offset _lastOffset = Offset.zero;
  double _lastFade = 0;

  late AnimationStatusListener statusListener;
  late VoidCallback valueListener;

  @override
  void initState() {
    super.initState();
    _resetController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
    _resetAnimation = CurvedAnimation(
      parent: _resetController,
      curve: Curves.easeOut,
    )..addListener(() {
      _scaleNotifier.value =
          _resetAnimation.value * (1 - _lastScale) + _lastScale;
      widget.animationController.value =
          _resetAnimation.value * (1 - _lastFade) + _lastFade;
      double dx =
          _resetAnimation.value * (1 - _lastOffset.dx) + _lastOffset.dx;
      double dy =
          _resetAnimation.value * (1 - _lastOffset.dy) + _lastOffset.dy;
      _offsetNotifier.value = Offset(dx, dy);
      widget.onDragEnd?.call(_lastOffset);
    });

    statusListener = (status) {
      if (status == AnimationStatus.completed) {
        widget.onAnimationFinish?.call();
      }
    };
    valueListener = () {
      widget.fadeAnimationController.value = widget.animationController.value;
    };
    widget.animationController.addStatusListener(statusListener);
    widget.animationController.addListener(valueListener);
  }

  @override
  void dispose() {
    _resetController.dispose();
    widget.animationController.removeStatusListener(statusListener);
    widget.animationController.removeListener(valueListener);
    super.dispose();
  }

  void onPanStart(DragStartDetails details) {
    widget.onDragStart?.call();
  }

  void onPanUpdate(DragUpdateDetails details) {
    _offsetNotifier.value += details.delta;

    if (isChildBelowMid(_offsetNotifier.value.dy)) {
      // dy : sy = x : 1 - min
      _scaleNotifier.value = 1 -
          (_offsetNotifier.value.dy /
              midDy *
              (1 - 0.6));
      widget.animationController.value = 1 - (_offsetNotifier.value.dy / midDy);
    } else {
      if (_scaleNotifier.value != 1) {
        _scaleNotifier.value = 1;
        widget.animationController.value = 1;
      }
    }

    if (details.delta.dy > 0) {
      _isBottomDir = true;
    } else {
      _isBottomDir = false;
    }
  }

  void onPanEnd(DragEndDetails details) {
    if (isChildBelowMid(_offsetNotifier.value.dy - 100)) {
      if (_isBottomDir) {
        closing();
        return;
      }
    }
    _lastScale = _scaleNotifier.value;
    _lastOffset = _offsetNotifier.value;
    _lastFade = widget.animationController.value;
    _resetController.forward(from: 0);
  }

  void onPanCancel() {}

  bool isChildBelowMid(double dy) {
    return _offsetNotifier.value.dy > 0;
  }

  void closing() {
    widget.animationController.removeListener(valueListener);
    widget.onClosing?.call();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener(
      onNotification: (notification) {
        if (notification is DragOnPanStartNotification) {
          onPanStart(notification.details);
        } else if (notification is DragOnPanUpdateNotification) {
          onPanUpdate(notification.details);
        } else if (notification is DragOnPanEndNotification) {
          onPanEnd(notification.details);
        } else if (notification is DragOnPanCancelNotification) {
          onPanCancel();
        }
        return false;
      },
      child: ValueListenableBuilder<Offset>(
        valueListenable: _offsetNotifier,
        builder: (context, offset, child) {
          return Transform.translate(
            offset: offset,
            child: ValueListenableBuilder<double>(
              valueListenable: _scaleNotifier,
              builder: (context, scale, child) {
                return Transform.scale(
                  scale: scale,
                  child: RepaintBoundary(
                    child: widget.child,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
