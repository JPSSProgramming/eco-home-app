import 'package:flutter/material.dart';
import '../models/arduino_home.dart';
import 'info_row.dart';
import 'section_card.dart';

class TimerSettingsCard extends StatelessWidget {
  const TimerSettingsCard({super.key, required this.home});

  final ArduinoHome home;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      icon: Icons.timer_outlined,
      title: 'Таймер і інтервали',
      child: Column(
        children: [
          InfoRow(
            label: 'Таймер',
            value: home.isTimerOn ? 'on · ${home.timerText}' : 'off',
          ),
          InfoRow(
            label: 'intervalOn',
            value: '${home.intervalOnMin} хв',
          ),
          InfoRow(
            label: 'intervalOff',
            value: '${home.intervalOffMin} хв',
          ),
          InfoRow(
            label: 'timeCorrection',
            value: home.timeCorrection.toStringAsFixed(1),
          ),
          InfoRow(
            label: 'Поточний час',
            value: home.clockText,
          ),
        ],
      ),
    );
  }
}
