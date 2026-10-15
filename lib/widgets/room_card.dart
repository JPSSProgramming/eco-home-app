import 'package:flutter/material.dart';
import '../models/room.dart';
import 'status_colors.dart';
import 'device_row.dart';

class RoomCard extends StatelessWidget {
  final Room room;
  final int index;
  final VoidCallback onLightToggle;
  final VoidCallback onHeaterToggle;

  const RoomCard({
    super.key,
    required this.room,
    required this.index,
    required this.onLightToggle,
    required this.onHeaterToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.surface,
              Theme.of(context).colorScheme.surface.withValues(alpha: 0.95),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: getStatusColor(room.status).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.bedroom_parent,
                      color: getStatusColor(room.status),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      room.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    Icons.thermostat,
                    color: getStatusColor(room.status),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${room.temperature}°C',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: getStatusColor(room.status),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: getStatusColor(room.status),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      room.status,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              buildDeviceRow(
                Icons.lightbulb,
                'Light',
                room.lightOn,
                Colors.amber,
                onLightToggle,
              ),
              const SizedBox(height: 12),
              buildDeviceRow(
                Icons.whatshot,
                'Heater',
                room.heaterOn,
                Colors.red,
                onHeaterToggle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
