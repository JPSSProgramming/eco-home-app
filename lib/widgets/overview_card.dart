import 'package:flutter/material.dart';
import 'stat_row.dart';

class OverviewCard extends StatelessWidget {
  final int roomCount;
  final double averageTemperature;

  const OverviewCard({
    super.key,
    required this.roomCount,
    required this.averageTemperature,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.home,
                  color: Theme.of(context).colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Home Overview',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            buildStatRow(Icons.meeting_room, 'Rooms', '$roomCount'),
            const SizedBox(height: 8),
            buildStatRow(
              Icons.thermostat,
              'Avg Temperature',
              '${averageTemperature.toStringAsFixed(1)}°C',
            ),
          ],
        ),
      ),
    );
  }
}
