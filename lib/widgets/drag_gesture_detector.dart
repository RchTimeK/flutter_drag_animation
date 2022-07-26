/// Created by RongCheng on 2022/7/26.

import 'package:flutter/material.dart';
import 'package:flutter_drag_animation/widgets/notification.dart';
/// 指定用于拖拽的区域
/// 包裹 [child], 则只有[child]会被响应拖拽事件
class DragGestureDetector extends StatelessWidget {
  const DragGestureDetector({Key? key,required this.child}) : super(key: key);
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (DragStartDetails details){
        DragOnPanStartNotification(details).dispatch(context);
      },
      onPanUpdate: (DragUpdateDetails details){
        DragOnPanUpdateNotification(details).dispatch(context);
      },
      onPanEnd: (DragEndDetails details){
        DragOnPanEndNotification(details).dispatch(context);
      },
      onPanCancel: (){
        DragOnPanCancelNotification().dispatch(context);
      },
      child: child,
    );
  }
}
