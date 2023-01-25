import 'package:flutter/material.dart';

class SaveImageFromWidget extends StatefulWidget {
  final Function(GlobalKey key) builder;

  const SaveImageFromWidget({Key? key, required this.builder}) : super(key: key);

  @override
  State<SaveImageFromWidget> createState() => _SaveImageFromWidgetState();
}

class _SaveImageFromWidgetState extends State<SaveImageFromWidget> {
  final globalKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: globalKey,
      child: widget.builder(globalKey),
    );
  }
}