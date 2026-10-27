import 'package:flutter/material.dart';
import 'section_card.dart';

/// Reference list of the sketch's Serial commands (help[] + literals
/// handled in bluetooth()). Tapping a chip runs the command locally.
class BluetoothCommandsCard extends StatelessWidget {
  const BluetoothCommandsCard({super.key, this.onCommand});

  /// Called when a chip is tapped; null makes the list read-only.
  final ValueChanged<String>? onCommand;

  static const List<String> commands = <String>[
    'help',
    'time',
    'time-',
    'timeTo ?',
    'timer ?',
    'timer on',
    'timer off',
    'temp',
    'interval ?',
    'intervalOn-',
    'intervalOff-',
    'rel ?',
    'rel on',
    'rel off',
    'timeCorrection ?',
    'timeCorrection-',
  ];

  /// Commands that need a value appended before they make sense.
  static const Set<String> _prefixCommands = <String>{
    'time-',
    'intervalOn-',
    'intervalOff-',
    'timeCorrection-',
  };

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      icon: Icons.bluetooth,
      title: 'Serial / Bluetooth',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final String command in commands)
                _CommandChip(
                  command: command,
                  onTap: onCommand == null || _prefixCommands.contains(command)
                      ? null
                      : () => onCommand!(command),
                ),
            ],
          ),
          if (onCommand != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Команди з значенням (time-HH:MM, intervalOn-N, '
                'intervalOff-N, timeCorrection-N) вводяться у консолі.',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }
}

class _CommandChip extends StatelessWidget {
  const _CommandChip({required this.command, this.onTap});

  final String command;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: onTap == null ? Colors.grey.shade100 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          command,
          style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
        ),
      ),
    );
  }
}
