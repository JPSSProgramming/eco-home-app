import 'package:flutter/material.dart';

import '../models/arduino_home.dart';
import '../services/arduino_simulation_engine.dart';
import '../widgets/bluetooth_commands_card.dart';
import '../widgets/heating_status_card.dart';
import '../widgets/lcd_panel.dart';
import '../widgets/section_card.dart';
import '../widgets/serial_console_card.dart';
import '../widgets/timer_settings_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ArduinoSimulationEngine _engine = ArduinoSimulationEngine();

  @override
  void dispose() {
    _engine.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Eco Home'),
        actions: [
          // Handy shortcut for the "time-HH:MM" command (sync from the phone).
          IconButton(
            tooltip: 'Sync time with the phone',
            icon: const Icon(Icons.access_time),
            onPressed: () => _engine.processCommand(
              'time-${DateTime.now().toString().substring(11, 16)}',
            ),
          ),
        ],
      ),
      body: ValueListenableBuilder<ArduinoHome>(
        valueListenable: _engine,
        builder: (BuildContext context, ArduinoHome home, Widget? child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SectionCard(
                icon: Icons.tv,
                title: 'LCD 16×2',
                child: LcdPanel(
                  line1: _engine.lcdLine1,
                  line2: _engine.lcdLine2,
                  sleeping: home.sleepLCD,
                  onSet: _engine.pressSet,
                  onStep: _engine.pressStep,
                ),
              ),
              const SizedBox(height: 12),
              HeatingStatusCard(home: home),
              const SizedBox(height: 12),
              TimerSettingsCard(home: home),
              const SizedBox(height: 12),
              SerialConsoleCard(engine: _engine),
              const SizedBox(height: 12),
              BluetoothCommandsCard(onCommand: _engine.processCommand),
              const SizedBox(height: 12),
              _SimulatorNotice(home: home),
            ],
          );
        },
      ),
    );
  }
}

class _SimulatorNotice extends StatelessWidget {
  const _SimulatorNotice({required this.home});

  final ArduinoHome home;

  @override
  Widget build(BuildContext context) {
    return Text(
      'Локальна симуляція прошивки (arduino.txt). '
      'Дані з пристрою надходитимуть після підключення Bluetooth HC-05.\n'
      'Реле: ${home.relayHigh ? "HIGH" : "LOW"} · '
      'Опалення: ${home.heatingOn ? "увімкнено" : "вимкнено"}',
      textAlign: TextAlign.center,
      style: TextStyle(color: Colors.grey[600], fontSize: 12),
    );
  }
}
