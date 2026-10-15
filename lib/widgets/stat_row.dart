import 'package:flutter/material.dart';

Widget buildStatRow(IconData icon, String label, String value) {
  return Row(
    children: [
      Icon(
        icon,
        color: Colors.blue,
        size: 20,
      ),
      const SizedBox(width: 12),
      Text(
        label,
        style: TextStyle(
          fontSize: 16,
          color: Colors.grey[700],
        ),
      ),
      const Spacer(),
      Text(
        value,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    ],
  );
}
