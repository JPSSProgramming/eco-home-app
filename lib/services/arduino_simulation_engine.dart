import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../models/arduino_home.dart';

/// Headless simulation of the Arduino heating-control sketch (arduino.txt).
///
/// Every timer, counter and branch mirrors the firmware:
/// - `clock_temp()` → [_tick] (1 Hz main-loop tick),
/// - `checkAlarm()` → [_checkAlarm],
/// - `checkTemp()` → [_checkTemp],
/// - `check_click_button()` → [pressSet] / [pressStep],
/// - `bluetooth()` → [processCommand] (Serial is simulated locally,
///   there is no real data transmission yet).
class ArduinoSimulationEngine extends ValueNotifier<ArduinoHome> {
  ArduinoSimulationEngine() : super(ArduinoHome.mock) {
    _timer = Timer.periodic(const Duration(milliseconds: 100), _tick);
  }

  // Simulated hardware timing, mirrors millis().
  final Stopwatch _stopwatch = Stopwatch()..start();
  late int _prev1 = _millis;
  late int _prev2 = _millis;

  bool _startHeating = false;
  bool _firstTime = false;
  bool _lastYellowLed = false;
  Timer? _timer;

  /// Push-button debounce, plays the role of BUTTON_PROTECTION in the sketch.
  static const int _buttonProtectionMs = 300;
  int _lastSetPressMs = -_buttonProtectionMs;
  int _lastStepPressMs = -_buttonProtectionMs;

  final Random _random = Random();

  /// Lines printed by the simulated Serial (newest last, capped).
  final List<String> _serialLog = <String>[];

  /// Immutable copy of the Serial log, exposed for the console UI.
  final ValueNotifier<List<String>> serialLog =
      ValueNotifier<List<String>>(const <String>[]);

  int get _millis => _stopwatch.elapsedMilliseconds;

  ArduinoHome get _home => value;

  // --------------------------------------------------------------------------
  // Main loop: clock_temp() + display + per-second logic
  // --------------------------------------------------------------------------

  void _tick(Timer timer) {
    // loop() runs continuously; clock_temp() gates work by timeCorrection.
    if (timeCorrectionMs < _millis - _prev1) {
      _prev1 = _millis;

      int second = _home.second + 1;
      int minute = _home.minute;
      int hour = _home.hour;
      if (second > 59) {
        second = 0;
        minute++;
        if (minute > 59) {
          minute = 0;
          hour++;
          if (hour > 23) {
            hour = 0;
          }
        }
      }

      _fetchTemp();
      _update(
        second: second,
        minute: minute,
        hour: hour,
      );

      _checkTemp();
      _checkAlarm();
    }
  }

  double get timeCorrection => _home.timeCorrection;

  int get timeCorrectionMs => (timeCorrection * 1000).round();

  /// fetch_temp(): DS18B20 reading is simulated as a slow random walk.
  /// Heating (relay LOW) biases the walk up, cooling biases it down.
  void _fetchTemp() {
    final bool heating = !_home.relayHigh;
    final double drift = (heating ? 0.12 : -0.08) +
        (_random.nextDouble() - 0.5) * 0.2;
    final double next = (_home.temperatureC + drift).clamp(5.0, 45.0);
    _update(temperatureC: double.parse(next.toStringAsFixed(1)));
  }

  /// checkTemp(): in the sketch relay HIGH (heating off) when below the
  /// low-temperature alarm threshold.
  void _checkTemp() {
    if (_home.temperatureC < _home.alarmLowTempC) {
      _setRelay(high: true);
    }
  }

