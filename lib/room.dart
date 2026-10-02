class Room {
  String name;
  double temperature;
  bool lightOn;
  bool heaterOn;

  Room({
    required this.name,
    required this.temperature,
    required this.lightOn,
    required this.heaterOn,
  });

  void toggleLight() {
    lightOn = !lightOn;
  }

  void toggleHeater() {
    heaterOn = !heaterOn;
  }

  String get status {
    if (heaterOn) {
      return "Heating";
    } else if (temperature < 20) {
      return "Too Cold";
    } else if (temperature > 24) {
      return "Too Hot";
    } else {
      return "Normal";
    }
  }

  bool get needsHeating {
    return temperature < 20;
  }
}
