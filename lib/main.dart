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
      title: 'Heating Control',
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
      name: "Kitchen",
      temperature: 22,
      waterTemperature: 45,
      boilerOn: true,
      floorHeatingOn: true,
    ),
    Room(
      name: "Bathroom",
      temperature: 24,
      waterTemperature: 50,
      boilerOn: true,
      floorHeatingOn: true,
    ),
    Room(
      name: "Living Room",
      temperature: 21,
      waterTemperature: 40,
      boilerOn: false,
      floorHeatingOn: false,
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
    int boilersOn = 0;
    int floorHeatingOn = 0;

    for (final room in rooms) {
      if (room.boilerOn) {
        boilersOn = boilersOn + 1;
      }
      if (room.floorHeatingOn) {
        floorHeatingOn = floorHeatingOn + 1;
      }
    }

    return {
      "Boilers": boilersOn,
      "FloorHeating": floorHeatingOn,
    };
  }

  void toggleRoomBoiler(int index) {
    setState(() {
      rooms[index].toggleBoiler();
    });
  }

  void toggleRoomFloorHeating(int index) {
    setState(() {
      rooms[index].toggleFloorHeating();
    });
  }

  void autoHeating() {
    setState(() {
      for (final room in rooms) {
        if (room.temperature < targetTemperature) {
          room.boilerOn = true;
        } else {
          room.boilerOn = false;
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
          'Heating Control',
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
            label: const Text('Auto Boiler'),
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
              onBoilerToggle: () => toggleRoomBoiler(index),
              onFloorHeatingToggle: () => toggleRoomFloorHeating(index),
            );
          }),
          const SizedBox(height: 16),
          StatisticsCard(
            roomCount: rooms.length,
            averageTemperature: avgTemp,
            boilersOn: stats["Boilers"]!,
            floorHeatingOn: stats["FloorHeating"]!,
            selectedRoom: selectedRoom,
          ),
        ],
      ),
    );
  }
}