  /// checkAlarm(): straight port of the sketch's timer/interval state machine.
  void _checkAlarm() {
    if (!_home.isTimerOn) {
      if (!_home.stateRelayByHand) {
        _setRelay(high: true);
      }
      _setYellowLed(false);
      _startHeating = false;
      return;
    }

    if (_home.hour == _home.timerHour &&
        _home.minute == _home.timerMinute &&
        _home.second == 0) {
      _startHeating = true;
      _firstTime = true;
    }

    if (!_startHeating) {
      return;
    }

    if (_firstTime) {
      _setRelay(high: false);
      _firstTime = false;
    }

    final int curr2 = _millis;
    final int minus = curr2 - _prev2;
    if (_home.relayHigh) {
      // Waiting for intervalOff to elapse, then heating turns ON.
      _update(timeToHeatingOnStr: '${_home.intervalOffMin - minus ~/ 60000}');
      if (_home.intervalOffMin * 60000 < minus) {
        _prev2 = curr2;
        _update(stateRelayByHand: false);
        _setRelay(high: false);
        _serialPrint('Heating ON');
      }
    } else {
      // Waiting for intervalOn to elapse, then heating turns OFF.
      _update(timeToHeatingOffStr: '${_home.intervalOnMin - minus ~/ 60000}');
      if (_home.intervalOnMin * 60000 < minus) {
        _prev2 = curr2;
        _update(stateRelayByHand: false);
        _setRelay(high: true);
        _serialPrint('Heating OFF');
      }
    }
  }

  // --------------------------------------------------------------------------
  // Buttons: check_click_button()
  // --------------------------------------------------------------------------

  /// PIN_button_SET (left button - mode). Returns false when debounced.
  bool pressSet() {
    if (_lastSetPressMs + _buttonProtectionMs > _millis) {
      return false;
    }
    _lastSetPressMs = _millis;

    if (_home.sleepLCD) {
      return true;
    }

    int flagDisp = _home.flagDisp;
    int punktMenu = _home.punktMenu;
    int flagSet = _home.flagSet;

    if (flagDisp == 2) {
      flagSet++;
      final bool backToMenu =
          (punktMenu == 4 && flagSet == 1) ||
          ((punktMenu == 1 || punktMenu == 3) && flagSet == 2) ||
          (punktMenu == 2 && flagSet == 3);
      if (backToMenu) {
        flagSet = 0;
        flagDisp = 1;
      }
    } else {
      flagDisp++;
      if ((flagDisp == 2 && punktMenu == 5) || flagDisp > 2) {
        flagDisp = 0;
        punktMenu = 1;
      }
    }

    _update(flagDisp: flagDisp, punktMenu: punktMenu, flagSet: flagSet);
    return true;
  }

  /// PIN_button_STEP (right button - select/increment).
  bool pressStep() {
    if (_lastStepPressMs + _buttonProtectionMs > _millis) {
      return false;
    }
    _lastStepPressMs = _millis;

    final int flagDisp = _home.flagDisp;

    if (flagDisp == 2) {
      final int flagSet = _home.flagSet;
      switch (_home.punktMenu) {
        case 1:
        case 2:
          _setOrTimerStep(flagSet);
        case 3:
          _intervalStep(flagSet);
        case 4:
          // Submenu 4 (timeCorrection) has no STEP action in the sketch.
          break;
      }
    } else if (flagDisp == 0) {
      _update(sleepLCD: !_home.sleepLCD);
    } else {
      int punktMenu = _home.punktMenu + 1;
      if (punktMenu > 5) {
        punktMenu = 1;
      }
      _update(punktMenu: punktMenu);
    }
    return true;
  }

  void _setOrTimerStep(int flagSet) {
    final bool isClock = _home.punktMenu == 1;
    switch (flagSet) {
      case 0:
        if (isClock) {
          _update(hour: _plusOne(_home.hour, 23));
        } else {
          _update(timerHour: _plusOne(_home.timerHour, 23));
        }
      case 1:
        if (isClock) {
          _update(minute: _plusOne(_home.minute, 59));
        } else {
          _update(timerMinute: _plusOne(_home.timerMinute, 59));
        }
      case 2:
        if (!isClock) {
          _update(isTimerOn: !_home.isTimerOn);
        }
    }
  }

