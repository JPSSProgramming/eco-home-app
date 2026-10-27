import 'package:flutter/material.dart';
import '../models/arduino_home.dart';
import 'info_row.dart';
import 'section_card.dart';

class HeatingStatusCard extends StatelessWidget {
  const HeatingStatusCard({super.key, required this.home});

  final ArduinoHome home;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      icon: Icons.whatshot,
      title: 'Опалення та реле',
      child: Column(
        children: [
          InfoRow(
            label: 'Реле (pin 12)',
            value: home.relayHigh ? 'HIGH / Off' : 'LOW / On',
          ),
          InfoRow(
            label: 'Опалення',
            value: home.heatingOn ? 'увімкнено' : 'вимкнено',
          ),
          InfoRow(
            label: 'Жовтий LED (pin 5)',
            value: home.yellowLedOn ? 'On' : 'Off',
          ),
          InfoRow(
            label: 'Поріг температури',
            value: '${home.alarmLowTempC.toStringAsFixed(0)}°C',
          ),
          InfoRow(
            label: 'Поточна температура',
            value: '${home.temperatureC.toStringAsFixed(1)}°C',
          ),
          if (home.heatingActive && home.relayHigh)
            InfoRow(
              label: 'До увімкнення опалення',
              value: '${home.timeToHeatingOnStr} хв',
            ),
          if (home.heatingActive && !home.relayHigh)
            InfoRow(
              label: 'До вимкнення опалення',
              value: '${home.timeToHeatingOffStr} хв',
            ),
          if (home.stateRelayByHand)
            const InfoRow(
              label: 'Реле перемкнуто вручну',
              value: 'так',
            ),
        ],
      ),
    );
  }
}
