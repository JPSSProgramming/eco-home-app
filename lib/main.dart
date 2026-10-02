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
        title: const Text('Mini Smart Home'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Home Overview',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text('Rooms: ${rooms.length}'),
                  Text('Average Temperature: ${avgTemp.toStringAsFixed(1)}°C'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: autoHeating,
            icon: const Icon(Icons.autorenew),
            label: const Text('Auto Heating'),
          ),
          const SizedBox(height: 16),
          ...rooms.asMap().entries.map((entry) {
            final int index = entry.key;
            final Room room = entry.value;
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      room.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Temperature: ${room.temperature}°C'),
                    Text('Status: ${room.status}'),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.lightbulb),
                        const SizedBox(width: 8),
                        const Text('Light'),
                        const Spacer(),
                        Switch(
                          value: room.lightOn,
                          onChanged: (bool value) {
                            toggleRoomLight(index);
                          },
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.whatshot),
                        const SizedBox(width: 8),
                        const Text('Heater'),
                        const Spacer(),
                        Switch(
                          value: room.heaterOn,
                          onChanged: (bool value) {
                            toggleRoomHeater(index);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Home Statistics',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text('Rooms: ${rooms.length}'),
                  Text('Average Temperature: ${avgTemp.toStringAsFixed(1)}°C'),
                  Text('Lights On: ${stats["Lights"]}'),
                  Text('Heaters On: ${stats["Heaters"]}'),
                  const SizedBox(height: 12),
                  Text('Selected: ${selectedRoom ?? "No room selected"}'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
