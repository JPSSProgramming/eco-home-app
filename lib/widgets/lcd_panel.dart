import 'package:flutter/material.dart';

class LcdPanel extends StatelessWidget {
  const LcdPanel({
    super.key,
    required this.line1,
    required this.line2,
    required this.sleeping,
    required this.onSet,
    required this.onStep,
  });

  final String line1;
  final String line2;
  final bool sleeping;
  final VoidCallback onSet;
  final VoidCallback onStep;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          decoration: BoxDecoration(
            color: sleeping ? const Color(0xFF0B1A12) : const Color(0xFF163C2A),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF2E2E2E), width: 4),
          ),
          child: sleeping
              ? const SizedBox(
                  height: 48,
                  child: Center(
                    child: Text(
                      'LCD sleep',
                      style: TextStyle(
                        color: Color(0xFF3D6A52),
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _LcdLine(text: line1),
                    const SizedBox(height: 8),
                    _LcdLine(text: line2),
                  ],
                ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Semantics(
                button: true,
                label: 'SET button',
                child: OutlinedButton(
                  onPressed: onSet,
                  child: const Text('SET · режим'),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Semantics(
                button: true,
                label: 'STEP button',
                child: OutlinedButton(
                  onPressed: onStep,
                  child: const Text('STEP · вибір'),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _LcdLine extends StatelessWidget {
  const _LcdLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.length > 16 ? text.substring(0, 16) : text,
      maxLines: 1,
      overflow: TextOverflow.clip,
      style: const TextStyle(
        color: Color(0xFF9CFFB2),
        fontFamily: 'monospace',
        fontSize: 20,
        letterSpacing: 1.2,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
