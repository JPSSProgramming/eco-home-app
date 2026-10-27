import 'package:flutter_test/flutter_test.dart';

import 'package:eco_home_app/services/arduino_simulation_engine.dart';

void main() {
  // Pause longer than the simulated BUTTON_PROTECTION debounce between taps.
  Future<void> gap() => Future<void>.delayed(const Duration(milliseconds: 350));

  group('ArduinoSimulationEngine serial commands (bluetooth() port)', () {
    late ArduinoSimulationEngine engine;

    setUp(() => engine = ArduinoSimulationEngine());
    tearDown(() => engine.dispose());

    test('help returns the sketch help[] list', () {
      final List<String> out = engine.processCommand('help');
      expect(out, hasLength(15));
      expect(out.first, 'time');
      expect(out.last, 'timeCorrection-');
    });

    test('time-HH:MM sets hour and minute', () {
      engine.processCommand('time-07:45');
      expect(engine.value.hour, 7);
      expect(engine.value.minute, 45);
    });

    test('timer on/off toggles isAlarmSet', () {
      engine.processCommand('timer on');
      expect(engine.value.isTimerOn, isTrue);
      expect(engine.processCommand('timer ?'), [
        'Timer on - ${engine.value.timerText}',
      ]);
      engine.processCommand('timer off');
      expect(engine.value.isTimerOn, isFalse);
    });

    test('rel on means relay HIGH and "Heating off" (sketch semantics)', () {
      final List<String> out = engine.processCommand('rel on');
      expect(out, ['Heating off']);
      expect(engine.value.relayHigh, isTrue);
      expect(engine.value.stateRelayByHand, isTrue);
      expect(engine.processCommand('rel ?'), ['On']);
    });

    test('rel off means relay LOW and "Heating on"', () {
      final List<String> out = engine.processCommand('rel off');
      expect(out, ['Heating on']);
      expect(engine.value.relayHigh, isFalse);
      expect(engine.value.heatingOn, isTrue);
      expect(engine.processCommand('rel ?'), ['Off']);
    });

    test('intervalOn- / intervalOff- set values', () {
      engine.processCommand('intervalOn-3');
      engine.processCommand('intervalOff-7');
      expect(engine.value.intervalOnMin, 3);
      expect(engine.value.intervalOffMin, 7);
      expect(engine.processCommand('interval ?'), [
        'interval on: 3',
        'interval off: 7',
      ]);
    });

    test('timeCorrection- sets the clock tick period', () {
      engine.processCommand('timeCorrection-0.5');
      expect(engine.value.timeCorrection, 0.5);
      expect(engine.timeCorrectionMs, 500);
    });
  });

  group('ArduinoSimulationEngine buttons (check_click_button() port)', () {
    late ArduinoSimulationEngine engine;

    setUp(() => engine = ArduinoSimulationEngine());
    tearDown(() => engine.dispose());

    test('SET walks clock -> menu -> submenu -> back to clock', () async {
      // Matches check_click_button(): each SET press inside a submenu only
      // advances flag_set; the display returns to the menu after the last
      // editing step, and a full SET press sequence 0 -> 1 -> 2 -> ... -> 0.
      expect(engine.value.flagDisp, 0);

      engine.pressSet(); // clock -> menu (punktMenu 1)
      expect(engine.value.flagDisp, 1);
      await gap();

      engine.pressSet(); // menu 1 -> submenu (set Time, hours)
      expect(engine.value.flagDisp, 2);
      await gap();

      engine.pressSet(); // submenu step: hours -> minutes
      expect(engine.value.flagDisp, 2);
      await gap();

      engine.pressSet(); // last step of submenu 1 -> back to menu
      expect(engine.value.flagDisp, 1);
      await gap();

      engine.pressSet(); // menu -> submenu again
      expect(engine.value.flagDisp, 2);
      await gap();
      engine.pressSet();
      await gap();
      engine.pressSet();
      expect(engine.value.flagDisp, 1); // and back to menu
    });

    test('STEP in clock mode sleeps the LCD', () async {
      engine.pressStep();
      expect(engine.value.sleepLCD, isTrue);
      await Future<void>.delayed(const Duration(milliseconds: 350));
      engine.pressStep();
      expect(engine.value.sleepLCD, isFalse);
    });

    test('SET then STEP cycles menu items 1..5', () async {
      engine.pressSet(); // to menu
      await Future<void>.delayed(const Duration(milliseconds: 350));
      engine.pressStep();
      expect(engine.value.punktMenu, 2);
      for (int i = 0; i < 4; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 350));
        engine.pressStep();
      }
      expect(engine.value.punktMenu, 1); // wraps after 5
    });
  });
}
