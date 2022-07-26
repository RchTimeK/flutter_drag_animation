/// Created by RongCheng on 2022/7/26.

import 'package:flutter/material.dart';

class DragListenerManager {
  static final List<DragListener> _listeners = [];

  static void addListener(DragListener listener) {
    _listeners.add(listener);
  }

  static void removeListener(DragListener listener) {
    _listeners.remove(listener);
  }

  static void sendDragStart() {
    for (var listener in _listeners) {
      listener.onDragStart();
    }
  }

  static void sendDragEnd(Offset endStatus) {
    for (var listener in _listeners) {
      listener.onDragEnd(endStatus);
    }
  }

  static void sendClosing() {
    for (var listener in _listeners) {
      listener.onClosing();
    }
  }

  static void sendAnimationFinish() {
    for (var listener in _listeners) {
      listener.onAnimationFinish();
    }
  }
}

// 抽象类，用于后续监听
abstract class DragListener {
  void onDragStart();

  void onDragEnd(Offset endStatus);

  void onClosing();

  void onAnimationFinish();
}