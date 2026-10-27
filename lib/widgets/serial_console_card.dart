import 'package:flutter/material.dart';

import '../services/arduino_simulation_engine.dart';
import 'section_card.dart';

/// Interactive Serial / Bluetooth console: type a sketch command,
/// get the same reply the Arduino would print over Serial.
class SerialConsoleCard extends StatefulWidget {
  const SerialConsoleCard({super.key, required this.engine});

  final ArduinoSimulationEngine engine;

  @override
  State<SerialConsoleCard> createState() => _SerialConsoleCardState();
}

class _SerialConsoleCardState extends State<SerialConsoleCard> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    widget.engine.serialLog.addListener(_scrollToEnd);
  }

  @override
  void dispose() {
    widget.engine.serialLog.removeListener(_scrollToEnd);
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToEnd() {
    if (!_scrollController.hasClients) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  void _send() {
    final String command = _controller.text.trim();
    if (command.isEmpty) {
      return;
    }
    widget.engine.processCommand(command);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      icon: Icons.developer_board,
      title: 'Serial-консоль (симуляція)',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  onSubmitted: (_) => _send(),
                  textInputAction: TextInputAction.send,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
                  decoration: const InputDecoration(
                    isDense: true,
                    border: OutlineInputBorder(),
                    hintText: 'temp / timer ? / rel off / intervalOn-3',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(onPressed: _send, child: const Text('Надіслати')),
            ],
          ),
          const SizedBox(height: 12),
          ValueListenableBuilder<List<String>>(
            valueListenable: widget.engine.serialLog,
            builder: (BuildContext context, List<String> log, Widget? child) {
              return SizedBox(
                height: 160,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF101418),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: log.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Text(
                        log[index],
                        style: const TextStyle(
                          color: Color(0xFF9CFFB2),
                          fontFamily: 'monospace',
                          fontSize: 12,
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
