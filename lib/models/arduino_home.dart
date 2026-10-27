/// Snapshot of values that exist in the current Arduino sketch.
/// This is display-only mock data, not a live device connection.
class ArduinoHome {
  const ArduinoHome({
    required this.hour,
    required this.minute,
    required this.second,
    required this.temperatureC,
    required this.alarmLowTempC,
    required this.isTimerOn,
    required this.timerHour,
    required this.timerMinute,
    required this.intervalOnMin,
    required this.intervalOffMin,
    required this.timeCorrection,
    required this.relayHigh,
    required this.yellowLedOn,
    required this.heatingActive,
    required this.stateRelayByHand,
    required this.timeToHeatingOnStr,
    required this.timeToHeatingOffStr,
    required this.sleepLCD,
    required this.flagDisp,
    required this.punktMenu,
    required this.flagSet,
  });

  final int hour;
  final int minute;
  final int second;
  final double temperatureC;
  final double alarmLowTempC;
  final bool isTimerOn;
  final int timerHour;
  final int timerMinute;
  final int intervalOnMin;
  final int intervalOffMin;
  final double timeCorrection;
  final bool relayHigh;
  final bool yellowLedOn;
  final bool heatingActive;

  /// Mirrors `stateRelbyHand` in the sketch: relay was switched manually.
  final bool stateRelayByHand;

  /// Mirrors `timeToHeatingOnStr` ("timeTo ?" reply while relay is HIGH).
  final String timeToHeatingOnStr;

  /// Mirrors `timeToHeatingOffStr` ("timeTo ?" reply while relay is LOW).
  final String timeToHeatingOffStr;

  /// Mirrors `sleepLCD`: display is off after STEP press in clock mode.
  final bool sleepLCD;

  /// Mirrors `flag_disp`: 0 - clock, 1 - menu, 2 - submenu.
  final int flagDisp;

  /// Mirrors `punktMenu`: current menu item (1..5).
  final int punktMenu;

  /// Mirrors `flag_set`: editing step inside a submenu.
  final int flagSet;

  /// Matches Serial messages: relay HIGH = heating off, LOW = heating on.
  bool get heatingOn => !relayHigh;

  String get clockText => formatTime(hour, minute, second);

  String get timerText => formatTime(timerHour, timerMinute, null);

  static const ArduinoHome mock = ArduinoHome(
    hour: 23,
    minute: 3,
    second: 15,
    temperatureC: 0.0,
    alarmLowTempC: 21,
    isTimerOn: false,
    timerHour: 23,
    timerMinute: 5,
    intervalOnMin: 2,
    intervalOffMin: 5,
    timeCorrection: 1.0,
    relayHigh: true,
    yellowLedOn: false,
    heatingActive: false,
    stateRelayByHand: false,
    timeToHeatingOnStr: '',
    timeToHeatingOffStr: '',
    sleepLCD: false,
    flagDisp: 0,
    punktMenu: 1,
    flagSet: 0,
  );

  static String formatTime(int hour, int minute, int? second) {
    final String hh = hour.toString().padLeft(2, '0');
    final String mm = minute.toString().padLeft(2, '0');
    if (second == null) {
      return '$hh:$mm';
    }
    final String ss = second.toString().padLeft(2, '0');
    return '$hh:$mm:$ss';
  }
}
