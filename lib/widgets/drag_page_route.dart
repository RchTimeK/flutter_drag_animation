/// Created by RongCheng on 2022/7/26.

import 'package:flutter/material.dart';
import 'package:flutter_drag_animation/widgets/drag_animation.dart';
import 'package:flutter_drag_animation/widgets/drag_listener_manager.dart';
class DragPageRoute<T> extends PageRoute<T> with MaterialRouteTransitionMixin {
  DragPageRoute({
    required this.builder,
    RouteSettings? settings,
    this.maintainState = true,
    this.needHero = true,
  }) : super(settings: settings, fullscreenDialog: true);

  final WidgetBuilder builder;

  @override
  final bool maintainState;

  final bool needHero;

  AnimationController? _animationController;
  AnimationController? _fadeAnimationController;

  @override
  Widget buildContent(BuildContext context) {
    return DragAnimation(
      animationController: _animationController!,
      fadeAnimationController: _fadeAnimationController!,
      onClosing: () {
        DragListenerManager.sendClosing();
        if (needHero) {
          _animationController!.value = 1;
          _fadeAnimationController!.animateTo(0, duration: transitionDuration);
        }
        Navigator.pop(context);
      },
      onDragStart: () {
        DragListenerManager.sendDragStart();
      },
      onDragEnd: (offset) {
        DragListenerManager.sendDragEnd(offset);
      },
      onAnimationFinish: () {
        DragListenerManager.sendAnimationFinish();
      },
      child: builder(context),
    );
  }

  @override
  AnimationController createAnimationController() {
    if (_animationController == null) {
      _animationController = AnimationController(
        vsync: navigator!.overlay!,
        duration: transitionDuration,
        reverseDuration: transitionDuration,
      );
      _fadeAnimationController = AnimationController(
        vsync: navigator!.overlay!,
        duration: transitionDuration,
        reverseDuration: transitionDuration,
        value: 1,
      );
    }
    return _animationController!;
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return Stack(
      children: [
        FadeTransition(
          opacity: !needHero || isActive
              ? _animationController!
              : _fadeAnimationController!,
          child: Container(
            color: Colors.black,
          ),
        ),
        child,
      ],
    );
  }

  String? get title => null;

}