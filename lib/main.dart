import 'package:flutter/material.dart';
import 'models/room.dart';
import 'widgets/room_card.dart';
import 'widgets/overview_card.dart';
import 'widgets/statistics_card.dart';

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
          OverviewCard(
            roomCount: rooms.length,
            averageTemperature: avgTemp,
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
            return RoomCard(
              room: room,
              index: index,
              onLightToggle: () => toggleRoomLight(index),
              onHeaterToggle: () => toggleRoomHeater(index),
            );
          }),
          const SizedBox(height: 16),
          StatisticsCard(
            roomCount: rooms.length,
            averageTemperature: avgTemp,
            lightsOn: stats["Lights"]!,
            heatersOn: stats["Heaters"]!,
            selectedRoom: selectedRoom,
          ),
        ],
      ),
    );
  }
}
