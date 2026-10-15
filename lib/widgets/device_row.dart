import 'package:flutter/material.dart';

Widget buildDeviceRow(
  IconData icon,
  String label,
  bool isOn,
  Color activeColor,
  VoidCallback onToggle,
) {
  return Row(
    children: [
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isOn ? activeColor.withValues(alpha: 0.2) : Colors.grey.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: isOn ? activeColor : Colors.grey,
          size: 24,
        ),
      ),
      const SizedBox(width: 12),
      Text(
        label,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: isOn ? activeColor : Colors.grey[600],
        ),
      ),
      const Spacer(),
      Switch(
        value: isOn,
        onChanged: (bool value) {
          onToggle();
        },
        activeTrackColor: activeColor,
      ),
    ],
  );
}
