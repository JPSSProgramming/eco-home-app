import 'package:flutter/material.dart';
import 'stat_row.dart';

class StatisticsCard extends StatelessWidget {
  final int roomCount;
  final double averageTemperature;
  final int boilersOn;
  final int floorHeatingOn;
  final String? selectedRoom;

  const StatisticsCard({
    super.key,
    required this.roomCount,
    required this.averageTemperature,
    required this.boilersOn,
    required this.floorHeatingOn,
    required this.selectedRoom,
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
                  Icons.analytics,
                  color: Theme.of(context).colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Home Statistics',
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
            const SizedBox(height: 8),
            buildStatRow(Icons.whatshot, 'Boilers On', '$boilersOn'),
            const SizedBox(height: 8),
            buildStatRow(Icons.grid_on, 'Floor Heating On', '$floorHeatingOn'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.grey[600],
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Selected: ${selectedRoom ?? "No room selected"}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
