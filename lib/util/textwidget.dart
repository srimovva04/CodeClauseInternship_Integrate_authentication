import 'package:flutter/material.dart';

class Textwidget extends StatelessWidget {
  final controller;
  final String hintText;
  final bool hiddenText;

  const Textwidget({
    super.key,
    required this.controller,
    required this.hintText,
    required this.hiddenText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0.0),
      child: TextField(
        controller: controller,
        obscureText: hiddenText,
        decoration: InputDecoration(
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black12),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black38),
          ),
          fillColor: const Color.fromRGBO(220, 220, 220, 1.0),
          filled: true,
          hintText: hintText,
        ),
      ),
    );
  }
}