  void _intervalStep(int flagSet) {
    switch (flagSet) {
      case 0:
        _update(intervalOnMin: _plusOne(_home.intervalOnMin, 59));
      case 1:
        _update(intervalOffMin: _plusOne(_home.intervalOffMin, 59));
    }
  }

  /// plusOne(): increment with wrap-around to 0 past [limit].
  int _plusOne(int item, int limit) {
    final int next = item + 1;
    return next > limit ? 0 : next;
  }

  // --------------------------------------------------------------------------
  // Simulated Serial: bluetooth() command handler
  // --------------------------------------------------------------------------

  /// Handles a sketch command locally and returns the lines "Serial" prints.
  List<String> processCommand(String raw) {
    String inData = raw;
    final List<String> out = <String>[];

    void print(String line) {
      out.add(line);
      _serialPrint(line);
    }

    if (inData == 'help') {
      out.addAll(kHelpCommands);
      _serialPrintAll(kHelpCommands);
    } else if (inData == 'time') {
      print(ArduinoHome.formatTime(_home.hour, _home.minute, _home.second));
    } else if (inData.startsWith('time-')) {
      final String body = inData.substring(5);
      final List<String> parts = body.split(':');
      if (parts.length >= 2) {
        _update(
          hour: int.tryParse(parts[0]) ?? _home.hour,
          minute: int.tryParse(parts[1]) ?? _home.minute,
        );
      }
      print('Done');
    } else if (inData == 'timeTo ?') {
      print(
        _home.relayHigh
            ? 'Time to heating ON - ${_home.timeToHeatingOnStr}'
            : 'Time to heating OFF - ${_home.timeToHeatingOffStr}',
      );
    } else if (inData == 'timer ?') {
      print(
        _home.isTimerOn
            ? 'Timer on - ${ArduinoHome.formatTime(_home.timerHour, _home.timerMinute, null)}'
            : 'Timer off',
      );
    } else if (inData == 'timer on') {
      _update(isTimerOn: true);
      print('Done');
    } else if (inData == 'timer off') {
      _update(isTimerOn: false);
      print('Done');
    } else if (inData == 'temp') {
      print('Temp: ${_home.temperatureC}C');
    } else if (inData == 'interval ?') {
      print('interval on: ${_home.intervalOnMin}');
      print('interval off: ${_home.intervalOffMin}');
    } else if (inData.startsWith('intervalOn-')) {
      final int? v = int.tryParse(inData.substring(11));
      if (v != null) {
        _update(intervalOnMin: v);
      }
      print('Done');
    } else if (inData.startsWith('intervalOff-')) {
      final int? v = int.tryParse(inData.substring(12));
      if (v != null) {
        _update(intervalOffMin: v);
      }
      print('Done');
    } else if (inData == 'rel ?') {
      print(_home.relayHigh ? 'On' : 'Off');
    } else if (inData == 'rel on') {
      _setRelay(high: true);
      _update(stateRelayByHand: true);
      print('Heating off');
    } else if (inData == 'rel off') {
      _setRelay(high: false);
      _update(stateRelayByHand: true);
      print('Heating on');
    } else if (inData == 'timeCorrection ?') {
      print('Correction: $timeCorrection');
    } else if (inData.startsWith('timeCorrection-')) {
      final double? v = double.tryParse(inData.substring(15));
      if (v != null && v > 0) {
        _update(timeCorrection: v);
      }
      print('Done');
    } else {
      print('Unknown command: "$inData" (try "help")');
    }

    return out;
  }

