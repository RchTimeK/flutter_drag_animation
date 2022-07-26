/// Created by RongCheng on 2022/7/26.

import 'package:flutter/material.dart';
import 'package:flutter_drag_animation/widgets/drag_gesture_detector.dart';
class TestPage extends StatelessWidget {
  const TestPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: DragGestureDetector(
          child: Hero(
            tag: "testTag",
            child: Container(
              width: double.maxFinite,
              height: 400,
              color: Colors.greenAccent,
            ),
          ),
        ),
      ),
    );
  }
}
