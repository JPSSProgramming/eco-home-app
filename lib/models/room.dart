class Room {
  String name;
  double temperature;
  double waterTemperature;
  bool boilerOn;
  bool floorHeatingOn;

  Room({
    required this.name,
    required this.temperature,
    required this.waterTemperature,
    required this.boilerOn,
    required this.floorHeatingOn,
  });

  void toggleBoiler() {
    boilerOn = !boilerOn;
  }

  void toggleFloorHeating() {
    floorHeatingOn = !floorHeatingOn;
  }

  String get status {
    if (boilerOn) {
      return "Heating";
    } else if (floorHeatingOn) {
      return "Floor Heating";
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