  /// Same content as the `help[]` array in the sketch.
  static const List<String> kHelpCommands = <String>[
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

  // --------------------------------------------------------------------------
  // LCD 16x2 rendering: showTime / showMenu / showSubMenu
  // --------------------------------------------------------------------------

  String get lcdLine1 {
    switch (_home.flagDisp) {
      case 0:
        return 'Time: ${_home.clockText}';
      case 1:
        return '      Menu';
      default:
        switch (_home.punktMenu) {
          case 1:
            return 'set Time';
          case 2:
            return 'set Relay On';
          case 3:
            return 'set interval min';
          case 4:
            return 'this * sec';
          default:
            return '';
        }
    }
  }

  String get lcdLine2 {
    switch (_home.flagDisp) {
      case 0:
        return 'Temp: ${_home.temperatureC.toStringAsFixed(1)}°C';
      case 1:
        switch (_home.punktMenu) {
          case 1:
            return '1.Set TIME';
          case 2:
            return '2.Set Rel Time';
          case 3:
            return '3.Set interval';
          case 4:
            return '4.Set correction';
          default:
            return '5.Exit to clock';
        }
      default:
        switch (_home.punktMenu) {
          case 1:
            return _home.clockText;
          case 2:
            return '${_home.timerText}  On${_home.isTimerOn ? '+' : '-'}';
          case 3:
            return 'On:${_home.intervalOnMin}  Off:${_home.intervalOffMin}';
          case 4:
            return '       $timeCorrection';
          default:
            return '';
        }
    }
  }

  // --------------------------------------------------------------------------
  // State helpers
  // --------------------------------------------------------------------------

  void _setRelay({required bool high}) {
    _update(relayHigh: high);
  }

  void _setYellowLed(bool on) {
    if (on != _lastYellowLed) {
      _lastYellowLed = on;
      _update(yellowLedOn: on);
    }
  }

  void _update({
    int? hour,
    int? minute,
    int? second,
    double? temperatureC,
    bool? isTimerOn,
    int? timerHour,
    int? timerMinute,
    int? intervalOnMin,
    int? intervalOffMin,
    double? timeCorrection,
    bool? relayHigh,
    bool? yellowLedOn,
    bool? stateRelayByHand,
    String? timeToHeatingOnStr,
    String? timeToHeatingOffStr,
    bool? sleepLCD,
    int? flagDisp,
    int? punktMenu,
    int? flagSet,
  }) {
    value = ArduinoHome(
      hour: hour ?? _home.hour,
      minute: minute ?? _home.minute,
      second: second ?? _home.second,
      temperatureC: temperatureC ?? _home.temperatureC,
      alarmLowTempC: _home.alarmLowTempC,
      isTimerOn: isTimerOn ?? _home.isTimerOn,
      timerHour: timerHour ?? _home.timerHour,
      timerMinute: timerMinute ?? _home.timerMinute,
      intervalOnMin: intervalOnMin ?? _home.intervalOnMin,
      intervalOffMin: intervalOffMin ?? _home.intervalOffMin,
      timeCorrection: timeCorrection ?? _home.timeCorrection,
      relayHigh: relayHigh ?? _home.relayHigh,
      yellowLedOn: yellowLedOn ?? _home.yellowLedOn,
      heatingActive: _startHeating,
      stateRelayByHand: stateRelayByHand ?? _home.stateRelayByHand,
      timeToHeatingOnStr: timeToHeatingOnStr ?? _home.timeToHeatingOnStr,
      timeToHeatingOffStr: timeToHeatingOffStr ?? _home.timeToHeatingOffStr,
      sleepLCD: sleepLCD ?? _home.sleepLCD,
      flagDisp: flagDisp ?? _home.flagDisp,
      punktMenu: punktMenu ?? _home.punktMenu,
      flagSet: flagSet ?? _home.flagSet,
    );
  }

  void _serialPrint(String line) {
    _serialLog.add(line);
    if (_serialLog.length > 60) {
      _serialLog.removeRange(0, _serialLog.length - 60);
    }
    serialLog.value = List<String>.unmodifiable(_serialLog);
  }

  void _serialPrintAll(Iterable<String> lines) {
    for (final String line in lines) {
      _serialPrint(line);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    serialLog.dispose();
    super.dispose();
  }
}
