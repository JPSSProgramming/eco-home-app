import 'package:flutter/material.dart';
import 'room.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mini Smart Home',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const SmartHomeDashboard(),
    );
  }
}

class SmartHomeDashboard extends StatefulWidget {
  const SmartHomeDashboard({super.key});

  @override
  State<SmartHomeDashboard> createState() => _SmartHomeDashboardState();
}

class _SmartHomeDashboardState extends State<SmartHomeDashboard> {
  static const double targetTemperature = 21.0;

  Color getStatusColor(String status) {
    if (status == "Heating") {
      return Colors.orange;
    } else if (status == "Too Cold") {
      return Colors.blue;
    } else if (status == "Too Hot") {
      return Colors.red;
    } else {
      return Colors.green;
    }
  }

  Widget _buildStatRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
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

  Widget _buildDeviceRow(
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

  final List<Room> rooms = <Room>[
    Room(
      name: "Living Room",
      temperature: 22,
      lightOn: true,
      heaterOn: false,
    ),
    Room(
      name: "Bedroom",
      temperature: 19,
      lightOn: false,
      heaterOn: true,
    ),
    Room(
      name: "Kitchen",
      temperature: 23,
      lightOn: true,
      heaterOn: false,
    ),
  ];

  String? selectedRoom;

  double calculateAverageTemperature(List<Room> rooms) {
    double total = 0;
    for (final room in rooms) {
      total = total + room.temperature;
    }
    return total / rooms.length;
  }

  Map<String, int> calculateDeviceStats(List<Room> rooms) {
    int lightsOn = 0;
    int heatersOn = 0;

    for (final room in rooms) {
      if (room.lightOn) {
        lightsOn = lightsOn + 1;
      }
      if (room.heaterOn) {
        heatersOn = heatersOn + 1;
      }
    }

    return {
      "Lights": lightsOn,
      "Heaters": heatersOn,
    };
  }

  void toggleRoomLight(int index) {
    setState(() {
      rooms[index].toggleLight();
    });
  }

  void toggleRoomHeater(int index) {
    setState(() {
      rooms[index].toggleHeater();
    });
  }

  void autoHeating() {
    setState(() {
      for (final room in rooms) {
        if (room.temperature < targetTemperature) {
          room.heaterOn = true;
        } else {
          room.heaterOn = false;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final double avgTemp = calculateAverageTemperature(rooms);
    final Map<String, int> stats = calculateDeviceStats(rooms);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mini Smart Home',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
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
                  _buildStatRow(Icons.meeting_room, 'Rooms', '${rooms.length}'),
                  const SizedBox(height: 8),
                  _buildStatRow(Icons.thermostat, 'Avg Temperature', '${avgTemp.toStringAsFixed(1)}°C'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: autoHeating,
            icon: const Icon(Icons.autorenew),
            label: const Text('Auto Heating'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              textStyle: const TextStyle(fontSize: 16),
            ),
          ),
          const SizedBox(height: 16),
          ...rooms.asMap().entries.map((entry) {
            final int index = entry.key;
            final Room room = entry.value;
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
                      _buildDeviceRow(
                        Icons.lightbulb,
                        'Light',
                        room.lightOn,
                        Colors.amber,
                        () => toggleRoomLight(index),
                      ),
                      const SizedBox(height: 12),
                      _buildDeviceRow(
                        Icons.whatshot,
                        'Heater',
                        room.heaterOn,
                        Colors.red,
                        () => toggleRoomHeater(index),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 16),
          Card(
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
                  _buildStatRow(Icons.meeting_room, 'Rooms', '${rooms.length}'),
                  const SizedBox(height: 8),
                  _buildStatRow(Icons.thermostat, 'Avg Temperature', '${avgTemp.toStringAsFixed(1)}°C'),
                  const SizedBox(height: 8),
                  _buildStatRow(Icons.lightbulb, 'Lights On', '${stats["Lights"]}'),
                  const SizedBox(height: 8),
                  _buildStatRow(Icons.whatshot, 'Heaters On', '${stats["Heaters"]}'),
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
          ),
        ],
      ),
    );
  }
}
