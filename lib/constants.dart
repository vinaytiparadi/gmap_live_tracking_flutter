import 'package:flutter/material.dart';

const String google_api_key = "AIzaSyAuny-ypKqnRF4BRhNtPECpmZcHn3N8mNA";
const Color primaryColor = Color(0xFF7B61FF);
const double defaultPadding = 16.0;

BoxDecoration boxDecoration(
    {double borderradius = 5,
      Color color = Colors.white,
      bool isBorder = false}) {
  return BoxDecoration(
      borderRadius: BorderRadius.circular(borderradius),
      border: isBorder == true ? Border.all(color: color) : null,
      color: isBorder == true ? Colors.white : color,
      boxShadow: [
        BoxShadow(blurRadius: 5, color: Colors.blue.withOpacity(0.5))
      ]);
}